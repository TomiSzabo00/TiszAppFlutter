class Picture {
  String key;
  final String url;
  final String title;
  final String author;

  Picture(
      {this.key = "0",
      required this.url,
      required this.title,
      required this.author});

  factory Picture.fromSnapshot(String key, Map<dynamic, dynamic> snapshot) {
    return Picture(
      key: key,
      url: snapshot['fileName'],
      title: snapshot['title'],
      author: snapshot['author'],
    );
  }
}
