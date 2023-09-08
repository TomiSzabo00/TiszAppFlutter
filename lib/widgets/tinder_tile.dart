import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:tiszapp_flutter/models/tinder/tinder_data.dart';
import 'package:tiszapp_flutter/models/tinder/tinder_tile_state.dart';
import 'package:tiszapp_flutter/models/user_data.dart';

// ignore: must_be_immutable
class TinderTile extends StatelessWidget {
  TinderTile({
    Key? key,
    required this.data,
    this.localImage,
    this.width,
    this.state = TinderTileState.none,
  }) : super(key: key);

  final TinderData data;
  final Image? localImage;
  final double? width;
  TinderTileState state;

  @override
  Widget build(BuildContext context) {
    return Material(
      child: SizedBox(
        width: width ?? MediaQuery.of(context).size.width * 0.8,
        height: (width ?? MediaQuery.of(context).size.width * 0.8) * 4 / 3,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            alignment: Alignment.bottomLeft,
            children: [
              Container(
                  width: width ?? MediaQuery.of(context).size.width,
                  height: (width ?? MediaQuery.of(context).size.width * 0.8) *
                      4 /
                      3,
                  foregroundDecoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.transparent, getFadeColor(state)],
                      stops: const [0.6, 0.96],
                    ),
                  ),
                  child: () {
                    if (localImage != null) {
                      return localImage;
                    }
                    return CachedNetworkImage(
                      imageUrl: data.imageUrl ?? UserData.defaultUrl,
                      fit: BoxFit.fill,
                    );
                  }()),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  SizedBox(
                    width: width ?? MediaQuery.of(context).size.width * 0.9,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 14, bottom: 14),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Flexible(
                            child: Text(
                              data.name,
                              maxLines: 3,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Text(
                            data.teamNum.teamNumberAsString,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color getFadeColor(TinderTileState state) {
    switch (state) {
      case TinderTileState.none:
        return Colors.black;
      case TinderTileState.liking:
        return Colors.green;
      case TinderTileState.disliking:
        return Colors.red;
    }
  }
}
