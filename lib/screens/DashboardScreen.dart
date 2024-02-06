import 'package:flutter/material.dart';
import 'package:linkwarden/MyApp.dart';
import 'package:linkwarden/components/AppDrawer.dart';
import 'package:linkwarden/components/DataSearch.dart';
import 'package:linkwarden/components/LinkCard.dart';
import 'package:linkwarden/components/Spinner.dart';
import 'package:linkwarden/models/Link.dart';
import 'package:linkwarden/screens/CollectionsScreen.dart';
import 'package:linkwarden/screens/NewLinkScreen.dart';
import 'package:linkwarden/screens/SearchResultScreen.dart';
import 'package:linkwarden/screens/TagsScreen.dart';
import 'package:provider/provider.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final api = Provider.of<MyAppState>(context, listen: false).api;
    var userInfo = Provider.of<MyAppState>(context, listen: false).userInfo;

    void performSearch(String searchTerm) {
      if (searchTerm != '') {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SearchResultScreen(searchTerm: searchTerm),
          ),
        );
      }
    }

    return Scaffold(
        appBar: AppBar(
          title: const Text('LinkWarden Dashboard'),
          actions: <Widget>[
            Builder(
              builder: (context) => IconButton(
                icon: const Icon(Icons.search),
                onPressed: () async {
                  await showSearch(
                    context: context,
                    delegate: DataSearch(searchAction: performSearch),
                  );
                },
              ),
            ),
          ],
        ),
        // Side bar
        drawer: AppDrawer(userInfo: userInfo),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const NewLinkScreen(),
              ),
            );
          },
          backgroundColor: const Color.fromRGBO(102, 51, 153, 1),
          foregroundColor: const Color.fromRGBO(167, 139, 250, 1),
          tooltip: 'Add Link',
          child: const Icon(Icons.add),
        ),
        body: FutureBuilder(
          future: api!.get('/dashboard'),
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Spinner();
            } else {
              if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              } else {
                List<dynamic> items = snapshot.data['response'];
                List<Link> links = items.map((jsonItem) => Link.fromJson(jsonItem)).toList();
                return Padding(
                  padding: const EdgeInsets.all(0.0),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              margin: const EdgeInsets.all(4.0),
                              child: InkWell(
                                onTap: () async {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => const CollectionsScreen()),
                                  );
                                },
                                child: Card(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15), // Increase corner radius
                                  ),
                                  clipBehavior: Clip.antiAlias,
                                  child: Container(
                                    color: const Color.fromARGB(255, 47, 47, 47), // Lighten the background
                                    padding: const EdgeInsets.all(10),
                                    child: const Center(
                                      child: Text(
                                        'Collections',
                                        style: TextStyle(fontSize: 18),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: Container(
                              margin: const EdgeInsets.all(4.0),
                              child: InkWell(
                                onTap: () async {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => const TagsScreen()),
                                  );
                                },
                                child: Card(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15), // Increase corner radius
                                  ),
                                  clipBehavior: Clip.antiAlias,
                                  child: Container(
                                    color: const Color.fromARGB(255, 47, 47, 47), // Lighten the background
                                    padding: const EdgeInsets.all(10),
                                    child: const Center(
                                      child: Text(
                                        'Tags',
                                        style: TextStyle(fontSize: 18),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      Expanded(
                        child: GridView.builder(
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: (MediaQuery.of(context).size.width / 600).floor() + 1,
                            childAspectRatio: 2.5,
                            crossAxisSpacing: 10, // Add horizontal spacing
                            mainAxisSpacing: 10,
                          ),
                          itemCount: links.length,
                          itemBuilder: (context, index) {
                            return LinkCard(link: links[index]);
                          },
                        ),
                      ),
                    ],
                  ),
                );
              }
            }
          },
        ));
  }
}
