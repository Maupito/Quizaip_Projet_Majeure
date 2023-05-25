import 'package:flutter/material.dart';
import 'package:random_string/random_string.dart';
import 'package:quiz/JoinRoom.dart';
import 'package:quiz/ModeHote.dart';

class MultijoueursPage extends StatelessWidget {
  final String pseudo;
  const MultijoueursPage({Key? key, required this.pseudo}) : super(key: key);

  Future<void> _onButtonPress(BuildContext context, Widget nextPage) async {
    await Future.delayed(const Duration(milliseconds: 250)); // délai de 0.25 seconde
    Navigator.push(
      context,
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 500),
        pageBuilder: (_, __, ___) => nextPage,
        transitionsBuilder: (context, animation, secondaryAnimation, child) =>
            SlideTransition(
              position:
              Tween<Offset>(begin: const Offset(1.0, 0.0), end: Offset.zero)
                  .animate(animation),
              child: child,
            ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final buttonHeight = MediaQuery.of(context).size.height / 3;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Menu Multijoueur'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: InkWell(
              onTap: () {
                String code = randomAlphaNumeric(6);
                _onButtonPress(context, ModeHote(pseudo: pseudo));
              },
              splashColor: Colors.pink.withOpacity(1),
              highlightColor: Colors.pink[900],
              borderRadius: BorderRadius.circular(30.0),
              hoverColor: Colors.transparent,
              focusColor: Colors.transparent,
              splashFactory: InkRipple.splashFactory,
              child: Ink(
                height: buttonHeight,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30.0),
                  gradient: const LinearGradient(
                    colors: [Colors.blue, Colors.pink],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: const Center(
                  child: Text(
                    'Créer une salle',
                    style: TextStyle(
                      fontSize: 24.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: InkWell(
              onTap: () {
                _onButtonPress(context, JoinRoom(pseudo: pseudo));
              },
              splashColor: Colors.blue.withOpacity(1),
              highlightColor: Colors.blue[900],
              borderRadius: BorderRadius.circular(30.0),
              hoverColor: Colors.transparent,
              focusColor: Colors.transparent,
              splashFactory: InkRipple.splashFactory,
              child: Ink(
                height: buttonHeight,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30.0),
                  gradient: const LinearGradient(
                    colors: [Colors.pink, Colors.blue],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: const Center(
                  child: Text(
                    'Rejoindre une salle',
                    style: TextStyle(
                      fontSize: 24.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}