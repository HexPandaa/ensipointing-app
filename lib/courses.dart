import 'package:ensipointing/utils.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

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

  String get formattedRooms {
    var lines = room.split('\n')
      ..removeWhere((element) => element.trim().isEmpty);
    var regex = RegExp(r'[A-Z]\d{3}');
    var formatted = lines.map((e) => regex.stringMatch(e)).join(', ');
    return formatted;
  }

  String get formattedTime {
    DateFormat dateFmt = DateFormat('dd/MM');
    return dateFmt.format(timeStart) +
        ' ' +
        DateFormat.Hm().format(timeStart) +
        ' ➜ ' +
        DateFormat.Hm().format(timeEnd);
  }
}

class CoursesList extends StatefulWidget {
  const CoursesList({required this.pageController, Key? key}) : super(key: key);

  final PageController pageController;

  @override
  _CoursesListState createState() => _CoursesListState();
}

class _CoursesListState extends State<CoursesList>
    with AutomaticKeepAliveClientMixin {
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
    return RefreshIndicator(
        child: ListView(
          children: _courses.map((Course course) {
            return CoursesListItem(
              course: course,
            );
          }).toList(),
          physics: const AlwaysScrollableScrollPhysics(),
        ),
        onRefresh: () async {
          String? err = CoursesHTTPClient.allSettingsSet();
          if (err == null) {
            // Everything should be set in the settings
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
          } else {
            // Something is missing from the settings
            final snackBar = SnackBar(
              content: Text(err + ' is missing from the settings'),
              action: SnackBarAction(
                label: 'Settings',
                onPressed: () {
                  widget.pageController.jumpToPage(1);
                },
              ),
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

class _PointedCoursesListState extends State<PointedCoursesList>
    with AutomaticKeepAliveClientMixin {
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
            );
          }).toList(),
          physics: const AlwaysScrollableScrollPhysics(),
        ),
        onRefresh: () async {
          try {
            List<Course> c = await CoursesHTTPClient.getPointedCourses();
            // Reverse sort the courses, newer at the top
            c.sort((Course a, Course b) {
              return b.timeStart.compareTo(a.timeStart);
            });
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

class CoursesListItem extends StatefulWidget {
  const CoursesListItem({required this.course, Key? key}) : super(key: key);

  final Course course;

  @override
  _CoursesListItemState createState() => _CoursesListItemState();
}

class _CoursesListItemState extends State<CoursesListItem> {
  Color _getColor(CourseState state) {
    switch (state) {
      case CourseState.pointed:
        return Colors.green;
      case CourseState.notYetPointed:
        return Colors.yellow;
      case CourseState.missed:
        return Colors.red;
      default:
        return Colors.blueGrey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
        child: ListTile(
      onTap: () async {
        if (widget.course.state == CourseState.notYetPointed) {
          var result = await CoursesHTTPClient.pointCourse(widget.course.id);
          if (result) {
            widget.course.setState(CourseState.pointed);
          }
          setState(() {});
        }
      },
      leading: const Icon(Icons.check),
      title: Text(widget.course.name),
      subtitle: Text(
          widget.course.formattedRooms + ' • ' + widget.course.formattedTime),
      tileColor: _getColor(widget.course.state),
    ));
  }
}
