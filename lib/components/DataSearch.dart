import 'package:flutter/material.dart';

class DataSearch extends SearchDelegate<String> {
  final Function searchAction;

  DataSearch({required this.searchAction});

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
      IconButton(
        icon: const Icon(Icons.search),
        onPressed: () {
          searchAction(query);
        },
      ),
    ];
  }

  @override
  void showResults(BuildContext context) {
    searchAction(query);
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: AnimatedIcon(
        icon: AnimatedIcons.menu_arrow,
        progress: transitionAnimation,
      ),
      onPressed: () {
        close(context, '');
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return Container();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return Container();
  }
}
