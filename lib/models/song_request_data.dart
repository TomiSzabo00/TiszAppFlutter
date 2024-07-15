class SongRequest {
  String id;
  final String name;
  final String url;
  final DateTime upload;
  final String user;

  SongRequest({required this.id, required this.name, required this.url,required this.upload, required this.user});

  factory SongRequest.fromMap(Map<dynamic, dynamic> map, String id) {
     return SongRequest(
      id: id,
      name: map['name'] as String? ?? 'Unknown name',
      url: map['url'] as String? ?? 'Unknown url',
      upload: DateTime.parse(map['upload']),
      user: map['user'] as String? ?? 'Unknown user',
    );
  }
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'url': url,
      'upload': upload.toIso8601String(),
      'user': user
    };
  }
}