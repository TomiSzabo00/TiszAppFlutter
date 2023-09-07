class TinderData {
  final String name;
  final int teamNum;
  final String? imageUrl;

  TinderData({
    required this.name,
    required this.teamNum,
    this.imageUrl,
  });

  factory TinderData.fromJson(Map<dynamic, dynamic> json) {
    return TinderData(
      name: json['name'] as String,
      teamNum: json['teamNum'] as int,
      imageUrl: json['imageUrl'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'teamNum': teamNum,
      'imageUrl': imageUrl,
    };
  }

  @override
  // ignore: hash_and_equals
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is TinderData &&
        other.name == name &&
        other.teamNum == teamNum &&
        other.imageUrl == imageUrl;
  }
}
