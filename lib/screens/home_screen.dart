import 'dart:io';

import 'package:file_manage_demo/controllers/home_screen_controller.dart';
import 'package:file_manage_demo/delegates/home_screen_search_delegate.dart';
import 'package:file_manage_demo/widgets/file_manager_widget.dart';
import 'package:file_manage_demo/widgets/view_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final controller = HomeScreenController();
  final List<FileSystemEntity> allEntities = [];

  @override
  void initState() {
    controller.requestPermission();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            onPressed: () async => await controller.createFolder(context),
            icon: const Icon(Icons.create_new_folder_outlined),
          ),
          IconButton(
            onPressed: () async {
              final result = await controller.createFile(context);
              if (result) setState(() {});
            },
            icon: const Icon(Icons.file_open_outlined),
          ),
          IconButton(
            onPressed: () async => await controller.sort(context),
            icon: const Icon(Icons.sort_rounded),
          ),
          // this can be uncommented but i commented it just to have breathing space on appbar
          // IconButton(
          //   onPressed: () async => await controller.selectStorage(context),
          //   icon: const Icon(Icons.sd_storage_rounded),
          // )
          IconButton(
            onPressed: () => showSearch(
              context: context,
              delegate: HomeScreenSearchDelegate(
                entities: allEntities,
                controller: controller,
              ),
            ),
            icon: const Icon(Icons.search),
          )
        ],
        title: StreamBuilder<String>(
          stream: controller.titleStream.stream,
          builder: (context, snapshot) => Text(snapshot.data ?? ""),
        ),
        leading: StreamBuilder<bool>(
            stream: controller.backStream.stream,
            builder: (context, snapshot) {
              final goBack = snapshot.data ?? false;
              return goBack
                  ? IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: () async {
                        await controller.goToParentDirectory();
                      },
                    )
                  : const SizedBox.shrink();
            }),
      ),
      body: Padding(
        padding: const EdgeInsets.all(10),
        child: FileManagerWidget(
          controller: controller.managerController,
          builder: (context, snapshot) {
            final List<FileSystemEntity> entities = snapshot;
            allEntities.clear();
            allEntities.addAll(entities);
            return ListView.builder(
              itemCount: entities.length,
              itemBuilder: (context, index) {
                FileSystemEntity entity = entities[index];
                return Slidable(
                  startActionPane: ActionPane(
                    motion: const ScrollMotion(),
                    extentRatio: 1,
                    children: [
                      SlidableAction(
                        onPressed: (_) async {
                          try {
                            await entity.delete(recursive: true);
                            setState(() {});
                          } catch (e) {
                            debugPrint("An error has occurred ${e.toString()}");
                          }
                        },
                        backgroundColor: const Color(0xFFFE4A49),
                        foregroundColor: Colors.white,
                        icon: Icons.delete,
                        label: 'Delete',
                      ),
                      SlidableAction(
                        onPressed: (_) async {
                          await controller.rename(
                              context: context, entity: entity);
                          setState(() {});
                        },
                        backgroundColor: const Color(0xFF21B7CA),
                        foregroundColor: Colors.white,
                        icon: Icons.edit,
                        label: 'Rename',
                      ),
                      SlidableAction(
                        onPressed: (_) async {
                          await controller.move(context, entity);
                          setState(() {});
                        },
                        backgroundColor:
                            const Color.fromARGB(255, 33, 106, 202),
                        foregroundColor: Colors.white,
                        icon: Icons.move_up_outlined,
                        label: 'Move',
                      ),
                    ],
                  ),
                  child: ViewWidget(entity: entity, controller: controller),
                );
              },
            );
          },
        ),
      ),
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}
