import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'exams_screen.dart';

class CalendarScreen extends StatelessWidget {
  final List<Exam> exams;
  final Map<DateTime, List<Exam>> events;
  final Null Function(dynamic updatedEvents) onUpdate;

  const CalendarScreen({
    Key? key,
    required this.exams,
    required this.events,
    required this.onUpdate,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Calendar"),
      ),
      body: CalendarWidget(
        exams: exams,
        events: events,
        onUpdate: (updatedEvents) {
          onUpdate(updatedEvents);
        },
      ),
    );
  }
}

class CalendarWidget extends StatefulWidget {
  final List<Exam> exams;
  final Map<DateTime, List<Exam>> events;
  final Function(Map<DateTime, List<Exam>>) onUpdate;

  const CalendarWidget({
    Key? key,
    required this.exams,
    required this.events,
    required this.onUpdate,
  }) : super(key: key);

  @override
  CalendarWidgetState createState() => CalendarWidgetState(onUpdate: onUpdate);
}

class CalendarWidgetState extends State<CalendarWidget> {
  final CalendarFormat _calendarFormat = CalendarFormat.month;
  final Function(Map<DateTime, List<Exam>>) onUpdate;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  late Map<DateTime, List<Exam>> _events;

  CalendarWidgetState({required this.onUpdate});


  @override
  void initState() {
    super.initState();
    _events = widget.events ?? {};
  }


  @override
  Widget build(BuildContext context) {
    return TableCalendar(
      calendarFormat: _calendarFormat,
      focusedDay: _focusedDay,
      firstDay: DateTime.now().subtract(const Duration(days: 365)),
      lastDay: DateTime.now().add(const Duration(days: 365)),
      eventLoader: _getEventsForDay,
      onDaySelected: (selectedDay, focusedDay) {
        setState(() {
          _selectedDay = selectedDay;
          _focusedDay = focusedDay;
        });
      },
      calendarBuilders: CalendarBuilders(
        markerBuilder: (context, date, events) {
          if (events.isNotEmpty) {
            return Positioned(
              right: 1,
              bottom: 1,
              child: Container(
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.blue,
                ),
                width: 6,
                height: 6,
              ),
            );
          }
        },
      ),
    );
  }

  List<Exam> _getEventsForDay(DateTime day) {
    return _events[day] ?? [];
  }

  void updateEvents(Map<DateTime, List<Exam>> updatedEvents) {
    setState(() {
      _events = updatedEvents;
    });
  }
}