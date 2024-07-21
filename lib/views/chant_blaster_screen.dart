import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:provider/provider.dart';

import '../viewmodels/chant_blaster_viewmodel.dart';
import '../widgets/3d_button.dart';

class ChantBlasterScreen extends StatefulWidget {
  const ChantBlasterScreen({
    super.key,
    required this.isAdmin,
  });

  final bool isAdmin;

  @override
  ChantBlasterScreenState createState() => ChantBlasterScreenState();
}

class ChantBlasterScreenState extends State<ChantBlasterScreen> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  double volume = 0.5;

  @override
  void initState() {
    super.initState();
    context.read<ChantBlasterViewModel>().addListener(_syncAudio);
  }

  @override
  void dispose() {
    _audioPlayer.stop();
    _audioPlayer.dispose();
    context.read<ChantBlasterViewModel>().removeListener(_syncAudio);
    super.dispose();
  }

  @override
  void pause() {
    _audioPlayer.pause();
  }

  void _syncAudio() async {
    final viewModel = context.read<ChantBlasterViewModel>();
    if (viewModel.isPlaying && viewModel.audioUrl.isNotEmpty) {
      //await _audioPlayer.setUrl(viewModel.audioUrl);
      if (!viewModel.isAlreadyPlaying) {
        await _audioPlayer.setAsset(viewModel.audioUrl);
        _audioPlayer.setSpeed(1);
        int delay = DateTime.now().millisecondsSinceEpoch - viewModel.timestamp;
        _audioPlayer.seek(Duration(milliseconds: delay));
        _audioPlayer.play();
        viewModel.isAlreadyPlaying = true;
      }
      if (!viewModel.isOwner) {
        int glitch = _audioPlayer.position.inMilliseconds - viewModel.played;
        _audioPlayer.setSpeed(1 - glitch / 2000);
      }
    } else {
      _audioPlayer.stop();
      viewModel.isAlreadyPlaying = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<ChantBlasterViewModel>();
    final isDarkTheme = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(title: const Text("Chant Blaster")),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(
                isDarkTheme ? "images/bg2_night.png" : "images/bg2_day.png"),
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            TextField(
              decoration: const InputDecoration(labelText: 'Audio URL'),
              onSubmitted: (value) => viewModel.startChant(value),
            ),
            const SizedBox(height: 80),
            if (!viewModel.isPlaying)
              Button3D(
                  height: 200,
                  width: 200,
                  isDisabled: !widget.isAdmin,
                  onPressed: () {
                    if (widget.isAdmin) {
                      viewModel.startChant("assets/audio/wimm.mp3");
                    }
                  },
                  child: const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.speaker_group_outlined,
                          size: 80,
                        ),
                        SizedBox(height: 10),
                        Text(
                          "Chant!",
                          style: TextStyle(
                            fontSize: 18,
                          ),
                        ),
                      ])),
            if (viewModel.isPlaying)
              Button3D(
                  height: 200,
                  width: 200,
                  isDisabled: !widget.isAdmin,
                  onPressed: () {
                    if (widget.isAdmin) {
                      viewModel.stopChant();
                    }
                  },
                  child: const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.volume_off_outlined,
                          size: 80,
                        ),
                        SizedBox(height: 10),
                        Text(
                          "Stop!",
                          style: TextStyle(
                            fontSize: 18,
                          ),
                        ),
                      ])),
            const SizedBox(height: 80),
            Text('Tulajdonos: ${viewModel.isOwner ? "igen" : "nem"}'),
            Text('Megy: ${viewModel.isAlreadyPlaying ? "igen" : "nem"}'),
            Text('Várt előrehaladás: ${viewModel.played} ms'),
            Text(
                'Aktu előrehaladás: ${_audioPlayer.position.inMilliseconds} ms'),
            Text('Sebesség: ${_audioPlayer.speed} x'),
          ],
        ),
      ),
    );
  }
}
