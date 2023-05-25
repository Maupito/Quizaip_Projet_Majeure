import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:quiz/quizsolo.dart';

class MenuPrincipal extends StatefulWidget {
  const MenuPrincipal({Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _MenuPrincipalState createState() => _MenuPrincipalState();
}

class _MenuPrincipalState extends State<MenuPrincipal>
    with SingleTickerProviderStateMixin {
  String selectedOption2 = "Choisissez la majeure";
  String selectedOption3 = "Choisissez le niveau de difficulté";
  bool isTimed = false;
  final TextEditingController _numberController = TextEditingController();
  bool isTextFieldEnabled = true;

  @override
  void dispose() {
    _numberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Menu Solo"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              width: 400.0,
              height: 150.0,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30.0),
                gradient: const LinearGradient(
                  colors: [Colors.blue, Colors.pink],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(30.0),
                  splashColor: Colors.pink.withOpacity(1),
                  highlightColor: Colors.pink[900],
                  onTap: () {
                    _showOptionsDialog(
                      context,
                      "Choisissez la majeure",
                      [
                        "Cybersécurité",
                        "BigData",
                      ],
                          (selectedOption) {
                        setState(() {
                          selectedOption2 = selectedOption;
                        });
                      },
                    );
                  },
                  child: Center(
                    child: Text(
                      selectedOption2,
                      style: const TextStyle(
                        fontSize: 20.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Container(
              width: 400.0,
              height: 150.0,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30.0),
                gradient: const LinearGradient(
                  colors: [Colors.pink, Colors.blue],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(30.0),
                  splashColor: Colors.pink.withOpacity(1),
                  highlightColor: Colors.blue[900],
                  onTap: () {
                    _showOptionsDialog(
                      context,
                      "Choisissez le niveau de difficulté",
                      [
                        "Débutant",
                        "Intermédiaire",
                        "Expert",
                      ],
                          (selectedOption) {
                        setState(() {
                          selectedOption3 = selectedOption;
                        });
                      },
                    );
                  },
                  child: Center(
                    child: Text(
                      selectedOption3,
                      style: const TextStyle(
                        fontSize: 20.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("Contre la montre"),
                Checkbox(
                  value: isTimed,
                  onChanged: (value) {
                    setState(() {
                      isTimed = value!;
                      isTextFieldEnabled = !value; // Enable/disable text field based on checkbox value
                      if (isTimed) {
                        _numberController.text = ''; // Clear the text field when enabling the checkbox
                      }
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: 200.0,
              child: TextField(
                controller: _numberController,
                decoration: const InputDecoration(
                  labelText: 'Nombre (1-50)',
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(
                    RegExp(r'^[1-9]$|^[1-4][0-9]$|^50$'),
                  ),
                ],
                enabled: isTextFieldEnabled && !isTimed, // Enable/disable text field based on checkbox value and isTimed
              ),
            ),
            const SizedBox(height: 20),
            Container(
              width: 400.0,
              height: 150.0,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30.0),
                gradient: const LinearGradient(
                  colors: [Colors.pink, Colors.orange],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(30.0),
                  splashColor: Colors.red.withOpacity(1),
                  highlightColor: Colors.red[900],
                  onTap: () {
                    _navigateToQuizPage(context);
                  },
                  child: const Center(
                    child: Text(
                      "Jouer !",
                      style: TextStyle(
                        fontSize: 20.0,
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

  void _showOptionsDialog(BuildContext context, String menu, List<String> options, Function(String) onSelect) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(menu),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(40.0),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (int i = 0; i < options.length; i++)
                ListTile(
                  title: Text(options[i]),
                  onTap: () {
                    onSelect(options[i]);
                    Navigator.of(context).pop();
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  void _navigateToQuizPage(BuildContext context) {
    if (selectedOption2 != "Choisissez la majeure" && selectedOption3 != "Choisissez le niveau de difficulté") {
      if (!isTimed) {
        String numberString = _numberController.text.trim();
        int? number = int.tryParse(numberString);
        if (number != null && number >= 1 && number <= 50) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => QuizScreen(
                category: selectedOption2,
                difficulty: selectedOption3,
                isTimed: isTimed,
                number: number,
              ),
            ),
          );
        } else {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text("Nombre invalide"),
                content: const Text(
                  "Veuillez entrer un nombre entre 1 et 50.",
                ),
                actions: <Widget>[
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
      } else {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => QuizScreen(
              category: selectedOption2,
              difficulty: selectedOption3,
              isTimed: isTimed,
              number: 0, // Pass a dummy value for number when isTimed is true
            ),
          ),
        );
      }
    } else {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text("Options non sélectionnées"),
            content: const Text(
              "Veuillez sélectionner une majeure et un niveau de difficulté.",
            ),
            actions: <Widget>[
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
  }
}