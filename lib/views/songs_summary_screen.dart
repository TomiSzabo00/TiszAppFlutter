import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tiszapp_flutter/widgets/songs_list.dart';
import '../viewmodels/songs_viewmodel.dart';

class SongsSummaryScreen extends StatefulWidget {
  const SongsSummaryScreen({Key? key}) : super(key: key);

  @override
  SongsSummaryScreenState createState() => SongsSummaryScreenState();
}

class SongsSummaryScreenState extends State<SongsSummaryScreen> {
  @override
  void initState() {
    super.initState();
    Provider.of<SongsViewModel>(context, listen: false).loadSongs();
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<SongsViewModel>();
    return () {
      if (viewModel.isLoading) {
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Center(
              child: CircularProgressIndicator(),
            ),
            SizedBox(height: 20),
            Text('Dalok betöltése...'),
          ],
        );
      } else {
        return Column(children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              autocorrect: false,
              onChanged: (value) {
                viewModel.filterSongs(value);
              },
              decoration: const InputDecoration(
                hintText: 'Keresés dalszöveg vagy cím alapján',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(16.0)),
                ),
              ),
            ),
          ),
          Expanded(
            child: SongsList(songs: viewModel.filteredSongs),
          )
        ]);
      }
    }();
  }
}
