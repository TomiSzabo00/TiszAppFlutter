import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:shimmer/shimmer.dart';
import 'package:tiszapp_flutter/viewmodels/pictures_viewmodel.dart';

class UploadPicturesScreen extends StatefulWidget {
  const UploadPicturesScreen({
    super.key,
    required this.isAdmin,
  });

  final bool isAdmin;

  @override
  State<UploadPicturesScreen> createState() => _UploadPicturesScreenState();
}

class _UploadPicturesScreenState extends State<UploadPicturesScreen> {
  //PicturesViewModel _viewModel = PicturesViewModel();
  bool _isMultipleSelection = false;
  AssetPathEntity? _path;

  Future<List<AssetPathEntity>> _categoryFuture = Future.value([]);

  @override
  void initState() {
    super.initState();
    _categoryFuture = PhotoManager.getAssetPathList();
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
          const Expanded(
            flex: 4,
            child: Text('asd'),
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
          return GridView.custom(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              mainAxisSpacing: 2,
              crossAxisSpacing: 2,
            ),
            childrenDelegate: SliverChildBuilderDelegate(
              (BuildContext context, int index) {
                final AssetEntity entity = snapshot.data![index];
                return Image(
                  image: AssetEntityImageProvider(
                    entity,
                    isOriginal: false,
                    thumbnailSize: const ThumbnailSize(200, 200),
                  ),
                  fit: BoxFit.cover,
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
          return DropdownButton<AssetPathEntity>(
            hint: const Text('Album'),
            value: _path,
            onChanged: (AssetPathEntity? newValue) {
              setState(() {
                _path = newValue;
              });
            },
            items: snapshot.data!.map<DropdownMenuItem<AssetPathEntity>>(
                (AssetPathEntity value) {
              return DropdownMenuItem<AssetPathEntity>(
                value: value,
                child: Text(value.name),
              );
            }).toList(),
          );
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
      icon: Row(
        children: [
          Icon(
            MdiIcons.checkboxMultipleBlankOutline,
            color: _isMultipleSelection ? Colors.blue : Colors.grey,
          ),
          Text(
            'Több kiválasztása',
            style: TextStyle(
              color: _isMultipleSelection ? Colors.blue : Colors.grey,
            ),
          ),
        ],
      ),
      onPressed: () {
        setState(() {
          _isMultipleSelection = !_isMultipleSelection;
        });
      },
    );
  }
}
