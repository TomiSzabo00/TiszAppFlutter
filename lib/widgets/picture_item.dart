import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_boxicons/flutter_boxicons.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:gal/gal.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:readmore/readmore.dart';
import 'package:tiszapp_flutter/models/pics/picture_data.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:tiszapp_flutter/viewmodels/pictures_viewmodel.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:tiszapp_flutter/widgets/heart_animation_widget.dart';
import 'package:zoom_pinch_overlay/zoom_pinch_overlay.dart';
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
        GestureDetector(
          onTap: () {
            showLikesSheet();
          },
          child: likeCount(),
        ),
        titleData(),
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
                  const Text(
                    'Meme',
                    style: TextStyle(fontSize: 14),
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 0.0),
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
                ),
              ],
            ),
          ),
        );
        return items;
      },
      onSelected: (value) async {
        if (value == 'delete') {
          viewModel.deletePic(widget.pic);
        } else if (value == 'download') {
          if (await Gal.hasAccess()) {
            final imagePath = '${Directory.systemTemp.path}/image.jpg';
            await Dio().download(widget.pic.url, imagePath);
            await Gal.putImage(imagePath);
            _showSnackBar('Kép mentve a galériába');
          }
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
                const EdgeInsets.symmetric(horizontal: 14.0, vertical: 10.0),
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
}
