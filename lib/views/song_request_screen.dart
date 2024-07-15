// ignore_for_file: use_build_context_synchronously

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
          title: const Text('Zenekérés'),
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
                  return listItem(widget.isAdmin, songRequest, () => showDeleteDialog(context, songRequest.id));
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
            child: TextField(
              controller: viewModel.singerTitle,
              autocorrect: false,
              onChanged: (value) {
                setState(() {
                  viewModel.titleError = null;
                });
              },
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                hintText: 'Előadó - Cím (teljes)',
                errorText: viewModel.titleError,
              ),
            ),
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(4.0),
            child: TextField(
              controller: viewModel.urlLink,
              autocorrect: false,
              onChanged: (value) {
                setState(() {
                  viewModel.urlError = null;
                });
              },
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                hintText: 'Link a zenéhez.',
                errorText: viewModel.urlError,
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(1.0),
          child: ElevatedButton(
            onPressed: () async {
              final remainingMinutes = await viewModel.uploadSongRequestOrReturnWithRemainingMinutes();
              if (remainingMinutes != null) {
                if (remainingMinutes == -1) {
                  return;
                }
                showSnackBar(context, 'Még $remainingMinutes percet kell várnod a következő kérésig.');
              } else {
                showSnackBar(context, 'Sikeresen elküldted a kérést.');
              }
            },
            child: const Text('Feltöltés'),
          ),
        ),
      ],
    );
  }

  Widget listItem(bool isAdmin, SongRequest songRequest, VoidCallback onDelete) {
    return ListTile(
      title: Text(songRequest.name),
      subtitle: Text(songRequest.url),
      trailing: isAdmin
          ? IconButton(
              icon: const Icon(Icons.delete),
              onPressed: onDelete,
            )
          : null,
    );
  }
}
