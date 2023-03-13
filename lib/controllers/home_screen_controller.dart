import 'dart:async';
import 'dart:io';

import 'package:file_manage_demo/helpers/file_manager_controller.dart';
import 'package:file_manage_demo/helpers/file_manager_enums.dart';
import 'package:file_manage_demo/services/file_manager_service.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class HomeScreenController {
  HomeScreenController();

  final FileManagerController managerController = FileManagerController();
  final StreamController<bool> backStream = StreamController<bool>();

  Future<void> requestPermission() async {
    final permissions = [Permission.storage];
    for (final permission in permissions) {
      final status = await permission.status;
      if (!status.isGranted) {
        await Permission.storage.request();
      }
    }
  }

  Future<void> selectStorage(BuildContext context) async {
    await showDialog(
      context: context,
      builder: (context) => Dialog(
        child: FutureBuilder<List<Directory>>(
          future: FileManagerService.getStorageList(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              final List<FileSystemEntity> storageList = snapshot.data!;
              return Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: storageList
                      .map(
                        (e) => ListTile(
                          title: Text(
                            FileManagerService.basename(e),
                          ),
                          onTap: () {
                            managerController.openDirectory(e);
                            Navigator.pop(context);
                          },
                        ),
                      )
                      .toList(),
                ),
              );
            }
            return const Dialog(
              child: CircularProgressIndicator(),
            );
          },
        ),
      ),
    );
  }

  Future<void> sort(BuildContext context) async {
    await showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: SortBy.values
                .map(
                  (e) => InkWell(
                    onTap: () {
                      managerController.sortBy(e);
                      Navigator.pop(context);
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(e.label),
                    ),
                  ),
                )
                .toList(),
          ),
        ),
      ),
    );
  }

  Future<void> createFolder(BuildContext context) async {
    final TextEditingController folderName = TextEditingController();
    await showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: TextField(
                    decoration: const InputDecoration(
                      hintText: 'Folder Type',
                      labelText: 'Folder name',
                    ),
                    controller: folderName,
                  ),
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width,
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: ElevatedButton(
                      onPressed: () async {
                        try {
                          // Create Folder
                          if (folderName.text.isNotEmpty) {
                            await FileManagerService.createFolder(
                              managerController.getCurrentPath,
                              folderName.text,
                            );
                            // Open Created Folder
                            managerController.setCurrentPath =
                                "${managerController.getCurrentPath}/${folderName.text}";
                          }
                        } catch (e) {
                          debugPrint("Something went wrong ${e.toString()}");
                        }

                        if (context.mounted) {
                          Navigator.pop(context);
                        }
                      },
                      child: const Text('Create Folder'),
                    ),
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
  }

  Future<bool> createFile(BuildContext context) async {
    final TextEditingController fileName = TextEditingController();
    bool result = false;

    await showDialog(
      context: context,
      builder: (context) {
        FileType fileType = FileType.png;
        return Dialog(
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: TextField(
                    decoration: const InputDecoration(
                      hintText: 'File Type',
                      labelText: 'File name',
                    ),
                    controller: fileName,
                  ),
                ),
                StatefulBuilder(
                  builder: (context, setState) => SizedBox(
                    width: MediaQuery.of(context).size.width,
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: DropdownButton<FileType>(
                        value: fileType,
                        items: FileType.values
                            .map(
                              (e) => DropdownMenuItem(
                                value: e,
                                child: Text(
                                  e.name,
                                  style: Theme.of(context).textTheme.titleSmall,
                                ),
                              ),
                            )
                            .toList(),
                        onChanged: (newFileType) {
                          setState(() {
                            fileType = newFileType!;
                          });
                        },
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: MediaQuery.of(context).size.width,
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: ElevatedButton(
                      onPressed: () async {
                        try {
                          if (fileName.text.isNotEmpty) {
                            await FileManagerService.createFile(
                              managerController.getCurrentPath,
                              "${fileName.text}.${fileType.name}",
                            );
                            result = true;
                          }
                        } catch (e) {
                          debugPrint("Something went wrong ${e.toString()}");
                          result = false;
                        }
                        if (context.mounted && result) {
                          Navigator.pop(context);
                        }
                      },
                      child: const Text('Create File'),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
    return result;
  }

  Future<void> rename({
    required BuildContext context,
    required FileSystemEntity entity,
  }) async {
    final newName = TextEditingController();
    await showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: TextField(
                    decoration: const InputDecoration(
                      hintText: 'New Name',
                      labelText: 'New Name',
                    ),
                    controller: newName,
                  ),
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width,
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: ElevatedButton(
                      onPressed: () async {
                        try {
                          if (!FileManagerService.isDirectory(entity)) {
                            final type = entity.path.split(".").last;

                            await entity.rename(
                                "${managerController.getCurrentPath}/${newName.text}.$type");
                          } else {
                            await entity.rename(
                                "${managerController.getCurrentPath}/${newName.text}");
                          }
                        } catch (e) {
                          debugPrint("Something went wrong ${e.toString()}");
                        }
                        if (context.mounted) {
                          Navigator.pop(context);
                        }
                      },
                      child: const Text('Rename'),
                    ),
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> move(BuildContext context, FileSystemEntity systemEntity) async {
    final currentDir = await FileManagerService.getStorageList();

    final FileManagerController moveController = FileManagerController();
    moveController.setCurrentPath = currentDir.first.path;

    Future<List<Directory>> openCloseDirectories() async {
      final List<FileSystemEntity> allEntities =
          await SortBy.name.sortEntitles(moveController.getCurrentPath);

      return allEntities.whereType<Directory>().toList();
    }

    final List<Directory> entities = await openCloseDirectories();
    final List<Widget> pathsWidget = [];
    if (context.mounted) {
      await showDialog(
        context: context,
        builder: (context) {
          FileSystemEntity entity = entities.first;
          return Dialog(
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  StatefulBuilder(
                    builder: (context, setState) => Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: pathsWidget,
                        ),
                        if (entities.isNotEmpty)
                          SizedBox(
                            width: MediaQuery.of(context).size.width,
                            child: Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: DropdownButton<FileSystemEntity>(
                                value: entity,
                                items: entities
                                    .map(
                                      (e) => DropdownMenuItem(
                                        value: e,
                                        child: Text(
                                          FileManagerService.basename(e),
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleSmall,
                                        ),
                                      ),
                                    )
                                    .toList(),
                                onChanged: (newEntity) async {
                                  moveController.openDirectory(newEntity!);
                                  entities.clear();
                                  final newEntities =
                                      await openCloseDirectories();

                                  if (newEntities.isNotEmpty) {
                                    entities.addAll(newEntities);
                                  }

                                  setState(() {
                                    if (entities.isNotEmpty) {
                                      entity = entities.first;
                                    } else {
                                      entity = newEntity;
                                    }
                                    final basename =
                                        FileManagerService.basename(newEntity);
                                    pathsWidget.add(
                                      InkWell(
                                        key: Key(basename),
                                        onTap: () async {
                                          moveController
                                              .openDirectory(newEntity);
                                          entities.clear();
                                          final newEntities =
                                              await openCloseDirectories();
                                          if (newEntities.isNotEmpty) {
                                            entities.addAll(newEntities);
                                            entity = entities.first;
                                          } else {
                                            entity = newEntity;
                                          }
                                          final index = pathsWidget.indexWhere(
                                            (element) =>
                                                element.key ==
                                                Key(FileManagerService.basename(
                                                    newEntity)),
                                          );

                                          final newPaths = pathsWidget.sublist(
                                              0, (index + 1));
                                          pathsWidget.clear();
                                          pathsWidget.addAll(newPaths);
                                          setState(() {});
                                        },
                                        child: Text("$basename / "),
                                      ),
                                    );
                                  });
                                },
                              ),
                            ),
                          )
                        else
                          const Padding(
                            padding: EdgeInsets.only(top: 12.0),
                            child: Text("Move to the selected path"),
                          )
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: MediaQuery.of(context).size.width,
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: ElevatedButton(
                        onPressed: () async {
                          try {
                            if (FileManagerService.isFile(systemEntity)) {
                              final type = systemEntity.path.split(".").last;
                              final name = systemEntity.path
                                  .split("/")
                                  .last
                                  .split(".")
                                  .first;

                              await systemEntity.rename(
                                  "${moveController.getCurrentPath}/$name.$type");
                            } else {
                              final name = systemEntity.path.split("/").last;
                              await systemEntity.rename(
                                  "${moveController.getCurrentPath}/$name");
                            }
                          } catch (e) {
                            debugPrint("Something went wrong ${e.toString()}");
                          }
                          if (context.mounted) Navigator.pop(context);
                        },
                        child: const Text('Move'),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    }
  }

  Future<void> goToParentDirectory() async {
    await managerController.goToParentDirectory(backStream: backStream);
  }
}
