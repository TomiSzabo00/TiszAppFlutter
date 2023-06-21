// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:tiszapp_flutter/colors.dart';

class StyleOf3dButton {
  final double width;
  final double height;
  final BorderRadius borderRadius;
  final double z;
  final double tapped;

  const StyleOf3dButton({
    this.width = 120,
    this.height = 60,
    this.borderRadius = const BorderRadius.all(
      Radius.circular(7.0),
    ),
    this.z = 10.0,
    this.tapped = 0.0,
  });
}

class Button3D extends StatefulWidget {
  final VoidCallback onPressed;
  final Widget child;
  final StyleOf3dButton style;
  final double width;
  final double height;

  const Button3D({
    super.key,
    required this.onPressed,
    required this.child,
    this.style = const StyleOf3dButton(),
    this.width = 120,
    this.height = 60,
  });

  @override
  State<StatefulWidget> createState() => Button3DState();
}

class Button3DState extends State<Button3D> {
  bool isTapped = false;

  Widget _buildBackLayout() {
    final isDarkTheme =
        MediaQuery.of(context).platformBrightness == Brightness.dark;
    return Padding(
      padding: EdgeInsets.only(top: widget.style.z),
      child: DecoratedBox(
        position: DecorationPosition.background,
        decoration: BoxDecoration(
          borderRadius: widget.style.borderRadius,
          boxShadow: [
            BoxShadow(
              color: isDarkTheme
                  ? CustomColor.btnSideNight
                  : CustomColor.btnSideDay,
              //offset: const Offset(2, 0),
            )
          ],
        ),
        child: ConstrainedBox(
          constraints: BoxConstraints.expand(
            width: widget.width,
            height: widget.height - widget.style.z,
          ),
        ),
      ),
    );
  }

  Widget _buildTopLayout() {
    final isDarkTheme =
        MediaQuery.of(context).platformBrightness == Brightness.dark;
    return Padding(
      padding: EdgeInsets.only(
        top: isTapped ? widget.style.z - widget.style.tapped : 3,
      ),
      child: DecoratedBox(
        position: DecorationPosition.background,
        decoration: BoxDecoration(
          borderRadius: widget.style.borderRadius,
          boxShadow: [
            BoxShadow(
              color: isDarkTheme
                  ? CustomColor.btnFaceNight
                  : CustomColor.btnFaceDay,
            ),
          ],
        ),
        child: ConstrainedBox(
          constraints: BoxConstraints.expand(
            width: widget.width,
            height: widget.height - widget.style.z,
          ),
          child: Container(
            padding: EdgeInsets.zero,
            alignment: Alignment.center,
            child: widget.child,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Stack(
        alignment: AlignmentDirectional.topCenter,
        children: <Widget>[_buildBackLayout(), _buildTopLayout()],
      ),
      onTapDown: (TapDownDetails event) {
        setState(() {
          isTapped = true;
        });
      },
      onTapCancel: () {
        setState(() {
          isTapped = false;
        });
      },
      onTapUp: (TapUpDetails event) {
        setState(() {
          isTapped = false;
        });
        widget.onPressed();
      },
    );
  }
}
