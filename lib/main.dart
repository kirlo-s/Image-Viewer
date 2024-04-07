import "dart:io";
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_viewer/gallery_window.dart';
import 'package:image_viewer/pick_window.dart';


final imageDirectoryProvider = StateProvider<Directory?>((ref) => null);

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Image Viewer',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const HomeView(),
    );
  }
}


class HomeView extends ConsumerWidget{
  const HomeView({super.key});

  @override
  Widget build(BuildContext context,WidgetRef ref) {
    Directory? imageDirectory = ref.watch(imageDirectoryProvider);
    if(imageDirectory == null){
      return PickWindow();
    } else{
      return GalleryWindow();
    }
  }
}
