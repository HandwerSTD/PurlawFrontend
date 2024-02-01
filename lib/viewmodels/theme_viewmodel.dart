import 'package:flutter/material.dart';
import 'package:purlaw/common/utils/database/database_util.dart';
import 'package:purlaw/common/utils/database/kvstore.dart';
import 'package:purlaw/models/theme_model.dart';

import 'base_viewmodel.dart';

/// 全局的主题状态管理
class ThemeViewModel extends BaseViewModel {
  late ThemeModel themeModel;

  ThemeViewModel(bool dark) {
    themeModel = ThemeModel(dark: dark);
  }

  void setThemeColor(Color color, {bool update = true}) {
    themeModel.setThemeColor(color);
    if (update) DatabaseUtil.updateThemeColor(ColorsUtil.colorTo6Str(color));
    notifyListeners();
  }

  void switchDarkMode() {
    themeModel.switchDarkMode();
    notifyListeners();
  }
}

class ColorsUtil {
  static Color hexToColor(String code) {
    return Color(int.parse(code.substring(1, 7), radix: 16) + 0xFF000000);
  }

  static String colorTo6Str(Color color) =>
      ("#${color.red.toRadixString(16)}${color.green.toRadixString(16)}${color.blue.toRadixString(16)}");
}
