import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:provider/provider.dart';
import 'package:tiszapp_flutter/colors.dart';
import 'package:tiszapp_flutter/viewmodels/karaoke/karaoke_basic_viewmodel.dart';
import 'package:tiszapp_flutter/widgets/3d_button.dart';
import 'package:tiszapp_flutter/widgets/karaoke/karaoke_tile.dart';

class KaraokeBasicScreen extends StatefulWidget {
  const KaraokeBasicScreen({super.key, required this.isAdmin});

  final bool isAdmin;

  @override
  KaraokeBasicScreenState createState() => KaraokeBasicScreenState();
}

class KaraokeBasicScreenState extends State<KaraokeBasicScreen> {
  @override
  void initState() {
    super.initState();
    context.read<KaraokeBasicViewModel>().subscribeToUserChanges();
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<KaraokeBasicViewModel>();
    final isDarkTheme = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Karaoke'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            const SizedBox(
              width: double.infinity,
              child: Text(
                'Akik már jelentkeztek:',
                style: TextStyle(fontSize: 16),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: () {
                if (viewModel.signedUpUsers.isEmpty) {
                  return const Center(
                    child: Text('Még senki sem jelentkezett.'),
                  );
                } else {
                  return Scrollbar(
                    thumbVisibility: true,
                    child: SingleChildScrollView(
                      child: SlidableAutoCloseBehavior(
                        child: Column(
                          children: List.generate(
                              viewModel.signedUpUsers.length, (index) {
                            if (widget.isAdmin) {
                              final key = Key(
                                  viewModel.signedUpUsers[index].user.uid +
                                      viewModel.signedUpUsers[index].music);
                              return Slidable(
                                  key: key,
                                  groupTag: 0,
                                  endActionPane: ActionPane(
                                    extentRatio: 0.3,
                                    motion: const DrawerMotion(),
                                    children: [
                                      SlidableAction(
                                        onPressed: (context) => {
                                          viewModel.removeFromKaraoke(
                                              viewModel.signedUpUsers[index])
                                        },
                                        borderRadius: BorderRadius.circular(12),
                                        backgroundColor: Colors.red,
                                        foregroundColor: Colors.white,
                                        icon: Icons.delete,
                                        label: 'Törlés',
                                      ),
                                    ],
                                  ),
                                  startActionPane: ActionPane(
                                    extentRatio: 0.3,
                                    motion: const DrawerMotion(),
                                    children: [
                                      () {
                                        if (viewModel
                                            .signedUpUsers[index].didPlay) {
                                          return SlidableAction(
                                            onPressed: (context) => {
                                              viewModel.markAsNotPlayed(
                                                  viewModel
                                                      .signedUpUsers[index])
                                            },
                                            borderRadius:
                                                BorderRadius.circular(12),
                                            backgroundColor: Colors.grey,
                                            foregroundColor: Colors.white,
                                            icon: Icons.close_rounded,
                                            label: 'Mégse',
                                          );
                                        } else {
                                          return SlidableAction(
                                            onPressed: (context) => {
                                              viewModel.markAsPlayed(viewModel
                                                  .signedUpUsers[index])
                                            },
                                            borderRadius:
                                                BorderRadius.circular(12),
                                            backgroundColor: Colors.green,
                                            foregroundColor: Colors.white,
                                            icon: Icons.check_rounded,
                                            label: 'Elénekelve',
                                          );
                                        }
                                      }(),
                                    ],
                                  ),
                                  child: KaraokeTile(
                                    data: viewModel.signedUpUsers[index],
                                  ));
                            }
                            return KaraokeTile(
                              data: viewModel.signedUpUsers[index],
                            );
                          }),
                        ),
                      ),
                    ),
                  );
                }
              }(),
            ),
            const SizedBox(height: 20),
            Button3D(
              onPressed: () => _showSignUpModalSheet(isDarkTheme),
              child: Text(
                'Jelentkezés',
                style: TextStyle(
                  color: isDarkTheme
                      ? CustomColor.btnTextNight
                      : CustomColor.btnTextDay,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 20, width: double.infinity),
          ],
        ),
      ),
    );
  }

  void _showSignUpModalSheet(bool isDarkTheme) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.0),
      ),
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
              top: 20,
              left: 20,
              right: 20),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Jelentkezés',
                  style: TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Add meg a választott szám címét, és be is állhatsz a sorba!',
                  style: TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller:
                      context.read<KaraokeBasicViewModel>().musicController,
                  decoration: const InputDecoration(
                    labelText: 'Szám címe (és előadója)',
                    border: OutlineInputBorder(),
                  ),
                  onSubmitted: (value) => FocusManager.instance.primaryFocus
                      ?.unfocus(), // hide keyboard
                  maxLength: 30,
                  autocorrect: false,
                ),
                const SizedBox(height: 20),
                const Text(
                  '''Kérlek csak olyan számot válassz, ami illik a tábor szabályaihoz! Ha ez mégsem sikerülne, a szervezők törölni fogják a jelentkezésedet.
Ez érvényes arra az esetre is, ha ez már a sokadik jelentkezésed lenne.''',
                  style: TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 20),
                Button3D(
                  width: 140,
                  onPressed: () {
                    context.read<KaraokeBasicViewModel>().signUpForKaraoke();
                    Navigator.pop(context);
                  },
                  child: Text(
                    'Beállok a sorba',
                    style: TextStyle(
                      color: isDarkTheme
                          ? CustomColor.btnTextNight
                          : CustomColor.btnTextDay,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        );
      },
    );
  }
}
