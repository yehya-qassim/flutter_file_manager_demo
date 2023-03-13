import 'dart:io';

import 'package:file_manage_demo/services/file_manager_service.dart';
import 'package:flutter/material.dart';

class SubTitle extends StatelessWidget {
  final FileSystemEntity entity;
  const SubTitle({
    super.key,
    required this.entity,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<FileStat>(
      future: entity.stat(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          if (entity is File) {
            final size = FileManagerService.formatBytes(snapshot.data!.size);
            final date = snapshot.data!.modified.toString().substring(0, 10);
            final type = entity.path.split(".").last;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: Text("$size - $date"),
                ),
                Text(type),
                const SizedBox(height: 4)
              ],
            );
          }
          return Text(
            "${snapshot.data!.modified}".substring(0, 10),
          );
        } else {
          return const SizedBox.shrink();
        }
      },
    );
  }
}
