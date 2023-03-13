import 'dart:io';
import 'package:file_manage_demo/services/file_manager_service.dart';
import 'package:flutter/material.dart';

import 'package:file_manage_demo/helpers/file_manager_enums.dart';
import 'package:file_manage_demo/helpers/file_manager_controller.dart';

typedef FileManagerBuilder = Widget Function(
  BuildContext context,
  List<FileSystemEntity> snapshot,
);

class FileManagerWidget extends StatefulWidget {
  final Widget? loadingWidget;
  final Widget? emptyWidget;
  final Widget? errorWidget;
  final FileManagerController controller;
  final FileManagerBuilder builder;
  // Hide the files and folders that are hidden.
  final bool hideHiddenEntity;

  const FileManagerWidget({
    super.key,
    this.emptyWidget,
    this.loadingWidget,
    this.errorWidget,
    required this.controller,
    required this.builder,
    this.hideHiddenEntity = true,
  });

  @override
  FileManagerWidgetState createState() => FileManagerWidgetState();
}

class FileManagerWidgetState extends State<FileManagerWidget> {
  Future<List<Directory>?>? currentDir;

  @override
  void dispose() {
    widget.controller.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    if (widget.controller.getCurrentPath.isNotEmpty) {
      currentDir = Future.value([widget.controller.getCurrentDirectory]);
    } else {
      currentDir = FileManagerService.getStorageList();
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Directory>?>(
      future: currentDir,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          widget.controller.setCurrentPath = snapshot.data!.first.path;

          return _body(context);
        } else if (snapshot.hasError) {
          debugPrint("${snapshot.error}");

          return _errorWidget(snapshot.error.toString());
        }

        return _loadingWidget();
      },
    );
  }

  Widget _body(BuildContext context) {
    final sortBy = widget.controller.getSortedByNotifier;

    return ValueListenableBuilder<String>(
      valueListenable: widget.controller.getPathNotifier,
      builder: (context, pathSnapshot, _) {
        return ValueListenableBuilder<SortBy>(
          valueListenable: sortBy,
          builder: (context, snapshot, _) {
            return FutureBuilder<List<FileSystemEntity>>(
              future: sortBy.value.sortEntitles(pathSnapshot),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  List<FileSystemEntity> entities = snapshot.data!;
                  if (entities.isEmpty) {
                    return _emptyWidget();
                  }
                  if (widget.hideHiddenEntity) {
                    entities = entities.where(
                      (element) {
                        final basename = FileManagerService.basename(element);
                        if (basename == "" || basename.startsWith('.')) {
                          return false;
                        } else {
                          return true;
                        }
                      },
                    ).toList();
                  }

                  return widget.builder(context, entities);
                } else if (snapshot.hasError) {
                  debugPrint("${snapshot.error}");
                  return _errorWidget(snapshot.error.toString());
                } else {
                  return _loadingWidget();
                }
              },
            );
          },
        );
      },
    );
  }

  Widget _emptyWidget() => widget.emptyWidget != null
      ? widget.emptyWidget!
      : Center(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(Icons.info_outline),
              SizedBox(width: 10),
              Text("Empty Directory"),
            ],
          ),
        );

  Widget _errorWidget(String error) => Center(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.red),
            const SizedBox(width: 10),
            Flexible(
              child: Text(
                "An error has occurred $error",
                style: const TextStyle(color: Colors.red),
              ),
            ),
          ],
        ),
      );

  Widget _loadingWidget() => widget.loadingWidget != null
      ? widget.loadingWidget!
      : const Center(child: CircularProgressIndicator());
}
