import 'package:flutter/material.dart';
import 'package:flutter_boxicons/flutter_boxicons.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:readmore/readmore.dart';
import 'package:tiszapp_flutter/models/pics/picture_data.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:tiszapp_flutter/viewmodels/pictures_viewmodel.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:tiszapp_flutter/widgets/heart_animation_widget.dart';
import 'package:zoom_pinch_overlay/zoom_pinch_overlay.dart';

class PictureItem extends StatefulWidget {
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
  State<PictureItem> createState() => PictureItemState();
}

class PictureItemState extends State<PictureItem> {
  final PicturesViewModel viewModel = PicturesViewModel();
  bool isAnimating = false;

  @override
  void initState() {
    super.initState();
    viewModel.loadImageData(widget.pic, widget.isReview);
  }

  @override
  Widget build(BuildContext context) {
    bool isLiked = viewModel.checkIfAlreadyLiked(widget.pic);
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
        GestureDetector(
          child: Stack(
            alignment: Alignment.center,
            children: [
              ZoomOverlay(
                modalBarrierColor: Colors.black45,
                minScale: 1,
                maxScale: 5.0,
                animationCurve: Curves.fastOutSlowIn,
                animationDuration: const Duration(milliseconds: 300),
                twoTouchOnly: true,
                child: CachedNetworkImage(
                  imageUrl: widget.pic.url,
                  fit: BoxFit.fitWidth,
                  placeholder: (context, url) => const Center(
                    heightFactor: 5,
                    child: CircularProgressIndicator(),
                  ),
                  errorWidget: (context, url, error) =>
                      const Icon(Boxicons.bxs_error),
                ),
              ),
              Opacity(
                opacity: isAnimating ? 1 : 0,
                child: HeartAnimationWidget(
                  isAnimating: isAnimating,
                  duration: const Duration(milliseconds: 300),
                  onEnd: () {
                    setState(() {
                      isAnimating = false;
                    });
                  },
                  child: Icon(
                    MdiIcons.heart,
                    color: Colors.white,
                    size: 100,
                  ),
                ),
              ),
            ],
          ),
          onDoubleTap: () {
            viewModel.likePicture(widget.pic);
            setState(() {
              isAnimating = true;
            });
          },
        ),
        likeAndComment(isLiked),
        likeCount(),
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
      padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 0.0),
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
        if (value == 'delete') {
          viewModel.deletePic(widget.pic);
        } else if (value == 'download') {
          //viewModel.downloadPicture(widget.pic);
        }
      },
    );
  }

  Widget likeAndComment(bool isLiked) {
    return Row(
      children: [
        IconButton(
          icon: Icon(
            isLiked ? MdiIcons.heart : MdiIcons.heartOutline,
            color: isLiked ? Colors.red : Colors.black,
            size: 30,
          ),
          onPressed: () {
            viewModel.toggleReactionTo(widget.pic, () {
              setState(() {});
            });
          },
        ),
        IconButton(
          icon: const FaIcon(
            FontAwesomeIcons.comment,
            color: Colors.black,
            size: 25,
          ),
          onPressed: () {},
        ),
      ],
    );
  }

  Widget likeCount() {
    return FutureBuilder(
      future: viewModel.getLikeText(widget.pic, () {
        if (mounted) {
          setState(() {});
        }
      }),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14.0),
            child: Row(
              children: [
                HtmlWidget(snapshot.data!),
              ],
            ),
          );
        } else {
          return const SizedBox.shrink();
        }
      },
    );
  }
}
