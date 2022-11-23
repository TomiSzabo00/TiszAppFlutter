class AdminApiData {
  final String name;
  final String id;

  AdminApiData({
    required this.name,
    required this.id,
  });

  factory AdminApiData.fromJson(Map<String, dynamic> json) {
    return AdminApiData(
      name: json['Név'],
      id: json['ID'],
    );
  }
}
