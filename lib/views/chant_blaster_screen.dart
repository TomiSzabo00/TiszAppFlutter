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
    context.read<ChantBlasterViewModel>().removeListener(_syncAudio);
    _audioPlayer.dispose();
    super.dispose();
  }

  void _syncAudio() async {
    final viewModel = context.read<ChantBlasterViewModel>();
    if (viewModel.isPlaying && viewModel.audioUrl.isNotEmpty) {
      //await _audioPlayer.setUrl(viewModel.audioUrl);
      if (!viewModel.isAlreadyPlaying) {
        await _audioPlayer.setAsset(viewModel.audioUrl);
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

    return Scaffold(
      appBar: AppBar(title: const Text("Chant Blaster")),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              decoration: const InputDecoration(labelText: 'Audio URL'),
              onSubmitted: (value) => viewModel.startChant(value),
            ),
            const SizedBox(height: 20),
            if (!viewModel.isPlaying)
              Button3D(
                  onPressed: () {
                    viewModel.startChant("assets/audio/wimm.mp3");
                  },
                  child: const Row(children: [
                    Icon(Icons.play_arrow),
                    SizedBox(width: 10),
                    Text(
                      "Chant!",
                      style: TextStyle(
                        fontSize: 18,
                      ),
                    ),
                  ])),
            if (viewModel.isPlaying)
              Button3D(
                  onPressed: () {
                    viewModel.stopChant();
                  },
                  child: const Row(children: [
                    Icon(Icons.stop),
                    SizedBox(width: 10),
                    Text(
                      "Stop!",
                      style: TextStyle(
                        fontSize: 18,
                      ),
                    ),
                  ])),
            const SizedBox(height: 20),
            Text(
                'Kántálás ${viewModel.isPlaying ? "folyamatban" : "szünetel"}'),
            Text('Tulajdonos: ${viewModel.isOwner ? "igen" : "nem"}'),
            Text('Mar megy?: ${viewModel.isAlreadyPlaying ? "igen" : "nem"}'),
            Text('Várt előrehaladás: ${viewModel.played} ms'),
            Text(
                'Aktu Előrehaladás: ${_audioPlayer.position.inMilliseconds} ms'),
            Text('Sebesség: ${_audioPlayer.speed} x'),
          ],
        ),
      ),
    );
  }
}
