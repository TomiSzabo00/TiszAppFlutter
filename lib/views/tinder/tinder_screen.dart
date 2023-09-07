import 'package:appinio_swiper/appinio_swiper.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:tiszapp_flutter/colors.dart';
import 'package:tiszapp_flutter/models/tinder_data.dart';
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
          return AppinioSwiper(
            controller: _controller,
            cardsCount: snapshot.data!.length,
            cardsSpacing: 30,
            maxAngle: 60,
            swipeOptions: const AppinioSwipeOptions.symmetric(horizontal: true),
            cardsBuilder: (context, index) {
              return Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: TinderTile(
                    width: MediaQuery.of(context).size.width * 0.8,
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
            onSwipe: (badIndex, direction) {
              final index = badIndex - 1;
              if (index < 0) {
                return;
              }
              if (direction == AppinioSwiperDirection.left) {
                viewModel.dislike(data: snapshot.data![index]);
              } else if (direction == AppinioSwiperDirection.right) {
                viewModel.like(data: snapshot.data![index]);
              }
            },
            onEnd: () {
              setState(() {
                noMoreCards = true;
              });
            },
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
}
