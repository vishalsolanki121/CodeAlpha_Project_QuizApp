import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:language_learning/AddQuestionScreen.dart';

class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  int currentIndex = 0;
  List<int> selectedIndexes = [];
  int score = 0;
  List<Map<String, dynamic>> questions = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchQuestions();
  }

  Future<void> fetchQuestions() async {
    final response = await http.get(
        Uri.parse('https://opentdb.com/api.php?amount=10&difficulty=medium&type=multiple'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        questions = (data['results'] as List).map((questionData) {
          final options = List<String>.from(questionData['incorrect_answers']);
          options.add(questionData['correct_answer']);
          options.shuffle();
          return {
            "question": questionData['question'],
            "options": options,
            "correctIndex": options.indexOf(questionData['correct_answer']),
          };
        }).toList();
        selectedIndexes = List.filled(questions.length, -1);
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });
      throw Exception('Failed to load questions');
    }
  }

  void addNewQuestion(Map<String, dynamic> newQuestion) {
    setState(() {
      questions.add(newQuestion);
      selectedIndexes.add(-1);
    });
  }

  void nextQuestion() {
    if (currentIndex < questions.length - 1) {
      setState(() {
        currentIndex++;
      });
    } else {
      calculateScore();
      showScoreDialog();
    }
  }

  void previousQuestion() {
    if (currentIndex > 0) {
      setState(() {
        currentIndex--;
      });
    }
  }

  void calculateScore() {
    score = 0;
    for (int i = 0; i < questions.length; i++) {
      if (selectedIndexes[i] == questions[i]["correctIndex"]) {
        score++;
      }
    }
  }

  void showScoreDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Quiz Completed!"),
        content: Text("Your score is $score/${questions.length}"),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              setState(() {
                currentIndex = 0;
                selectedIndexes = List.filled(questions.length, -1);
                score = 0;
                isLoading = true;
                fetchQuestions();
              });
            },
            child: Text("Restart"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Quiz App'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => AddQuestionScreen(onAddQuestion: addNewQuestion),
                ),
              );
            },
          ),
        ],
      ),
      body: Container(
        height: Get.height,
        width: Get.width,
        color: Color(0xFFB1AFFF),
        child: isLoading
            ? Center(child: CircularProgressIndicator())
            : Column(
          children: [
            SizedBox(height: 80),
            Center(
              child: SingleChildScrollView(
                child: Container(
                  padding: EdgeInsets.all(16),
                  height: 200,
                  width: 400,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        spreadRadius: 2,
                        blurRadius: 5,
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      questions[currentIndex]["question"] as String,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF212121),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 20),
            for (int i = 0; i < questions[currentIndex]["options"].length; i++)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: InkWell(
                  onTap: () {
                    setState(() {
                      selectedIndexes[currentIndex] = i;
                    });
                  },
                  child: Container(
                    height: 50,
                    width: 400,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: selectedIndexes[currentIndex] == i
                          ? Color(0xFF4CAF50)
                          : Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          spreadRadius: 1,
                          blurRadius: 3,
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        questions[currentIndex]["options"][i],
                        style: TextStyle(
                          fontSize: 18,
                          color: Color(0xFF212121),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ElevatedButton(
                  onPressed: currentIndex > 0 ? previousQuestion : null,
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    textStyle: TextStyle(fontSize: 16),
                  ),
                  child: Text("Previous"),
                ),
                ElevatedButton(
                  onPressed: nextQuestion,
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    textStyle: TextStyle(fontSize: 16),
                  ),
                  child: Text(currentIndex < questions.length - 1 ? "    Next    " : "Finish"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
