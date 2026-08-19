import 'package:flutter/material.dart';

import '../models/models.dart';
import '../widgets/media_preview.dart';

class PhotoPreviewScreen extends StatefulWidget {
  final List<Photo> photos;
  final int initialIndex;

  const PhotoPreviewScreen({
    super.key,
    required this.photos,
    required this.initialIndex,
  });

  @override
  State<PhotoPreviewScreen> createState() => _PhotoPreviewScreenState();
}

class _PhotoPreviewScreenState extends State<PhotoPreviewScreen> {
  late final PageController _pageController;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();

    _currentIndex = widget.initialIndex;

    _pageController = PageController(
      initialPage: widget.initialIndex,
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,

      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: Text(
          "${_currentIndex + 1} / ${widget.photos.length}",
        ),
      ),

      body: PageView.builder(
        controller: _pageController,
        itemCount: widget.photos.length,

        onPageChanged: (index) {
          setState(() {
            _currentIndex = index;
          });
        },

        itemBuilder: (context, index) {
          final photo = widget.photos[index];

          return Center(
            child: InteractiveViewer(
              minScale: 1,
              maxScale: 5,
              child: Hero(
                tag: photo.id,
                child: MediaPreview(
                  asset: photo.asset,
                  url: photo.url,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}