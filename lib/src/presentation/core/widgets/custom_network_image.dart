import 'package:cached_network_image/cached_network_image.dart';
import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:material_ui/material_ui.dart';

import '../theme/theme.dart';

class CustomNetworkImage extends StatelessWidget {
  final String imageUrl;
  final double? height;
  final double? width;
  final double? radius;
  final Widget? placeholder;
  final Widget? errorWidget;
  final bool isLoading;

  const CustomNetworkImage({
    super.key,
    required this.imageUrl,
    this.height,
    this.width,
    this.radius,
    this.placeholder,
    this.errorWidget,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final imageHeight = height ?? context.sizes.md2;
    final imageWidth = width ?? context.sizes.md2;
    final cornerRadius = radius ?? context.radius.xs;

    return ClipRRect(
      borderRadius: BorderRadius.circular(cornerRadius),
      child: CachedNetworkImage(
        imageUrl: imageUrl,
        height: imageHeight,
        width: imageWidth,
        fit: BoxFit.cover,
        imageBuilder: (context, imageProvider) {
          return Container(
            height: imageHeight,
            width: imageWidth,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(cornerRadius),
              image: DecorationImage(image: imageProvider, fit: BoxFit.cover),
            ),
          );
        },
        progressIndicatorBuilder: (context, url, downloadProgress) {
          return placeholder ??
              Container(
                height: imageHeight,
                width: imageWidth,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(cornerRadius),
                  color: context.color.surfaceSubtle,
                ),
                child: Center(
                  child: CupertinoActivityIndicator(
                    color: context.color.warning,
                  ),
                ),
              );
        },
        errorWidget: (context, url, error) {
          return errorWidget ??
              Container(
                height: imageHeight,
                width: imageWidth,
                padding: EdgeInsets.all(context.spacing.sm),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(cornerRadius),
                  color: context.color.surfaceSubtle,
                ),
                child: Center(
                  child: Icon(
                    Icons.image_not_supported,
                    color: context.color.text.tertiary,
                  ),
                ),
              );
        },
      ),
    );
  }
}
