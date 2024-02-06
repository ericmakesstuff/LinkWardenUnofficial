
import 'package:flutter/material.dart';
import 'package:linkwarden/models/Link.dart';
import 'package:html_unescape/html_unescape.dart';
import 'package:url_launcher/url_launcher.dart';

class LinkCard extends StatelessWidget {
  const LinkCard({
    Key? key,
    required this.link,
  }) : super(key: key);

  final Link link;

  Future<void> _launchUrl() async {
    if (!await launchUrl(Uri.parse(link.url))) {
      throw Exception('Could not launch ${link.url}');
    }
  }

  @override
  Widget build(BuildContext context) {
    var unescape = HtmlUnescape();
    return InkWell(
      onTap: () async {
        await _launchUrl();
      },
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15), // Increase corner radius
        ),
        clipBehavior: Clip.antiAlias,
        child: Container(
          color: const Color.fromARGB(255, 47, 47, 47), // Lighten the background
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              //Image.network('https://cloud.linkwarden.app/${link.image}'),
              const SizedBox(height: 10),
              Flexible(
                child: Text(
                  link.description == ''
                    ? link.linkDomain
                    : unescape.convert(link.description),
                  style: const TextStyle(fontSize: 20),
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: <Widget>[
                  const Icon(Icons.link),
                  const SizedBox(width: 5),
                  Text(link.linkDomain),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
