import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AddQuestionScreen extends StatefulWidget {
  final Function(Map<String, dynamic>) onAddQuestion;

  const AddQuestionScreen({super.key, required this.onAddQuestion});

  @override
  State<AddQuestionScreen> createState() => _AddQuestionScreenState();
}

class _AddQuestionScreenState extends State<AddQuestionScreen> {
  final TextEditingController _questionController = TextEditingController();
  final List<TextEditingController> _optionControllers =
      List.generate(4, (_) => TextEditingController());
  int _correctIndex = -1;

  void _saveQuestion() {
    if (_questionController.text.isNotEmpty &&
        _optionControllers.every((controller) => controller.text.isNotEmpty) &&
        _correctIndex != -1) {
      final Map<String, dynamic> newQuestion = {
        'question': _questionController.text,
        'options':
            _optionControllers.map((controller) => controller.text).toList(),
        'correctIndex': _correctIndex,
      };
      widget.onAddQuestion(newQuestion);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add New Question'),
      ),
      body: Container(height: Get.height,
        width: Get.width,
        color: Color(0xffBBE9FF),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: _questionController,
                decoration: InputDecoration(labelText: 'Question'),
              ),
              SizedBox(height: 10),
              ...List.generate(_optionControllers.length, (index) {
                return Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _optionControllers[index],
                        decoration:
                            InputDecoration(labelText: 'Option ${index + 1}'),
                      ),
                    ),
                    Radio<int>(
                      value: index,
                      groupValue: _correctIndex,
                      onChanged: (value) {
                        setState(() {
                          _correctIndex = value!;
                        });
                      },
                    )
                  ],
                );
              }),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveQuestion,
                child: Text('Add Question'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
