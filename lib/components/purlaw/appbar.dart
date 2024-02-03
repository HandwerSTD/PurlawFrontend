import 'package:flutter/material.dart';

class PurlawAppTitleBar {
  final String title;
  final bool showBack;
  bool centerTitle;
  PurlawAppTitleBar({required this.title, required this.showBack, this.centerTitle = true});

  PreferredSizeWidget build(BuildContext context) {
    return AppBar(
      title: Text(title),
      centerTitle: centerTitle,
      automaticallyImplyLeading: showBack,
    );
  }
}
