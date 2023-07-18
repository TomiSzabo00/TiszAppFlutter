import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tiszapp_flutter/colors.dart';
import 'package:tiszapp_flutter/models/pics/picture_data.dart';
import 'package:tiszapp_flutter/models/pics/picture_reaction.dart';
import 'package:tiszapp_flutter/viewmodels/pictures_viewmodel.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:flutter_boxicons/flutter_boxicons.dart';
import 'package:community_material_icon/community_material_icon.dart';

class PictureDetailsScreen extends StatefulWidget {
  const PictureDetailsScreen({
    super.key,
    required this.picture,
    required this.isReview,
    required this.isAdmin,
  });

  final Picture picture;
  final bool isReview;
  final bool isAdmin;

  @override
  State<PictureDetailsScreen> createState() => PictureDetailsScreenState();
}

class PictureDetailsScreenState extends State<PictureDetailsScreen> {
  @override
  void initState() {
    super.initState();
    Provider.of<PicturesViewModel>(context, listen: false)
        .loadImageData(widget.picture);
  }

  @override
  Widget build(BuildContext context) {
    final isDarkTheme = Theme.of(context).brightness == Brightness.dark;
    final viewModel = context.watch<PicturesViewModel>();
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.picture.title),
        actions: widget.isAdmin
            ? widget.isReview
                ? [
                    // review actions
                    IconButton(
                      onPressed: () {
                        // TODO: dont allow image
                      },
                      icon: const Icon(
                        Icons.do_disturb,
                        color: Colors.red,
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        // TODO: allow image
                      },
                      icon: const Icon(
                        Icons.check_circle_outline,
                        color: Colors.green,
                      ),
                    ),
                  ]
                : [
                    // simple admin actions
                    IconButton(
                        onPressed: () {
                          // TODO: delete image
                        },
                        icon: const Icon(
                          Icons.delete,
                          color: Colors.red,
                        ))
                  ]
            : null,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
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
              const SizedBox(height: 10),
              Text('Csapat: ${viewModel.authorDetails.teamNum}',
                  style: const TextStyle(fontSize: 16)),
              const SizedBox(height: 20),
              CachedNetworkImage(
                imageUrl: widget.picture.url,
                width: MediaQuery.of(context).size.width,
                fit: BoxFit.cover,
                placeholder: (context, url) => const Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              reactionsWidget(viewModel, isDarkTheme),
            ],
          ),
        ),
      ),
    );
  }

  Widget reactionsWidget(PicturesViewModel viewModel, bool isDarkTheme) {
    return Row(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(widget.picture.reactions.length, (index) {
        final key = widget.picture.reactions.keys.toList()[index];
        return singleReactionWidget(
          index,
          key,
          (widget.picture.reactions[key]?.length ?? 1) - 1,
          viewModel.isSelected(widget.picture, key),
          isDarkTheme,
          () {
            viewModel.toggleReactionTo(widget.picture, key);
          },
        );
      }),
    );
  }

  Widget singleReactionWidget(int index, PicReaction type, int count,
      bool isSelected, bool isDarkTheme, Function onTap) {
    return Container(
      decoration: BoxDecoration(
        color: isSelected
            ? _getColorForReaction(type).withOpacity(0.2)
            : isDarkTheme
                ? CustomColor.btnFaceNight.withOpacity(0.8)
                : CustomColor.btnFaceDay.withOpacity(0.5),
        borderRadius: index == 0
            ? const BorderRadius.only(
                topLeft: Radius.circular(10),
                bottomLeft: Radius.circular(10),
              )
            : index == widget.picture.reactions.length - 1
                ? const BorderRadius.only(
                    topRight: Radius.circular(10),
                    bottomRight: Radius.circular(10),
                  )
                : null,
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () {
              onTap();
            },
            icon: () {
              switch (type) {
                case PicReaction.love:
                  return Icon(MdiIcons.heartOutline);
                case PicReaction.funny:
                  return const Icon(Boxicons.bx_happy_beaming);
                case PicReaction.sad:
                  return const Icon(
                      CommunityMaterialIcons.emoticon_sad_outline);
                case PicReaction.angry:
                  return const Icon(Boxicons.bx_angry);
              }
            }(),
            color: isSelected
                ? _getColorForReaction(type)
                : isDarkTheme
                    ? CustomColor.btnTextNight
                    : CustomColor.btnTextDay,
          ),
          const SizedBox(width: 10),
          AutoSizeText(
            count.toString(),
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
            minFontSize: 6,
          ),
          const SizedBox(width: 12),
          () {
            if (index != widget.picture.reactions.length - 1) {
              return Divider(
                thickness: 3,
                color: isDarkTheme
                    ? CustomColor.btnTextNight
                    : CustomColor.btnTextDay,
              );
            } else {
              return const SizedBox();
            }
          }(),
        ],
      ),
    );
  }

  Color _getColorForReaction(PicReaction reaction) {
    switch (reaction) {
      case PicReaction.love:
        return Colors.red;
      case PicReaction.funny:
        return Colors.orange;
      case PicReaction.sad:
        return Colors.purple;
      case PicReaction.angry:
        return const Color.fromARGB(255, 245, 105, 18);
    }
  }
}
