import 'dart:async';
import 'dart:developer';
import 'dart:typed_data';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:tiszapp_flutter/models/ejjeli_portya_data.dart';
import 'dart:ui' as ui;
import 'package:location/location.dart';

import '../models/user_data.dart';
import '../services/database_service.dart';

class EjjeliPortyaViewModel with ChangeNotifier {
  EjjeliPortyaData data = EjjeliPortyaData(csapatData: List.empty(growable: true));

  UserData user = UserData(uid: "", name: "", isAdmin: false, teamNum: -1);

  final LatLng _center = const LatLng(47.220617, 20.298267);
  final List<BitmapDescriptor> colorList = List<BitmapDescriptor>.empty(growable: true);

  LatLng get center => _center;

  bool locSettingsSet = false;
  late StreamSubscription<Position> locationSubscription;

  void getData() async {
    final databaseref = FirebaseDatabase.instance.ref().child(
        'ejjeli_porty_locs');
    databaseref.onValue.listen((event) {
      data = EjjeliPortyaData.fromSnapshot(event.snapshot);
    });
    if (user.uid.isEmpty) {
      user = await DatabaseService.getUserData(
          FirebaseAuth.instance.currentUser!.uid);
    }
    notifyListeners();
  }

/*  Future<void> updateLocationCore() async {
    log("Updating location");
    final positionStream = Geolocator.getPositionStream(locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.best,
        distanceFilter: 0,
        timeLimit: Duration(seconds: 20),));
    if(user.uid.isEmpty) {
      user = await DatabaseService.getUserData(FirebaseAuth.instance.currentUser!.uid);
    }
    locationSubscription = positionStream.listen((Position position) {
      final ref = FirebaseDatabase.instance.ref().child(
          'ejjeli_porty_locs/${user.teamNum.toString()}/${user.uid}');
      ref.set({
        'lat': position.latitude,
        'long': position.longitude
      });
    });
  }*/

  Future<void> updateLocationCore() async {

    if(user.uid.isEmpty) {
      user = await DatabaseService.getUserData(FirebaseAuth.instance.currentUser!.uid);
    }

    Location location = Location();

    bool _serviceEnabled;
    PermissionStatus _permissionGranted;
    LocationData _locationData;

    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        log("faszkivan");
        return;
      }
    }

    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return;
      }
    }
    final res = await location.enableBackgroundMode(enable: true);
    log(res.toString());
    location.onLocationChanged.listen((LocationData currentLocation) {
      final ref = FirebaseDatabase.instance.ref().child(
          'ejjeli_porty_locs/${user.teamNum.toString()}/${user.uid}');
      ref.set({
        'lat': currentLocation.latitude,
        'long': currentLocation.longitude
      });
    });
  }

  pauseLocation() async {
    locationSubscription.pause();
  }

  @override
  void dispose() {
    //locationSubscription.cancel();
    super.dispose();
  }

  Future<int> getNumberOfTeams() async {
    final num = await DatabaseService.getNumberOfTeams();
    return num;
  }

  Future<double> getColor(int team) async {
    final colorStr = await FirebaseDatabase.instance.ref().child(
        'colors/colors/${team.toString()}').get();
    Color color = Color(
        int.parse(colorStr.value.toString().substring(1, 7), radix: 16) +
            0xFF000000);
    final hsvColor = HSVColor.fromColor(color);
    return hsvColor.hue;
  }

  /*void getColors() async {
    final num = await getNumberOfTeams();
    for(int i = 0; i <= num; i++)
    {
      final color = await getColor(i);
      colorList.add(color);
    }
  }*/

  Future<List<Marker>> getMarkers() async {
    getData();
    final markers = List<Marker>.empty(growable: true);
    for (EjjeliPortyaCsapatData data in data.csapatData) {
      if (data.team > await getNumberOfTeams()) {
        continue;
      }
      for (EjjeliPortyaGyerekData gyerekData in data.gyerekData) {
        markers.add(
          Marker(
              markerId: MarkerId(gyerekData.id.toString()),
              position: LatLng(gyerekData.location.latitude,
                  gyerekData.location.longitude), // New marker position
              infoWindow: InfoWindow(title: gyerekData.id),
              icon: BitmapDescriptor.defaultMarkerWithHue(
                  await getColor(data.team))
          ),
        );
      }
    }
    return markers;
  }

}