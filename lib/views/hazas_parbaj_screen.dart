import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:provider/provider.dart';
import 'package:tiszapp_flutter/viewmodels/hazas_parbaj_viewmodel.dart';
import 'package:tiszapp_flutter/widgets/3d_button.dart';
import 'package:tiszapp_flutter/colors.dart';

class HazasParbajScreen extends StatefulWidget {
  const HazasParbajScreen({super.key, required this.isAdmin});

  final bool isAdmin;

  @override
  HazasParbajScreenState createState() => HazasParbajScreenState();
}

class HazasParbajScreenState extends State<HazasParbajScreen> {
  void initStatte() {
    Provider.of<HazasParbajViewModel>(context, listen: false)
        .subscribeToUserChanges();
  }

  @override
  Widget build(BuildContext context) {
    final viewmodel = context.watch<HazasParbajViewModel>();
    final isDarkTheme = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Házaspárbaj'),
      ),
      body: Padding(
          padding: EdgeInsets.all(20.0),
          child: Column(
            children: <Widget>[
              const SizedBox(
                  width: double.infinity,
                  child: Text(
                    'Akik már jelentkeztek:',
                    style: TextStyle(fontSize: 16.0),
                  )),
              const SizedBox(height: 20.0),
              Expanded(child: () {
                if (viewmodel.signedUpPairs.isEmpty) {
                  return const Center(
                      child: Text('Még senki sem jelentkezett!',
                          style: TextStyle(fontSize: 20.0)));
                } else {
                  return ListView.builder(
                    itemCount: viewmodel.signedUpPairs.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        title: Text(viewmodel.signedUpPairs[index].name1),
                      );
                    },
                  );
                }
              }()),
              const SizedBox(height: 20.0),
              Button3D(
                onPressed: () => _showSignUpModalSheet(viewmodel, isDarkTheme),
                child: Text(
                  'Jelentkezés',
                  style: TextStyle(
                    color: isDarkTheme
                        ? CustomColor.btnTextNight
                        : CustomColor.btnTextDay,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          )),
    );
  }

  void _showSignUpModalSheet(HazasParbajViewModel vm, bool isDarkTheme) {
    bool showError = false;
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.0),
      ),
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(builder: (context, setState) {
          return Padding(
              padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom,
                  top: 20,
                  left: 20,
                  right: 20),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Jelentkezés',
                      style: TextStyle(fontSize: 16.0),
                    ),
                    const SizedBox(height: 20.0),
                    const Text(
                      'Add meg a saját és a párod nevét, valamint a csapatotok számát!',
                      style: TextStyle(fontSize: 16.0),
                    ),
                    const SizedBox(height: 20.0),
                    TextField(
                      controller: vm.name1Controller,
                      decoration: InputDecoration(
                        labelText: 'Saját neved',
                        errorText: showError ? 'Kötelező mező!' : null,
                        border: const OutlineInputBorder(),
                      ),
                      onSubmitted: (value) =>
                          FocusManager.instance.primaryFocus?.unfocus(),
                      onChanged: (_) {
                        setState(() {
                          showError = false;
                        });
                      },
                      maxLength: 20,
                      autocorrect: false,
                    ),
                    const SizedBox(height: 20.0),
                    TextField(
                      controller: vm.name2Controller,
                      decoration: InputDecoration(
                        labelText: 'Párod neve',
                        errorText: showError ? 'Kötelező mező!' : null,
                        border: const OutlineInputBorder(),
                      ),
                      onSubmitted: (value) =>
                          FocusManager.instance.primaryFocus?.unfocus(),
                      onChanged: (_) {
                        setState(() {
                          showError = false;
                        });
                      },
                      maxLength: 20,
                      autocorrect: false,
                    ),
                    const SizedBox(height: 20.0),
                    TextField(
                      controller: vm.teamController,
                      decoration: InputDecoration(
                        labelText: 'Csapat száma (1-4)',
                        errorText: showError ? 'Kötelező mező!' : null,
                        border: const OutlineInputBorder(),
                      ),
                      onSubmitted: (value) =>
                          FocusManager.instance.primaryFocus?.unfocus(),
                      onChanged: (_) {
                        setState(() {
                          showError = false;
                        });
                      },
                      maxLength: 1,
                      autocorrect: false,
                    ),
                    const SizedBox(height: 20.0),
                    Button3D(
                        width: 140,
                        onPressed: () async {
                          final shouldShowError = await vm.signUp();
                          setState(() {
                            showError = shouldShowError;
                          });
                          if (!showError) Navigator.pop(context);
                        },
                        child: Text(
                          'Jelentkezés',
                          style: TextStyle(
                            color: isDarkTheme
                                ? CustomColor.btnTextNight
                                : CustomColor.btnTextDay,
                            fontWeight: FontWeight.bold,
                          ),
                        ))
                  ],
                ),
              ));
        });
      },
    );
  }
}
