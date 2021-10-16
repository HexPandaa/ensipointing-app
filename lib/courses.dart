import 'package:ensipointing/utils.dart';
import 'package:flutter/material.dart';

// Inspired by the Shopping List example :
// https://flutter.dev/docs/development/ui/widgets-intro

enum CourseState { pointed, notYetPointed, missed }

class Course {
  Course({
    required this.name,
    required this.room,
    required this.timeStart,
    required this.timeEnd,
    required this.id,
  });

  final String name;
  final String room;
  final DateTime timeStart;
  final DateTime timeEnd;
  final int id;
  CourseState state = CourseState.notYetPointed;

  Course setState(CourseState state) {
    this.state = state;
    return this;
  }
}

class CoursesList extends StatefulWidget {
  const CoursesList({Key? key}) : super(key: key);

  @override
  _CoursesListState createState() => _CoursesListState();
}

class _CoursesListState extends State<CoursesList> {
  late List<Course> _courses;

  void _handleCoursesChanged(Course course) {
    setState(() {
      course.setState(CourseState.pointed);
    });
  }

  @override
  void initState() {
    super.initState();
    _courses = [];
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
        child: ListView(
          children: _courses.map((Course course) {
            return CoursesListItem(
              course: course,
              onCoursesChanged: _handleCoursesChanged,
            );
          }).toList(),
          physics: const AlwaysScrollableScrollPhysics(),
        ),
        onRefresh: () async {
          try {
            List<Course> c = await CoursesHTTPClient.getPointableCourses();
            return setState(() {
              _courses = c;
            });
          } catch (err) {
            final snackBar = SnackBar(
              content: Text(err.toString()),
            );
            ScaffoldMessenger.of(context).showSnackBar(snackBar);
          }
          return Future.value(true);
        });
  }
}

class PointedCoursesList extends StatefulWidget {
  const PointedCoursesList({Key? key}) : super(key: key);

  @override
  _PointedCoursesListState createState() => _PointedCoursesListState();
}

class _PointedCoursesListState extends State<PointedCoursesList> with AutomaticKeepAliveClientMixin {
  late List<Course> _courses;

  void _handleCoursesChanged(Course course) {
    setState(() {
      course.setState(CourseState.pointed);
    });
  }

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _courses = [];
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return RefreshIndicator(
        child: ListView(
          children: _courses.map((Course course) {
            return CoursesListItem(
              course: course,
              onCoursesChanged: _handleCoursesChanged,
            );
          }).toList(),
          physics: const AlwaysScrollableScrollPhysics(),
        ),
        onRefresh: () async {
          try {
            List<Course> c = await CoursesHTTPClient.getPointedCourses();
            return setState(() {
              _courses = c;
            });
          } catch (err) {
            final snackBar = SnackBar(
              content: Text(err.toString()),
            );
            ScaffoldMessenger.of(context).showSnackBar(snackBar);
          }
          return Future.value(true);
        });
  }
}

typedef CoursesChangedCallback = Function(Course course);

class CoursesListItem extends StatelessWidget {
  const CoursesListItem(
      {required this.course, required this.onCoursesChanged, Key? key})
      : super(key: key);

  final Course course;
  final CoursesChangedCallback onCoursesChanged;

  Color _getColor(BuildContext context) {
    switch (course.state) {
      case CourseState.pointed:
        return Colors.green;
      case CourseState.notYetPointed:
        return Colors.yellow;
      case CourseState.missed:
        return Colors.red;
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
    ));
  }
}
