// ignore_for_file: use_build_context_synchronously

import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tiszapp_flutter/colors.dart';
import 'package:tiszapp_flutter/models/pics/picture_data.dart';
import 'package:tiszapp_flutter/models/pics/picture_reaction.dart';
import 'package:tiszapp_flutter/viewmodels/pictures_viewmodel.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:flutter_boxicons/flutter_boxicons.dart';
import 'package:community_material_icon/community_material_icon.dart';
import 'package:tiszapp_flutter/views/pics/picture_full_screen_screen.dart';
import 'package:tiszapp_flutter/widgets/3d_button.dart';

import '../models/text_data.dart';
import '../viewmodels/texts_viewmodel.dart';
import '../widgets/text_item.dart';

class TextDetailsScreen extends StatefulWidget {
  const TextDetailsScreen({
    super.key,
    required this.text,
  });
  final TextData text;

  @override
  State<TextDetailsScreen> createState() => TextDetailsScreenState();
}

class TextDetailsScreenState extends State<TextDetailsScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkTheme = Theme.of(context).brightness == Brightness.dark;
    final viewModel = context.watch<TextsViewModel>();
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.text.title),
        ),
        body: SingleChildScrollView(
            child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Feltöltő: ${viewModel.text!.author}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                      Text(
                        'Szöveg:  ${viewModel.text!.text}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                    ]))));
  }
}
