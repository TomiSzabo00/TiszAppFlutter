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
        authorData(),
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
      ],
    );
  }

  Widget authorData() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FutureBuilder(
            future: viewModel.getAuthorDetails(widget.pic.author),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      snapshot.data!.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                );
              } else {
                return const Text('Betöltés...');
              }
            },
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text(viewModel.authorDetails.teamNumberAsString),
              dotDivider(),
              const Text('Meme'),
              dotDivider(),
              Text(viewModel.timeStampFromKey(widget.pic.key)),
            ],
          ),
        ],
      ),
    );
  }

  Widget titleData() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            viewModel.authorDetails.name,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
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
}
