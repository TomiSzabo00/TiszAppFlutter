import 'package:appinio_swiper/appinio_swiper.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_boxicons/flutter_boxicons.dart';
import 'package:tiszapp_flutter/colors.dart';
import 'package:tiszapp_flutter/models/tinder/tinder_data.dart';
import 'package:tiszapp_flutter/models/tinder/tinder_tile_state.dart';
import 'package:tiszapp_flutter/viewmodels/tinder_viewmodel.dart';
import 'package:tiszapp_flutter/widgets/3d_button.dart';
import 'package:tiszapp_flutter/widgets/tinder_tile.dart';

class TinderScreen extends StatefulWidget {
  const TinderScreen({super.key, required this.context});

  final BuildContext context;

  @override
  TinderScreenState createState() => TinderScreenState();
}

class TinderScreenState extends State<TinderScreen> {
  final viewModel = TinderViewModel();
  final _controller = AppinioSwiperController();
  bool noMoreCards = false;
  Future<List<TinderData>> _getCardsFuture = Future.value([]);
  TinderTileState currentTileState = TinderTileState.none;
  int cardNum = 0;
  late OverlayEntry _matchOverlayEntry;
  GlobalKey _matchTextKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    viewModel.subscribeToLikes();
    viewModel.subscribeToDislikes();
    _getCardsFuture = viewModel.getCards();
  }

  @override
  Widget build(BuildContext context) {
    context = widget.context;
    return Scaffold(
        appBar: AppBar(
          title: const Text('Párkereső'),
        ),
        body: () {
          if (noMoreCards) {
            return noMoreCardsWidget();
          }
          return cardsWidget();
        }());
  }

  Widget cardsWidget() {
    return FutureBuilder(
      future: _getCardsFuture,
      builder: (context, AsyncSnapshot<List<TinderData>> snapshot) {
        if (snapshot.hasData) {
          SchedulerBinding.instance.addPostFrameCallback((_) {
            if (snapshot.data!.isNotEmpty) {
              setState(() {
                noMoreCards = false;
              });
            } else {
              setState(() {
                noMoreCards = true;
              });
            }
          });
          return Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.max,
            children: [
              const Flexible(
                flex: 2,
                child: Padding(
                  padding: EdgeInsets.all(20.0),
                  child: Text(
                      'Húzd az embereket jobbra vagy balra! Jobbra, ha lennél a párjuk, balra, ha nem.'),
                ),
              ),
              Flexible(
                flex: 10,
                child: AppinioSwiper(
                  controller: _controller,
                  cardsCount: snapshot.data!.length,
                  cardsSpacing: 30,
                  maxAngle: 60,
                  swipeOptions:
                      const AppinioSwipeOptions.symmetric(horizontal: true),
                  cardsBuilder: (context, index) {
                    return Center(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: TinderTile(
                          width: MediaQuery.of(context).size.width * 0.8,
                          state: index == cardNum
                              ? currentTileState
                              : TinderTileState.none,
                          data: TinderData(
                            uid: snapshot.data![index].uid,
                            name: snapshot.data![index].name,
                            teamNum: snapshot.data![index].teamNum,
                            imageUrl: snapshot.data![index].imageUrl,
                          ),
                        ),
                      ),
                    );
                  },
                  onSwiping: (direction) {
                    setState(() {
                      currentTileState = getStateFrom(direction: direction);
                    });
                  },
                  onSwipeCancelled: () {
                    setState(() {
                      currentTileState = TinderTileState.none;
                    });
                  },
                  onSwipe: (badIndex, direction) {
                    final index = badIndex - 1;
                    if (index < 0) {
                      return;
                    }
                    if (direction == AppinioSwiperDirection.left) {
                      viewModel.dislike(data: snapshot.data![index]);
                    } else if (direction == AppinioSwiperDirection.right) {
                      viewModel.like(data: snapshot.data![index]);
                      if (viewModel.isMatch(data: snapshot.data![index])) {
                        _showMatchOverlay(snapshot.data![index]);
                      }
                    }
                    setState(() {
                      currentTileState = TinderTileState.none;
                      cardNum++;
                    });
                  },
                  onEnd: () {
                    setState(() {
                      noMoreCards = true;
                      currentTileState = TinderTileState.none;
                      cardNum = 0;
                    });
                  },
                ),
              ),
              Flexible(
                flex: 2,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        _controller.swipeLeft();
                      },
                      style: ElevatedButton.styleFrom(
                        shape: const StadiumBorder(),
                        padding: const EdgeInsets.all(15),
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        shadowColor: Colors.red,
                        elevation: currentTileState == TinderTileState.disliking
                            ? 20
                            : 10,
                      ),
                      child: const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        child: Icon(Boxicons.bxs_dislike),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        _controller.swipeRight();
                      },
                      style: ElevatedButton.styleFrom(
                        shape: const StadiumBorder(),
                        padding: const EdgeInsets.all(15),
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        shadowColor: Colors.green,
                        elevation: currentTileState == TinderTileState.liking
                            ? 20
                            : 10,
                      ),
                      child: const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        child: Icon(Boxicons.bxs_like),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        }
        return const Center(
          child: CircularProgressIndicator(),
        );
      },
    );
  }

  Widget noMoreCardsWidget() {
    bool isDarkTheme = Theme.of(context).brightness == Brightness.dark;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
                'Elfogytok az emberek! Gyere vissza később, vagy próbáld meg frissíteni a listát!'),
            const SizedBox(height: 20),
            Button3D(
              onPressed: () {
                setState(() {
                  noMoreCards = false;
                  _getCardsFuture = viewModel.getCards();
                });
              },
              child: Text(
                'Frissítés',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isDarkTheme
                        ? CustomColor.btnTextNight
                        : CustomColor.btnTextDay),
              ),
            ),
          ],
        ),
      ),
    );
  }

  TinderTileState getStateFrom({required AppinioSwiperDirection direction}) {
    switch (direction) {
      case AppinioSwiperDirection.left:
        return TinderTileState.disliking;
      case AppinioSwiperDirection.right:
        return TinderTileState.liking;
      default:
        return TinderTileState.none;
    }
  }

  void _showMatchOverlay(TinderData data) {
    _matchOverlayEntry = OverlayEntry(
      builder: (context) {
        return Material(
          child: SizedBox(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            child: Stack(
              alignment: AlignmentDirectional.bottomCenter,
              children: [
                CachedNetworkImage(
                  imageUrl: data.imageUrl ?? '',
                  fit: BoxFit.cover,
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height,
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 50),
                  child: matchTextWidget(),
                ),
              ],
            ),
          ),
        );
      },
    );
    Overlay.of(context).insert(
      _matchOverlayEntry,
    );
    Future.delayed(const Duration(seconds: 2), () {
      _matchOverlayEntry.remove();
    });
  }

  Widget matchTextWidget() {
    return SizedBox(
      height: MediaQuery.of(context).size.height / 4,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned.fill(
            top: 60,
            left: 20,
            child: Align(
              alignment: Alignment.topCenter,
              child: ClipRect(
                clipper: MatchClipper(),
                child: const Text(
                  'ÚJ PÁR!',
                  style: TextStyle(
                    fontSize: 60,
                    color: Colors.blue,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),
          ),
          Positioned.fill(
            top: 30,
            left: 10,
            child: Align(
              alignment: Alignment.topCenter,
              child: ClipRect(
                clipper: MatchClipper(),
                child: const Text(
                  'ÚJ PÁR!',
                  style: TextStyle(
                    fontSize: 60,
                    color: Colors.red,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),
          ),
          const Positioned.fill(
            top: 0,
            left: 0,
            child: Align(
              alignment: Alignment.topCenter,
              child: Text(
                'ÚJ PÁR!',
                style: TextStyle(
                  fontSize: 60,
                  color: Colors.green,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class MatchClipper extends CustomClipper<Rect> {
  @override
  Rect getClip(Size size) {
    return Rect.fromLTWH(0, 38, size.width, 200);
  }

  @override
  bool shouldReclip(covariant CustomClipper<Rect> oldClipper) => false;
}
