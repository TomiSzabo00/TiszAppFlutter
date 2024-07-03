import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class ChantBlasterViewModel with ChangeNotifier {
  final DatabaseReference _chantRef =
      FirebaseDatabase.instance.reference().child('chant');

  bool _isPlaying = false;
  int _timestamp = 0;
  int _originalTimestamp = 0;
  String _audioUrl = '';
  int _played = 0; // Elapsed time in milliseconds
  bool isOwner = false;
  bool isAlreadyPlaying = false;

  bool get isPlaying => _isPlaying;

  int get timestamp => _timestamp;

  String get audioUrl => _audioUrl;

  int get played => _played;

  ChantBlasterViewModel() {
    _chantRef.onValue.listen((event) {
      final data = event.snapshot.value as Map<dynamic, dynamic>?;
      if (data != null) {
        _isPlaying = data['isPlaying'] ?? false;
        _timestamp = data['timestamp'] ?? 0;
        _audioUrl = data['audioUrl'] ?? '';
        _played = data['played'] ?? 0;

        if (_originalTimestamp != _timestamp) {
          _originalTimestamp = _timestamp;
          isOwner = false;
        }

        notifyListeners();
      }
    });
  }

  Future<void> startChant(String url) async {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    await _chantRef.set({
      'isPlaying': true,
      'timestamp': timestamp,
      'audioUrl': url,
      'played': 0,
    });

    _originalTimestamp = timestamp;
    isOwner = true;

    // Update played time every second while playing
    while (_isPlaying) {
      final elapsed = DateTime.now().millisecondsSinceEpoch - timestamp;
      await _chantRef.update({'played': elapsed});
      await Future.delayed(const Duration(seconds: 1));
    }
  }

  Future<void> stopChant() async {
    isOwner = false;
    isAlreadyPlaying = false;
    await _chantRef.set({
      'isPlaying': false,
      'timestamp': timestamp,
      'audioUrl': '',
      'played': _played, // Preserve elapsed time when stopping playback
    });
  }
}
