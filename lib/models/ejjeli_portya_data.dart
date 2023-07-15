import 'dart:developer';
import 'dart:ffi';

import 'package:firebase_database/firebase_database.dart';
import 'package:tiszapp_flutter/helpers/try_cast.dart';

class LatitudeLongitude {
  final double latitude;
  final double longitude;

  LatitudeLongitude({
    required this.latitude,
    required this.longitude,
  });

  LatitudeLongitude.fromJson(Map<String, dynamic> json)
      : latitude = json['latitude'],
        longitude = json['longitude'];

  Map<String, dynamic> toJson() => {
    'latitude': latitude,
    'longitude': longitude,
  };
}

class EjjeliPortyaGyerekData {
  final String id;
  late LatitudeLongitude location;

  EjjeliPortyaGyerekData({
    required this.id,
    required this.location,
  });

  EjjeliPortyaGyerekData.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        location = json['location'];

  Map<String, dynamic> toJson() => {
    'id': id,
    'location': location,
  };
  
  EjjeliPortyaGyerekData.fromSnapshot(DataSnapshot snapshot, this.id)
  {
    location = LatitudeLongitude(
        latitude: tryCast<double>(snapshot.child("lat").value ?? 0.0)!,
        longitude: tryCast<double>(snapshot.child("long").value ?? 0.0)!);
  }
}

class EjjeliPortyaCsapatData {
  final int team;
  late List<EjjeliPortyaGyerekData> gyerekData;

  EjjeliPortyaCsapatData({
    required this.team,
    required this.gyerekData,
  });

  EjjeliPortyaCsapatData.fromJson(Map<String, dynamic> json)
      : team = json['team'],
        gyerekData = json['gyerekData'];

  Map<String, dynamic> toJson() =>
      {
        'team': team,
        'gyerekData': gyerekData,
      };

  EjjeliPortyaCsapatData.fromSnapshot(DataSnapshot snapshot, this.team)
  {
    gyerekData = List<EjjeliPortyaGyerekData>.empty(growable: true);
    for (var child in snapshot.children) {
      gyerekData.add(
          EjjeliPortyaGyerekData.fromSnapshot(child, child.key ?? ""));
    }
  }
}

class EjjeliPortyaData {
  late List<EjjeliPortyaCsapatData> csapatData;

  EjjeliPortyaData({
    required this.csapatData,
  });

  List<EjjeliPortyaCsapatData> getCsapatData() {
    return csapatData;
  }

  EjjeliPortyaData.fromJson(Map<String, dynamic> json)
      : csapatData = json['csapatData'];

  Map<String, dynamic> toJson() =>
      {
        'csapatData': csapatData,
      };

  EjjeliPortyaData.fromSnapshot(DataSnapshot snapshot)
  {
    csapatData = List<EjjeliPortyaCsapatData>.empty(growable: true);
    for (var child in snapshot.children) {
      csapatData.add(
          EjjeliPortyaCsapatData.fromSnapshot(child, int.parse(child.key.toString())));
    }
  }
}
