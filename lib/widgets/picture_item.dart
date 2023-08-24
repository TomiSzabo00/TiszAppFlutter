import 'dart:async';
import 'dart:io';

import 'package:community_material_icon/community_material_icon.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:gal/gal.dart';
import 'package:info_popup/info_popup.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:readmore/readmore.dart';
import 'package:tiszapp_flutter/models/pics/picture_category.dart';
import 'package:tiszapp_flutter/models/pics/picture_data.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:tiszapp_flutter/viewmodels/pictures_viewmodel.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:tiszapp_flutter/widgets/heart_animation_widget.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';

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
  Future _titleFuture = Future.value();
  Future _authorFuture = Future.value();
  Future _likeCountFuture = Future.value();
  Future _commentCountFuture = Future.value();

  final ScrollController _commentsScrollController = ScrollController();
  final _scaleStateController = PhotoViewScaleStateController();

  late StreamSubscription<bool> keyboardSubscription;
  late KeyboardVisibilityController keyboardVisibilityController;

  @override
  void initState() {
    super.initState();
    viewModel.loadImageData(widget.pic, widget.isReview);
    _titleFuture = viewModel.getAuthorDetails(widget.pic.author);
    _authorFuture = viewModel.getAuthorDetails(widget.pic.author);
    _likeCountFuture = viewModel.getLikeText(widget.pic, () {
      if (mounted) {
        setState(() {});
      }
    });
    _commentCountFuture = viewModel.getCommentCountAsString(widget.pic);

    keyboardVisibilityController = KeyboardVisibilityController();
    keyboardSubscription =
        keyboardVisibilityController.onChange.listen((bool visible) {});
  }

  @override
  void dispose() {
    keyboardSubscription.cancel();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant PictureItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.pic != widget.pic) {
      _likeCountFuture = viewModel.getLikeText(widget.pic, () {
        if (mounted) {
          setState(() {});
        }
      });
      if (viewModel.getCommentCountAsString(widget.pic) !=
          viewModel.getCommentCountAsString(oldWidget.pic)) {
        _commentCountFuture = viewModel.getCommentCountAsString(widget.pic);
      }
    }
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
        image(),
        () {
          if (widget.isReview) {
            return const SizedBox.shrink();
          } else {
            return likeAndComment(isLiked);
          }
        }(),
        GestureDetector(
          onTap: () {
            showLikesSheet();
          },
          child: likeCount(),
        ),
        titleData(),
        () {
          if (widget.isReview) {
            return reviewButtons();
          } else {
            return const SizedBox.shrink();
          }
        }(),
        GestureDetector(
          onTap: () {
            showCommentsSheet(isFromButton: false);
          },
          child: commentCount(),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget image() {
    return GestureDetector(
      child: Stack(
        alignment: Alignment.center,
        children: [
          Stack(
            alignment: Alignment.topRight,
            children: [
              photoGallery(),
              () {
                if (widget.pic.isPicOfTheDay) {
                  return const Padding(
                    padding: EdgeInsets.all(20.0),
                    child: InfoPopupWidget(
                      contentTitle: 'Ez a kép a nap képe lett!',
                      arrowTheme: InfoPopupArrowTheme(
                        color: Colors.white,
                      ),
                      contentTheme: InfoPopupContentTheme(
                          infoTextStyle: TextStyle(fontSize: 16)),
                      dismissTriggerBehavior:
                          PopupDismissTriggerBehavior.anyWhere,
                      //areaBackgroundColor: Colors.black12,
                      enableHighlight: true,
                      child: Icon(
                        FontAwesomeIcons.award,
                        color: Colors.yellow,
                        size: 40,
                      ),
                    ),
                  );
                } else {
                  return const SizedBox.shrink();
                }
              }(),
            ],
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
        if (widget.isReview) {
          return;
        }
        viewModel.likePicture(widget.pic);
        setState(() {
          isAnimating = true;
        });
      },
    );
  }

  Widget photoGallery() {
    final isDarkTheme = Theme.of(context).brightness == Brightness.dark;
    return SizedBox(
      height: MediaQuery.of(context).size.width,
      child: PhotoViewGallery.builder(
        scrollPhysics: const BouncingScrollPhysics(),
        builder: (BuildContext context, int index) {
          return PhotoViewGalleryPageOptions(
              imageProvider: CachedNetworkImageProvider(widget.pic.urls[index]),
              initialScale: PhotoViewComputedScale.contained,
              minScale: PhotoViewComputedScale.contained,
              maxScale: PhotoViewComputedScale.covered * 3,
              scaleStateController: _scaleStateController,
              onScaleEnd: (context, details, controllerValue) {
                _scaleStateController.scaleState = PhotoViewScaleState.initial;
              });
        },
        itemCount: widget.pic.urls.length,
        loadingBuilder: (context, progress) => Center(
          child: SizedBox(
            width: 20.0,
            height: 20.0,
            child: CircularProgressIndicator(
              value: progress == null
                  ? null
                  : progress.cumulativeBytesLoaded /
                      (progress.expectedTotalBytes?.toInt() ?? 1),
            ),
          ),
        ),
        backgroundDecoration: BoxDecoration(
          color: Colors.grey.withOpacity(isDarkTheme ? 0.25 : 1),
        ),
        onPageChanged: (int index) {},
      ),
    );
  }

  Widget reviewButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        IconButton(
          onPressed: () {
            _showAreYouSureDialog(ActionType.accept, () async {
              viewModel.acceptPic(widget.pic);
              _showSnackBar('Kép elfogadva!');
            });
          },
          icon: const Row(
            children: [
              Icon(
                Icons.check_circle_outline_rounded,
                color: Colors.green,
                size: 25,
              ),
              SizedBox(width: 5),
              Text('Elfogad', style: TextStyle(fontSize: 16)),
            ],
          ),
        ),
        IconButton(
          onPressed: () {
            _showAreYouSureDialog(ActionType.reject, () async {
              viewModel.rejectPic(widget.pic);
              _showSnackBar('Kép elutasítva!');
            });
          },
          icon: const Row(
            children: [
              Icon(
                CommunityMaterialIcons.close_circle_outline,
                color: Colors.red,
                size: 25,
              ),
              SizedBox(width: 5),
              Text('Elutasít', style: TextStyle(fontSize: 16)),
            ],
          ),
        ),
      ],
    );
  }

  Widget authorData() {
    return FutureBuilder(
      future: _authorFuture,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final authorDetails = snapshot.data!;
          return SizedBox(
            width: MediaQuery.of(context).size.width * 0.8,
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 10.0),
              visualDensity: VisualDensity.compact,
              leading: const CircleAvatar(
                backgroundColor: Colors.grey,
              ),
              title: Text(
                authorDetails.name,
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              subtitle: Wrap(
                children: [
                  Text(
                    authorDetails.teamNumberAsString,
                    style: const TextStyle(fontSize: 14),
                  ),
                  dotDivider(),
                  Text(
                    widget.pic.category.displayName,
                    style: const TextStyle(fontSize: 14),
                  ),
                  dotDivider(),
                  Text(
                    viewModel.timeStampFromKey(widget.pic.key),
                    style: const TextStyle(fontSize: 14),
                  ),
                ],
              ),
            ),
          );
        } else {
          return const Text('Betöltés...');
        }
      },
    );
  }

  Widget titleData() {
    if (widget.pic.title.isEmpty) {
      return const SizedBox.shrink();
    }
    return Padding(
      padding: const EdgeInsets.only(left: 14.0, right: 14.0, top: 10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FutureBuilder(
              future: _titleFuture,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return Text(
                    snapshot.data!.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  );
                } else {
                  return const Text('Betöltés...');
                }
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
        if (widget.isAdmin && !widget.isReview) {
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
          items.add(
            const PopupMenuItem(
              value: 'markPicOfTheDay',
              child: Row(
                children: [
                  Icon(FontAwesomeIcons.award),
                  SizedBox(width: 10),
                  Text('Nap képének választás'),
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
                ),
              ],
            ),
          ),
        );
        return items;
      },
      onSelected: (value) async {
        if (value == 'delete') {
          _showAreYouSureDialog(ActionType.delete, () async {
            viewModel.deletePic(widget.pic);
            _showSnackBar('Kép törölve!');
          });
        } else if (value == 'download') {
          if (await Gal.hasAccess()) {
            final imagePath = '${Directory.systemTemp.path}/image.jpg';
            await Future.forEach(widget.pic.urls, (url) async {
              await Dio().download(url, imagePath);
              await Gal.putImage(imagePath);
            });
            _showSnackBar('Kép(ek) mentve a galériába');
          }
        } else if (value == 'markPicOfTheDay') {
          _showAreYouSureDialog(ActionType.choose, () async {
            viewModel.choosePic(widget.pic);
            _showSnackBar(
                'Kép kiválasztva nap képének! Értesítés elküldve a feltöltőnek!');
          });
        }
      },
    );
  }

  Widget likeAndComment(bool isLiked) {
    bool isDarkTheme = Theme.of(context).brightness == Brightness.dark;
    return Row(
      children: [
        IconButton(
          icon: Icon(
            isLiked ? MdiIcons.heart : MdiIcons.heartOutline,
            color: isLiked
                ? Colors.red
                : isDarkTheme
                    ? Colors.white
                    : Colors.black,
            size: 30,
          ),
          onPressed: () {
            viewModel.toggleReactionTo(widget.pic, () {
              if (mounted) {
                setState(() {});
              }
            });
          },
        ),
        IconButton(
          icon: FaIcon(
            FontAwesomeIcons.comment,
            color: isDarkTheme ? Colors.white : Colors.black,
            size: 25,
          ),
          onPressed: () {
            showCommentsSheet(isFromButton: true);
          },
        ),
      ],
    );
  }

  Widget likeCount() {
    return FutureBuilder(
      future: _likeCountFuture,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 14.0, vertical: 0.0),
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

  Widget commentCount() {
    return FutureBuilder(
      future: _commentCountFuture,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14.0),
            child: Row(
              children: [
                Text(
                  snapshot.data!,
                  style: const TextStyle(
                    fontWeight: FontWeight.w300,
                  ),
                ),
              ],
            ),
          );
        } else {
          return const SizedBox.shrink();
        }
      },
    );
  }

  void showLikesSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.0),
      ),
      builder: (_) {
        return DraggableScrollableSheet(
          maxChildSize: 0.85,
          expand: false,
          builder: (_, controller) {
            return ListView(
              controller: controller,
              children: [
                Column(
                  children: [
                    titleSection('Kedvelések'),
                    likesSection(),
                  ],
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget likesSection() {
    return FutureBuilder(
      future: viewModel.getLikesList(widget.pic),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: widget.pic.likes.length,
            itemBuilder: (context, index) {
              return ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Colors.grey,
                ),
                title: Text(snapshot.data!.values.elementAt(index)),
                subtitle: Text(viewModel
                    .timeStampFromKey(snapshot.data!.keys.elementAt(index))),
              );
            },
          );
        } else {
          return const Text('Betöltés...');
        }
      },
    );
  }

  void showCommentsSheet({required bool isFromButton}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.0),
      ),
      builder: (context) {
        return StatefulBuilder(builder: (context, setModalState) {
          return Padding(
            padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom),
            child: DraggableScrollableSheet(
              maxChildSize: 0.6,
              expand: false,
              builder: (_, controller) {
                return Column(
                  children: [
                    titleSection('Kommentek'),
                    commentsSection(),
                    commnetTextBoxSection(isFromButton),
                    const SizedBox(height: 30),
                  ],
                );
              },
            ),
          );
        });
      },
    );
  }

  Widget commentsSection() {
    return FutureBuilder(
        future: viewModel.getCommentsList(widget.pic),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Text('Hiba történt a kommentek betöltése közben.');
          }
          if (snapshot.hasData) {
            SchedulerBinding.instance.addPostFrameCallback((_) {
              _scrollDown();
            });
            return Expanded(
              flex: 100,
              child: ListView.builder(
                controller: _commentsScrollController,
                itemCount: snapshot.data!.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 10.0),
                    visualDensity: VisualDensity.compact,
                    leading: const CircleAvatar(
                      backgroundColor: Colors.grey,
                    ),
                    title: Text(snapshot.data![index].keys.first,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 12)),
                    subtitle: Text(
                      snapshot.data![index].values.first,
                      style: const TextStyle(fontSize: 16),
                    ),
                  );
                },
              ),
            );
          } else {
            return const Text('Betöltés...');
          }
        });
  }

  Widget commnetTextBoxSection(bool isFromButton) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: viewModel.commentController,
              autofocus: isFromButton,
              decoration: const InputDecoration(
                isDense: true,
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                hintText: 'Írj egy kommentet...',
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(20.0))),
              ),
              onSubmitted: (value) => FocusManager.instance.primaryFocus
                  ?.unfocus(), // hide keyboard
              autocorrect: false,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.send),
            onPressed: () {
              viewModel.uploadComment(widget.pic);
              viewModel.commentController.clear();
              if (keyboardVisibilityController.isVisible) {
                FocusManager.instance.primaryFocus?.unfocus();
              } else {
                Navigator.of(context).pop();
                _showSnackBar('Komment elküldve.');
              }
            },
          ),
        ],
      ),
    );
  }

  Widget titleSection(String text) {
    bool isDarkTheme = Theme.of(context).brightness == Brightness.dark;
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Text(
          text,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 10),
        Divider(
          color: (isDarkTheme ? Colors.white : Colors.black).withOpacity(0.4),
          indent: 20,
          endIndent: 20,
        ),
      ],
    );
  }

  void _showSnackBar(String text) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(text),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _scrollDown() {
    if (widget.pic.comments.isNotEmpty) {
      if (_commentsScrollController.hasClients) {
        _commentsScrollController.animateTo(
          _commentsScrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeOut,
        );
      }
    }
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
