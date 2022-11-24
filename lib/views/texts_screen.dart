import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tiszapp_flutter/viewmodels/texts_viewmodel.dart';
import 'package:tiszapp_flutter/widgets/text_item.dart';

class TextsScreen extends StatefulWidget {
  const TextsScreen({super.key});

  @override
  State<TextsScreen> createState() => _TextsScreenState();
}

class _TextsScreenState extends State<TextsScreen> {
  @override
  Widget build(BuildContext context) {
    final isDarkTheme = Theme.of(context).brightness == Brightness.dark;
    final viewModel = context.watch<TextsViewModel>();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Szövegek'),
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
        child: GridView.count(
          crossAxisCount: 1,
          childAspectRatio: 3,
          children: [
            for (var text in viewModel.texts)
              TextItem(
                text: text,
              ),
          ],
        ),
      ),
    );
  }
}
