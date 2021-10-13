import 'package:flutter/material.dart';
import 'utils.dart';
import 'courses.dart';

void main() {
  // HttpOverrides.global = ProxyHttpOverrides();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'EnsiPointing',
      theme: ThemeData(
        // This is the theme of your application.
        primarySwatch: Colors.lightBlue,
      ),
      home: Scaffold(
          body: HomePage(),
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              Courses.getCourses();
            },
            child: const Icon(Icons.push_pin_outlined),
            tooltip: 'Point',
          ),
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerDocked,
          bottomNavigationBar: const BottomNavBar()),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

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

class BottomNavBar extends StatelessWidget {
  const BottomNavBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
        shape: const CircularNotchedRectangle(),
        color: Colors.lightBlueAccent,
        child: Row(
          children: <Widget>[
            IconButton(
              tooltip: 'Open navigation menu',
              icon: const Icon(Icons.menu),
              onPressed: () {},
            ),
            const Spacer(),
            IconButton(
              tooltip: 'Settings',
              icon: const Icon(Icons.settings),
              onPressed: () {},
            )
          ],
        ));
  }
}
