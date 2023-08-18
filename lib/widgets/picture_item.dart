import 'package:flutter/material.dart';
import 'package:flutter_boxicons/flutter_boxicons.dart';
import 'package:readmore/readmore.dart';
import 'package:tiszapp_flutter/models/pics/picture_data.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:tiszapp_flutter/viewmodels/pictures_viewmodel.dart';

class PictureItem extends StatefulWidget {
  PictureItem({
    super.key,
    required this.pic,
    required this.isReview,
    required this.isAdmin,
  });

  final Picture pic;
  final bool isReview;
  final bool isAdmin;

  @override
  State<PictureItem> createState() => PictureItemState();
}

class PictureItemState extends State<PictureItem> {
  final PicturesViewModel viewModel = PicturesViewModel();

  @override
  void initState() {
    super.initState();
    viewModel.loadImageData(widget.pic, widget.isReview);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            authorData(),
            const Spacer(),
            moreOptions(),
          ],
        ),
        CachedNetworkImage(
          imageUrl: widget.pic.url,
          fit: BoxFit.fitWidth,
          placeholder: (context, url) => const Center(
            heightFactor: 5,
            child: CircularProgressIndicator(),
          ),
          errorWidget: (context, url, error) => const Icon(Boxicons.bxs_error),
        ),
        titleData(),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget authorData() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 10.0),
      child: FutureBuilder(
        future: viewModel.getAuthorDetails(widget.pic.author),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final authorDetails = snapshot.data!;
            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      authorDetails.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(authorDetails.teamNumberAsString),
                    dotDivider(),
                    const Text('Meme'),
                    dotDivider(),
                    Text(viewModel.timeStampFromKey(widget.pic.key)),
                  ],
                ),
              ],
            );
          } else {
            return const Text('Betöltés...');
          }
        },
      ),
    );
  }

  Widget titleData() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FutureBuilder(
              future: viewModel.getAuthorDetails(widget.pic.author),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Text('Betöltés...');
                }
                return Text(
                  snapshot.data!.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                );
              }),
          const SizedBox(width: 8),
          Expanded(
            child: ReadMoreText(widget.pic.title,
                trimLines: 1,
                colorClickableText: Colors.grey,
                trimMode: TrimMode.Line,
                trimCollapsedText: ' Több',
                trimExpandedText: ' Kevesebb',
                moreStyle: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
                lessStyle: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                )),
          ),
        ],
      ),
    );
  }

  Widget dotDivider() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 8.0),
      child: Text(
        '•',
        style: TextStyle(
          fontSize: 14,
        ),
      ),
    );
  }

  Widget moreOptions() {
    return PopupMenuButton(
      itemBuilder: (context) {
        final items = <PopupMenuEntry<String>>[];
        if (widget.isAdmin) {
          items.add(
            const PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete),
                  SizedBox(width: 10),
                  Text('Törlés'),
                ],
              ),
            ),
          );
        }
        items.add(
          const PopupMenuItem(
            value: 'download',
            child: Row(
              children: [
                Icon(Icons.download),
                SizedBox(width: 10),
                Text(
                  'Letöltés',
                  style: TextStyle(color: Colors.black),
                ),
              ],
            ),
          ),
        );
        return items;
      },
      onSelected: (value) {
        if (value == 'delete') {}
      },
    );
  }
}
