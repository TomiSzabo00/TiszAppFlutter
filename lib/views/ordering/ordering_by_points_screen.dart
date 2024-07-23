import 'package:flutter/material.dart';

class OrderingByPointsScreen extends StatefulWidget {
  const OrderingByPointsScreen({super.key});

  @override
  OrderingByPointsScreenState createState() => OrderingByPointsScreenState();
}

class OrderingByPointsScreenState extends State<OrderingByPointsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: const Center(
        child: Text("Ordering by points screen"),
      ),
    );
  }
}