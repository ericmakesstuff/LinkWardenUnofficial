class Link {
  final int id;
  final String name;
  final String type;
  final int collectionId;
  final String url;
  final String textContent;
  final String image;
  final DateTime createdAt;
  final String description;
  final String linkDomain;

  Link({
    required this.id,
    required this.name,
    required this.type,
    required this.collectionId,
    required this.url,
    required this.textContent,
    required this.image,
    required this.createdAt,
    required this.description,
    required this.linkDomain,
  });

  factory Link.fromJson(Map<String, dynamic> json) {
    return Link(
      id: json['id'],
      name: json['name'],
      type: json['type'],
      collectionId: json['collectionId'],
      url: json['url'],
      textContent: json['textContent'] ?? '',
      image: json['image'] ?? '',
      createdAt: DateTime.parse(json['createdAt']),
      description: json['description'] ?? '',
      linkDomain: Uri.parse(json['url']).host,
    );
  }
}
