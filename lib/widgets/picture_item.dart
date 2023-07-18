import 'package:flutter/material.dart';
import 'package:tiszapp_flutter/models/pics/picture_data.dart';
import 'package:tiszapp_flutter/views/pics/picture_details_screen.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:super_banners/super_banners.dart';

class PictureItem extends StatelessWidget {
  const PictureItem({
    super.key,
    required this.pic,
    required this.isReview,
    required this.isAdmin,
  });

  final Picture pic;
  final bool isReview;
  final bool isAdmin;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                PictureDetailsScreen(picture: pic, isReview: isReview),
          ),
        );
      },
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        clipBehavior: Clip.hardEdge,
        child: Stack(
          alignment: Alignment.topRight,
          children: [
            Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  height: 100,
                  child: CachedNetworkImage(
                    imageUrl: pic.url,
                    fit: BoxFit.fitWidth,
                    placeholder: (context, url) => const Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(),
                      ],
                    ),
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
            () {
              if (pic.isPicOfTheDay) {
                return const CornerBanner(
                  bannerPosition: CornerBannerPosition.topRight,
                  bannerColor: Colors.red,
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 2.0),
                    child: Text(
                      "Nap képe",
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                );
              } else {
                return const SizedBox();
              }
            }(),
          ],
        ),
      ),
    );
  }
}
