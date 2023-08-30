import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:provider/provider.dart';
import 'package:tiszapp_flutter/models/pics/filter.dart';
import 'package:tiszapp_flutter/models/pics/picture_category.dart';
import 'package:tiszapp_flutter/widgets/picture_item.dart';
import '../../viewmodels/pictures_viewmodel.dart';

// ignore: must_be_immutable
class PicturesScreen extends StatefulWidget {
  PicturesScreen({
    super.key,
    required this.isReview,
    required this.isAdmin,
  });

  final bool isReview;
  final bool isAdmin;
  PicturesViewModel? viewModel;
  @override
  State<PicturesScreen> createState() => _PicturesScreenState();
}

class _PicturesScreenState extends State<PicturesScreen> {
  @override
  void initState() {
    super.initState();
    widget.viewModel = Provider.of<PicturesViewModel>(context, listen: false);
    widget.viewModel!.getImages(widget.isReview);
    widget.viewModel!.getNumberOfTeams();
  }

  @override
  void dispose() {
    widget.viewModel?.disposeListeners();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<PicturesViewModel>();
    SchedulerBinding.instance.addPostFrameCallback((_) {
      viewModel.filterPictures();
    });
    bool isDarkTheme =
        MediaQuery.of(context).platformBrightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(
        title: widget.isReview
            ? const Text('Képek ellenőrzése')
            : const Text('Képek'),
      ),
      body: Container(
        decoration: BoxDecoration(
          color: isDarkTheme ? Colors.black : Colors.white,
        ),
        child: ListView.builder(
          itemCount: viewModel.filteredPictures.length,
          itemBuilder: (context, index) {
            return PictureItem(
              pic: viewModel.filteredPictures[index],
              isReview: widget.isReview,
              isAdmin: widget.isAdmin,
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          showFiltersBottomSheet();
        },
        label: const Text('Szűrő'),
        icon: Stack(
          children: <Widget>[
            Icon(MdiIcons.filter),
            Positioned(
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(1),
                decoration: BoxDecoration(
                  color: viewModel.filters.isEmpty
                      ? Colors.transparent
                      : Colors.red,
                  borderRadius: BorderRadius.circular(6),
                ),
                constraints: const BoxConstraints(
                  minWidth: 12,
                  minHeight: 12,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  void showFiltersBottomSheet() {
    showModalBottomSheet(
      showDragHandle: true,
      isScrollControlled: true,
      useSafeArea: true,
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return ListView(
              children: [
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                  child: Text(
                    'Szűrők',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const Divider(),
                ExpansionTile(
                  title: const Text(
                    'Csapat',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  children: List.generate(widget.viewModel?.numberOfTeams ?? 0,
                      (index) {
                    return CheckboxListTile(
                      title: Text('${index + 1}. csapat'),
                      value: widget.viewModel!.filters
                          .contains(Filter(teamNum: index + 1)),
                      onChanged: (value) {
                        widget.viewModel!.toggleTeamFilter(teamNum: index + 1);
                        setState(() {});
                      },
                    );
                  }),
                ),
                ExpansionTile(
                  title: const Text(
                    'Kategória',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  children: List.generate(
                    PictureCategory.values.length,
                    (index) {
                      return CheckboxListTile(
                        title: Text(PictureCategory.values[index].displayName),
                        value: widget.viewModel!.filters.contains(
                            Filter(category: PictureCategory.values[index])),
                        onChanged: (value) {
                          widget.viewModel!.toggleCategoryFilter(
                              category: PictureCategory.values[index]);
                          setState(() {});
                        },
                      );
                    },
                  ),
                ),
                ExpansionTile(
                    title: const Text(
                      'Dátum',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    children: List.generate(DateFilter.values.length, (index) {
                      return CheckboxListTile(
                        title: Text(DateFilter.values[index].displayName),
                        value: widget.viewModel!.filters
                            .contains(Filter(date: DateFilter.values[index])),
                        onChanged: (value) {
                          widget.viewModel!
                              .toggleDateFilter(date: DateFilter.values[index]);
                          setState(() {});
                        },
                      );
                    })),
                ExpansionTile(
                  title: const Text(
                    'Nap képei',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  children: [
                    CheckboxListTile(
                      title: const Text('Csak nap képei'),
                      value: widget.viewModel!.filters
                          .contains(Filter(isPicOfTheDay: true)),
                      onChanged: (value) {
                        widget.viewModel!
                            .toggleIsPicOfTheDayFilter(isPicOfTheDay: true);
                        setState(() {});
                      },
                    ),
                    CheckboxListTile(
                      title: const Text('Csak nem nap képei'),
                      value: widget.viewModel!.filters
                          .contains(Filter(isPicOfTheDay: false)),
                      onChanged: (value) {
                        widget.viewModel!
                            .toggleIsPicOfTheDayFilter(isPicOfTheDay: false);
                        setState(() {});
                      },
                    ),
                  ],
                ),
              ],
            );
          },
        );
      },
    );
  }
}
