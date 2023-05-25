import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// ignore: library_prefixes
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:random_string/random_string.dart';
import 'package:quiz/quizmulti.dart';

class ModeHote extends StatefulWidget {
  final String pseudo;

  const ModeHote({Key? key, required this.pseudo}) : super(key: key);

  @override
  _ModeHoteState createState() => _ModeHoteState();
}

class _ModeHoteState extends State<ModeHote> {
  String roomId = '';
  int participantsCount = 1;
  String selectedCategory = 'Choisissez la majeure';
  String selectedDifficulty = 'Choisissez la difficulté';
  late TextEditingController _numberController;
  late IO.Socket socket;

  @override
  void initState() {
    super.initState();
    _numberController = TextEditingController();
    socket = IO.io('http://10.2.0.216:3000', <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
    });

    socket.onConnect((_) {
      String generatedRoomId = randomAlphaNumeric(5);
      socket.emit('createRoom', generatedRoomId);

      socket.on('participantsCount', (data) {
        setState(() {
          participantsCount = data['count'];
        });
      });
    });

    socket.on('roomId', (data) {
      setState(() {
        roomId = data;
      });
    });

    socket.connect();
  }

  @override
  void dispose() {
    socket.disconnect();
    _numberController.dispose();
    super.dispose();
  }

  void selectCategory() {
    _showOptionsDialog(
      context,
      "Choisissez la majeure",
      [
        "Cybersécurité",
        "BigData",
      ],
          (selectedOption) {
        setState(() {
          selectedCategory = selectedOption;
        });
      },
    );
  }

  void selectDifficulty() {
    _showOptionsDialog(
      context,
      "Choisissez la difficulté",
      [
        "Débutant",
        "Intermédiaire",
        "Expert",
      ],
          (selectedOption) {
        setState(() {
          selectedDifficulty = selectedOption;
        });
      },
    );
  }

  void _showOptionsDialog(
      BuildContext context,
      String menu,
      List<String> options,
      Function(String) onSelect,
      ) {
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
                RadioListTile(
                  title: Text(options[i]),
                  value: options[i],
                  groupValue: menu == "Choisissez la majeure"
                      ? selectedCategory
                      : selectedDifficulty,
                  onChanged: (value) {
                    onSelect(value.toString());
                    Navigator.of(context).pop();
                  },
                ),
            ],
          ),
        );
      },
    ).then((value) {
      if (value != null) {
        onSelect(value);
        setState(() {});
      }
    });
  }

  void goToQuizMulti() {
    if (selectedCategory != 'Choisissez la majeure' &&
        selectedDifficulty != 'Choisissez la difficulté' &&
        _numberController.text.isNotEmpty &&
        int.tryParse(_numberController.text) != null &&
        int.parse(_numberController.text) >= 1 &&
        int.parse(_numberController.text) <= 50) {
      socket.emit('startQuiz', {
        'category': selectedCategory,
        'difficulty': selectedDifficulty,
        'number': int.parse(_numberController.text),
        'roomId': roomId,
      });

      socket.emit('participantsCount', participantsCount); // Ajoutez cette ligne

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => QuizMulti(
            category: selectedCategory,
            difficulty: selectedDifficulty,
            number: int.parse(_numberController.text),
            roomId: roomId,
            pseudo: widget.pseudo,
          ),
        ),
      );
    } else {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Erreur'),
            content: const Text(
              'Veuillez choisir une majeure, une difficulté et entrer un nombre entre 1 et 50.',
            ),
            actions: [
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mode Hôte'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 40),
            Text(
              'Identifiant de la salle : $roomId',
              style: const TextStyle(fontSize: 20),
            ),
            const SizedBox(height: 20),
            Text(
              'Nombre de participants: $participantsCount',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),
            Container(
              width: 380.0,
              height: 130.0,
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
                  onTap: selectCategory,
                  child: Center(
                    child: Text(
                      selectedCategory,
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
              width: 380.0,
              height: 130.0,
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
                  splashColor: Colors.blue.withOpacity(1),
                  highlightColor: Colors.blue[900],
                  onTap: selectDifficulty,
                  child: Center(
                    child: Text(
                      selectedDifficulty,
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
              ),
            ),
            const SizedBox(height: 20),
            Container(
              width: 380.0,
              height: 130.0,
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
                  onTap: goToQuizMulti,
                  child: const Center(
                    child: Text(
                      'Jouer !',
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
}