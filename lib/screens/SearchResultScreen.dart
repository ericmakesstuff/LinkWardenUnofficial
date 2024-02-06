import 'package:flutter/material.dart';
import 'package:linkwarden/MyApp.dart';
import 'package:linkwarden/components/AppDrawer.dart';
import 'package:linkwarden/components/LinkCard.dart';
import 'package:linkwarden/components/Spinner.dart';
import 'package:linkwarden/models/Link.dart';
import 'package:provider/provider.dart';

class SearchResultScreen extends StatelessWidget {
  final String searchTerm;

  const SearchResultScreen({Key? key, required this.searchTerm}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Get the Api instance from the provider
    final api = Provider.of<MyAppState>(context, listen: false).api;
    var userInfo = Provider.of<MyAppState>(context, listen: false).userInfo;

    return Scaffold(
        appBar: AppBar(
          title: Text('Search: $searchTerm'),
        ),
        // Side bar
        drawer: AppDrawer(userInfo: userInfo),
        body: FutureBuilder(
          future: api!.get('/links?sort=0&searchByName=true&searchByUrl=true&searchByDescription=true&searchByTags=true&searchByTextContent=true&searchQueryString=$searchTerm'),
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
                  padding: const EdgeInsets.all(8.0),
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
                );
              }
            }
          },
        ));
  }
}
