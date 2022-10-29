import 'package:flutter/material.dart';
import 'package:tiszapp_flutter/data/picture_data.dart';

class PictureItem extends StatelessWidget {
  const PictureItem({super.key, required this.pic});

  final Picture pic;

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
            height: 100,
            child: Image.network(
              pic.url,
              fit: BoxFit.fitWidth,
            ),
          ),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Text(pic.title),
          ),
          const Spacer(),
        ],
      ),
    );
  }
}
