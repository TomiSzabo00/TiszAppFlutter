import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gal/gal.dart';

class FullScreenPage extends StatefulWidget {
  const FullScreenPage({
    super.key,
    required this.child,
    required this.url,
    required this.dark,
  });

  final Image child;
  final String url;
  final bool dark;

  @override
  FullScreenPageState createState() => FullScreenPageState();
}

class FullScreenPageState extends State<FullScreenPage> {
  @override
  void initState() {
    var brightness = widget.dark ? Brightness.light : Brightness.dark;
    var color = widget.dark ? Colors.black12 : Colors.white70;

    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: [SystemUiOverlay.top]);
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      systemNavigationBarColor: color,
      statusBarColor: color,
      statusBarBrightness: brightness,
      statusBarIconBrightness: brightness,
      systemNavigationBarDividerColor: color,
      systemNavigationBarIconBrightness: brightness,
    ));
    super.initState();
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: SystemUiOverlay.values);
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
        // Restore your settings here...
        ));
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: widget.dark ? Colors.black : Colors.white,
      body: Stack(
        children: [
          Stack(
            children: [
              AnimatedPositioned(
                duration: const Duration(milliseconds: 333),
                curve: Curves.fastOutSlowIn,
                top: 0,
                bottom: 0,
                left: 0,
                right: 0,
                child: InteractiveViewer(
                  panEnabled: true,
                  minScale: 0.5,
                  maxScale: 4,
                  child: widget.child,
                ),
              ),
            ],
          ),
          SafeArea(
            child: Align(
              alignment: Alignment.topLeft,
              child: Row(
                children: [
                  MaterialButton(
                    padding: const EdgeInsets.all(15),
                    elevation: 0,
                    color: widget.dark ? Colors.black12 : Colors.white70,
                    highlightElevation: 0,
                    minWidth: double.minPositive,
                    height: double.minPositive,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(100),
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                    child: Icon(
                      Icons.arrow_back,
                      color: widget.dark ? Colors.white : Colors.black,
                      size: 25,
                    ),
                  ),
                  const Spacer(),
                  PopupMenuButton(
                    color: widget.dark ? Colors.white : Colors.black,
                    onSelected: _onMenuItemSelected,
                    itemBuilder: (context) {
                      return [
                        const PopupMenuItem(
                          value: 'download',
                          child: Row(
                            children: [
                              Icon(Icons.download),
                              SizedBox(width: 10),
                              Text(
                                'Letöltés',
                                style: TextStyle(color: Colors.black),
                              ),
                            ],
                          ),
                        ),
                      ];
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _onMenuItemSelected(String value) async {
    switch (value) {
      case 'download':
        if (await Gal.hasAccess()) {
          final imagePath = '${Directory.systemTemp.path}/image.jpg';
          await Dio().download(widget.url, imagePath);
          await Gal.putImage(imagePath);
          _showSnackBar('Kép mentve a galériába');
        }
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 3),
      ),
    );
  }
}
