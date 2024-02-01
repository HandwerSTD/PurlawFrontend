import 'package:flutter/material.dart';

class PurlawRRectButton extends StatelessWidget {
  final double? height;
  final double? width;
  final double radius;
  final bool disabled;
  final Color? backgroundColor;
  final Color? disabledColor;
  final Widget child;
  final EdgeInsetsGeometry? padding, margin;
  final Function onClick;
  const PurlawRRectButton({
    this.height = 36,
    this.width = 36,
    this.radius = 36,
    this.disabled = false,
    required this.child,
    this.backgroundColor,
    this.disabledColor,
    this.padding, this.margin,
    required this.onClick,
    super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () { if (!disabled) onClick(); },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(radius),
          color: (disabled ? disabledColor : backgroundColor)
        ),
        alignment: Alignment.center,
        width: width,
        height: height,
        margin: margin,
        padding: padding,
        child: child,
      ),
    );
  }
}
