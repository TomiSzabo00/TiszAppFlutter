import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tiszapp_flutter/widgets/picture_item.dart';
import '../../viewmodels/pictures_viewmodel.dart';

class PicturesScreen extends StatefulWidget {
  // ignore: prefer_const_constructors_in_immutables
  PicturesScreen({
    super.key,
    required this.isReview,
  });

  final bool isReview;
  late final PicturesViewModel viewModel;
  @override
  State<PicturesScreen> createState() => _PicturesScreenState();
}

class _PicturesScreenState extends State<PicturesScreen> {
  @override
  void initState() {
    super.initState();
    widget.viewModel = Provider.of<PicturesViewModel>(context, listen: false);
    widget.viewModel.getImages(widget.isReview);
  }

  @override
  void dispose() {
    widget.viewModel.disposeListeners();
    super.dispose();
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
        child: ListView.builder(
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
    );
  }
}
