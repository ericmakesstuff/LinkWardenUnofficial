import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutScreen extends StatelessWidget {
  final List<String> items = [
    'Pagination for Collections/Tags/Search',
    'Multiple Tags for a Link',
    'Editing Links (Title, Description, Tags, Collection)',
    'Editing Collections/Tags',
    'Deleting Links/Collections/Tags',
    'Link Image (I tried, LinkWarden is blocking, but I\'ll keep trying)',
  ];

  AboutScreen({super.key});

  Future<void> _launchUrl(url) async {
    if (!await launchUrl(Uri.parse(url))) {
      throw Exception('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('About'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const Text(
              'This is NOT an official app for LinkWarden. I am just a user who wanted an app. There wasn\'t one, so I made one. I hope you find it useful.',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            const Text(
              'I am aware that not all features are present. I mostly focused on getting the app to work for my use case, which was sharing URLs to create new links, seeing my recent links, and searching. I will keep trying to improve it as I have time. If you have any feature requests, please let me know. I will do my best to add them. I am also open to pull requests on GitHub.',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 26),
            InkWell(
              onTap: () {
                _launchUrl('https://github.com/ericmakesstuff/LinkWardenUnofficial');
              },
              child: Image.asset(
                'assets/images/github.png',
                height: 100,
              ),
            ),
            const SizedBox(height: 26),
            const Text(
              'To-Do List:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: items.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(items[index]),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
