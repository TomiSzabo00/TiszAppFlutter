import 'package:flutter/material.dart';

class TinderRegistrationScreen extends StatefulWidget {
  const TinderRegistrationScreen({Key? key}) : super(key: key);

  @override
  TinderRegistrationScreenState createState() => TinderRegistrationScreenState();
}

class TinderRegistrationScreenState extends State<TinderRegistrationScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tinder Registration'),
      ),
      body: const Center(
        child: Text('Tinder Registration Screen'),
      ),
    );
  }
}