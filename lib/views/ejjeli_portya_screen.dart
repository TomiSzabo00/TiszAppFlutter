import 'dart:developer';
import 'dart:ffi';

import 'package:battery_info/battery_info_plugin.dart';
import 'package:battery_info/enums/charging_status.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'dart:io' show Platform;


import '../viewmodels/ejjeli_portya_viewmodel.dart';
import '../widgets/3d_button.dart';

class EjjeliPortyaScreen extends StatefulWidget {
  const EjjeliPortyaScreen({super.key});

  @override
  State<EjjeliPortyaScreen> createState() => _EjjeliPortyaState();
}

class _EjjeliPortyaState extends State<EjjeliPortyaScreen> {

  EjjeliPortyaViewModel viewModel = EjjeliPortyaViewModel();

  @override
  void initState() {
    Provider.of<EjjeliPortyaViewModel>(context, listen: false).getData();
    super.initState();
  }

  Future<void> _showMyDialog(EjjeliPortyaViewModel viewModel) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Lokáció Megosztása'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text("Éjjeli Portyához szükség van GPS (lokáció) adatokra.\n\n" +
                    "Ha itt rányomsz az 'Értem'-re, akkor engedélyezheted a lokációd megosztását a háttérben a szervezőkkel a " +
                    "portya ideje alatt lezárt képernyő, illetve az applikáció bezárása mellett is.\n" +
                    "A lokáció megosztását bármikor leállíthatod.\n\n" +
                    "Location data is crucial for the Éjjeli Portya activity.\n\n" +
                    "By clicking on the 'Értem' option, you can allow the sharing of your location data in the background " +
                    "even when your phone's screen is locked or the application has been closed.\n" +
                    "This option can always be disabled"),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Értem'),
              onPressed: () async {
                Navigator.of(context).pop(true);
                if (await _handleLocationPermission()) {
                viewModel.updateLocationCore();
                }
              },
            ),
          ],
        );
      },
    );
  }


  @override
  Widget build(BuildContext context) {

    viewModel = context.watch<EjjeliPortyaViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Éjjeli Portya"),
      ),
      body: Center(
          child: TextButton(
            onPressed: () async {
              if(viewModel.locBackGroundOn) {
                viewModel.stopBackGroundLoc(false);
              }
              else {
                _showMyDialog(viewModel);
              }
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: viewModel.locBackGroundOn ? Colors.red : Colors.green,
            ),
            child: viewModel.locBackGroundOn ?
                    const Text("Megosztás leállítása"):
                    const Text("Lokáció megosztása"),
          )),
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

  @override
  void dispose() {
    viewModel.stopBackGroundLoc(true);
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    viewModel = Provider.of<EjjeliPortyaViewModel>(context, listen: false);
    super.didChangeDependencies();
  }
}