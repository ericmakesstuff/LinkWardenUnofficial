import 'package:flutter/material.dart';
import 'package:linkwarden/MyApp.dart';
import 'package:linkwarden/components/AppDrawer.dart';
import 'package:linkwarden/components/Spinner.dart';
import 'package:linkwarden/screens/CollectionLinksScreen.dart';
import 'package:provider/provider.dart';

class CollectionsScreen extends StatelessWidget {
  const CollectionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Get the Api instance from the provider
    final api = Provider.of<MyAppState>(context, listen: false).api;
    var userInfo = Provider.of<MyAppState>(context, listen: false).userInfo;

    return Scaffold(
        appBar: AppBar(
          title: const Text('Collections'),
        ),
        // Side bar
        drawer: AppDrawer(userInfo: userInfo),
        body: FutureBuilder(
          future: api!.get('/collections'),
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Spinner();
            } else {
              if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              } else {
                List<dynamic> items = snapshot.data['response'];
                return ListView.builder(
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    return Container(
                      margin: const EdgeInsets.all(8.0),
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(255, 47, 47, 47), // Lighten the background
                        borderRadius: BorderRadius.circular(10), // Rounded border
                      ),
                      child: ListTile(
                        title: Text('${items[index]['name']} (${items[index]['_count']['links']})', style: const TextStyle(fontSize: 20), overflow: TextOverflow.ellipsis, maxLines: 1),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => CollectionLinksScreen(collectionId: items[index]['id'], collectionName: items[index]['name']),
                            ),
                          );
                        },
                      ),
                    );
                  },
                );
              }
            }
          },
        ));
  }
}
