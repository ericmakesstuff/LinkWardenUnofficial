import "session.dart";
import 'package:flutter/foundation.dart';

class Api extends ChangeNotifier {
  static const String baseUrl = "/api/v1";
  final String? domain;
  final String? email;
  final String? password;
  final Session session;
  String userId = "";
  bool loggedIn = false;

  Api({this.domain, this.email, this.password}) : session = Session();

  Future<Map> get(String url) async {
    if (!loggedIn) {
      await login();
    }
    url = processUrl(url);
    return await session.get('https://$domain$baseUrl$url', jsonHeader: true);
  }

  Future<Map> post(String url, dynamic data) async {
    if (!loggedIn) {
      await login();
    }
    url = processUrl(url);
    return await session.post('https://$domain$baseUrl$url', data);
  }

  Future<bool> login() async {
    Map data1 = await session.get('https://$domain$baseUrl/auth/providers');
    Map data2 = await session.get('https://$domain$baseUrl/auth/csrf');
    if (!data2.containsKey('csrfToken')) {
      throw Exception('Failed to login - please check your URL');
    }
    //print("CSRF: ${data2['csrfToken']}");
    try {
      Map data3 = await session.post('https://$domain$baseUrl/auth/callback/credentials', {
        'username': email,
        'password': password,
        'redirect': 'false',
        'csrfToken': data2['csrfToken'],
        'callbackUrl': 'https://cloud.linkwarden.app/login',
        'json': 'true',
      });
      if (!data3.containsKey('url')) {
        throw Exception('Failed to login - please check your credentials');
      }
    } catch (e) {
      throw Exception('Failed to login - please check your credentials');
    }
    Map data4 = await session.get('https://$domain$baseUrl/auth/session', jsonHeader: true, additionalHeaders: {
      'referer': 'https://$domain/login',
    });
    if (!data4.containsKey('user')) {
      throw Exception('Failed to login - Could not retrieve user data');
    }
    userId = data4['user']['id'].toString();
    loggedIn = true;
    return true;
  }
  
  String processUrl(String url) {
    url = url.replaceAll('{userId}', userId);
    return url;
  }
}
