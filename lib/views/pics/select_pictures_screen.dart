import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:tiszapp_flutter/viewmodels/pictures_viewmodel.dart';
import 'package:tiszapp_flutter/views/pics/upload_picture_screen.dart';
// ignore: depend_on_referenced_packages
import 'package:collection/collection.dart';

class SelectPicturesScreen extends StatefulWidget {
  const SelectPicturesScreen({
    super.key,
    required this.isAdmin,
  });

  final bool isAdmin;

  @override
  State<SelectPicturesScreen> createState() => _SelectPicturesScreenState();
}

class _SelectPicturesScreenState extends State<SelectPicturesScreen> {
  bool _isMultipleSelection = false;
  AssetPathEntity? _path;
  AssetEntity? _shownImage;
  final List<int> _selectedImageIndexes = [];
  List<AssetEntity> _images = [];

  int _maxNumberOfImages = 10;

  Future<List<AssetPathEntity>> _categoryFuture = Future.value([]);

  @override
  void initState() {
    super.initState();
    _categoryFuture = PhotoManager.getAssetPathList(
      filterOption: FilterOptionGroup(
        imageOption: const FilterOption(
          sizeConstraint: SizeConstraint(
            minWidth: 100,
            minHeight: 100,
            maxWidth: 10000,
            maxHeight: 10000,
          ),
        ),
        videoOption: const FilterOption(
          durationConstraint: DurationConstraint(
            max: Duration(seconds: 0),
          ),
        ),
      ),
    );

    PicturesViewModel.getMaxNumberOfImages((value) {
      if (value != null) {
        setState(() {
          _maxNumberOfImages = value;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Kép kiválasztása"),
        actions: [
          if (_shownImage != null)
            IconButton(
              icon: Icon(MdiIcons.arrowRight),
              onPressed: () async {
                final nullableFiles =
                    await Future.wait(_selectedImageIndexes.map(
                  (index) => _images[index].file,
                ));
                final files = nullableFiles.whereNotNull().toList();
                if (files.isEmpty) {
                  return;
                }
                // ignore: use_build_context_synchronously
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => UploadPictureScreen(
                      isAdmin: widget.isAdmin,
                      images: files,
                    ),
                  ),
                );
              },
            ),
        ],
      ),
      body: Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          Expanded(
            flex: 4,
            child: () {
              if (_shownImage == null) {
                return const Center(
                  child: Text(
                    'Képek betöltése...',
                    style: TextStyle(fontSize: 20),
                  ),
                );
              } else {
                return Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox.expand(
                      child: Container(color: Colors.black.withOpacity(0.8)),
                    ),
                    Image(
                      image: AssetEntityImageProvider(
                        _shownImage!,
                      ),
                      fit: BoxFit.contain,
                    ),
                  ],
                );
              }
            }(),
          ),
          Expanded(
            flex: 5,
            child: Column(
              children: [
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: selectionHeadline(),
                ),
                Expanded(child: imagesGrid()),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget imagesGrid() {
    return FutureBuilder(
      future: _path?.getAssetListPaged(
        page: 0,
        size: 100,
      ),
      builder: (context, AsyncSnapshot<List<AssetEntity>> snapshot) {
        if (snapshot.hasData) {
          if (_shownImage == null) {
            WidgetsBinding.instance.addPostFrameCallback((_) async {
              setState(() {
                _shownImage = snapshot.data!.first;
              });
            });
          }
          if (_images.isEmpty) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              setState(() {
                _images = snapshot.data!;
              });
            });
          }
          return GridView.custom(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              mainAxisSpacing: 2,
              crossAxisSpacing: 2,
            ),
            childrenDelegate: SliverChildBuilderDelegate(
              (BuildContext context, int index) {
                final AssetEntity entity = snapshot.data![index];
                if (_selectedImageIndexes.isEmpty) {
                  toggleSelection(0);
                }
                return Stack(
                  alignment: Alignment.center,
                  children: [
                    Positioned.fill(
                      child: Image(
                        image: AssetEntityImageProvider(
                          entity,
                          isOriginal: false,
                          thumbnailSize: const ThumbnailSize(200, 200),
                        ),
                        fit: BoxFit.cover,
                      ),
                    ),
                    Material(
                      color: _selectedImageIndexes.contains(index)
                          ? Colors.white.withOpacity(0.5)
                          : Colors.transparent,
                      child: InkWell(
                          onTap: () {
                            setState(() {
                              toggleSelection(index);
                              _shownImage =
                                  snapshot.data![_selectedImageIndexes.last];
                            });
                          },
                          splashColor: Colors.blue.withOpacity(0.2),
                          child: () {
                            if (!_isMultipleSelection) {
                              return const SizedBox(
                                width: 200,
                                height: 200,
                              );
                            }
                            return SizedBox(
                              height: 200,
                              width: 200,
                              child: Column(
                                mainAxisSize: MainAxisSize.max,
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      CircleAvatar(
                                        backgroundColor: _selectedImageIndexes
                                                .contains(index)
                                            ? Colors.blue
                                            : Colors.white.withOpacity(0.5),
                                        radius: 10,
                                      ),
                                      Container(
                                          margin: const EdgeInsets.all(5),
                                          padding: const EdgeInsets.all(0),
                                          decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(100),
                                              border: Border.all(
                                                  width: 1,
                                                  color: Colors.white)),
                                          child: () {
                                            if (_selectedImageIndexes
                                                .contains(index)) {
                                              return SizedBox(
                                                height: 20,
                                                width: 20,
                                                child: AspectRatio(
                                                  aspectRatio: 1,
                                                  child: Center(
                                                    child: Text(
                                                      (_selectedImageIndexes
                                                                  .indexOf(
                                                                      index) +
                                                              1)
                                                          .toString(),
                                                      style: const TextStyle(
                                                          color: Colors.white,
                                                          fontSize: 12),
                                                    ),
                                                  ),
                                                ),
                                              );
                                            } else {
                                              return const SizedBox(
                                                width: 20,
                                                height: 20,
                                              );
                                            }
                                          }()),
                                    ],
                                  ),
                                ],
                              ),
                            );
                          }()),
                    ),
                  ],
                );
              },
              childCount: snapshot.data!.length,
              findChildIndexCallback: (Key key) {
                // Re-use elements.
                if (key is ValueKey<int>) {
                  return key.value;
                }
                return null;
              },
            ),
          );
        } else {
          return const Text('Betöltés...');
        }
      },
    );
  }

  Widget selectionHeadline() {
    return Row(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        categorySelector(),
        selectMultipleButton(),
      ],
    );
  }

  Widget categorySelector() {
    return FutureBuilder(
      future: _categoryFuture,
      builder: (BuildContext context,
          AsyncSnapshot<List<AssetPathEntity>> snapshot) {
        if (snapshot.hasData) {
          if (_path == null) {
            WidgetsBinding.instance.addPostFrameCallback((_) async {
              setState(() {
                _path = snapshot.data!.first;
              });
            });
          }
          return DropdownMenu<AssetPathEntity>(
              label: const Text('Album'),
              width: MediaQuery.of(context).size.width * 0.4,
              dropdownMenuEntries: [
                for (final path in snapshot.data!)
                  DropdownMenuEntry(
                    label: path.name,
                    value: path,
                  ),
              ],
              initialSelection: _path,
              onSelected: (value) {
                setState(() {
                  _path = value;
                });
              },
              textStyle: const TextStyle(fontSize: 12),
              menuHeight: MediaQuery.of(context).size.height * 0.3,
              menuStyle: const MenuStyle(
                visualDensity: VisualDensity.compact,
              ),
              inputDecorationTheme: InputDecorationTheme(
                  isDense: true,
                  constraints: const BoxConstraints(maxHeight: 40),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  contentPadding: const EdgeInsets.only(left: 10)));
        } else {
          return const Text('Betöltés...');
        }
      },
    );
  }

  Widget selectMultipleButton() {
    return IconButton(
      padding: const EdgeInsets.all(10),
      style: ButtonStyle(
        backgroundColor: MaterialStateColor.resolveWith(
          (states) => _isMultipleSelection
              ? Colors.blue.withOpacity(0.3)
              : Colors.grey.withOpacity(0.3),
        ),
      ),
      splashColor: Colors.transparent,
      focusColor: Colors.transparent,
      highlightColor: Colors.blue.withOpacity(0.3),
      hoverColor: Colors.transparent,
      icon: Icon(
        MdiIcons.checkboxMultipleBlankOutline,
        color: _isMultipleSelection ? Colors.blue : Colors.grey,
      ),
      onPressed: () {
        setState(() {
          _isMultipleSelection = !_isMultipleSelection;
          if (!_isMultipleSelection) {
            toggleSelection(_selectedImageIndexes.last);
          }
        });
      },
    );
  }

  void toggleSelection(int index) {
    if (!_isMultipleSelection) {
      _selectedImageIndexes.clear();
      _selectedImageIndexes.add(index);
      return;
    } else {
      if (_selectedImageIndexes.length == _maxNumberOfImages &&
          !_selectedImageIndexes.contains(index)) {
        return;
      }
      if (_selectedImageIndexes.contains(index) &&
          _selectedImageIndexes.length > 1) {
        _selectedImageIndexes.remove(index);
      } else {
        _selectedImageIndexes.add(index);
      }
    }
  }
}
