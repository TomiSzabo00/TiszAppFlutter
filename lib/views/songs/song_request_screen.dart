import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tiszapp_flutter/viewmodels/songs/song_request_viewmodel.dart';

class SongsSummaryScreen extends StatefulWidget {
  const SongsSummaryScreen({
    Key? key,
    required this.isAdmin,
  }) : super(key: key);

  final bool isAdmin;

  @override
  SongsSummaryScreenState createState() => SongsSummaryScreenState();
}

class SongsSummaryScreenState extends State<SongsSummaryScreen> {
  @override
  void initState() {
    super.initState();
    if (widget.isAdmin) {
      Provider.of<SongRequestViewModel>(context, listen: false).loadRequests();
    } else {
      Provider.of<SongRequestViewModel>(context, listen: false).loadData();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Zenekérés'),
      ),
      body: const Center(
        child: Text('TODO'),
      ),
    );
  }
}
