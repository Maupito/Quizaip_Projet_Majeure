import 'dart:async';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:quiz/mode.dart';
import '../Solo.dart';

void main() {
  String selectedOption2 = 'true'; // Récupérez votre valeur depuis la page Solo
  bool isTimed = selectedOption2.toLowerCase() == 'true'; // Convertissez la valeur en booléen
  int number = 0; // Remplacez par la valeur de votre choix pour "number"

  runApp(MaterialApp(
    home: QuizScreen(
      category: "valeur_de_selectedOption2",
      difficulty: "valeur_de_selectedOption3",
      isTimed: isTimed,
      number: number,
    ),
  ));
}

class QuizScreen extends StatefulWidget {
  final String category;
  final String difficulty;
  final bool isTimed;
  final int number;

  const QuizScreen({
    Key? key,
    required this.category,
    required this.difficulty,
    required this.isTimed,
    required this.number,
  }) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _QuizScreenState createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  List<QuestionModel> questionAnswers = [];
  List<QuestionModel> answeredQuestions = [];
  int currentQuestionIndex = 0; // Index de la question actuelle
  int score = 0; // Score du quiz
  Timer? timer; // Timer pour la durée de chaque question
  int timeRemaining = 30; // Temps restant pour chaque question

  @override
  void initState() {
    super.initState();
    loadQuizData();
    if (widget.isTimed) {
      startTimer();
    }
  }

  @override
  void dispose() {
    timer?.cancel(); // Annuler le timer lors de la suppression de l'écran
    super.dispose();
  }

  void loadQuizData() async {
    String jsonString = await rootBundle.loadString('assets/Questions/Cyber.json');
    List<dynamic> jsonData = json.decode(jsonString);

    List<QuestionModel> filteredQuestions = [];
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
      }
    }

    if (widget.isTimed) {
      setState(() {
        questionAnswers = filteredQuestions;
      });
    } else {
      int number = widget.number; // Récupérer la valeur de widget.number
      if (number < filteredQuestions.length) {
        filteredQuestions = filteredQuestions.sublist(0, number);
      }
      setState(() {
        questionAnswers = filteredQuestions;
      });
    }
  }



  void startTimer() {
    timer = Timer.periodic(const Duration(seconds: 1), (Timer timer) {
      if (timeRemaining > 0) {
        setState(() {
          timeRemaining--;
        });
      } else {
        // Toutes les questions ont été répondues
        // Afficher l'écran des résultats
        timer.cancel(); // Annuler le timer restant
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ResultScreen(
              score: score,
              totalQuestions: questionAnswers.length,
              answeredQuestions: answeredQuestions,
            ),
          ),
        );
      }
    });
  }

  void goToNextQuestion() {
    setState(() {
      if (currentQuestionIndex < questionAnswers.length - 1) {
        currentQuestionIndex++; // Passer à la question suivante si disponible
        if (widget.isTimed) {
          startTimer(); // Démarrer le timer pour la nouvelle question
        }
      } else {
        // Toutes les questions ont été répondues
        // Afficher l'écran des résultats
        timer?.cancel(); // Annuler le timer restant
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ResultScreen(
              score: score,
              totalQuestions: questionAnswers.length,
              answeredQuestions: answeredQuestions,
            ),
          ),
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
        //backgroundColor: Colors.black,
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
      //backgroundColor: Colors.black,
      appBar: AppBar(
        title: Row(
          children: [
            Text('Quiz'),
            SizedBox(width: 20),
          ],
        ),
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
            const SizedBox(height: 10),
            if (widget.isTimed)
              Expanded(
                child: Center(
                  child: Text(
                    'Temps restant: $timeRemaining secondes',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
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

class ResultScreen extends StatelessWidget {
  final int score;
  final int totalQuestions;
  final List<QuestionModel> answeredQuestions;

  const ResultScreen({
    Key? key,
    required this.score,
    required this.totalQuestions,
    required this.answeredQuestions,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Résultats du quiz'),
        actions: [
          IconButton(
            icon: const Icon(Icons.home),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => const MenuPrincipal(),
                ),
              );
            },
          ),
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Score: $score/$totalQuestions',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Questions répondues:',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 10),
              Column(
                children: answeredQuestions.map((question) {
                  String questionText = question.question;
                  List<dynamic> answers = question.options;
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                    color: const Color(0xFF1E385B), // Couleur bleu foncé
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Question: $questionText',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Column(
                            children: answers.map((answer) {
                              String answerText = answer['text'];
                              bool isCorrect = answer['correct'];
                              Color answerColor = isCorrect ? Colors.lightGreen : Colors.red;

                              return SizedBox(
                                width: double.infinity,
                                child: Text(
                                  answerText,
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: answerColor,
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
              OutlinedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SelectionMenu(pseudo: '',),
                    ),
                  );
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white, backgroundColor: const Color(0xFF1E385B),
                  padding: const EdgeInsets.symmetric(horizontal: 70, vertical: 30),
                  textStyle: const TextStyle(fontSize: 22),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.0),
                  ),
                ),
                child: const Text('Recommencer'),
              ),
            ],
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