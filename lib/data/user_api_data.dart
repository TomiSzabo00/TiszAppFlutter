class UserApiData {
  final String name;
  final String teamNum;
  final String id;

  UserApiData({
    required this.name,
    required this.teamNum,
    required this.id,
  });

  factory UserApiData.fromJson(Map<String, dynamic> json) {
    return UserApiData(
      name: json['Név'],
      teamNum: json['Csapat'],
      id: json['ID'],
    );
  }
}
