import 'package:flutter/material.dart';
import 'package:purlaw/components/third_party/modified_td_dialog/modified_td_alert_dialog.dart';
import 'package:purlaw/viewmodels/theme_viewmodel.dart';
import 'package:tdesign_flutter/tdesign_flutter.dart';

import '../third_party/modified_td_dialog/modified_td_input_dialog.dart';

class PurlawAlertDialog extends StatelessWidget {
  final String title;
  final String? content;
  final String rightBtnTitle;
  final dynamic Function() acceptAction;
  final bool destructiveOperation;
  const PurlawAlertDialog({super.key, required this.title, this.content, required this.rightBtnTitle, required this.acceptAction, this.destructiveOperation = false});

  @override
  Widget build(BuildContext context) {
    final themeModel = getThemeModel(context);
    return ModifiedTDAlertDialog(
      title: title,
      content: content,
      backgroundColor: themeModel.themeData.scaffoldBackgroundColor,
      titleColor: themeModel.themeData.colorScheme.onBackground,
      contentColor: themeModel.themeData.colorScheme.onBackground.withOpacity(0.8),
      rightBtn: TDDialogButtonOptions(
        // titleColor: (destructiveOperation ? Colors.redAccent : themeModel.colorModel.generalFillColor),
          theme: TDButtonTheme.danger,
          title: rightBtnTitle, action: acceptAction
      ),
    );
  }
}

class PurlawInputDialog extends StatelessWidget {
  final String title;
  final String? content;
  final String? defaultText;
  final Function(String) onSubmitted;
  const PurlawInputDialog({super.key, required this.title, this.content, required this.onSubmitted, this.defaultText});

  @override
  Widget build(BuildContext context) {
    TextEditingController controller = TextEditingController(text: defaultText);
    final themeModel = getThemeModel(context);
    return ModifiedTDInputDialog(
      textEditingController: controller,
      title: title,
        // backgroundColor: themeModel.themeData.scaffoldBackgroundColor,
        titleColor: themeModel.themeData.colorScheme.onBackground,
      leftBtn: TDDialogButtonOptions(
        title: '取消',
        titleColor: themeModel.themeData.colorScheme.onBackground,
        action: (){}
      ),
      rightBtn: TDDialogButtonOptions(
          title: '确定',
          action: () {
            onSubmitted(controller.text);
          }),
    );
  }
}

