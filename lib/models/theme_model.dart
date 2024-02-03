import 'package:flutter/material.dart';

/// 全局主题与颜色管理
class ThemeModel {
  static const defaultThemeColor = Color.fromARGB(255, 176, 156, 241);

  static const List<Color> presetThemes = [defaultThemeColor, Colors.blueAccent];
  static const List<String> presetNames = ["法藤紫", "远峰蓝"];

  late Color themeColor;
  late ThemeData themeData ;
  bool dark;
  late ColorModel colorModel;

  ThemeModel({required this.dark, Color? setColor}) {
    themeColor = setColor ?? defaultThemeColor;
    themeData = ThemeData(
        fontFamily: 'HarmonyOS Sans SC',
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color.fromARGB(255, 176, 156, 241),
          brightness: dark ? Brightness.dark : Brightness.light
        ));
    colorModel = (dark ? ColorModel.dark() : ColorModel.light());
  }

  void setThemeColor(Color color) {
    themeColor = color;
    if (!dark) {
      setLightTheme();
    } else {
      setDarkTheme();
    }
  }

  void setLightTheme() {
    themeData = ThemeData(
        fontFamily: 'HarmonyOS Sans SC',
        colorScheme: ColorScheme.fromSeed(
            seedColor: themeColor, brightness: Brightness.light));
    colorModel = ColorModel.light();
  }

  void setDarkTheme() {
    themeData = ThemeData(
        fontFamily: 'HarmonyOS Sans SC',
        colorScheme: ColorScheme.fromSeed(
            seedColor: themeColor, brightness: Brightness.dark));
    colorModel = ColorModel.dark();
  }

  void switchDarkMode() {
    if (dark) {
      setLightTheme();
    } else {
      setDarkTheme();
    }
    dark = !dark;
  }
}

class ColorModel {
  Color loginTextFieldColor;
  Color loginTextIndicatorColor;
  Color generalFillColor;
  Color generalFillColorLight;
  Color generalFillColorBright;
  Color chatInputDividerColor;
  Color secondarySurfaceColor;

  ColorModel({
    required this.loginTextFieldColor,
    required this.generalFillColor,
    required this.chatInputDividerColor,
    required this.loginTextIndicatorColor,
    required this.generalFillColorLight,
    required this.secondarySurfaceColor,
    required this.generalFillColorBright
  });

  static ColorModel light() {
    return ColorModel(
      loginTextFieldColor: const Color(0xfff2f2f2),
        generalFillColorBright: const Color(0xffe4ddfc),
      generalFillColorLight: const Color(0xffb09cf1),
      generalFillColor: const Color(0xFF8465EC),
        chatInputDividerColor: const Color(0xffcbbcfa),
      loginTextIndicatorColor: const Color(0xff343e60),
        secondarySurfaceColor: const Color(0xffffffff)
    );
  }
  static ColorModel dark() {
    return ColorModel(
        loginTextFieldColor: Colors.black,
        generalFillColorBright: const Color(0xffe4ddfc),
        generalFillColorLight: const Color(0xffb09cf1),
        generalFillColor: const Color(0xFF8465EC),
        chatInputDividerColor: const Color(0xffcbbcfa),
        loginTextIndicatorColor: const Color(0xffffffff),
        secondarySurfaceColor: const Color(0xff444444)
    );
  }
}