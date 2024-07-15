import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tiszapp_flutter/models/song_request_data.dart';
import '../viewmodels/song_request_viewmodel.dart';

class SongRequestScreen extends StatefulWidget {
  const SongRequestScreen({
    super.key,
    required this.isAdmin,
  });

  final bool isAdmin;

  @override
  State<SongRequestScreen> createState() => SongRequestScreenState();
}

class SongRequestScreenState extends State<SongRequestScreen> {
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
              child: uploadSection(viewModel),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: viewModel.songRequests.length,
                itemBuilder: (context, index) {
                  final songRequest = viewModel.songRequests[index];
                  return widget.isAdmin
                      ? AdminSongListItem(
                          songRequest: songRequest, onDelete: () => showDeleteDialog(context, songRequest.id))
                      : UserSongListItem(songRequest: songRequest);
                },
              ),
            ),
          ],
        ));
  }

  Widget uploadSection(SongRequestViewModel viewModel) {
    return Column(
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
                viewModel.singerTitle.text = selection; // Populate the text field with the selected title
              },
              fieldViewBuilder: (BuildContext context, TextEditingController textEditingController, FocusNode focusNode,
                  VoidCallback onFieldSubmitted) {
                return TextField(
                  controller: viewModel.singerTitle,
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
              controller: viewModel.urlLink,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Link a zenéhez.',
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(1.0),
          child: ElevatedButton(
            onPressed: () async {
              final remainingMinutes = await viewModel.uploadSongRequestWithTimeLimit();
              if (remainingMinutes != null) {
                // ignore: use_build_context_synchronously
                showSnackBar(context, 'Még $remainingMinutes percet kell várnod a következő kérésig.');
              } else {
                // ignore: use_build_context_synchronously
                showSnackBar(context, 'Sikeresen elküldted a kérést.');
              }
            },
            child: const Text('Feltöltés'),
          ),
        ),
      ],
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
