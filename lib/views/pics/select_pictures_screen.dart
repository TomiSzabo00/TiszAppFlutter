import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:photo_manager/photo_manager.dart';

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
  AssetEntity? _selectedImage;
  int _selectedImageIndex = 0;

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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Képek feltöltése"),
      ),
      body: Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          Expanded(
            flex: 4,
            child: () {
              if (_selectedImage == null) {
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
                        _selectedImage!,
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
          if (_selectedImage == null) {
            WidgetsBinding.instance.addPostFrameCallback((_) async {
              setState(() {
                _selectedImage = snapshot.data!.first;
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
                      color: _selectedImageIndex == index
                          ? Colors.blue.withOpacity(0.4)
                          : Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          setState(() {
                            _selectedImage = entity;
                            _selectedImageIndex = index;
                          });
                        },
                        splashColor: Colors.blue.withOpacity(0.2),
                      ),
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
        });
      },
    );
  }
}
