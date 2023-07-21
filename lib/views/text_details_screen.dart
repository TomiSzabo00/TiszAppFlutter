// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tiszapp_flutter/models/user_data.dart';

import '../models/text_data.dart';
import '../viewmodels/texts_viewmodel.dart';

class TextDetailsScreen extends StatefulWidget {
  TextDetailsScreen({super.key, required this.text});
  final TextData text;
  final UserData authorDetails = UserData.empty();

  @override
  State<TextDetailsScreen> createState() => TextDetailsScreenState();
}

class TextDetailsScreenState extends State<TextDetailsScreen> {
  @override
  void initState() {
    super.initState();
    Provider.of<TextsViewModel>(context, listen: false)
        .getSelectedText(widget.text, widget.authorDetails);
  }

  @override
  Widget build(BuildContext context) {
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
                    Row(
                      children: [
                        SelectableText(
                          'Feltöltő: ${widget.authorDetails.name}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        ),
                      ],
                    ),
                    const Row(
                      children: [
                        Text(
                          'Szöveg:',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Flexible(
                          child: SelectableText(
                            widget.text.text,
                            style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                                overflow: TextOverflow.visible),
                          ),
                        ),
                      ],
                    ),
                  ]),
            )));
  }
}
