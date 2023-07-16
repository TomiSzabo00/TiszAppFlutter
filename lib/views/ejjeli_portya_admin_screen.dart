import 'dart:math';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

import '../viewmodels/ejjeli_portya_viewmodel.dart';

class EjjeliPortyaAdminScreen extends StatefulWidget {
  const EjjeliPortyaAdminScreen({super.key});

  @override
  State<EjjeliPortyaAdminScreen> createState() => _EjjeliPortyaAdminState();
}

class _EjjeliPortyaAdminState extends State<EjjeliPortyaAdminScreen> {

  @override
  void initState() {
    super.initState();
    //Provider.of<EjjeliPortyaViewModel>(context, listen: false).getColors();
    Provider.of<EjjeliPortyaViewModel>(context, listen: false).getDataAdmin(true);
  }

  late GoogleMapController mapController;

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  List<Marker> markers = [];

  @override
  Widget build(BuildContext context) {

    final viewModel = context.watch<EjjeliPortyaViewModel>();

    return Scaffold(
        appBar: AppBar(
          title: const Text('Éjjeli Portya Admin'),
          elevation: 2,
          actions: <Widget>[
            IconButton(
              icon: Icon(
                Icons.refresh,
                color: Colors.white,
              ),
              onPressed: () {
                updateMarkers(viewModel);
              },
            )
          ],
        ),
        body: GoogleMap(
          onMapCreated: _onMapCreated,
          initialCameraPosition: CameraPosition(
            target: viewModel.center,
            zoom: 11.0,
          ),
          markers: Set<Marker>.from(markers)
        ),

      );
  }

  Future<void> updateMarkers(EjjeliPortyaViewModel viewModel)
  async {
    final tmpMarkers = await viewModel.getMarkers();
    setState(() {
      // Update the positions of the markers
      markers = tmpMarkers; // Clear existing markers
    });
  }
}