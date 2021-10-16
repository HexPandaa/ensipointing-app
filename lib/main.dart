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
            HistoryPage(),
            SettingsPage(
              changePageCallback: _changePage,
              pageId: 2,
            )
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            String? err = CoursesHTTPClient.allSettingsSet();
            if (err == null) {
              // Everything should be set in the settings
              //var c = CoursesHTTPClient();
              //c.updateCourses();
            } else {
              // Something is missing from the settings
              final snackBar = SnackBar(
                content: Text(err + ' is missing'),
                action: SnackBarAction(
                  label: 'Settings',
                  onPressed: () {
                    pageController.jumpToPage(1);
                  },
                ),
              );
              ScaffoldMessenger.of(context).showSnackBar(snackBar);
            }
          },
          child: const Icon(Icons.push_pin_outlined),
          tooltip: 'Point',
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        bottomNavigationBar: BottomNavBar(
          changePageCallback: _changePage,
          pageController: pageController,
        ));
  }
}

class BottomNavBar extends StatelessWidget {
  const BottomNavBar(
      {required this.changePageCallback,
      required this.pageController,
      Key? key})
      : super(key: key);

  final Function(int pageId) changePageCallback;
  final PageController pageController;

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
              icon: Icon(Icons.home,
                  color: (pageController.page == 0) ? Colors.white : null),
              onPressed: () {
                changePageCallback(0);
              },
            ),
            IconButton(
                tooltip: 'History',
                icon: Icon(
                  Icons.history,
                  color: (pageController.page == 1) ? Colors.white : null,
                ),
                onPressed: () {
                  changePageCallback(1);
                }),
            IconButton(
              tooltip: 'Settings',
              icon: Icon(Icons.settings,
                  color: (pageController.page == 2) ? Colors.white : null),
              onPressed: () {
                changePageCallback(2);
              },
            )
          ],
        ));
  }
}
