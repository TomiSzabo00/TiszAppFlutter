import 'package:flutter/material.dart';
import 'package:tiszapp_flutter/viewmodels/texts_viewmodel.dart';
import 'package:tiszapp_flutter/widgets/3d_button.dart';

class UploadTextsScreen extends StatelessWidget {
  UploadTextsScreen({super.key});

  final titleController = TextEditingController();
  final textController = TextEditingController();
  final TextsViewModel _viewModel = TextsViewModel();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Szövegek feltöltése"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          children: [
            TextField(
              controller: titleController,
              maxLines: 1,
              decoration: InputDecoration(
                labelText: "Cím",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            TextField(
              controller: textController,
              minLines: 3,
              maxLines: null,
              autocorrect: false,
              keyboardType: TextInputType.multiline,
              decoration: const InputDecoration(
                hintText: "Szöveg",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                ),
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Button3D(
                  onPressed: () {
                    _viewModel.uploadText(
                        titleController.text, textController.text);
                    _clearFields();
                    _showDialog(context);
                  },
                  child: const Text("Feltöltés"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _clearFields() {
    titleController.clear();
    textController.clear();
  }

  void _showDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Sikeres feltöltés"),
          content: const Text("A szöveg sikeresen feltöltésre került."),
          actions: [
            TextButton(
              child: const Text("OK"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
