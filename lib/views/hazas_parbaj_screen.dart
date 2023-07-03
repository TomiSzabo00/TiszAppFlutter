import 'package:flutter/material.dart';

class HazasParbajScreen extends StatefulWidget {
  HazasParbajScreen({Key? key}) : super(key: key);

  @override
  HazasParbajScreenState createState() => HazasParbajScreenState();
}

class HazasParbajScreenState extends State<HazasParbajScreen> {
  // @override
  // void initStatte() {
  //   super.initState();
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Házaspárbaj'),
      ),
    );
  }
}
