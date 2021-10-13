import 'dart:io';
import 'package:http/http.dart' as http;

/// From https://api.flutter.dev/flutter/dart-io/HttpClient/findProxyFromEnvironment.html
/// From https://stackoverflow.com/questions/54763466/flutter-webview-with-proxy
class ProxyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    // Hardcoded for now
    String proxyHost = "sub.domain.tld";
    String proxyPort = "3128";
    String proxyUsername = "user";
    String proxyPassword = "password";

    HttpClient client = super.createHttpClient(context);
    client.findProxy = (Uri uri) {
      return 'PROXY $proxyHost:$proxyPort';
    };
    client.authenticateProxy = (host, port, scheme, realm) {
      client.addProxyCredentials(host, port, realm!,
          HttpClientBasicCredentials(proxyUsername, proxyPassword));
      return Future.value(true);
    };
    return client;
  }
  
// Alternative
// @override
// HttpClient createHttpClient(SecurityContext? context) {
//   print("Called custom http");
//   HttpClient client = super.createHttpClient(context);
//   // HttpClient client = HttpClient(context: context);
//   client.findProxy = (url) {
//     print("Called findProxy");
//     return HttpClient.findProxyFromEnvironment(url, environment: {
//       "http_proxy": "127.0.0.1:3128",
//       "https_proxy": "127.0.0.1:3128"
//     });
//   };
//   return client;
// }
}

class Courses {
  static void getCourses() async {
    HttpOverrides.runWithHttpOverrides(() async {
      var url = Uri.parse('https://extranet.ensimag.fr/assiduite');
      var response = await http.get(url);
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');
    }, ProxyHttpOverrides());
  }
}
