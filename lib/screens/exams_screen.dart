import 'package:flutter/material.dart';

class Exam {
  final String subjectName;
  final DateTime dateTime;

  Exam({required this.subjectName, required this.dateTime});
}

class ExamCard extends StatelessWidget {
  final Exam exam;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const ExamCard({
    Key? key,
    required this.exam,
    required this.onEdit,
    required this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(8),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              exam.subjectName,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 4),
            Text(
              "Date & Time: ${exam.dateTime.toLocal()}",
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: onEdit,
                  child: const Text("Edit"),
                ),
                ElevatedButton(
                  onPressed: onDelete,
                  style: ElevatedButton.styleFrom(
                    primary: Colors.red, // Set the background color
                  ),
                  child: const Text("Delete"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}


class AddEditExamScreen extends StatefulWidget {
  final Exam? exam;

  const AddEditExamScreen({Key? key, this.exam}) : super(key: key);

  @override
  _AddEditExamScreenState createState() => _AddEditExamScreenState();
}

class _AddEditExamScreenState extends State<AddEditExamScreen> {
  late TextEditingController _subjectController;
  late DateTime _selectedDateTime;

  @override
  void initState() {
    super.initState();
    _subjectController = TextEditingController(text: widget.exam?.subjectName ?? "");
    _selectedDateTime = widget.exam?.dateTime ?? DateTime.now();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.exam == null ? "Add Exam" : "Edit Exam"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _subjectController,
              decoration: const InputDecoration(labelText: "Subject Name"),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                final DateTime? selectedDateTime = await showDatePicker(
                  context: context,
                  initialDate: _selectedDateTime,
                  firstDate: DateTime.now(),
                  lastDate: DateTime(2101),
                );

                if (selectedDateTime != null) {
                  final TimeOfDay? selectedTime = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay.fromDateTime(_selectedDateTime),
                  );

                  if (selectedTime != null) {
                    setState(() {
                      _selectedDateTime = DateTime(
                        selectedDateTime.year,
                        selectedDateTime.month,
                        selectedDateTime.day,
                        selectedTime.hour,
                        selectedTime.minute,
                      );
                    });
                  }
                }
              },
              child: const Text("Select Date & Time"),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Exam newExam = Exam(
                  subjectName: _subjectController.text,
                  dateTime: _selectedDateTime,
                );

                // TODO: Implement the logic to save the exam
                // Add the new exam to the list or save it to your database
                Navigator.pop(context, newExam); // Close the screen and pass the new exam back
              },
              child: const Text("Save"),
            ),
          ],
        ),
      ),
    );
  }
}

class ExamsScreen extends StatefulWidget {
  const ExamsScreen({Key? key}) : super(key: key);

  @override
  _ExamsScreenState createState() => _ExamsScreenState();
}

class _ExamsScreenState extends State<ExamsScreen> {
  List<Exam> exams = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Exams"),
      ),
      body: exams.isNotEmpty
          ? GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
        ),
        itemCount: exams.length,
        itemBuilder: (context, index) {
          return ExamCard(
            exam: exams[index],
            onEdit: () {
              _navigateToEditExamScreen(exams[index]);
            },
            onDelete: () {
              _showDeleteConfirmation(exams[index]);
            },
          );
        },
      )
          : const Center(
        child: Text("No exams available. Add exams using the '+' button."),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          Exam? newExam = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddEditExamScreen()),
          );

          if (newExam != null) {
            setState(() {
              exams.add(newExam);
            });
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  void _navigateToEditExamScreen(Exam exam) async {
    Exam? editedExam = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AddEditExamScreen(exam: exam)),
    );

    if (editedExam != null) {
      setState(() {
        int index = exams.indexWhere((element) => element == exam);
        exams[index] = editedExam;
      });
    }
  }

  void _showDeleteConfirmation(Exam exam) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Confirm Deletion"),
          content: const Text("Are you sure you want to delete this exam?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("No"),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  exams.remove(exam);
                });
                Navigator.pop(context);
              },
              child: const Text("Yes"),
            ),
          ],
        );
      },
    );
  }
}

void main() {
  runApp(
    MaterialApp(
      home: ExamsScreen(),
    ),
  );
}
