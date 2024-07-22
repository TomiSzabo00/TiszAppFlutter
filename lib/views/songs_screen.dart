import 'package:flutter/material.dart';
import 'package:tiszapp_flutter/views/songs_summary_screen.dart';

class SongsScreen extends StatefulWidget {
  const SongsScreen({
    super.key,
    required this.isOffline,
  });

  final bool isOffline;

  @override
  SongsScreenState createState() => SongsScreenState();
}

class SongsScreenState extends State<SongsScreen> with TickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    final isDarkTheme = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daloskönyv'),
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: isDarkTheme ? const AssetImage("images/bg2_night.png") : const AssetImage("images/bg2_day.png"),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.7), BlendMode.dstATop),
          ),
        ),
        child: SongsSummaryScreen(isOffline: widget.isOffline),
      ),
    );
  }
}
