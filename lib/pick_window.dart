import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_viewer/main.dart';

class PickWindow extends ConsumerWidget {
  @override
  Widget build(BuildContext context,WidgetRef ref){
    return Scaffold(
      appBar: AppBar(
        title: const Text("Pick Directory"),
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("Pick the directory where the images are located."),
            ElevatedButton(
              onPressed: () async {
                String? selectedDirectoryPath = await FilePicker.platform.getDirectoryPath();
                if(selectedDirectoryPath == null){
                  showDialog(
                    context: context, 
                    builder: (context) {
                      return AlertDialog(
                        title: const Text("The Path is not Provided."),
                        content: const Text("Choose the directory aganin."),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context), 
                            child: const Text("OK")
                          ),
                        ],
                      );
                    }
                  );
                }else{
                  ref.watch(imageDirectoryProvider.notifier).state = Directory(selectedDirectoryPath!);
                }
                
              }, 
              child: const Text("Choose")
            ),
          ],
        ),
      )
    );
  }
}