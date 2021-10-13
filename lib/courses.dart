import 'package:flutter/material.dart';

// Inspired by the Shopping List example :
// https://flutter.dev/docs/development/ui/widgets-intro


enum CourseState {
  pointed,
  notYetPointed,
  missed
}

class Course {
  Course({
    required this.name,
    required this.room,
    required this.time,
    required this.state,
  });

  final String name;
  final String room;
  final DateTime time;
  CourseState state = CourseState.notYetPointed;

  void setState(CourseState state) {
    this.state = state;
  }

}

class CoursesList extends StatefulWidget {
  const CoursesList({required this.courses, Key? key}) : super(key: key);

  final List<Course> courses;

  @override
  _CoursesListState createState() => _CoursesListState();
}

class _CoursesListState extends State<CoursesList> {

  final _courses = <Course>{};

  void _handleCoursesChanged(Course course) {
    setState(() {
      course.setState(CourseState.pointed);
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: widget.courses.map((Course course) {
        return CoursesListItem(
          course: course,
          onCoursesChanged: _handleCoursesChanged,
        );
      }).toList(),
    );
  }
}

typedef CoursesChangedCallback = Function(Course course);

class CoursesListItem extends StatelessWidget {
  const CoursesListItem({
    required this.course,
    required this.onCoursesChanged,
    Key? key
  }) : super(key: key);

  final Course course;
  final CoursesChangedCallback onCoursesChanged;

  Color _getColor(BuildContext context) {
    switch (course.state) {
      case CourseState.pointed: return Colors.green;
      case CourseState.notYetPointed: return Colors.yellow;
      case CourseState.missed: return Colors.red;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
        child: ListTile(
          onTap: () {
            onCoursesChanged(course);
          },
          leading: const Icon(Icons.check),
          title: Text(course.name),
          subtitle: Text(course.room),
          tileColor: _getColor(context),
        )
    );
  }
}