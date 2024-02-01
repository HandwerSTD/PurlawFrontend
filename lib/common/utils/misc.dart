
import 'package:date_format/date_format.dart';


/// 响应式开发断点设置
class Responsive {
  // 响应式断点
  static const smallDp = 400.0;
  static const mediumDp = 800.0;
  // 断点标记
  static String sm = 'sm';
  static String md = 'md';
  static String lg = 'lg';

  /// 检查屏幕尺寸
  static String checkWidth(double width) {
    if (width < smallDp) return 'sm';
    if (width < mediumDp) return 'md';
    return 'lg';
  }

  /// 自动限制组件尺寸到手机形态
  ///
  /// 适用于折叠屏、平板限制尺寸到手机形态
  static double? assignWidthSmall(double width) {
    if (width < smallDp) return null;
    return smallDp;
  }
  /// 自动限制组件尺寸最大到折叠屏形态
  ///
  /// 适用于平板限制尺寸到折叠屏形态，手机、折叠屏不受影响
  static double? assignWidthMedium(double width) {
    if (width < mediumDp) return null;
    return mediumDp;
  }
  /// 自动限制组件尺寸
  ///
  /// 适用于折叠屏、平板限制尺寸到其上一级设备
  static double? assignWidthStM(double width) {
    if (width < smallDp) return null;
    if (width < mediumDp) return smallDp;
    return mediumDp;
  }
}

/// 时间格式化
class TimeUtils {
  static String formatDateTime(int timestamp) {
    var date = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
    return formatDate(date, [yyyy,'年',mm,'月',dd,'日 ',HH,':',nn,':', ss]);
  }
}

