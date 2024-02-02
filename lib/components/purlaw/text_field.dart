/// Purlaw 项目的通用输入框封装

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:purlaw/common/constants/constants.dart';
import 'package:purlaw/viewmodels/theme_viewmodel.dart';

import '../../common/utils/misc.dart';
import '../../models/theme_model.dart';

/// 登录界面的输入框
class PurlawLoginTextField extends StatelessWidget {
  final EdgeInsetsGeometry? margin;
  final String hint;
  final TextEditingController controller;
  final bool? secureText;
  const PurlawLoginTextField(
      {required this.hint,
      required this.controller,
      this.secureText,
      this.margin,
      super.key});

  @override
  Widget build(BuildContext context) {
    ThemeModel themeModel = Provider.of<ThemeViewModel>(context).themeModel;
    // print("width: ${MediaQuery.of(context).size.width}");
    return LayoutBuilder(builder: (context, constraints) {
      return Container(
        decoration: BoxDecoration(
            color: (themeModel.dark ? Colors.grey[800] : themeModel
                .colorModel
                .loginTextFieldColor),
            borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.all(14),
        margin: margin,
        width: Responsive.assignWidthSmall(constraints.maxWidth),
        child: TextField(
          autocorrect: false,
          controller: controller,
          decoration: loginInputDeco(hint),
          obscureText: secureText ?? false,
          style: const TextStyle(fontSize: 14),
        ),
      );
    });
  }

  InputDecoration loginInputDeco(String hint) {
    return InputDecoration(
        hintText: hint,
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 3),
        border: InputBorder.none);
  }
}

/// 对话界面的输入框
///
/// 适用于 AI 对话、评论区发送消息
/// 可进行多行输入
class PurlawChatTextField extends StatelessWidget {
  final String hint;
  final FocusNode focusNode;
  final bool readOnly;
  final TextEditingController controller;
  final double? borderRadius;

  const PurlawChatTextField(
      {required this.hint,
      required this.focusNode,
      required this.readOnly,
      required this.controller,
      this.borderRadius,
      super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme =
        Provider.of<ThemeViewModel>(context).themeModel.themeData.colorScheme;
    return Container(
      // margin: EdgeInsets.only(right: 2),
      // color: Colors.red,
      constraints: const BoxConstraints(
        maxHeight: 144.0,
        minHeight: 36.0,
      ),
      child: TextField(
          focusNode: focusNode,
          autocorrect: false,
          autofocus: false,
          readOnly: readOnly,
          controller: controller,
          minLines: 1,
          maxLines: null,
          keyboardType: TextInputType.multiline,
          decoration: chatInputDeco(hint, Colors.transparent, borderRadius),
          style: TextStyle(fontSize: 16),
          ),
    );
  }

  InputDecoration chatInputDeco(String hint, Color fillColor, double? radius) {
    return InputDecoration(
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        border: OutlineInputBorder(
            borderSide: BorderSide.none,
            borderRadius: (radius == null
                ? const BorderRadius.only(
                    topLeft: Radius.circular(6), topRight: Radius.circular(6))
                : BorderRadius.circular(radius))),
        filled: true,
        fillColor: fillColor,
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey));
  }
}
