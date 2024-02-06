import 'package:linkwarden/components/Spinner.dart';
import 'package:linkwarden/screens/DashboardScreen.dart';
import 'package:linkwarden/screens/LoginScreen.dart';
import 'package:linkwarden/screens/NewLinkScreen.dart';
import 'api.dart';
import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';

class UserInfo {
  int id = 0;
  String name = '';
  String username = '';
  String email = '';
  bool subscriptionActive = false;
  String image = '';
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  MyAppState createState() => MyAppState();
}

class MyAppState extends State<MyApp> {
  final scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();
  late StreamSubscription _intentSub;
  final ValueNotifier<bool> isLoggedIn = ValueNotifier(false);
  String sharedText = '';
  Api? api;
  UserInfo userInfo = UserInfo();

  Future<void> checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    String? domain = prefs.getString('domain');
    String? email = prefs.getString('email');
    String? password = prefs.getString('password');

    if (domain == null || email == null || password == null) {
      return;
    }

    if (domain == '' || email == '' || password == '') {
      return;
    }

    api = Api(
      domain: domain,
      email: email,
      password: password,
    );

    try {
      bool loginSuccessful = await api!.login();
      if (loginSuccessful) {
        loadUserInfo();
        isLoggedIn.value = true;
      }
    } catch (e) {
      scaffoldMessengerKey.currentState?.showSnackBar(
        SnackBar(
          content: Text('Error logging in: $e'),
        ),
      );
    }
  }

  Future<void> loadUserInfo() async {
    api!.get('/users/{userId}').then((value) {
      userInfo.id = value['response']['id'];
      userInfo.name = value['response']['name'];
      userInfo.username = value['response']['username'];
      userInfo.email = value['response']['email'];
      userInfo.subscriptionActive = value['response']['subscription']['active'];
      userInfo.image = value['response']['image'];
    });
  }

  @override
  void initState() {
    super.initState();

    if (Platform.isAndroid) {
      // Listen to media sharing coming from outside the app while the app is in the memory.
      _intentSub = ReceiveSharingIntent.getMediaStream().listen((value) {
        if (value.isNotEmpty) {
          setState(() {
            sharedText = value[0].path;
          });
        }
      }, onError: (err) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error with Share: $err"),
          ),
        );
      });

      // Get the media sharing coming from outside the app while the app is closed.
      ReceiveSharingIntent.getInitialMedia().then((value) {
        if (value.isNotEmpty) {
          setState(() {
            sharedText = value[0].path;

            // Tell the library that we are done processing the intent.
            ReceiveSharingIntent.reset();
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Provider<MyAppState>.value(
      value: this,
      child: FutureBuilder(
        future: checkLoginStatus(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
              return const Spinner();
          } else {
            return ValueListenableBuilder<bool>(
              valueListenable: isLoggedIn,
              builder: (context, isLoggedIn, _) {
                return MaterialApp(
                  theme: ThemeData.dark(),
                  home: ScaffoldMessenger(
                    key: scaffoldMessengerKey,
                    child: isLoggedIn
                        ? (
                          (sharedText != '')
                            ? const NewLinkScreen()
                            : const DashboardScreen()
                          )
                        : LoginScreen(
                            onLogin: handleSaveSettings,
                          ),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }

  void handleSaveSettings(String domain, String email, String password) async {
    api = Api(
      domain: domain,
      email: email,
      password: password,
    );
    if (domain != '' && email != '' && password != '') {
      try {
        scaffoldMessengerKey.currentState?.showSnackBar(
          const SnackBar(
            content: Text('Trying log in...'),
            duration: Duration(seconds: 2),
          ),
        );

        bool loginSuccessful = await api!.login();
        if (loginSuccessful) {
          SharedPreferences.getInstance().then((prefs) {
            prefs.setString('domain', domain);
            prefs.setString('email', email);
            prefs.setString('password', password);
          });
          loadUserInfo();
          isLoggedIn.value = true;
        }
      } catch (e) {
        scaffoldMessengerKey.currentState?.showSnackBar(
          SnackBar(
            content: Text(e.toString()),
          ),
        );
      }
    }
  }

  void logout() {
    SharedPreferences.getInstance().then((prefs) {
      prefs.remove('domain');
      prefs.remove('email');
      prefs.remove('password');
    });
    api = null;
    isLoggedIn.value = false;
  }
}
