// This enum is to sort files and directory
import 'dart:io';

import 'package:file_manage_demo/services/file_manager_service.dart';
import 'package:file_manage_demo/utils/string_utils.dart';

enum SortBy {
  name,
  type,
  date,
  size,
}

extension SortByE on SortBy {
  String get label => name.capitalize();

  Future<List<FileSystemEntity>> sortEntitles(
    String path,
  ) async {
    final List<FileSystemEntity> list = await Directory(path).list().toList();
    switch (this) {
      case SortBy.name:
        final dirs = list.whereType<Directory>().toList();
        dirs.sort(
            (a, b) => a.path.toLowerCase().compareTo(b.path.toLowerCase()));

        final files = list.whereType<File>().toList();
        files.sort(
            (a, b) => a.path.toLowerCase().compareTo(b.path.toLowerCase()));

        return [...dirs, ...files];

      case SortBy.type:
        final dirs = list.whereType<Directory>().toList();

        dirs.sort(
            (a, b) => a.path.toLowerCase().compareTo(b.path.toLowerCase()));

        final files = list.whereType<File>().toList();

        files.sort((a, b) => a.path
            .toLowerCase()
            .split('.')
            .last
            .compareTo(b.path.toLowerCase().split('.').last));
        return [...dirs, ...files];

      case SortBy.date:
        List<_Stat> stats = [];
        for (FileSystemEntity e in list) {
          final stat = await e.stat();
          stats.add(
            _Stat(
              path: e.path,
              dateTime: stat.modified,
              type: stat.type.toString(),
              size: FileManagerService.formatBytes(stat.size),
            ),
          );
        }

        stats.sort((b, a) => a.dateTime.compareTo(b.dateTime));

        list.sort((a, b) => stats
            .indexWhere((element) => element.path == a.path)
            .compareTo(stats.indexWhere((element) => element.path == b.path)));
        return list;

      case SortBy.size:
        Map<String, int> sizeMap = {};
        for (FileSystemEntity e in list) {
          sizeMap[e.path] = (await e.stat()).size;
        }

        final dirs = list.whereType<Directory>().toList();
        dirs.sort(
            (a, b) => a.path.toLowerCase().compareTo(b.path.toLowerCase()));

        final files = list.whereType<File>().toList();

        final List<MapEntry<String, int>> sizeMapList =
            sizeMap.entries.toList();
        sizeMapList.sort((b, a) => a.value.compareTo(b.value));

        files.sort((a, b) => sizeMapList
            .indexWhere((element) => element.key == a.path)
            .compareTo(
                sizeMapList.indexWhere((element) => element.key == b.path)));
        return [...dirs, ...files];
    }
  }
}

enum FileType {
  png,
  jpg,
  pdf,
  txt,
}

class _Stat {
  final String path;
  final String size;
  final String type;
  final DateTime dateTime;

  _Stat({
    required this.path,
    required this.dateTime,
    required this.size,
    required this.type,
  });
}
