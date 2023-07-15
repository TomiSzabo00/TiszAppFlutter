import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

import '../viewmodels/ejjeli_portya_viewmodel.dart';

class EjjeliPortyaScreen extends StatefulWidget {
  const EjjeliPortyaScreen({super.key});

  @override
  State<EjjeliPortyaScreen> createState() => _EjjeliPortyaState();
}

class _EjjeliPortyaState extends State<EjjeliPortyaScreen> {

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    final viewModel = context.watch<EjjeliPortyaViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Maps'),
        elevation: 2,
        actions: <Widget>[
          IconButton(
            icon: Icon(
              Icons.refresh,
              color: Colors.white,
            ),
            onPressed: () async {
              if (await _handleLocationPermission()) {
                viewModel.updateLocationCore();
              }
            },
          )
        ],
      ),

    );
  }

  Future<bool> _handleLocationPermission() async {
    bool serviceEnabled;
    PermissionStatus permission;
    final messenger = ScaffoldMessenger.of(context);

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      log("Location services are disabled.");
      messenger.showSnackBar(const SnackBar(content: Text('Location services are disabled.')));
      return false;
    }
    permission = await Permission.location.request();
    if (permission == PermissionStatus.denied) {
      log("Location permissions are denied.");
      permission = await Permission.location.request();
      if (permission == PermissionStatus.denied) {
        log("Location permissions are denied (2).");
        messenger.showSnackBar(
            const SnackBar(content: Text('Location permissions are denied')));
        return false;
      }
    }
    if (permission == PermissionStatus.permanentlyDenied) {
      log("Location permissions are permanently denied, we cannot request permissions.");
      messenger.showSnackBar(const SnackBar(
          content: Text('Location permissions are permanently denied, we cannot request permissions.')));
      return false;
    }
    return true;
  }
}