import 'package:flutter/material.dart';
import 'package:tiszapp_flutter/viewmodels/texts_viewmodel.dart';
import 'package:tiszapp_flutter/widgets/text_item.dart';

class TextsScreen extends StatefulWidget {
  const TextsScreen({super.key});

  @override
  State<TextsScreen> createState() => _TextsScreenState();
}

class _TextsScreenState extends State<TextsScreen> {
  final TextsViewModel _viewModel = TextsViewModel();

  @override
  void initState() {
    _viewModel.getTexts().then((_) => setState(() {}));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkTheme = Theme.of(context).brightness == Brightness.dark;
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
            for (var text in _viewModel.texts)
              TextItem(
                text: text,
              ),
          ],
        ),
      ),
    );
  }
}
