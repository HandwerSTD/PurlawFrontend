import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

class CacheUtil {
  static Future<int> total() async {
    Directory tempDir = await getTemporaryDirectory();
    int total = await _reduce(tempDir);
    return total;
  }

  static Future<void> clear() async {
    Directory tempDir = await getTemporaryDirectory();
    await _delete(tempDir);
  }
  static Future<void> clearRemote() async {
    Directory tempDir = Directory(p.join((await getTemporaryDirectory()).path, 'just_audio_cache'));
    await _delete(tempDir);
  }

  static Future<int> _reduce(final FileSystemEntity file) async {
    if (file is File) {
      int length = await file.length();
      return length;
    }

    if (file is Directory) {
      final List<FileSystemEntity> children = file.listSync();

      int total = 0;

      if (children.isNotEmpty)
        for (final FileSystemEntity child in children) {
          total += await _reduce(child);
        }

      return total;
    }

    return 0;
  }

  static Future<void> _delete(FileSystemEntity file) async {
    if (file is Directory) {
      final List<FileSystemEntity> children = file.listSync();
      for (final FileSystemEntity child in children) {
        await _delete(child);
      }
    } else {
      await file.delete();
    }
  }
}