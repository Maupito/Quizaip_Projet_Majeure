import 'package:flutter/material.dart';
import 'Multijoueurs.dart';
import 'Solo.dart';

class SelectionMenu extends StatefulWidget {
  final String pseudo;

  const SelectionMenu({Key? key, required this.pseudo}) : super(key: key);

  @override
  _SelectionMenuState createState() => _SelectionMenuState();
}

class _SelectionMenuState extends State<SelectionMenu> with TickerProviderStateMixin {

  @override
  void initState() {
    super.initState();
  }

  Future<void> _onButtonPress(BuildContext context, Widget nextPage) async {
    await Future.delayed(
        const Duration(milliseconds: 250)); // délai de 0.25 seconde
    Navigator.push(
      context,
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 500),
        pageBuilder: (context, animation, secondaryAnimation) => nextPage,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          var begin = const Offset(1.0, 0.0);
          var end = Offset.zero;
          var curve = Curves.easeOut;

          var tween = Tween(begin: begin, end: end);
          var curvedAnimation = CurvedAnimation(parent: animation, curve: curve);

          return SlideTransition(
            position: tween.animate(curvedAnimation),
            child: child,
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final buttonHeight = MediaQuery
        .of(context)
        .size
        .height / 3;
    return Scaffold(
      appBar: AppBar(
        title: Text('Bienvenue ${widget.pseudo} !'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Expanded(
            child: InkWell(
              onTap: () => _onButtonPress(context, const MenuPrincipal()),
              splashColor: Colors.pink.withOpacity(1),
              highlightColor: Colors.pink[900],
              borderRadius: BorderRadius.circular(30.0),
              hoverColor: Colors.transparent,
              focusColor: Colors.transparent,
              splashFactory: InkRipple.splashFactory,
              child: AnimatedOpacity(
                opacity: 1.0,
                duration: const Duration(milliseconds: 500),
                child: Ink(
                  height: buttonHeight,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Colors.blue, Colors.pink],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(30.0),
                  ),
                  child: const Center(
                    child: Text(
                      'Solo',
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
          ),
          const SizedBox(height: 20),
          Expanded(
            child: InkWell(
              onTap: () => _onButtonPress(context, MultijoueursPage(pseudo: widget.pseudo)),
              splashColor: Colors.blue.withOpacity(1),
              highlightColor: Colors.blue[900],
              borderRadius: BorderRadius.circular(30.0),
              hoverColor: Colors.transparent,
              focusColor: Colors.transparent,
              splashFactory: InkRipple.splashFactory,
              child: Ink(
                height: buttonHeight,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Colors.pink, Colors.blue],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(30.0),
                ),
                child: const Center(
                  child: Text(
                    'Multijoueur',
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