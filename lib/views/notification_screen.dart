import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tiszapp_flutter/viewmodels/notification_viewmodel.dart';
import 'package:tiszapp_flutter/widgets/3d_button.dart';

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
        body: Padding(
          padding: const EdgeInsets.all(20.0),
          child: SingleChildScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                const Text('Értesítés küldése', style: TextStyle(fontSize: 20)),
                const SizedBox(height: 20),
                TextField(
                  controller: viewModel.titleController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Értesítés címe',
                  ),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: viewModel.bodyController,
                  maxLines: 2,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Értesítés szövege',
                  ),
                ),
                const SizedBox(height: 20),
                const Text('Kiknek akarod elküldeni?',
                    style: TextStyle(fontSize: 16)),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Összes táborozó'),
                    Switch(
                      value: viewModel.allUsersSwitch,
                      activeColor: Colors.green,
                      onChanged: (value) {
                        if (value) {
                          viewModel.turnOnAllUsers();
                        } else {
                          viewModel.turnOffAllUsers();
                        }
                      },
                    ),
                  ],
                ),
                Column(
                  children: List.generate(
                    viewModel.switches.length,
                    (index) => Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('${index + 1}. csapat'),
                        Switch(
                          value: viewModel.switches[index],
                          activeColor: Colors.green,
                          onChanged: (value) {
                            viewModel.updateSwitch(index, value);
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Szervezők'),
                    Switch(
                      value: viewModel.adminsSwitch,
                      activeColor: Colors.red,
                      onChanged: (value) {
                        if (value) {
                          viewModel.turnOnAdmins();
                        } else {
                          viewModel.turnOffAdmins();
                        }
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Button3D(
                  onPressed: () async {
                    _showLoadingDialog();
                    await viewModel.sendNotification();
                    // ignore: use_build_context_synchronously
                    Navigator.of(context).pop();
                    _showDialog(viewModel);
                  },
                  child: const Text('Küldés'),
                ),
              ],
            ),
          ),
        ));
  }

  Future<void> _showLoadingDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return const AlertDialog(
          title: Text('Értesítés küldése'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
            ],
          ),
        );
      },
    );
  }

  Future<void> _showDialog(NotificationViewModel viewModel) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(viewModel.alertTitle),
          content: SingleChildScrollView(
            child: (() {
              if (viewModel.error != null) {
                return Text(viewModel.error!);
              } else {
                return const Text('Sikeresen elküldted az értesítést!');
              }
            }()),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Ok'),
              onPressed: () {
                viewModel.dismissAlert();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
