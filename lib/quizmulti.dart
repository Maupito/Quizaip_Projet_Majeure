import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:quiz/pseudo.dart';
import 'dart:convert';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:flutter/services.dart' show rootBundle;

import 'Multijoueurs.dart';

void main() {
  print("Entrez le nombre de questions : ");
  int number = int.parse(stdin.readLineSync()!); // Lire l'entrée de l'utilisateur et convertir en entier
  runApp(MaterialApp(
    home: QuizMulti(
      category: "selectedOption2",
      difficulty: "selectedOption3",
      number: number,
      roomId: '', // Laissez la valeur initiale vide pour l'instant
      pseudo: '',
    ),
  ));
}



class QuizMulti extends StatefulWidget {
  int participantsCount = 0;
  final String category;
  final String difficulty;
  final int number;
  final String roomId;
  final String pseudo;

  QuizMulti({
    required this.category,
    required this.difficulty,
    required this.number,
    required this.roomId,
    required this.pseudo,
  });

  @override
  _QuizMultiState createState() => _QuizMultiState();
}

class _QuizMultiState extends State<QuizMulti> {
  String roomId = '';
  List<Map<String, dynamic>> scores = [];
  String pseudo = ''; // Ajoutez cette variable pour stocker le pseudo
  int ParticipantFini = 0;
  List<QuestionModel> questionAnswers = [];
  List<QuestionModel> answeredQuestions = [];
  int currentQuestionIndex = 0; // Index de la question actuelle
  int score = 0; // Score du quiz
  Timer? timer; // Timer pour la durée de chaque question
  int timeRemaining = 10; // Temps restant pour chaque question (10 secondes)
  IO.Socket socket = IO.io('http://10.2.0.216:3000');

  @override
  void initState() {
    super.initState();
    loadQuizData();
    startTimer();
    socket.on('quizStarted', (data) {
      String category = data['category'];
      String difficulty = data['difficulty'];
    });
  }

  @override
  void dispose() {
    timer?.cancel(); // Annuler le timer lors de la suppression de l'écran
    socket.dispose(); // Fermer la connexion socket IO
    super.dispose();
  }

  void loadQuizData() async {
    String jsonString = await rootBundle.loadString('assets/Questions/Cyber.json');
    List<dynamic> jsonData = json.decode(jsonString);

    List<QuestionModel> filteredQuestions = [];
    int questionCount = 0; // Variable pour compter le nombre de questions chargées
    bool isQuizLoaded = false; // Variable pour vérifier si le quiz est complètement chargé

    for (int i = 0; i < jsonData.length; i++) {
      String category = jsonData[i]['category'];
      String difficulty = jsonData[i]['difficulty'];

      if (category == widget.category && difficulty == widget.difficulty) {
        List<dynamic> answers = jsonData[i]['answers'];
        answers.shuffle();

        dynamic correctAnswer = answers.firstWhere((answer) => answer['correct']);

        QuestionModel questionModel = QuestionModel(
          question: jsonData[i]['questionText'],
          options: answers,
          correctAnswer: correctAnswer,
        );
        filteredQuestions.add(questionModel);
        questionCount++;
        if (questionCount >= widget.number) {
          isQuizLoaded = true; // Le quiz est complètement chargé
          break; // Arrêter la boucle si le nombre de questions atteint widget.number
        }
      }
    }

    if (!isQuizLoaded) {
      // Le quiz n'est pas complètement chargé avec le nombre de questions demandé
      print("Le quiz n'a pas pu être chargé avec le nombre de questions demandé.");
      return;
    }

    setState(() {
      questionAnswers = filteredQuestions;
    });
  }


  void startTimer() {
    timer = Timer.periodic(const Duration(seconds: 1), (Timer timer) {
      if (timeRemaining > 0) {
        setState(() {
          timeRemaining--;
        });
      } else {
        handleTimerFinished(); // Le timer est terminé
      }
    });
  }

  void handleTimerFinished() {
    setState(() {
      timer?.cancel(); // Annuler le timer restant
      goToNextQuestion(); // Passer à la prochaine question
    });
  }



