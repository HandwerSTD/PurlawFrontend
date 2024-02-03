
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class ImageLoader extends StatelessWidget {
  final String url;
  final double? width;
  final double? height;
  final double? borderRadius;
  final EdgeInsetsGeometry? margin;
  final Widget? errorWidget;
  final Widget? loadingWidget;
  const ImageLoader(
      {required this.url,
        this.width,
        this.height,
        this.errorWidget,
        this.loadingWidget,
        this.borderRadius,
        this.margin,
        super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius ?? 0),
        child: CachedNetworkImage(
          imageUrl: url,
          width: width,
          height: height,
          fit: BoxFit.cover,
          errorWidget: (errorWidget != null ? (_, __, ___) => errorWidget! : null),
          placeholder: (loadingWidget != null ? (_, __) => loadingWidget! : null),
        ),
      ),
    );
  }
}

class ImageLoaderWithMemory extends StatelessWidget {
  final String url;
  final double? width;
  final double? height;
  final double? borderRadius;
  final EdgeInsetsGeometry? margin;
  final Widget? errorWidget;
  final Widget? loadingWidget;
  final Function saveRatio;
  const ImageLoaderWithMemory(
      {required this.url,
      this.width,
      this.height,
        this.errorWidget,
        this.loadingWidget,
      this.borderRadius,
        this.margin,
        required this.saveRatio,
      super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius ?? 0),
        child: CachedNetworkImage(
          imageUrl: url,
          width: width,
          height: height,
          fit: BoxFit.cover,
          imageBuilder: (context, image) {
            image.resolve(const ImageConfiguration())
                .addListener(ImageStreamListener((image, _) {
                  // print("${image.image.height}x${image.image.width}");
              saveRatio(image.image.height.toDouble(), image.image.width.toDouble());
            }));
            return Image(image: image);
          },
          errorWidget: (errorWidget != null ? (_, __, ___) => errorWidget! : null),
          placeholder: (loadingWidget != null ? (_, __) => loadingWidget! : null),
        ),
      ),
    );
  }
}

class AppIconImage extends StatelessWidget {
  final EdgeInsetsGeometry? margin;
  final double? size;
  const AppIconImage({this.margin, this.size, super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
        child: Image.asset('assets/rounded_app_icon.png', width: size??108, height: size??108,));
  }
}

