// ignore_for_file: depend_on_referenced_packages
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:tiszapp_flutter/models/song_request_data.dart';

import '../services/database_service.dart';

class SongRequestViewModel with ChangeNotifier {
  List<SongRequest> songRequests = [];
  final DatabaseService database = DatabaseService();

  SongRequestViewModel() {
    fetchSongs();
  }

  void fetchSongs() async {
    songRequests = await database.getSongs();
    notifyListeners();
  }

  Future<void> uploadSongRequest(String name, String url) async {
    final newSong = SongRequest(id: '', name: name, url: url, upload: DateTime.now(), user: FirebaseAuth.instance.currentUser!.uid);
    await database.addSongRequest(newSong);
    songRequests.add(newSong);
    notifyListeners();
  }

  Future<void> deleteSongRequest(String songRequestId) async {
    await database.removeSongRequest(songRequestId);
    songRequests.removeWhere((songRequest) => songRequest.id == songRequestId);
    fetchSongs(); // Refresh the list after deleting a song
  }
}