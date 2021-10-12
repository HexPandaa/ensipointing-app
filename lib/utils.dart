import 'dart:io';
import 'package:http/http.dart' as http;


/// From https://api.flutter.dev/flutter/dart-io/HttpClient/findProxyFromEnvironment.html
/// From https://stackoverflow.com/questions/54763466/flutter-webview-with-proxy
class ProxyHttpOverrides extends HttpOverrides {

  @override
  HttpClient createHttpClient(SecurityContext? context) {
    // var c = super.createHttpClient(context);
    HttpClient client = HttpClient(context: context);
    client.findProxy = (url) {
      return HttpClient.findProxyFromEnvironment(url, environment: {
        "http_proxy": "127.0.0.1:3128",
        "https_proxy": "127.0.0.1:3128"
      });
    };
    return client;
  }

  // Possible alternative
  // @override
  // HttpClient createHttpClient(SecurityContext? context) {
  //   HttpClient client = HttpClient();
  //   client.findProxy = (Uri uni) {
  //     return 'PROXY 127.0.0.1';
  //   };
  //   client.authenticate = (uri, scheme, realm) { // authenticateProxy ?
  //     client.addCredentials(uri, realm!, HttpClientBasicCredentials('username', 'password'));
  //   };
  //   return client;
  // }
}

class Courses {
  static void getCourses() {
    // HttpOverrides.runZoned(() => {
    //
    // }, createHttpClient: (SecurityContext c) => new ProxyHttpOverrides(c))

    void getPage() async {
      var url = Uri.parse('https://extranet.ensimag.fr/assiduite');
      var response = await http.get(url);
    }

    HttpOverrides.runWithHttpOverrides(() async {
      var url = Uri.parse('https://extranet.ensimag.fr/assiduite');
      var response = await http.get(url);
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');
    }, ProxyHttpOverrides());
  }
}