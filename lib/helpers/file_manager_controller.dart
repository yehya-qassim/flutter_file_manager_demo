import 'dart:async';
import 'dart:io';
import 'package:file_manage_demo/helpers/file_manager_enums.dart';
import 'package:file_manage_demo/services/file_manager_service.dart';
import 'package:flutter/widgets.dart';

class FileManagerController {
  final ValueNotifier<String> _path = ValueNotifier<String>('');
  final ValueNotifier<SortBy> _sort = ValueNotifier<SortBy>(SortBy.name);

  _updatePath({required String path}) {
    _path.value = path;
    titleStream.add(path.split('/').last);
  }

  final StreamController<String> titleStream = StreamController<String>();

  ValueNotifier<String> get getPathNotifier => _path;

  ValueNotifier<SortBy> get getSortedByNotifier => _sort;

  SortBy get getSortedBy => _sort.value;

  void sortBy(SortBy sortType) => _sort.value = sortType;

  Directory get getCurrentDirectory => Directory(_path.value);

  String get getCurrentPath => _path.value;

  set setCurrentPath(String path) {
    _updatePath(path: path);
  }

  Future<bool> isRootDirectory() async {
    final List<Directory> storageList =
        await FileManagerService.getStorageList();
    return storageList
        .where((element) => element.path == Directory(_path.value).path)
        .isNotEmpty;
  }

  Future<void> goToParentDirectory({StreamController<bool>? backStream}) async {
    final bool isRoot = await isRootDirectory();
    if (!isRoot) {
      openDirectory(Directory(_path.value).parent);
      final bool isRootAfterUpdate = await isRootDirectory();
      if (isRootAfterUpdate) {
        if (backStream != null) {
          backStream.add(false);
        }
      }
    }
  }

  void openDirectory(FileSystemEntity entity) {
    if (entity is Directory) {
      _updatePath(path: entity.path);
    } else {
      throw Exception("provide a Directory to be opened not a File");
    }
  }

  void dispose() {
    _path.dispose();
    _sort.dispose();
  }
}
