import 'package:flutter/material.dart';
import 'package:quiz/pseudo.dart';

void main() {
  runApp(const quizaiptest());
}

// ignore: camel_case_types
class quizaiptest extends StatelessWidget {
  const quizaiptest({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Pseudo(),
    );
  }
}