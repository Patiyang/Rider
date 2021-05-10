import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

import 'customText.dart';

class Loading extends StatelessWidget {
  final String text;
  final Color color;
  final double height;
  final double size;
  final double fontSize;
  final Color spinkitColor;
  final Color textColor;
  final FontWeight fontWeight;

  const Loading({Key key, this.text, this.color, this.height, this.size, this.spinkitColor, this.textColor, this.fontSize, this.fontWeight}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      color: color ?? Colors.white.withOpacity(.7),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SpinKitFadingGrid(color: spinkitColor ?? Colors.black, size: size ?? 20),
            text != null ? SizedBox(height: 10) : SizedBox.shrink(),
            text != null
                ? CustomText(text: text ?? '', letterSpacing: .3, fontWeight:fontWeight?? FontWeight.w500, size: fontSize?? 15, color: textColor ?? Colors.black)
                : SizedBox.shrink()
          ],
        ),
      ),
    );
  }
}

class LoadingImages extends StatelessWidget {
  final String text;
  final Color color;
  final double height;
  final double size;

  const LoadingImages({Key key, this.text, this.color, this.height, this.size}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      color: color ?? Colors.transparent,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SpinKitRipple(color: Colors.black, size: size ?? 25),
            text != null ? SizedBox(height: 10) : SizedBox.shrink(),
            text != null ? CustomText(text: text ?? '', letterSpacing: .3, fontWeight: FontWeight.w500, size: 15) : SizedBox.shrink()
          ],
        ),
      ),
    );
  }
}
