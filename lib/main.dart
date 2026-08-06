import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'root_screen.dart';
import 'theme.dart';

void main() {
  runApp(const ProviderScope(child: GalleryCleanerApp()));
}

class GalleryCleanerApp extends StatelessWidget {
  const GalleryCleanerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gallery Cleaner',
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(),
      home: const RootScreen(),
    );
  }
}
