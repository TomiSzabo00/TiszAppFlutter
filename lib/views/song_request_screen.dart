import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tiszapp_flutter/models/song_request_data.dart';
import 'package:tiszapp_flutter/services/database_service.dart';
import '../viewmodels/song_request_viewmodel.dart';

class SongRequestScreen extends StatefulWidget {
  const SongRequestScreen({
    Key? key,
    required this.isAdmin,
  });

  final bool isAdmin;

  @override
  State<SongRequestScreen> createState() => SongRequestScreenState();
}
class SongRequestScreenState extends State<SongRequestScreen> {
  final TextEditingController singerTitle = TextEditingController();
  final TextEditingController urlLink = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final viewModel = Provider.of<SongRequestViewModel>(context, listen: false);
      viewModel.fetchSongs();
    });
  }

  void showDeleteDialog(BuildContext context, String songRequestId) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Zenekérés törlése'),
          content: const Text('Biztosan ki akarod törölni ezt a kérést?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Mégse'),
            ),
            TextButton(
              onPressed: () {
                Provider.of<SongRequestViewModel>(context, listen: false).deleteSongRequest(songRequestId);
                Navigator.of(context).pop();
              },
              child: const Text('Törlés'),
            ),
          ],
        );
      },
    );
  }

  Future<bool> hasAtLeast30MinutesDifference(DateTime date1, DateTime date2) async {
    final difference = date1.difference(date2).abs(); // Get the absolute difference
    DatabaseReference ref = DatabaseService.database;
    final timeLimit = await ref.child('timeLimit').get();
    return difference >= Duration(minutes: timeLimit.value as int); // Check if the difference is at least 30 minutes
  }

  void showSnackBar(BuildContext context, String message) {
    final snackBar = SnackBar(
      content: Text(message),
      duration: const Duration(seconds: 2), // Duration for the SnackBar to be visible
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<SongRequestViewModel>();


    return Scaffold(
      appBar: AppBar(
        title: const Text('Zene kérések'),
      ),
      body: Column(
        children: [
          SizedBox(
            height: 200,
            child: Column(
                  children: [
                    SizedBox(
                      height: 80,
                      child: Padding(
                                  padding: const EdgeInsets.all(4.0),
                                  child: Autocomplete<String>(
                                    optionsBuilder: (TextEditingValue textEditingValue) {
                                      if (textEditingValue.text.isEmpty) {
                                        return const Iterable<String>.empty();
                                      }
                                      return viewModel.songRequests
                                          .map((song) => song.name)
                                          .where((title) => title.toLowerCase().contains(textEditingValue.text.toLowerCase()));
                                    },
                                    onSelected: (String selection) {
                                      singerTitle.text = selection; // Populate the text field with the selected title
                                    },
                                    fieldViewBuilder: (BuildContext context, TextEditingController textEditingController, FocusNode focusNode, VoidCallback onFieldSubmitted) {
                                      return TextField(
                                        controller: singerTitle,
                                        decoration: const InputDecoration(
                                          border: OutlineInputBorder(),
                                          hintText: 'Előadó - Cím (teljes)',
                                        ),
                                      );
                                    },
                                  ),
                                ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: TextField(
                          controller: urlLink,
                          decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          hintText: 'Link a zenéhez.',
                        ),),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(1.0),
                      child: ElevatedButton(
                        onPressed: () async {
                          bool timeLimit = false;
                          for (var songRequest in viewModel.songRequests) {
                            if(songRequest.user == FirebaseAuth.instance.currentUser!.uid){
                              if(await hasAtLeast30MinutesDifference(DateTime.now(), songRequest.upload)){
                                timeLimit = true;
                              }
                              else{
                                timeLimit = false;
                                break;
                              }
                            }
                          }
                          if(timeLimit){
                            viewModel.uploadSongRequest(singerTitle.text, urlLink.text);
                          }
                          else{
                            showSnackBar(context, 'Csak meghatározott időközönként lehet zenét kérni!');
                          }
                          singerTitle.clear();
                          urlLink.clear();
                          timeLimit = false;
                        },
                        child: const Text('Feltöltés'),
                      ),
                    ),
                  ],
                ),
          ),
          Expanded(
                child: ListView.builder(
                  itemCount: viewModel.songRequests.length,
                  itemBuilder: (context, index) {
                    final songRequest = viewModel.songRequests[index];
                    return widget.isAdmin
                      ? AdminSongListItem(songRequest: songRequest, onDelete: () => showDeleteDialog(context, songRequest.id))
                      : UserSongListItem(songRequest: songRequest);
                  },
                ),
              ),
        ],
      )
        
    );
  }
}
class AdminSongListItem extends StatelessWidget {
  final SongRequest songRequest;
  final VoidCallback onDelete;

  const AdminSongListItem({
    Key? key,
    required this.songRequest,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(songRequest.name),
      subtitle: Text(songRequest.url),
      trailing: IconButton(
        icon: const Icon(Icons.close),
        onPressed: onDelete,
      ),
    );
  }
}

class UserSongListItem extends StatelessWidget {
  final SongRequest songRequest;

  const UserSongListItem({
    Key? key,
    required this.songRequest,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(songRequest.name),
      subtitle: Text(songRequest.url),
    );
  }
}