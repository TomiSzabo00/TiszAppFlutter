// ignore_for_file: depend_on_referenced_packages
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:tiszapp_flutter/models/song_request_data.dart';

import '../services/database_service.dart';

class SongRequestViewModel with ChangeNotifier {
  List<SongRequest> songRequests = [];
  final database = DatabaseService.database;

  final TextEditingController singerTitle = TextEditingController();
  final TextEditingController urlLink = TextEditingController();

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

  Future<bool> hasAtLeast30MinutesDifference(DateTime date1, DateTime date2) async {
    final difference = date1.difference(date2).abs(); // Get the absolute difference
    final timeLimit = await database.child('timeLimit').get();
    return difference >= Duration(minutes: timeLimit.value as int); // Check if the difference is at least 30 minutes
  }

  Future<bool> uploadSongRequestWithTimeLimit() async {
    bool timeLimit = false;
    for (var songRequest in songRequests) {
      if (songRequest.user == FirebaseAuth.instance.currentUser!.uid) {
        if (await hasAtLeast30MinutesDifference(DateTime.now(), songRequest.upload)) {
          timeLimit = true;
        } else {
          timeLimit = false;
          break;
        }
      }
    }
    if (timeLimit) {
      uploadSongRequest(singerTitle.text, urlLink.text);
      singerTitle.clear();
      urlLink.clear();
      return true;
    } else {
      return false;
      // showSnackBar(context, 'Csak meghatározott időközönként lehet zenét kérni!');
    }
  }
}
