import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class CustomCachedNetworkImage extends StatelessWidget {
  final String imageUrl;
  final BoxFit fit;
  final BoxFit errorBoxFit;
  final String? onErrorAsset;
  final double imageHeight;
  final double imageWidth;
  final double borderRadius;
  const CustomCachedNetworkImage({
    Key? key,
    required this.imageUrl,
    this.fit = BoxFit.contain,
    this.errorBoxFit = BoxFit.contain,
    this.onErrorAsset,
    this.imageHeight = 100,
    this.imageWidth = 100,
    this.borderRadius = 0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      clipBehavior: Clip.antiAlias,
      child: CachedNetworkImage(
        imageUrl: imageUrl,
        fit: fit,
        width: imageWidth,
        height: imageHeight,
        progressIndicatorBuilder: (BuildContext context, String value, DownloadProgress progress) => Center(
          child: Shimmer(
            gradient: LinearGradient(
              colors: [Colors.grey.shade200, Colors.white],
            ),
            child: Container(
              height: imageHeight,
              width: imageWidth,
              color: Colors.white,
            ),
          ),
        ),
        errorWidget: (
          BuildContext context,
          String url,
          dynamic error,
        ) =>
            Text("No data found"),
      ),
    );
  }
}
