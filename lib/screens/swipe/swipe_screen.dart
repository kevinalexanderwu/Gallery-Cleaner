import 'package:flutter/material.dart';
import '../../models/models.dart';
import '../../theme.dart';
import 'details_panel.dart';
import 'swipe_photo.dart';

class SwipeScreen extends StatefulWidget {
  final SwipeContext ctx;
  final ValueChanged<ReviewResult> onDone;
  final VoidCallback onBack;

  const SwipeScreen({super.key, required this.ctx, required this.onDone, required this.onBack});

  @override
  State<SwipeScreen> createState() => _SwipeScreenState();
}

class _SwipeScreenState extends State<SwipeScreen> {
  int _idx = 0;
  Map<PhotoAction, int> _counts = {
    PhotoAction.keep: 0,
    PhotoAction.delete: 0,
    PhotoAction.later: 0,
    PhotoAction.favorite: 0,
    
  };

  final List<Photo> _deletePhotos = [];
  final List<Photo> _keptPhotos = [];
  final List<Photo> _laterPhotos = [];
  final List<Photo> _favoritePhotos = [];
  
  bool _detailsOpen = false;

  Photo? _lastPhoto;
  PhotoAction? _lastAction;

  void _handleAction(PhotoAction action) {
    final photo = widget.ctx.photos[_idx];
    _lastPhoto = photo;
    _lastAction = action;


    switch (action) {
      case PhotoAction.keep:
        _keptPhotos.add(photo);
        break;

      case PhotoAction.delete:
        _deletePhotos.add(photo);
        break;

      case PhotoAction.later:
        _laterPhotos.add(photo);
        break;

      case PhotoAction.favorite:
        _favoritePhotos.add(photo);
        break;
    }

    setState(() {
      _detailsOpen = false;
      _counts = {..._counts, action: (_counts[action] ?? 0) + 1};
    });

    if (_idx >= widget.ctx.photos.length - 1) {
      widget.onDone(
        ReviewResult(
          counts: _counts,
          deletePhotos: _deletePhotos,
          keptPhotos: _keptPhotos,
          laterPhotos: _laterPhotos,
          favoritePhotos: _favoritePhotos,
        ),
      );
    } else {
      setState(() => _idx++);
    }
  }

  void _favoriteAndKeep() {
    final photo = widget.ctx.photos[_idx];

    _favoritePhotos.add(photo);

    _handleAction(PhotoAction.keep);
  }

  void _undoLastAction() {
    if (_lastPhoto == null || _lastAction == null) return;

    switch (_lastAction!) {
      case PhotoAction.keep:
        _keptPhotos.removeLast();
        break;

      case PhotoAction.delete:
        _deletePhotos.removeLast();
        break;

      case PhotoAction.favorite:
        _favoritePhotos.removeLast();
        break;

      case PhotoAction.later:
        _laterPhotos.removeLast();
        break;
    }

    setState(() {
      _counts = {
        ..._counts,
        _lastAction!: (_counts[_lastAction!] ?? 1) - 1,
      };

      _idx--;
    });

    _lastPhoto = null;
    _lastAction = null;
  }
  void _finishReview() {
    widget.onDone(
      ReviewResult(
        counts: _counts,
        deletePhotos: _deletePhotos,
        keptPhotos: _keptPhotos,
        laterPhotos: _laterPhotos,
        favoritePhotos: _favoritePhotos,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final photo = _idx < widget.ctx.photos.length ? widget.ctx.photos[_idx] : null;
    final reviewed = _idx;
    final total = widget.ctx.total;
    final pct = total == 0 ? 0.0 : (reviewed / total).clamp(0, 1).toDouble();

    return Column(
      children: [
        Container(
          color: Colors.white,
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
          child: Column(
            children: [
              Row(
                children: [
                  IconButton(
                    onPressed: widget.onBack,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    icon: const Icon(Icons.chevron_left, size: 20, color: AppColors.inkSoft),
                  ),
                  Expanded(
                    child: Column(
                      children: [
                        Text(
                          widget.ctx.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.ink, letterSpacing: -0.2),
                        ),
                        const SizedBox(height: 1),
                        Text(
                          widget.ctx.subtitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 11.5, color: AppColors.grey500),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    width: 52,
                    child: Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(text: '$reviewed', style: const TextStyle(color: AppColors.grey400)),
                          const TextSpan(text: ' / ', style: TextStyle(color: Color(0xFFDCDCDC))),
                          TextSpan(text: '$total', style: const TextStyle(color: AppColors.grey400)),
                        ],
                      ),
                      textAlign: TextAlign.right,
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: _finishReview,
                  child: const Text(
                    "Finish",
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              ClipRRect(
                borderRadius: BorderRadius.circular(999),
                child: Container(
                  height: 1.5,
                  color: AppColors.grey150,
                  alignment: Alignment.centerLeft,
                  child: TweenAnimationBuilder<double>(
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.easeOut,
                    tween: Tween<double>(begin: 0, end: pct),
                    builder: (context, value, child) {
                      return FractionallySizedBox(
                        widthFactor: value,
                        child: Container(color: AppColors.ink),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: Stack(
            children: [
              if (photo != null)
              SwipePhoto(
                key: ValueKey(photo.id),
                photo: photo,
                onAction: _handleAction,
                onOpenDetails: () => setState(() => _detailsOpen = true),
                onFavorite: _favoriteAndKeep,
              ),
              if (_detailsOpen && photo != null)
                DetailsPanel(
                  key: const ValueKey('details'),
                  photo: photo,
                  onClose: () => setState(() => _detailsOpen = false),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

