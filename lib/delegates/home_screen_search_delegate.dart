import 'dart:io';

import 'package:file_manage_demo/controllers/home_screen_controller.dart';
import 'package:file_manage_demo/services/file_manager_service.dart';
import 'package:file_manage_demo/widgets/view_widget.dart';
import 'package:flutter/material.dart';

class HomeScreenSearchDelegate extends SearchDelegate {
  final List<FileSystemEntity> entities;
  final HomeScreenController controller;
  HomeScreenSearchDelegate({
    required this.entities,
    required this.controller,
  });

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        onPressed: () => query = '',
        icon: const Icon(Icons.clear),
      ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      onPressed: () => close(context, null),
      icon: const Icon(Icons.arrow_back),
    );
  }

  @override
  Widget buildResults(BuildContext context) => result;

  @override
  Widget buildSuggestions(BuildContext context) => result;

  Widget get result {
    final List<FileSystemEntity> matchEntities = [];
    for (final entity in entities) {
      final entityName = FileManagerService.basename(entity).toLowerCase();
      if (entityName.contains(query.toLowerCase())) {
        matchEntities.add(entity);
      }
    }

    return ListView.builder(
      itemCount: matchEntities.length,
      itemBuilder: (context, index) {
        final entity = matchEntities[index];
        return ViewWidget(
          entity: entity,
          onTap: () {
            if (FileManagerService.isDirectory(entity)) {
              controller.backStream.add(true);
              controller.openDirectory(entity: entity);
              close(context, null);
            }
          },
        );
      },
    );
  }
}
