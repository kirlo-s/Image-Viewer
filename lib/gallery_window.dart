import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_viewer/main.dart';
import 'package:mime/mime.dart';

final imageListProvider = FutureProvider<List<File>>((ref) {
  List<File> imageFileList = [];
  final dir = ref.watch(imageDirectoryProvider);
  final entities = dir!.listSync();
  final Iterable<File> files = entities.whereType<File>();
  for(File file in files){
    final mimeType = lookupMimeType(file.path);
    if(mimeType!.startsWith('image/')){
      imageFileList.add(file);
    }
  }
  return imageFileList;
});

class GalleryWindow extends ConsumerStatefulWidget{
  const GalleryWindow({super.key});

  @override
  _GalleryWindowState createState() => _GalleryWindowState();
}

class _GalleryWindowState extends ConsumerState<GalleryWindow>{
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context){
    final imageListP = ref.watch(imageListProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text("Gallery"),
        leading: TextButton(
          onPressed: (){
            ref.watch(imageDirectoryProvider.notifier).state = null;
          },
          child: const Icon(Icons.arrow_back),
        ),
        actions: [
          TextButton(
            onPressed: (){
              print("folderinfo");
            }, 
            child: const Icon(Icons.info)
          ),
        ],
      ),
      body: imageListP.when(
        data: (data) {
          return GridView.builder(
            key: const PageStorageKey("galleryGrid"),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 4),
            itemCount: data.length,
            itemBuilder: (context,index) {
              final imageFile = data[index];
              return InkWell(
                onTap: null,
                child: Image.file(imageFile),
              );
            },
          );
        }, 
        error: (error,stackTrace) => const Icon(Icons.error),
        loading: () => const CircularProgressIndicator(),
        ),
    );
  }
}