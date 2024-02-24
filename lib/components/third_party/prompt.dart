import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:grock/grock.dart';
import 'package:purlaw/common/utils/database/database_util.dart';
import 'package:purlaw/models/theme_model.dart';
import 'package:tdesign_flutter/tdesign_flutter.dart';

enum ToastType {
  success("success"),
  error("error"),
  warning("warning"),
  info("info");

  final String type;

  const ToastType(this.type);
}

void showToast(String message,
    {Duration? duration, ToastType? toastType, Alignment? alignment}) {
  // return Prompt.showToast(message, duration: duration ?? 3.seconds, type: toastType, alignment: alignment ?? Alignment.center);

  switch (toastType?.type) {
    case "info":
      {
        Grock.toast(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.info_outline_rounded,
                  color: Colors.white,
                ),
                Text(
                  " $message",
                  style: const TextStyle(fontSize: 16, color: Colors.white),
                )
              ],
            ),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
            alignment: alignment ?? Alignment.bottomCenter,
            backgroundColor: ToastColors.info,
            boxShadow: TDThemeData.defaultData().shadowsBase,
            duration: duration ?? 3.seconds);
        break;
      }
    case "warning":
      {
        Grock.toast(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.warning_amber_rounded,
                  color: Colors.white,
                ),
                Text(
                  " $message",
                  style: const TextStyle(fontSize: 16, color: Colors.white),
                )
              ],
            ),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
            alignment: alignment ?? Alignment.bottomCenter,
            backgroundColor: ToastColors.warning,
            boxShadow: TDThemeData.defaultData().shadowsBase,
            duration: duration ?? 3.seconds);
        break;
      }
    case "success":
      {
        Grock.toast(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.done_rounded,
                  color: Colors.white,
                ),
                Text(
                  " $message",
                  style: const TextStyle(fontSize: 16, color: Colors.white),
                )
              ],
            ),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
            alignment: alignment ?? Alignment.bottomCenter,
            boxShadow: TDThemeData.defaultData().shadowsBase,
            backgroundColor: ToastColors.success,
            duration: duration ?? 3.seconds);
        break;
      }
    case "error":
      {
        Grock.toast(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.error_outline_rounded,
                  color: Colors.white,
                ),
                Text(
                  " $message",
                  style: const TextStyle(fontSize: 16, color: Colors.white),
                )
              ],
            ),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
            alignment: alignment ?? Alignment.bottomCenter,
            backgroundColor: ToastColors.error,
            boxShadow: TDThemeData.defaultData().shadowsBase,
            duration: duration ?? 3.seconds);
        break;
      }
    default:
      {
        Grock.toast(
            text: message,
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
            alignment: alignment ?? Alignment.bottomCenter,
            textStyle: const TextStyle(fontSize: 16, color: Colors.white),
            boxShadow: TDThemeData.defaultData().shadowsBase,
            duration: duration ?? 3.seconds);
      }
  }
}

void showLoading(String message) {
  Grock.fullScreenDialog(
    openDuration: 0.milliseconds,
    openAlignment: Alignment.center,
      closeAlignment: Alignment.center,
      child: Scaffold(
        backgroundColor: const Color(0x66000000),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0
        ),
        body: Center(
          child: Container(
            width: 144,
            padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 24),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              color: Colors.white.withOpacity(0.5)
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SpinKitRing(color: ThemeModel.presetThemes[DatabaseUtil.getThemeIndex()],),
                Text("\n$message", style: TextStyle(fontSize: 14, color: ThemeModel.presetThemes[DatabaseUtil.getThemeIndex()]),)
              ],
            ),
          ),
        ),
      )
  );
}
void hideLoading() {
  Grock.closeGrockOverlay();
}
