import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tiszapp_flutter/widgets/picture_item.dart';
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
  @override
  void initState() {
    super.initState();
    Provider.of<PicturesViewModel>(context, listen: false)
        .getImages(widget.isReview);
  }

  @override
  Widget build(BuildContext context) {
    final isDarkTheme = Theme.of(context).brightness == Brightness.dark;
    final viewModel = context.watch<PicturesViewModel>();
    return Scaffold(
      appBar: AppBar(
        title: widget.isReview
            ? const Text('Képek ellenőrzése')
            : const Text('Képek'),
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
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              childAspectRatio: 1.15,
            ),
            itemCount: viewModel.pictures.length,
            itemBuilder: (context, index) {
              return PictureItem(
                pic: viewModel.pictures[index],
                isReview: widget.isReview,
                isAdmin: viewModel.isAdmin,
              );
            },
          ),
        ),
      ),
    );
  }
}
