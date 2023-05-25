import 'package:flutter/material.dart';
import 'package:quiz/mode.dart';

void main() {
  runApp(const quizaiptest());
}

// ignore: camel_case_types
class quizaiptest extends StatelessWidget {
  const quizaiptest({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Pseudo(),
    );
  }
}

class Pseudo extends StatefulWidget {
  const Pseudo({Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _PseudoState createState() => _PseudoState();
}

class _PseudoState extends State<Pseudo> {
  final TextEditingController _pseudoController = TextEditingController();
  String pseudo = ''; // Nouvelle variable pour stocker le pseudo

  bool _validatePseudo(String pseudo) {
    if (pseudo.length < 3) {
      return false;
    }
    RegExp regExp = RegExp(r'^[\wÀ-ÿ ]+$'); // Expression régulière mise à jour
    return regExp.hasMatch(pseudo);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Bienvenue !'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Positioned(
              top: 10,
              right: 0,
              child: Image.asset(
                'assets/images/Esaip.png',
                width: 350,
                height: 190,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: _pseudoController,
                style: const TextStyle(color: Colors.pink),
                decoration: const InputDecoration(
                  labelText: 'Entrez votre pseudo',
                  labelStyle: TextStyle(color: Colors.pinkAccent),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.black),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.pinkAccent),
                  ),
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  pseudo = _pseudoController.text; // Stocker le pseudo dans la variable 'pseudo'
                });
                if (_validatePseudo(pseudo)) {
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (BuildContext context) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    },
                  );
                  Future.delayed(const Duration(milliseconds: 350), () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      PageRouteBuilder(
                        transitionDuration: const Duration(milliseconds: 500),
                        pageBuilder: (context, animation, secondaryAnimation) =>
                            SelectionMenu(pseudo: pseudo),
                        transitionsBuilder: (context, animation, secondaryAnimation, child) {
                          const begin = Offset(1.0, 0.0);
                          const end = Offset.zero;
                          const curve = Curves.ease;
                          final tween =
                          Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
                          return SlideTransition(
                            position: animation.drive(tween),
                            child: child,
                          );
                        },
                      ),
                    );
                  });
                } else {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(40),
                        ),
                        title: const Text('Pseudo invalide'),
                        content: const Text(
                            'Le pseudo doit contenir au moins 3 caractères et ne doit contenir que des lettres et des chiffres.'),
                        actions: [
                          TextButton(
                            child: const Text('OK'),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          ),
                        ],
                      );
                    },
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                maximumSize: const Size(190, 80),
                padding: const EdgeInsets.all(0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: Ink(
                height: 80,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Colors.blue, Colors.pink],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(30.0),
                ),
                child: InkWell(
                  splashColor: Colors.pink.withOpacity(1),
                  highlightColor: Colors.pink[900],
                  hoverColor: Colors.transparent,
                  focusColor: Colors.transparent,
                  splashFactory: InkRipple.splashFactory,
                  child: const Center(
                    child: Text(
                      'Valider',
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
      ),
    );
  }
}