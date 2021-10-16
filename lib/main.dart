import 'package:flutter/material.dart';
import 'utils.dart';
import 'courses.dart';
import 'pages.dart';
import 'package:flutter_settings_screens/flutter_settings_screens.dart'
    show Settings;

void main() async {
  await Settings.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'EnsiPointing',
      theme: ThemeData(
        // This is the theme of your application.
        primarySwatch: Colors.lightBlue,
      ),
      home: const App(),
    );
  }
}

/// Main application widget
class App extends StatefulWidget {
  const App({Key? key}) : super(key: key);

  @override
  _AppState createState() => _AppState();
}

class _AppState extends State<App> {
  late PageController pageController;

  @override
  void initState() {
    super.initState();
    pageController = PageController(initialPage: 0);
  }

  void _changePage(int pageId) {
    setState(() {
      pageController.jumpToPage(pageId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: PageView(
          physics: const NeverScrollableScrollPhysics(),
          controller: pageController,
          children: <Widget>[
            HomePage(
              changePageCallback: _changePage,
              pageId: 0,
            ),
            SettingsPage(
              changePageCallback: _changePage,
              pageId: 1,
            )
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            var c = CoursesHTTPClient();
            c.updateCourses();
          },
          child: const Icon(Icons.push_pin_outlined),
          tooltip: 'Point',
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        bottomNavigationBar: BottomNavBar(changePageCallback: _changePage));
  }
}

class BottomNavBar extends StatelessWidget {
  const BottomNavBar({required this.changePageCallback, Key? key})
      : super(key: key);

  final Function(int pageId) changePageCallback;

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
        shape: const CircularNotchedRectangle(),
        color: Colors.lightBlueAccent,
        child: Row(
          children: <Widget>[
            const Spacer(),
            IconButton(
              tooltip: 'Home',
              icon: const Icon(Icons.home),
              onPressed: () {
                changePageCallback(0);
              },
            ),
            IconButton(
              tooltip: 'Settings',
              icon: const Icon(Icons.settings),
              onPressed: () {
                changePageCallback(1);
              },
            )
          ],
        ));
  }
}
