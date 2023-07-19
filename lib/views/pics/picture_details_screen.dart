// ignore_for_file: use_build_context_synchronously

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
import 'package:tiszapp_flutter/views/pics/picture_full_screen_screen.dart';
import 'package:tiszapp_flutter/widgets/3d_button.dart';

class PictureDetailsScreen extends StatefulWidget {
  const PictureDetailsScreen({
    super.key,
    required this.picture,
    required this.isReview,
  });

  final Picture picture;
  final bool isReview;

  @override
  State<PictureDetailsScreen> createState() => PictureDetailsScreenState();
}

class PictureDetailsScreenState extends State<PictureDetailsScreen> {
  @override
  void initState() {
    super.initState();
    Provider.of<PicturesViewModel>(context, listen: false)
        .loadImageData(widget.picture, widget.isReview);
  }

  @override
  Widget build(BuildContext context) {
    final isDarkTheme = Theme.of(context).brightness == Brightness.dark;
    final viewModel = context.watch<PicturesViewModel>();
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.picture.title),
        actions: viewModel.isAdmin
            ? widget.isReview
                ? [
                    // review actions
                    IconButton(
                      onPressed: () async {
                        _showAreYouSureDialog(ActionType.reject, () async {
                          await viewModel.rejectPic(widget.picture);
                          _showSnackBar('Kép elutasítva!');
                          Navigator.pop(context);
                        });
                      },
                      icon: const Icon(
                        Icons.do_disturb,
                        color: Colors.red,
                      ),
                    ),
                    IconButton(
                      onPressed: () async {
                        _showAreYouSureDialog(ActionType.accept, () async {
                          await viewModel.acceptPic(widget.picture);
                          _showSnackBar('Kép elfogadva!');
                          Navigator.pop(context);
                        });
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
                        onPressed: () async {
                          _showAreYouSureDialog(ActionType.delete, () async {
                            await viewModel.deletePic(widget.picture);
                            _showSnackBar('Kép törölve!');
                            Navigator.pop(context);
                          });
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
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => FullScreenPage(
                        dark: true,
                        url: widget.picture.url,
                        child: Image(
                          image: CachedNetworkImageProvider(
                            widget.picture.url,
                          ),
                        ),
                      ),
                    ),
                  );
                },
                child: CachedNetworkImage(
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
              ),
              const SizedBox(height: 20),
              () {
                if (widget.isReview) {
                  return const SizedBox();
                } else {
                  return reactionsWidget(viewModel, isDarkTheme);
                }
              }(),
              const SizedBox(height: 40),
              () {
                if (widget.isReview) {
                  return const SizedBox();
                } else {
                  if (widget.picture.isPicOfTheDay) {
                    return const Text(
                      'Ez a kép nap képének lett választva!',
                      style: TextStyle(
                        fontSize: 16,
                      ),
                    );
                  }
                  if (viewModel.isAdmin) {
                    return Center(
                      child: Button3D(
                        onPressed: () {
                          _showAreYouSureDialog(ActionType.choose, () async {
                            viewModel.choosePic(widget.picture);
                            _showSnackBar(
                                'Kép nap képének kiválasztva! Értesítés küldve a feltöltőnek.');
                          });
                        },
                        width: MediaQuery.of(context).size.width - 80,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: Row(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                CommunityMaterialIcons.tooltip_image,
                                color: isDarkTheme
                                    ? CustomColor.btnTextNight
                                    : CustomColor.btnTextDay,
                              ),
                              const SizedBox(width: 10),
                              Flexible(
                                child: AutoSizeText(
                                  'Nap képének választása',
                                  style: TextStyle(
                                    color: isDarkTheme
                                        ? CustomColor.btnTextNight
                                        : CustomColor.btnTextDay,
                                  ),
                                  minFontSize: 6,
                                  maxLines: 1,
                                  textScaleFactor: 1.3,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }
                  return const SizedBox();
                }
              }(),
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
      children: List.generate(viewModel.availableReactions.length, (index) {
        final key = viewModel.availableReactions[index];
        return singleReactionWidget(
          index,
          key,
          viewModel.reactions[key] ?? 0,
          viewModel.isSelected(key),
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
            : index ==
                    Provider.of<PicturesViewModel>(context)
                            .availableReactions
                            .length -
                        1
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

  void _showSnackBar(String text) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(text),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showAreYouSureDialog(ActionType type, Future<void> Function() onYes) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: type == ActionType.choose
              ? const Text(
                  'Biztos vagy benne, hogy ezt a képet akarod nap képének választani?')
              : Text('Biztos vagy benne, hogy ${type.name} akarod a képet?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Mégse'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                onYes();
              },
              child: const Text('Igen'),
            ),
          ],
        );
      },
    );
  }
}

enum ActionType {
  delete,
  accept,
  reject,
  choose,
}

extension NameExtension on ActionType {
  String get name {
    switch (this) {
      case ActionType.delete:
        return 'törölni';
      case ActionType.accept:
        return 'elfogadni';
      case ActionType.reject:
        return 'elutasítani';
      case ActionType.choose:
        return '';
    }
  }
}
