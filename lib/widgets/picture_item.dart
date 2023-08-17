import 'package:flutter/material.dart';
import 'package:flutter_boxicons/flutter_boxicons.dart';
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
        Padding(
          padding: const EdgeInsets.all(10),
          child: Text(widget.pic.title),
        ),
      ],
    );
  }

  Widget authorData() {
    return Column(
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
                  Text(snapshot.data!.name),
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
            Text(viewModel.timeStampFromKey(widget.pic.key)),
          ],
        ),
      ],
    );
  }
}
