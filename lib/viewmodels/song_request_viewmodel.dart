// ignore_for_file: depend_on_referenced_packages
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:tiszapp_flutter/helpers/try_cast.dart';
import 'package:tiszapp_flutter/models/song_request_data.dart';
import 'package:collection/collection.dart';

import '../services/database_service.dart';

class SongRequestViewModel with ChangeNotifier {
  List<SongRequest> songRequests = [];
  final database = DatabaseService.database;

  final TextEditingController singerTitle = TextEditingController();
  final TextEditingController urlLink = TextEditingController();

  String? titleError;
  String? urlError;

  int timeoutMinutes = 30;

  SongRequestViewModel() {
    getTimeoutMinutes();
  }

  Future<void> uploadSongRequest(String name, String url) async {
    final newSong =
        SongRequest(id: '', name: name, url: url, upload: DateTime.now(), user: FirebaseAuth.instance.currentUser!.uid);
    await addSongRequest(newSong);
    songRequests.add(newSong);
    notifyListeners();
  }

  Future<void> deleteSongRequest(String songRequestId) async {
    await removeSongRequest(songRequestId);
    songRequests.removeWhere((songRequest) => songRequest.id == songRequestId);
    fetchSongs(); // Refresh the list after deleting a song
  }

  Future<List<SongRequest>> fetchSongs() async {
    try {
      final snapshot = await database.child('wishes').get();
      if (snapshot.exists) {
        final data = snapshot.value as Map<dynamic, dynamic>;
        final songsList = data.entries.map((entry) {
          final key = entry.key;
          final value = entry.value as Map<dynamic, dynamic>;
          return SongRequest.fromMap(value, key);
        }).toList();
        songRequests = songsList;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error fetching songs: $e');
    }
    return [];
  }

  Future<void> addSongRequest(SongRequest songRequest) async {
    final newSongRef = database.child('wishes').push();
    await newSongRef.set(songRequest.toMap());
    songRequest.id = newSongRef.key!;
  }

  Future<void> removeSongRequest(String songRequestId) async {
    await database.child('wishes').child(songRequestId).remove();
  }

  Future<List<SongRequest>> getSongs() async {
    final snapshot = await database.child('wishes').once();
    final dataSnapshot = snapshot.snapshot.value as Map<dynamic, dynamic>?;

    if (dataSnapshot != null) {
      return dataSnapshot.entries.map((entry) {
        final songData = entry.value;
        if (songData is Map) {
          return SongRequest.fromMap(songData, entry.key);
        } else {
          throw ArgumentError('Expected a Map for song data, but got ${songData.runtimeType}');
        }
      }).toList();
    } else {
      return [];
    }
  }

  Future<void> getTimeoutMinutes() async {
    final snapshot = await database.child('_settings/timeout_minutes_for_songs').get();
    timeoutMinutes = tryCast<int>(snapshot.value) ?? 30;
  }

  bool didWaitTimeout(DateTime date) {
    final difference = DateTime.now().difference(date).abs();
    return difference >= Duration(minutes: timeoutMinutes);
  }

  Future<int?> uploadSongRequestOrReturnWithRemainingMinutes() async {
    if (singerTitle.text.isEmpty) {
      titleError = 'A cím nem lehet üres';
    }
    if (urlLink.text.isEmpty) {
      urlError = 'A link nem lehet üres';
    }
    if (singerTitle.text.isEmpty || urlLink.text.isEmpty) {
      notifyListeners();
      return -1;
    }
    
    var songRequestsCopy = List<SongRequest>.from(songRequests);
    songRequestsCopy.sort((a, b) => a.upload.compareTo(b.upload));

    var lastUploadByUser =
        songRequestsCopy.lastWhereOrNull((element) => element.user == FirebaseAuth.instance.currentUser!.uid);
    if (lastUploadByUser == null || didWaitTimeout(lastUploadByUser.upload)) {
      uploadSongRequest(singerTitle.text, urlLink.text);
      singerTitle.clear();
      urlLink.clear();
      return null;
    } else {
      return timeoutMinutes - DateTime.now().difference(lastUploadByUser.upload).inMinutes;
    }
  }
}
