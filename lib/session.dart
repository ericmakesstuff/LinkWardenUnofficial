import 'dart:io';

import 'package:http/http.dart' as http;
import 'dart:convert';

class Session {
    bool debug = false;
    Map<String, Cookie> cookies = {};
    Map<String, String> headers = {'Content-Type': 'application/json'};

    Future<Map> get(String url, {bool jsonHeader = false, Map additionalHeaders = const {}}) async {
        var requestHeaders = headers;
        requestHeaders.addAll(additionalHeaders.cast<String, String>());
        if (jsonHeader) {
            requestHeaders['Content-Type'] = 'application/json';
        }
        http.Response response = await http.get(Uri.parse(url), headers: requestHeaders);
        updateCookie(response);
        try {
            if (debug) {
              print("\n\n" 'URL: $url');
              print('Headers: $requestHeaders');
              print('Response status: ${response.statusCode}');
              print('Response headers: ${response.headers}');
              print('Response body: ${response.body}');
            }
            return jsonDecode(response.body);
        } catch (e) {
            if (debug) {
              print("\n\n" 'URL: $url');
              print('Headers: $requestHeaders');
              print('Error occurred while decoding JSON: $e');
              print('Response status: ${response.statusCode}');
              print('Response headers: ${response.headers}');
              print('Response body: ${response.body}');
            }
            throw Exception('Failed to decode JSON');
        }
    }

    Future<Map> post(String url, dynamic data) async {
        if (debug) {
          print("headers: $headers");
        }
        http.Response response = await http.post(Uri.parse(url), body: json.encode(data), headers: headers);

        updateCookie(response);

        if (response.statusCode != 200) {
            if (debug) {
              print("\n\n" 'URL: $url');
              print('Headers: $headers');
              print('Data: $data');
              print('Response status: ${response.statusCode}');
              print('Response headers: ${response.headers}');
              print('Response body: ${response.body}');
            }
            throw Exception('Failed to post data');
        }

        try {
          if (debug) {
            print("\n\n" 'URL: $url');
            print('Headers: $headers');
            print('Data: $data');
            print('Response status: ${response.statusCode}');
            print('Response headers: ${response.headers}');
            print('Response body: ${response.body}');
          }
          return jsonDecode(response.body);
        } catch (e) {
          if (debug) {
            print("\n\n" 'URL: $url');
            print('Headers: $headers');
            print('Data: $data');
            print('Error occurred while decoding JSON: $e');
            print('Response status: ${response.statusCode}');
            print('Response headers: ${response.headers}');
            print('Response body: ${response.body}');
          }
          throw Exception('Failed to decode JSON');
        }
    }

    void updateCookie(http.Response response) {
        String? rawCookie = response.headers['set-cookie'];
        if (rawCookie != null) {
            Map<String, Cookie> newCookies = parseCookies(rawCookie);
            cookies.addAll(newCookies);
            headers['Cookie'] = getHttpCookiesAsString(cookies);
        }
    }

    Map<String, Cookie> parseCookies(String value) {
        Map<String, Cookie> cookies = {};

        final regex = RegExp('(?:[^,]|, )+');
        Iterable<Match> rawCookies = regex.allMatches(value);
        for (var rawCookie in rawCookies) {
          try {
            if(rawCookie.group(0) != null) {
              final cookie = Cookie.fromSetCookieValue(rawCookie.group(0)!);
              cookies[cookie.name] = cookie;
            }
          } on Exception {
            // the cookie might be invalid. do something or ignore it.
            continue;
          }
        }

        return cookies;
    }

    String getHttpCookiesAsString(Map<String, Cookie> cookies) {
      List<String> rawCookies = [];
      cookies.forEach((name, cookie) {
           rawCookies.add("$name=${cookie.value}");
      });
      return rawCookies.join('; ');
    }
}
