import 'package:appinio_swiper/appinio_swiper.dart';
import 'package:flutter/material.dart';
import 'package:tiszapp_flutter/models/tinder_data.dart';
import 'package:tiszapp_flutter/viewmodels/tinder_viewmodel.dart';
import 'package:tiszapp_flutter/widgets/tinder_tile.dart';

class TinderScreen extends StatefulWidget {
  const TinderScreen({super.key, required this.context});

  final BuildContext context;

  @override
  TinderScreenState createState() => TinderScreenState();
}

class TinderScreenState extends State<TinderScreen> {
  final viewModel = TinderViewModel();

  @override
  void initState() {
    super.initState();
    // viewModel.subscribeToCards();
  }

  @override
  Widget build(BuildContext context) {
    context = widget.context;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Párkereső'),
      ),
      body: FutureBuilder(
        future: viewModel.getCards(),
        builder: (context, AsyncSnapshot<List<TinderData>> snapshot) {
          if (snapshot.hasData) {
            return AppinioSwiper(
              cardsCount: snapshot.data!.length,
              cardsBuilder: (context, index) {
                return Center(
                  child: TinderTile(
                    width: MediaQuery.of(context).size.width * 0.8,
                    height: MediaQuery.of(context).size.width * 0.8 * 4 / 3,
                    data: TinderData(
                      name: snapshot.data![index].name,
                      teamNum: snapshot.data![index].teamNum,
                      imageUrl: snapshot.data![index].imageUrl,
                    ),
                  ),
                );
              },
            );
          }
          return const Center(
            child: CircularProgressIndicator(),
          );
        },
      ),
    );
  }
}
