class TinderData {
  final String name;
  final int teamNum;
  final String? imageUrl;

  TinderData({
    required this.name,
    required this.teamNum,
    this.imageUrl,
  });

  factory TinderData.fromJson(Map<String, dynamic> json) {
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
}
