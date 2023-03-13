import 'dart:io';

import 'package:file_manage_demo/controllers/home_screen_controller.dart';
import 'package:file_manage_demo/services/file_manager_service.dart';
import 'package:file_manage_demo/widgets/subtitle.dart';
import 'package:flutter/material.dart';

class ViewWidget extends StatelessWidget {
  const ViewWidget({
    super.key,
    required this.entity,
    this.controller,
    this.onTap,
  });

  final FileSystemEntity entity;
  final HomeScreenController? controller;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    assert(onTap != null && controller == null ||
        onTap == null && controller != null);
    return Card(
      child: ListTile(
        leading: FileManagerService.isFile(entity)
            ? const Icon(Icons.file_copy_outlined)
            : const Icon(Icons.folder),
        title: Text(FileManagerService.basename(entity)),
        subtitle: SubTitle(entity: entity),
        onTap: onTap ??
            () {
              if (FileManagerService.isDirectory(entity)) {
                controller!.backStream.add(true);
                controller!.managerController.openDirectory(entity);
              }
            },
      ),
    );
  }
}
