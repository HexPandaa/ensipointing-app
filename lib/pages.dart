import 'package:flutter/material.dart';
import 'courses.dart';


class SettingsPage extends StatelessWidget {
  const SettingsPage(
      {required this.changePageCallback, required this.pageId, Key? key})
      : super(key: key);

  final Function(int pageId) changePageCallback;
  final pageId;

  @override
  Widget build(BuildContext context) {
    return ListView(children: <Widget>[
      SettingsGroup(title: 'Pointing', children: <Widget>[
        TextInputSettingsTile(
          title: 'URL',
          settingKey: AppSettingKeys.platformUrl,
          initialValue: 'https://extranet.ensimag.fr/assiduite',
          validator: (String? input) {
            if (input != null &&
                Uri.tryParse(input) != null &&
                Uri.parse(input).userInfo == '') {
              return null;
            }
            return 'Input only the bare URL of the platform';
          },
        ),
        TextInputSettingsTile(
          title: 'Username',
          settingKey: AppSettingKeys.platformUsername,
          validator: (String? input) {
            return null;
            if (input != null && input.isNotEmpty) {
              return null;
            }
            return 'Platform username is required';
          },
        ),
        TextInputSettingsTile(
          title: 'Password',
          settingKey: AppSettingKeys.platformPassword,
          obscureText: true,
          validator: (String? input) {
            if (input != null && input.isNotEmpty) {
              return null;
            }
            return 'Platform password is required';
          },
        ),
      ]),
      SettingsGroup(title: 'Proxy', children: <Widget>[
        TextInputSettingsTile(
          title: 'Host',
          settingKey: AppSettingKeys.proxyHost,
          validator: (String? input) {
            if (input != null &&
                RegExp(r'^[\w\-.]+?:\d{1,5}$').hasMatch(input) &&
                Uri.tryParse(input) != null) {
              return null;
            }

            return "The proxy host should be in the form host:port";
          },
        ),
        TextInputSettingsTile(
          title: 'Username',
          settingKey: AppSettingKeys.proxyUsername,
          validator: (String? input) {
            if (input != null && input.isNotEmpty) {
              return null;
            }
            return 'Proxy username is required';
          },
        ),
        TextInputSettingsTile(
          title: 'Password',
          settingKey: AppSettingKeys.proxyPassword,
          obscureText: true,
          validator: (String? input) {
            if (input != null && input.isNotEmpty) {
              return null;
            }
            return 'Proxy password is required';
          },
        ),
      ]),
    ]);
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
