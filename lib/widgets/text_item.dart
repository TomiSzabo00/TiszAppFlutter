import 'package:flutter/material.dart';
import 'package:tiszapp_flutter/models/text_data.dart';

class TextItem extends StatelessWidget {
  final TextData text;

  const TextItem({Key? key, required this.text}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      clipBehavior: Clip.hardEdge,
      child: Column(
        children: [
          SizedBox(
            width: double.infinity,
            height: (MediaQuery.of(context).size.width - 10) / 5,
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: SelectableText(text.text),
            ),
          ),
          const Divider(
            height: 1,
            thickness: 1,
          ),
          SizedBox(
            width: double.infinity,
            height: (MediaQuery.of(context).size.width - 10) / 10,
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Text(text.title),
            ),
          ),
          const Spacer(),
        ],
      ),
    );
  }
}
