import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' show parse;
import 'package:html/dom.dart';
import 'package:intl/intl.dart';
import 'dart:convert' show base64Encode, utf8;
import 'package:flutter_settings_screens/flutter_settings_screens.dart'
    show Settings;
import 'settings.dart';
import 'courses.dart';

/// From https://api.flutter.dev/flutter/dart-io/HttpClient/findProxyFromEnvironment.html
/// From https://stackoverflow.com/questions/54763466/flutter-webview-with-proxy
class ProxyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    String proxyHostPort = Settings.getValue(AppSettingKeys.proxyHost, "");
    String proxyUsername = Settings.getValue(AppSettingKeys.proxyUsername, "");
    String proxyPassword = Settings.getValue(AppSettingKeys.proxyPassword, "");

    HttpClient client = super.createHttpClient(context);
    client.findProxy = (Uri uri) {
      return 'PROXY $proxyHostPort';
    };
    client.authenticateProxy = (host, port, scheme, realm) {
      client.addProxyCredentials(host, port, realm!,
          HttpClientBasicCredentials(proxyUsername, proxyPassword));
      return Future.value(true);
    };
    return client;
  }
}

class CoursesHTTPClient {
  static Future<List<Course>> getPointableCourses() async {
    var url = Settings.getValue<String>(AppSettingKeys.platformUrl, "");
    var response = await _doGet(url);
    print('Response status: ${response.statusCode}');

    if (response.statusCode == 401) {
      throw Exception("Bad user credentials");
    }

    var document = parse(response.body);
    var adeTable = document.getElementById('adeEvent');
    if (adeTable == null) {
      throw Exception("Could not find adeTable");
    }

    List<Course> courses = [];

    var adeBody = adeTable.getElementsByTagName('tbody');
    if (adeBody.isEmpty) {
      print("Not tbody found in adeTable, there must be no course to point");
      return courses; // empty
    }

    List<Element> toPointRows = adeBody[0].getElementsByTagName('tr');

    for (Element row in toPointRows) {
      Course course = _parseTableRow(row);
      course.setState(CourseState.notYetPointed);
      print("Adding course " + course.name);
      courses.add(course);
    }

    return courses;
  }

  static Future<List<Course>> getPointedCourses() async {
    var url = Settings.getValue<String>(AppSettingKeys.platformUrl, "");
    var response = await _doGet(url);
    print('Response status: ${response.statusCode}');

    if (response.statusCode == 401) {
      throw Exception("Bad user credentials");
    }

    var document = parse(response.body);
    var tables = document.getElementsByTagName('table');
    if (tables.length < 3) {
      throw Exception("Could not find the table of pointed courses");
    }

    List<Course> courses = [];

    List<Element> toPointRows = tables[2].getElementsByTagName('tr');

    if (toPointRows.length < 2) {
      // There is only the thead row
      return courses; // empty
    }

    toPointRows.removeAt(0); // Remove the thead row

    for (Element row in toPointRows) {
      Course course = _parseTableRow(row);
      course.setState(CourseState.pointed);
      print("Adding course " + course.name);
      courses.add(course);
    }

    return courses;
  }

  static Future<bool> pointCourse(int courseId) async {
    var baseUrl = Settings.getValue(AppSettingKeys.platformUrl, '');

    var url = baseUrl + '/pointage/groupe?idE=' + courseId.toString();
    print(url);
    var r = await _doGet(url);
    print('Pointage: ${r.statusCode}');
    print(r.body);
    return r.statusCode == 200 && r.body.startsWith('ok');
  }

  static Future<http.Response> _doGet(String uri) async {
    var url = Uri.parse(uri);
    http.Response response = await HttpOverrides.runWithHttpOverrides(() async {
      var r = await http.get(url, headers: <String, String>{
        'Authorization': _getAuthorizationString()
      });
      return r;
    }, ProxyHttpOverrides());
    return response;
  }

  static String _getAuthorizationString() {
    // Hardcode for now
    var user = Settings.getValue<String>(AppSettingKeys.platformUsername, "");
    var pass = Settings.getValue<String>(AppSettingKeys.platformPassword, "");
    return 'Basic ' + base64Encode(utf8.encode('$user:$pass'));
  }

  static Course _parseTableRow(Element row) {
    String id = row.attributes['ide'].toString();
    var infos = row.getElementsByTagName('td');
    // idEvent, activityId, date, hDebut, hFin, name, groupeEtudiant, salle, enseignant
    int _id = int.parse(infos[0].text);
    String date = infos[2].text;
    String hStart = infos[3].text;
    String hEnd = infos[4].text;
    String name = infos[5].text;
    String room = infos[7].text;

    DateFormat format = DateFormat('dd/MM/yyyy hh:mm');
    DateTime dateStart = format.parse(date + ' ' + hStart);
    DateTime dateEnd = format.parse(date + ' ' + hEnd);

    return Course(
        name: name,
        room: room,
        timeStart: dateStart,
        timeEnd: dateEnd,
        id: _id);
  }

  static String? allSettingsSet() {
    if (Settings.getValue(AppSettingKeys.proxyHost, '') == '') {
      return "Proxy host";
    } else if (Settings.getValue<String>(AppSettingKeys.proxyUsername, '') ==
        '') {
      return "Proxy username";
    } else if (Settings.getValue<String>(AppSettingKeys.proxyPassword, '') ==
        '') {
      return "Proxy password";
    } else if (Settings.getValue<String>(AppSettingKeys.platformUrl, '') ==
        '') {
      return "Platform URL";
    } else if (Settings.getValue<String>(AppSettingKeys.platformUsername, '') ==
        '') {
      return "Platform username";
    } else if (Settings.getValue<String>(AppSettingKeys.platformPassword, '') ==
        '') {
      return "Platform password";
    }
    return null;
  }
}
