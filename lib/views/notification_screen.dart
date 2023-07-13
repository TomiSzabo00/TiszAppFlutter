import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tiszapp_flutter/viewmodels/notification_viewmodel.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({Key? key}) : super(key: key);

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  @override
  void initState() {
    super.initState();
    Provider.of<NotificationViewModel>(context, listen: false).initSwitches();
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<NotificationViewModel>();
    return Scaffold(
        appBar: AppBar(title: const Text('Értesítések')),
        body: Column(
          children: [
            const SizedBox(height: 20),
            const Text('Értesítés küldése', style: TextStyle(fontSize: 20)),
            const SizedBox(height: 20),
            TextField(
              controller: viewModel.titleController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Értesítés címe',
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: viewModel.bodyController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Értesítés szövege',
              ),
            ),
            const SizedBox(height: 20),
            const Text('Kiknek akarod elküldeni?',
                style: TextStyle(fontSize: 16)),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                const Text('Táborozók'),
                Switch(
                  value: true,
                  onChanged: (value) {},
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                const Text('Szervezők'),
                Switch(
                  value: true,
                  onChanged: (value) {},
                ),
              ],
            ),
          ],
        ));
  }
}
