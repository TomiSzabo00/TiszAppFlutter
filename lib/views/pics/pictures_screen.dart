import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tiszapp_flutter/widgets/picture_item.dart';
import '../../viewmodels/pictures_viewmodel.dart';

// ignore: must_be_immutable
class PicturesScreen extends StatefulWidget {
  PicturesScreen({
    super.key,
    required this.isReview,
    required this.isAdmin,
  });

  final bool isReview;
  final bool isAdmin;
  PicturesViewModel? viewModel;
  @override
  State<PicturesScreen> createState() => _PicturesScreenState();
}

class _PicturesScreenState extends State<PicturesScreen> {
  @override
  void initState() {
    super.initState();
    widget.viewModel = Provider.of<PicturesViewModel>(context, listen: false);
    widget.viewModel!.getImages(widget.isReview);
  }

  @override
  void dispose() {
    widget.viewModel?.disposeListeners();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<PicturesViewModel>();
    bool isDarkTheme =
        MediaQuery.of(context).platformBrightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(
        title: widget.isReview
            ? const Text('Képek ellenőrzése')
            : const Text('Képek'),
      ),
      body: Container(
        decoration: BoxDecoration(
          color: isDarkTheme ? Colors.black : Colors.white,
        ),
        child: ListView.builder(
          itemCount: viewModel.pictures.length,
          itemBuilder: (context, index) {
            return PictureItem(
              pic: viewModel.pictures[index],
              isReview: widget.isReview,
              isAdmin: widget.isAdmin,
            );
          },
        ),
      ),
    );
  }
}
