class TextData {
  String key;
  final String title;
  final String text;
  final String author;

  TextData(
      {this.key = "0",
      required this.title,
      required this.text,
      required this.author});

  factory TextData.fromSnapshot(String key, Map<String, dynamic> snapshot) =>
      TextData(
        key: key,
        title: snapshot["title"],
        text: snapshot["text"],
        author: snapshot["author"],
      );

  Map<String, dynamic> toJson() => {
        "title": title,
        "text": text,
        "author": author,
      };
}