  void goToNextQuestion() {
    setState(() {
      if (currentQuestionIndex < questionAnswers.length - 1) {
        currentQuestionIndex++; // Passer à la question suivante si disponible
        timeRemaining = 10; // Réinitialiser le temps restant pour la nouvelle question
        startTimer(); // Démarrer le timer pour la nouvelle question
      } else {
        // Toutes les questions ont été répondues
        // Afficher l'écran des résultats
        timer?.cancel(); // Annuler le timer restant
        // Envoyer l'événement scoreUpdate au serveur
        socket.emit('scoreUpdate', {
          'score': score,
          'pseudo': widget.pseudo,
          'roomId': roomId,
        });
        // Naviguer vers la page WaitingPage
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => WaitingPage(roomId: '',)),
        );
      }
    });
  }


  void handleAnswerSelection(bool isCorrect) {
    setState(() {
      QuestionModel currentQuestion = questionAnswers[currentQuestionIndex];
      answeredQuestions.add(currentQuestion); // Ajouter la question à answeredQuestions

      if (isCorrect) {
        score++;
      }

      timer?.cancel();
      goToNextQuestion();
    });
  }

  @override
  Widget build(BuildContext context) {
    if (questionAnswers.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Quiz'),
        ),
        body: Center(
          child: Text(
            'Aucune question trouvée pour la catégorie "${widget.category}" et la difficulté "${widget.difficulty}"',
            textAlign: TextAlign.center,
          ),
        ),
      );
    }
    QuestionModel currentQuestion = questionAnswers[currentQuestionIndex];
    String question = currentQuestion.question;
    List<dynamic> responseOptions = currentQuestion.options;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Quiz'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 80),
            ClipRRect(
              borderRadius: BorderRadius.circular(20.0),
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.transparent,
                    style: BorderStyle.solid,
                    width: 8.0,
                  ),
                  gradient: const LinearGradient(
                    colors: [Colors.blue, Colors.green],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Question ${currentQuestionIndex + 1} :',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 25,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      question,
                      style: const TextStyle(
                        fontSize: 20,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            ClipRRect(
              borderRadius: BorderRadius.circular(20.0),
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.transparent,
                    style: BorderStyle.solid,
                    width: 8.0,
                  ),
                  gradient: const LinearGradient(
                    colors: [Colors.green, Colors.blue],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: responseOptions.map((option) {
                    String optionText = option['text'];
                    bool isCorrect = option['correct'];
                    return Theme(
                      data: ThemeData(
                        unselectedWidgetColor: Colors
                            .white, // Set the color for unselected radio buttons
                      ),
                      child: RadioListTile(
                        title: Text(
                          optionText,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                          ),
                        ),
                        value: isCorrect,
                        groupValue: null,
                        onChanged: (value) {
                          handleAnswerSelection(isCorrect);
                        },
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Temps restant : $timeRemaining',
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.red,
                  ),
                ),
                Text(
                  'Score : $score',
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class WaitingPage extends StatefulWidget {
  final String roomId;

  WaitingPage({required this.roomId});

  @override
  _WaitingPageState createState() => _WaitingPageState();
}

class _WaitingPageState extends State<WaitingPage> {
  int participantsFini = 0;
  IO.Socket socket = IO.io('http://10.2.0.216:3000', <String, dynamic>{
    'transports': ['websocket'],
  });

  int participantsCount = 0;

  @override
  void initState() {
    super.initState();
    socket.on('participantFini', (data) {
      setState(() {
        participantsFini = data['participantsFini'];
      });
    });

    socket.emit('TotalUsers', {
      'ParticipantsCount': participantsCount,
    });

    socket.on('redirectToLeaderboard', (data) {
      List<String> socketIds = List<String>.from(data);
      // Vérifier si l'ID de socket de l'utilisateur actuel est présent dans socketIds
      if (socketIds.contains(socket.id)) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => LeaderboardPage(roomId: widget.roomId),
          ),
        );
      }
    });
  }


  @override
  void dispose() {
    socket.dispose(); // Fermer la connexion socket IO
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'En attente que tous les joueurs finissent',
              style: TextStyle(fontSize: 20),
            ),
            SizedBox(height: 20),
            Text(
              'Nombre de participants ayant terminé : $participantsFini',
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}

class LeaderboardPage extends StatefulWidget {
  final String roomId;

  LeaderboardPage({required this.roomId});

  @override
  _LeaderboardPageState createState() => _LeaderboardPageState();
}

class _LeaderboardPageState extends State<LeaderboardPage> {
  int participantsCount = 0;
  int userFinished = 0;
  List<Map<String, dynamic>> scores = [];
  IO.Socket socket = IO.io('http://10.2.0.216:3000');

  @override
  void initState() {
    super.initState();

    socket.on('participantsCount', (count) {
      setState(() {
        participantsCount = count['participantsCount'];
      });
    });
    socket.on('participantFini', (data) {
      final roomId = data['roomId'];
      final participantsFini = data['participantsFini'];

      // Vérifier si les données correspondent à la salle actuelle
      if (roomId == widget.roomId) {
        setState(() {
          userFinished = participantsFini;
        });
      }
    });

    socket.emit('getScores');
    socket.on('scoresData', (data) {
      List<Map<String, dynamic>> scoresData = List<Map<String, dynamic>>.from(
          data);
      scoresData.sort((a, b) =>
          b['score'].compareTo(
              a['score'])); // Tri du tableau par score décroissant
      setState(() {
        scores = scoresData;
      });
    });


    // Écouter l'événement 'redirectToLeaderboard'
    socket.on('redirectToLeaderboard', (socketIds) {
      // Vérifier si l'ID de socket du client courant est présent dans la liste socketIds
      if (socketIds.contains(socket.id)) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => LeaderboardPage(roomId: widget.roomId),
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    socket.dispose(); // Fermer la connexion socket IO
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Classement'),
      ),
      body: Container(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20.0),
              border: Border.all(
                color: Colors.grey,
                width: 2.0,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Classement',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                ListView.builder(
                  shrinkWrap: true,
                  itemCount: scores.length,
                  itemBuilder: (context, index) {
                    final scoreData = scores[index];
                    final pseudo = scoreData['pseudo'];
                    final score = scoreData['score'];
                    return ListTile(
                      title: Text(pseudo),
                      subtitle: Text('Score: $score'),
                    );
                  },
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => MultijoueursPage(pseudo: '',)),
                    );
                  },
                  child: const Text('Retour vers Multijoueurs'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class QuestionModel {
  final String question;
  final List<dynamic> options;
  final dynamic correctAnswer;

  QuestionModel({
    required this.question,
    required this.options,
    required this.correctAnswer,
  });
}