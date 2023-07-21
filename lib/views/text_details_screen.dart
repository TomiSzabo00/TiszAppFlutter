import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tiszapp_flutter/models/text_data.dart';
import 'package:tiszapp_flutter/viewmodels/texts_viewmodel.dart';

class TextDetailsScreen extends StatefulWidget {
  const TextDetailsScreen({
    super.key,
    required this.text,
  });
  final TextData text;

  @override
  State<TextDetailsScreen> createState() => TextDetailsScreenState();
}

class TextDetailsScreenState extends State<TextDetailsScreen> {
  @override
  void initState() {
    super.initState();
    Provider.of<TextsViewModel>(context, listen: false)
        .getSelectedText(widget.text);
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<TextsViewModel>();
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.text.title),
        ),
        body: Padding(
            padding: const EdgeInsets.all(20.0),
            child: SingleChildScrollView(
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Feltöltő: ${viewModel.authorDetails.name}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Text(
                      'Csapat: ${viewModel.authorDetails.teamNum}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    const Text(
                      'Szöveg:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    SelectableText(
                      widget.text.text,
                      style: const TextStyle(
                          fontSize: 14, overflow: TextOverflow.visible),
                    ),
                  ]),
            )));
  }
}
