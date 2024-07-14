import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:tiszapp_flutter/helpers/try_cast.dart';
import 'package:tiszapp_flutter/models/song_request_data.dart';
import 'package:tiszapp_flutter/models/user_data.dart';

// Insert globally used database getters here. E.x.: getNumberOfTeams() or getFirstDay()

class DatabaseService {
  static get database {
    if (kDebugMode) {
      return FirebaseDatabase.instance.ref().child('debug');
    } else {
      return FirebaseDatabase.instance.ref();
    }
  }

  static Future<int> getNumberOfTeams() async {
    final snapshot = await database.child('_settings/number_of_teams').get();
    if (snapshot.exists) {
      return tryCast<int>(snapshot.value) ?? 4;
    }
    return 4;
  }

  static Future<UserData> getUserData(String uid) async {
    if (FirebaseAuth.instance.currentUser == null) {
      return UserData.empty();
    }
    return await FirebaseDatabase.instance
        .ref()
        .child('users/$uid')
        .get()
        .then((snapshot) {
      if (snapshot.value != null) {
        return UserData.fromSnapshot(snapshot);
      }
      return UserData.empty();
    });
  }

  static Future<String> getDriveURL({required int teamNum}) {
    return database
        .child('porty_drive_links/$teamNum')
        .get()
        .then((snapshot) => tryCast<String>(snapshot.value) ?? "");
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
        return songsList;
      }
    } catch (e) {
      print('Error fetching songs: $e');
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
}
