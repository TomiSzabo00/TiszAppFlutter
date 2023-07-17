import 'package:flutter/material.dart';
import '../../viewmodels/pictures_viewmodel.dart';

class PicturesScreen extends StatefulWidget {
  const PicturesScreen({
    super.key,
    required this.isReview,
  });

  final bool isReview;

  @override
  State<PicturesScreen> createState() => _PicturesScreenState();
}

class _PicturesScreenState extends State<PicturesScreen> {
  final PicturesViewModel _viewModel = PicturesViewModel();

  @override
  Widget build(BuildContext context) {
    final isDarkTheme = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
        appBar: AppBar(
          title: const Text('Képek'),
        ),
        body: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: isDarkTheme
                  ? const AssetImage('images/bg2_night.png')
                  : const AssetImage('images/bg2_day.png'),
              fit: BoxFit.cover,
            ),
          ),
          child: StreamBuilder(
            stream: _viewModel.picsRef.onValue,
            builder: (context, AsyncSnapshot snapshot) {
              if (snapshot.hasData) {
                return GridView.count(
                  crossAxisCount: 2,
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                  padding: const EdgeInsets.all(10),
                  childAspectRatio: 1.2,
                  children: _viewModel.handlePics(snapshot, widget.isReview),
                );
              } else {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }
            },
          ),
        ));
  }
}
