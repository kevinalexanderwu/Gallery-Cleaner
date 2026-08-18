import 'package:flutter/material.dart';
import '../models/models.dart';
import '../theme.dart';
import '../widgets/net_image.dart';
import 'photo_preview_screen.dart';

class FavoritesScreen extends StatelessWidget {
  final List<Photo> photos;

  const FavoritesScreen({
    super.key,
    required this.photos,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        title: const Text(
          'Favorites',
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w600,
            color: AppColors.ink,
          ),
        ),
      ),
      body: photos.isEmpty
          ? const Center(
              child: Text(
                'No favorites yet',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.grey500,
                ),
              ),
            )
          : GridView.builder(
              padding: const EdgeInsets.all(1.5),
              itemCount: photos.length,
              gridDelegate:
                  const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisSpacing: 1.5,
                crossAxisSpacing: 1.5,
              ),
              itemBuilder: (context, index) {
                final photo = photos[index];

                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => PhotoPreviewScreen(
                          photos: photos,
                          initialIndex: index,
                        ),
                      ),
                    );
                  },
                  child: Hero(
                    tag: photo.id,
                    child: SquareThumb(
                      url: photo.url,
                      asset: photo.asset,
                    ),
                  ),
                );
              },
            ),
    );
  }
}