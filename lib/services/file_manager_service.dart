import 'dart:io';
import 'dart:math' as math;

import 'package:path_provider/path_provider.dart';

class FileManagerService {
  static bool isFile(FileSystemEntity entity) {
    return entity is File;
  }

  static bool isDirectory(FileSystemEntity entity) {
    return entity is Directory;
  }

  static String basename(dynamic entity, [bool showFileExtension = true]) {
    if (entity is Directory) {
      return entity.path.split('/').last;
    } else if (entity is File) {
      return (showFileExtension)
          ? entity.path.split('/').last.split('.').first
          : entity.path.split('/').last;
    } else {
      throw Exception("entity must be either File or Directory");
    }
  }

  static String formatBytes(int bytes, [int precision = 2]) {
    if (bytes != 0) {
      final double base = math.log(bytes) / math.log(1024);
      final suffix = const ['B', 'KB', 'MB', 'GB', 'TB'][base.floor()];
      final size = math.pow(1024, base - base.floor());
      return '${size.toStringAsFixed(precision)} $suffix';
    } else {
      return "0B";
    }
  }

  static Future<void> createFolder(String currentPath, String name) async {
    await Directory("$currentPath/$name").create();
  }

  static Future<void> createFile(String currentPath, String name) async {
    await File("$currentPath/$name").create();
  }

  static String getFileExtension(FileSystemEntity file) {
    if (file is File) {
      return file.path.split("/").last.split('.').last;
    } else {
      throw "FileSystemEntity is Directory, not a File";
    }
  }

  // currently this is only available for android
  static Future<List<Directory>> getStorageList() async {
    if (Platform.isAndroid) {
      List<Directory> directories = (await getExternalStorageDirectories())!;

      directories = directories.map(
        (Directory e) {
          final List<String> paths = e.path.split("/");
          return Directory(
            paths
                .sublist(0, paths.indexWhere((element) => element == "Android"))
                .join("/"),
          );
        },
      ).toList();

      return directories;
    }
    return [];
  }
}
