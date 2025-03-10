import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class NoDataAvailable extends StatelessWidget {
  const NoDataAvailable({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(child: Text('No Data Available'));
  }
}

class NoDataAvailableImage extends StatelessWidget {
  const NoDataAvailableImage({
    super.key,
    this.imageHeight = 200,
    this.imageWidth,
    this.imageColor,
    this.showText = true,
  });

  final double imageHeight;
  final double? imageWidth;
  final Color? imageColor;
  final bool showText;

  @override
  Widget build(BuildContext context) {
    Color? tempImageColor = imageColor;
    tempImageColor ??=
        Theme.of(context).brightness == Brightness.dark ? Colors.white60 : Colors.black12;
    if (!showText) {
      return SvgPicture.asset(
        'assets/no-data-ghost.svg',
        height: imageHeight,
        width: imageWidth,
        colorFilter: ColorFilter.mode(tempImageColor, BlendMode.srcIn),
      );
    }
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SvgPicture.asset(
            'assets/no-data-ghost.svg',
            height: imageHeight,
            width: imageWidth,
            colorFilter: ColorFilter.mode(tempImageColor, BlendMode.srcIn),
          ),
          const SizedBox(height: 10),
          Text("No Data Available"),
        ],
      ),
    );
  }
}
