import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tiszapp_flutter/models/pics/picture_data.dart';
import 'package:tiszapp_flutter/viewmodels/pictures_viewmodel.dart';

class PictureDetailsScreen extends StatefulWidget {
  const PictureDetailsScreen({
    super.key,
    required this.picture,
    required this.isReview,
    required this.isAdmin,
  });

  final Picture picture;
  final bool isReview;
  final bool isAdmin;

  @override
  State<PictureDetailsScreen> createState() => PictureDetailsScreenState();
}

class PictureDetailsScreenState extends State<PictureDetailsScreen> {
  @override
  void initState() {
    super.initState();
    Provider.of<PicturesViewModel>(context).loadImageData(widget.picture);
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<PicturesViewModel>();
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.picture.title),
        actions: widget.isAdmin
            ? widget.isReview
                ? [
                    // review actions
                    IconButton(
                      onPressed: () {
                        // TODO: dont allow image
                      },
                      icon: const Icon(
                        Icons.do_disturb,
                        color: Colors.red,
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        // TODO: allow image
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
                        onPressed: () {
                          // TODO: delete image
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
            children: [
              Text('Feltöltő: ${viewModel.authorDetails.name}'),
              const SizedBox(height: 10),
              Text('Csapat: ${viewModel.authorDetails.teamNum}'),
              const SizedBox(height: 20),
              Image.network(
                widget.picture.url,
                width: double.infinity,
                height: double.infinity,
                fit: BoxFit.cover,
              )
            ],
          ),
        ),
      ),
    );
  }
}
