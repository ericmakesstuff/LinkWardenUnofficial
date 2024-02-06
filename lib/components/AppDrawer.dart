import 'package:flutter/material.dart';
import 'package:linkwarden/MyApp.dart';
import 'package:linkwarden/screens/AboutScreen.dart';
import 'package:linkwarden/screens/CollectionsScreen.dart';
import 'package:linkwarden/screens/DashboardScreen.dart';
import 'package:linkwarden/screens/TagsScreen.dart';
import 'package:provider/provider.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({
    super.key,
    required this.userInfo,
  });

  final UserInfo userInfo;

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(
              color: Colors.blue,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                (userInfo.image != '') ? CircleAvatar(
                  backgroundImage: NetworkImage(userInfo.image),
                  radius: 30.0,
                ) : const CircleAvatar(
                  radius: 30.0,
                  child: Icon(Icons.person),
                ),
                const SizedBox(height: 10.0), // Add some spacing
                Text(
                  'Name: ${userInfo.name}',
                  style: const TextStyle(fontSize: 14.0),
                ),
                Text(
                  'Email: ${userInfo.email}',
                  style: const TextStyle(fontSize: 14.0),
                ),
                Text(
                  'Subscription Status: ${userInfo.subscriptionActive ? 'Active' : 'Inactive'}',
                  style: const TextStyle(fontSize: 14.0),
                ),
              ],
            ),
          ),
          ListTile(
            title: const Text('Dashboard'),
            onTap: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const DashboardScreen()),
                (Route<dynamic> route) => false, // Never allow back navigation
              );
            },
          ),
          ListTile(
            title: const Text('Collections'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const CollectionsScreen()),
              );
            },
          ),
          ListTile(
            title: const Text('Tags'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const TagsScreen()),
              );
            },
          ),
          ListTile(
            title: const Text('About / Help'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AboutScreen()),
              );
            },
          ),
          ListTile(
            title: const Text('Logout'),
            onTap: () {
              Provider.of<MyAppState>(context, listen: false).logout();
            },
          ),
        ],
      ),
    );
  }
}
