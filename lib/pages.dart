import 'package:flutter/material.dart';
import 'courses.dart';


class SettingsPage extends StatelessWidget {
  const SettingsPage({
    required this.changePageCallback,
    required this.pageId,
    Key? key
  }) : super(key: key);

  final Function(int pageId) changePageCallback;
  final pageId;

  @override
  Widget build(BuildContext context) {
    return const Center(
        child: Text('Settings')
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({
    required this.changePageCallback,
    required this.pageId,
    Key? key
  }) : super(key: key);

  final Function(int pageId) changePageCallback;
  final pageId;

  @override
  Widget build(BuildContext context) {
    return CoursesList(
      courses: <Course>[
        Course(
            name: 'Test 1',
            room: 'Room 11',
            time: DateTime.now(),
            state: CourseState.notYetPointed),
        Course(
            name: 'Test 2',
            room: 'Room 22',
            time: DateTime.now(),
            state: CourseState.missed),
      ],
    );
  }
}
