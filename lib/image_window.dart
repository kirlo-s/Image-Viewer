import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_viewer/gallery_window.dart';
import 'package:image_viewer/main.dart';
import 'package:mime/mime.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:super_clipboard/super_clipboard.dart';

class ImageWindow extends ConsumerStatefulWidget{
  const ImageWindow({super.key});
  
  @override
  ImageWindowState createState() => ImageWindowState();
}

class ImageWindowState extends ConsumerState<ImageWindow> {
  @override
  Widget build(BuildContext context){
    final index = ref.watch(imageWindowIndexProvider);
    final listP = ref.watch(imageListProvider);
    File? imageFile;
    listP.when(
      data: (data) {
        imageFile = data[index!];
      },
      error: (error,stackTrace){
        imageFile = null;
      },
      loading: () {
        imageFile = null;
      }
    );
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            ref.watch(imageWindowIndexProvider.notifier).state = null;
          },
          tooltip: "Back to gallery",
          icon: const Icon(Icons.arrow_back),
        ),
        title: Text(basename(imageFile!.path)),
      ),
      body: Center(child: Image.file(imageFile!),),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton.small(
            tooltip: "Copy to clipboard",
            onPressed: () async{
              final clipboard = SystemClipboard.instance;
              if(clipboard == null){
                showDialog(
                  context: context, 
                  builder: (context) {
                    return const AlertDialog(
                      title: Text("Error"),
                      content: Text("Clipboard API is not supported on this device."),
                    );
                });
              }
              final item = DataWriterItem();
              final mimeType = lookupMimeType(imageFile!.path);
              if(mimeType!.startsWith('image/jpeg')){
                item.add(Formats.jpeg(await imageFile!.readAsBytes()));
              }
              if(mimeType.startsWith('image/png')){
                item.add(Formats.png(await imageFile!.readAsBytes()));
              }
              await clipboard!.write([item]);
            },
            child: const Icon(Icons.copy),
          ),
          const SizedBox(
            height: 24
          ),
          FloatingActionButton(
            tooltip: "Copy to download folder",
            onPressed: () async {
              Directory? downloadDirectory = await getDownloadsDirectory();
              await imageFile!.copy("${downloadDirectory!.path}/${basename(imageFile!.path)}");
            },
            child: const Icon(Icons.download)
            )
        ],
      )
    );
  }
  
}