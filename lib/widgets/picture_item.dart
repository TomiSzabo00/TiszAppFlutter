import 'package:flutter/material.dart';
import 'package:tiszapp_flutter/models/pics/picture_data.dart';

class PictureItem extends StatelessWidget {
  const PictureItem({
    super.key,
    required this.pic,
    required this.isReview,
  });

  final Picture pic;
  final bool isReview;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        // TODO: show details screen
      },
      child: Card(
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
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(Icons.wifi_off);
                },
                loadingBuilder: (context, child, loadingProgress) {
                  return const Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(),
                    ],
                  );
                },
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
      ),
    );
  }
}
