import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tiszapp_flutter/models/pics/picture_data.dart';
import 'package:tiszapp_flutter/models/pics/picture_reaction.dart';
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
    Provider.of<PicturesViewModel>(context, listen: false)
        .loadImageData(widget.picture);
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
                width: MediaQuery.of(context).size.width,
                fit: BoxFit.cover,
              ),
              const SizedBox(height: 20),
              reactionsWidget(viewModel),
            ],
          ),
        ),
      ),
    );
  }

  Widget reactionsWidget(PicturesViewModel viewModel) {
    return Row(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(widget.picture.reactions.length, (index) {
        final key = widget.picture.reactions.keys.toList()[index];
        return singleReactionWidget(key, widget.picture.reactions[key] ?? 0);
      }),
    );
  }

  Widget singleReactionWidget(PicReaction type, int count) {
    return Row(
      children: [
        () {
          return const Icon(Icons.heart_broken);
        }(),
        const SizedBox(width: 10),
        Text(count.toString()),
      ],
    );
  }
}
