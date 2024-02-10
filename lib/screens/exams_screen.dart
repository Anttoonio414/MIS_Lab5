import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'calendar_widget.dart';
import 'google_map.dart';

class Exam {
  final String subjectName;
  final DateTime dateTime;
  final double latitude; // Add latitude
  final double longitude; // Add longitude

  Exam({
    required this.subjectName,
    required this.dateTime,
    required this.latitude,
    required this.longitude,
  });

  get course => null;

  get timestamp => null;
}

class ExamsScreen extends StatefulWidget {
  final Function(Map<DateTime, List<Exam>>) onCalendarUpdate;

  const ExamsScreen({Key? key, this.onCalendarUpdate = _defaultCallback})
      : super(key: key);

  static void _defaultCallback(Map<DateTime, List<Exam>> updatedEvents) {}

  @override
  ExamsScreenState createState() => ExamsScreenState();
}

class ExamsScreenState extends State<ExamsScreen> {
  List<Exam> exams = [];
  late Map<DateTime, List<Exam>> _events = {};

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
            onNavigateToMaps: () {
              _navigateToMaps(exams[index]);
            },
          );
        },
      )
          : const Center(
        child: Text("No exams available. Add exams using the '+' button."),
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: 'add_exam_button',
            onPressed: () async {
              Exam? newExam = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      AddEditExamScreen(
                        onExamAddedOrEdited: (exam) {
                          _loadEvents();
                        },
                      ),
                ),
              );

              if (newExam != null) {
                setState(() {
                  exams.add(newExam);
                  _loadEvents(); // Load events after adding a new exam
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Exam added successfully."),
                    duration: Duration(seconds: 2),
                  ),
                );
              }
            },
            child: const Icon(Icons.add),
          ),
          const SizedBox(height: 16),
          FloatingActionButton(
            heroTag: 'open_calendar_button',
            onPressed: () async {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      CalendarScreen(
                        events: _events, // Pass the initial events
                        onUpdate: (updatedEvents) {
                          _updateCalendar(updatedEvents);
                        },
                        exams: [],
                      ),
                ),
              );
            },
            child: const Icon(Icons.calendar_today),
          ),
        ],
      ),
    );
  }

  void _loadEvents() {
    _events.clear();

    for (var exam in exams) {
      DateTime examDate = DateTime(
        exam.dateTime.year,
        exam.dateTime.month,
        exam.dateTime.day,
      );

      if (!_events.containsKey(examDate)) {
        _events[examDate] = [];
      }

      _events[examDate]!.add(exam);
    }

    widget.onCalendarUpdate(_events);

    setState(() {});
  }

  void _updateCalendar(Map<DateTime, List<Exam>> updatedEvents) {
    widget.onCalendarUpdate(updatedEvents);
  }

  void _navigateToEditExamScreen(Exam exam) async {
    Exam? editedExam = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            AddEditExamScreen(
              exam: exam,
              onExamAddedOrEdited: (editedExam) {
                int index = exams.indexWhere((element) => element == exam);
                exams[index] = editedExam;
                _loadEvents();
              },
            ),
      ),
    );
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
                _loadEvents();
              },
              child: const Text("Yes"),
            ),
          ],
        );
      },
    );
  }

  void _navigateToMaps(Exam exam) async {
    if (exam.latitude != null && exam.longitude != null) {
      // Explicitly convert String to Uri
      final uri = Uri.parse(
          'https://www.google.com/maps/search/?api=1&query=${exam
              .latitude},${exam.longitude}');

      // Use the launch function from the url_launcher package
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        print('Could not launch $uri');
      }
    } else {
      print('Latitude and longitude are not available for this exam.');
    }
  }

}

class ExamCard extends StatelessWidget {
  final Exam exam;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onNavigateToMaps; // Add this callback

  const ExamCard({
    Key? key,
    required this.exam,
    required this.onEdit,
    required this.onDelete,
    required this.onNavigateToMaps, // Add this argument
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
                    backgroundColor: Colors.red,
                  ),
                  child: const Text("Delete"),
                ),
                ElevatedButton(
                  onPressed: onNavigateToMaps, // Add this callback to the button
                  child: const Text("Navigate to Maps"),
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
  final Function(Exam) onExamAddedOrEdited;

  const AddEditExamScreen({
    Key? key,
    this.exam,
    required this.onExamAddedOrEdited,
  }) : super(key: key);

  @override
  AddEditExamScreenState createState() => AddEditExamScreenState();
}

class AddEditExamScreenState extends State<AddEditExamScreen> {
  late TextEditingController _subjectController;
  late DateTime _selectedDateTime;

  @override
  void initState() {
    super.initState();
    _subjectController =
        TextEditingController(text: widget.exam?.subjectName ?? "");
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
                  latitude: 37.7749,
                  longitude: -122.4194,
                );

                widget.onExamAddedOrEdited(newExam);

                Navigator.pop(context, newExam);
              },
              child: const Text("Save"),
            ),
          ],
        ),
      ),
    );
  }
}


void main() {
  runApp(
    MaterialApp(
      routes: {
        '/': (context) => ExamsScreen(),
        '/calendar': (context) => CalendarScreen(exams: const [], events: const {}, onUpdate: (updatedEvents) {  },),
      },
    ),
  );
}


