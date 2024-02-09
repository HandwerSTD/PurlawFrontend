import 'package:flutter/material.dart';

/// 全局主题与颜色管理
class ThemeModel {
  static const defaultThemeColor = Color.fromARGB(255, 176, 156, 241);

  static const List<Color> presetThemes = [
    defaultThemeColor,
    Color(0xff0a59f7),
    Color(0xffde7638)
  ];
  static const List<String> presetNames = ["法藤紫", "星河蓝", "丹霞橙"];
  static const List<ColorModel> presetModelsLight = [light1,light2,light3,];
  static const List<ColorModel> presetModelsDark = [dark1,dark2,dark3,];

  late Color themeColor;
  late int index;
  late ThemeData themeData;
  bool dark;
  late ColorModel colorModel;

  ThemeModel({required this.dark, int? setIndex}) {
    index = setIndex ?? 0;
    themeColor = presetThemes[index];
    themeData = ThemeData(
        fontFamily: 'HarmonyOS Sans SC',
        colorScheme: ColorScheme.fromSeed(
            seedColor: themeColor,
            brightness: dark ? Brightness.dark : Brightness.light));
    colorModel = (dark ? presetModelsDark[index] : presetModelsLight[index]);
  }

  void setThemeColor(int newIndex) {
    index = newIndex;
    themeColor = presetThemes[index];
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
    colorModel = presetModelsLight[index];
  }

  void setDarkTheme() {
    themeData = ThemeData(
        fontFamily: 'HarmonyOS Sans SC',
        colorScheme: ColorScheme.fromSeed(
            seedColor: themeColor, brightness: Brightness.dark));
    colorModel = presetModelsDark[index];
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
  final Color loginTextFieldColor;
  final Color loginTextIndicatorColor;
  final Color generalFillColor;
  final Color generalFillColorLight;
  final Color generalFillColorBright;
  final Color chatInputDividerColor;
  final Color secondarySurfaceColor;

  const ColorModel(
      {required this.loginTextFieldColor,
      required this.generalFillColor,
      required this.chatInputDividerColor,
      required this.loginTextIndicatorColor,
      required this.generalFillColorLight,
      required this.secondarySurfaceColor,
      required this.generalFillColorBright});
}

const ColorModel light1 = ColorModel(
    loginTextFieldColor: Color(0xfff2f2f2),
    generalFillColorBright: Color(0xffe4ddfc),
    generalFillColorLight: Color(0xffb09cf1),
    generalFillColor: Color(0xFF8465EC),
    chatInputDividerColor: Color(0xffcbbcfa),
    loginTextIndicatorColor: Color(0xff343e60),
    secondarySurfaceColor: Color(0xffffffff));

const ColorModel dark1 = ColorModel(
    loginTextFieldColor: Colors.black,
    generalFillColorBright: Color(0xffe4ddfc),
    generalFillColorLight: Color(0xffb09cf1),
    generalFillColor: Color(0xFF8465EC),
    chatInputDividerColor: Color(0xffcbbcfa),
    loginTextIndicatorColor: Color(0xffffffff),
    secondarySurfaceColor: Color(0xff444444));

const ColorModel light2 = ColorModel(
    loginTextFieldColor: Color(0xfff2f2f2),
    generalFillColorBright: Color(0xff93baff),
    generalFillColorLight: Color(0xff5291ff),
    generalFillColor: Color(0xff0a59f7),
    chatInputDividerColor: Color(0xff5291ff),
    loginTextIndicatorColor: Color(0xff343e60),
    secondarySurfaceColor: Color(0xffffffff));

const ColorModel dark2 = ColorModel(
    loginTextFieldColor: Colors.black,
    generalFillColorBright: Color(0xff93baff),
    generalFillColorLight: Color(0xff74a6ff),
    generalFillColor: Color(0xff317af7),
    chatInputDividerColor: Color(0xff5291ff),
    loginTextIndicatorColor: Color(0xffffffff),
    secondarySurfaceColor: Color(0xff444444));

const ColorModel light3 = ColorModel(
    loginTextFieldColor: Color(0xfff2f2f2),
    generalFillColorBright: Color(0xffF9de98),
    generalFillColorLight: Color(0xffF9BC64),
    generalFillColor: Color(0xffde7638),
    chatInputDividerColor: Color(0xffF9BC64),
    loginTextIndicatorColor: Color(0xff343e60),
    secondarySurfaceColor: Color(0xffffffff));

const ColorModel dark3 = ColorModel(
    loginTextFieldColor: Colors.black,
    generalFillColorBright: Color(0xffF9de98),
    generalFillColorLight: Color(0xffF9BC64),
    generalFillColor: Color(0xffde7638),
    chatInputDividerColor: Color(0xffF9BC64),
    loginTextIndicatorColor: Color(0xffffffff),
    secondarySurfaceColor: Color(0xff444444));