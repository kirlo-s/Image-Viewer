import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_viewer/main.dart';
import 'package:mime/mime.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' show basename;
import 'package:fc_native_image_resize/fc_native_image_resize.dart';

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
  int imageCount = 0;
  double _crossAxisCount = 4;
  
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
        leading: IconButton(
          onPressed: (){
            ref.watch(imageDirectoryProvider.notifier).state = null;
          },
          tooltip: "Back to folder selection",
          icon: const Icon(Icons.arrow_back),
        ),
        actions: [
          const Icon(Icons.grid_view_rounded),
          Slider(
            value: _crossAxisCount, 
            min:1,
            max:7,
            divisions: 6,
            onChanged: (value) {
              setState(() {
                _crossAxisCount = value;
              });
            } 
          ),
          IconButton(
            onPressed: (){
              showDialog(
                context: context, 
                builder: (context) {
                  return AlertDialog(
                    title: const Text("Folder Information"),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ListTile(
                          title: const Text("Directory Path"),
                          subtitle: Text(ref.watch(imageDirectoryProvider)!.path),
                        ),
                        ListTile(
                          title: const Text("Number of Images"),
                          subtitle: Text(imageCount.toString()),
                        )
                      ],
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text("OK") 
                      )
                    ],
                  );
                } 
              );
            }, 
            tooltip: "Folder Information",
            icon: const Icon(Icons.info)
          ),
        ],
      ),
      body: imageListP.when(
        data: (data) {
          imageCount = data.length;
          return GridView.builder(
            key: const PageStorageKey("galleryGrid"),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: _crossAxisCount.toInt()),
            itemCount: data.length,
            itemBuilder: (context,index) {
              final imageFile = data[index];
              return InkWell(
                onTap: null,
                child: GridTile(
                  child: FutureBuilder(
                    future: _cacheThumbnail(data[index]),
                    builder: (context, snapshot) {
                        if(snapshot.hasData){
                          return Image.file(snapshot.data!);
                        }else{
                          return const CircularProgressIndicator();
                        }
                    }),
                  ),
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

Future<File> _cacheThumbnail(File imageFile) async{
  final fcPlugin = FcNativeImageResize();
  final cacheDirectory = await getApplicationCacheDirectory();
  final imageName = basename(imageFile.path).split('.')[0];
  final thumbnailPath = "${cacheDirectory.path}/$imageName.png";
  File thumbnailFile = File(thumbnailPath);
  if(await thumbnailFile.exists()){
    return thumbnailFile;
  }
 
  await fcPlugin.resizeFile(
    srcFile: imageFile.path, 
    destFile: thumbnailPath, 
    width: 1000, 
    height: 600,
    keepAspectRatio: true, 
    format: 'png'
    );
  return thumbnailFile;
}