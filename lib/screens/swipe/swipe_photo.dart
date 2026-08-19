import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';
import 'package:flutter/services.dart';
import 'package:photo_manager/photo_manager.dart';

import '../../models/models.dart';
import '../../theme.dart';
import '../../widgets/media_preview.dart';

enum _DragDir { up, down, left, right }

enum DragAxis {
  none,
  horizontal,
  vertical,
}

/// Fullscreen media card.
///
/// 1 finger:
/// - Swipe up    -> Keep
/// - Swipe down  -> Delete
/// - Swipe left  -> For Later
/// - Swipe right -> Details
///
/// 2 fingers:
/// - Pinch       -> Zoom
/// - Drag        -> Pan while zoomed
///
/// Double tap:
/// - Favorite
class SwipePhoto extends StatefulWidget {
  final Photo photo;
  final ValueChanged<PhotoAction> onAction;
  final VoidCallback onFavorite;
  final VoidCallback onOpenDetails;

  const SwipePhoto({
    super.key,
    required this.photo,
    required this.onAction,
    required this.onFavorite,
    required this.onOpenDetails,
  });

  @override
  State<SwipePhoto> createState() => _SwipePhotoState();
}

class _SwipePhotoState extends State<SwipePhoto>
    with TickerProviderStateMixin {
  // Card swipe controllers.
  late final AnimationController _xCtrl =
      AnimationController.unbounded(vsync: this, value: 0);

  late final AnimationController _yCtrl =
      AnimationController.unbounded(vsync: this, value: 0);

  late final AnimationController _entrance =
      AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 180),
      )..forward();

  late final AnimationController _heartCtrl =
      AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 1100),
      );

  _DragDir? _dragDir;
  double _intensity = 0;
  DragAxis _axis = DragAxis.none;
  bool _showHeart = false;

  static const double _dist = 72;
  static const double _vel = 380;

  // ------------------------------------------------------------
  // Zoom state
  // ------------------------------------------------------------
  
  double _zoomScale = 1.0;
  Offset _zoomOffset = Offset.zero;

  double _gestureStartScale = 1.0;
  Offset _gestureStartOffset = Offset.zero;
  Size _viewportSize = Size.zero;
  bool _zoomGesture = false;

  bool get _isZoomed =>
      _zoomScale > 1.001;

  @override
  void dispose() {
    _xCtrl.dispose();
    _yCtrl.dispose();
    _entrance.dispose();
    _heartCtrl.dispose();
    super.dispose();
  }

  // ------------------------------------------------------------
  // Gesture handling
  // ------------------------------------------------------------

  void _onScaleStart(ScaleStartDetails details) {
    _xCtrl.stop();
    _yCtrl.stop();

    if (_heartCtrl.isAnimating) {
      _heartCtrl.stop();
    }

    _heartCtrl.value = 0;

    if (_showHeart) {
      setState(() {
        _showHeart = false;
      });
    }

    _gestureStartScale = _zoomScale;
    _gestureStartOffset = _zoomOffset;

    // Two or more fingers means zoom/pan.
    _zoomGesture = details.pointerCount >= 2;

    // If already zoomed, a single finger should pan the image,
    // not swipe the card away.
    if (_isZoomed) {
      _zoomGesture = true;
    }

    if (!_zoomGesture) {
      _axis = DragAxis.none;
    }
  }

  void _onScaleUpdate(ScaleUpdateDetails details) {
    // ----------------------------------------------------------
    // ZOOM / PAN
    // ----------------------------------------------------------

    if (_zoomGesture) {
      if (details.pointerCount >= 2) {
        final newScale =
            (_gestureStartScale * details.scale).clamp(1.0, 5.0);

        final rawOffset =
            _gestureStartOffset + details.focalPointDelta;

        final newOffset = _clampZoomOffset(
          rawOffset,
          newScale,
          _viewportSize,
        );

        setState(() {
          _zoomScale = newScale;
          _zoomOffset = newOffset;
        });

        return;
      }

      if (_isZoomed) {
        final rawOffset =
            _zoomOffset + details.focalPointDelta;

        setState(() {
          _zoomOffset = _clampZoomOffset(
            rawOffset,
            _zoomScale,
            _viewportSize,
          );
        });

        return;
      }
    }

    // ----------------------------------------------------------
    // NORMAL ONE-FINGER SWIPE
    // ----------------------------------------------------------

    final delta = details.focalPointDelta;

    if (_axis == DragAxis.none) {
      if (delta.dx.abs() > 2 || delta.dy.abs() > 2) {
        if (delta.dx.abs() > delta.dy.abs()) {
          _axis = DragAxis.horizontal;
        } else {
          _axis = DragAxis.vertical;
        }
      }
    }

    if (_axis == DragAxis.horizontal) {
      _xCtrl.value += delta.dx;
    }

    if (_axis == DragAxis.vertical) {
      _yCtrl.value += delta.dy;
    }

    final ox = _xCtrl.value;
    final oy = _yCtrl.value;

    final absX = ox.abs();
    final absY = oy.abs();

    final dist = absX > absY ? absX : absY;

    setState(() {
      _intensity = (dist / 88).clamp(0, 1);

      if (_axis == DragAxis.vertical) {
        _dragDir = oy < 0
            ? _DragDir.up
            : _DragDir.down;
      } else {
        _dragDir = ox > 0
            ? _DragDir.right
            : _DragDir.left;
      }
    });
  }

  void _onScaleEnd(ScaleEndDetails details) {
    // ----------------------------------------------------------
    // END ZOOM / PAN
    // ----------------------------------------------------------

    if (_zoomGesture) {
      // Keep zoom state.
      if (_zoomScale <= 1.001) {
        setState(() {
          _zoomScale = 1.0;
          _zoomOffset = Offset.zero;
        });
      }

      _zoomGesture = false;
      _axis = DragAxis.none;
      return;
    }

    // ----------------------------------------------------------
    // END NORMAL SWIPE
    // ----------------------------------------------------------

    final ox = _xCtrl.value;
    final oy = _yCtrl.value;

    final absX = ox.abs();
    final absY = oy.abs();

    final velocity = details.velocity.pixelsPerSecond;

    if (absY >= absX) {
      // Swipe UP -> KEEP
      if (oy < -_dist || velocity.dy < -_vel) {
        _flyAndFire(
          PhotoAction.keep,
          -900,
        );
      }

      // Swipe DOWN -> DELETE
      else if (oy > _dist || velocity.dy > _vel) {
        _flyAndFire(
          PhotoAction.delete,
          900,
        );
      }

      // Not far enough -> spring back
      else {
        setState(() {
          _dragDir = null;
          _intensity = 0;
        });

        _springTo(
          _yCtrl,
          0,
          velocity.dy,
        );

        _springTo(
          _xCtrl,
          0,
          velocity.dx,
        );
      }
    } else {
      // Swipe LEFT -> FOR LATER
      if (ox < -_dist || velocity.dx < -_vel) {
        _flyAndFire(
          PhotoAction.later,
          -900,
        );
      }

      // Swipe RIGHT -> DETAILS
      else if (ox > 52 || velocity.dx > 280) {
        _springTo(
          _xCtrl,
          0,
          velocity.dx,
        );

        setState(() {
          _dragDir = null;
          _intensity = 0;
        });

        widget.onOpenDetails();
      }

      // Not far enough -> spring back
      else {
        setState(() {
          _dragDir = null;
          _intensity = 0;
        });

        _springTo(
          _xCtrl,
          0,
          velocity.dx,
        );

        _springTo(
          _yCtrl,
          0,
          velocity.dy,
        );
      }
    }

    _axis = DragAxis.none;
  }

  // ------------------------------------------------------------
  // Swipe animation
  // ------------------------------------------------------------

  void _springTo(
    AnimationController ctrl,
    double target,
    double velocity,
  ) {
    final spring = SpringDescription(
      mass: 1,
      stiffness: 380,
      damping: 32,
    );

    ctrl.animateWith(
      SpringSimulation(
        spring,
        ctrl.value,
        target,
        velocity,
      ),
    );
  }

  void _flyAndFire(
    PhotoAction action,
    double targetY,
  ) async {
    setState(() {
      _dragDir = null;
      _intensity = 0;
    });

    final flyCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 260),
    );

    final anim = Tween<double>(
      begin: _yCtrl.value,
      end: targetY,
    ).animate(
      CurvedAnimation(
        parent: flyCtrl,
        curve: Curves.easeOut,
      ),
    );

    void listener() {
      _yCtrl.value = anim.value;
    }

    anim.addListener(listener);

    await flyCtrl.forward();

    anim.removeListener(listener);
    flyCtrl.dispose();

    _xCtrl.value = 0;
    _yCtrl.value = 0;
    _axis = DragAxis.none;

    // Reset zoom for the next card.
    _zoomScale = 1.0;
    _zoomOffset = Offset.zero;
    _zoomGesture = false;

    if (!mounted) return;

    if (action == PhotoAction.favorite) {
      widget.onFavorite();
    } else {
      widget.onAction(action);
    }
  }

  // ------------------------------------------------------------
  // Favorite
  // ------------------------------------------------------------

  Future<void> playFavoriteAnimation() async {
    await _heartCtrl.forward(from: 0);
  }

  Future<void> _onDoubleTap() async {
    HapticFeedback.mediumImpact();

    setState(() {
      _showHeart = true;
    });

    await Future.delayed(
      const Duration(milliseconds: 1200),
    );

    if (!mounted) return;

    setState(() {
      _showHeart = false;
    });

    _flyAndFire(
      PhotoAction.favorite,
      -900,
    );
  }

  // ------------------------------------------------------------
  // Zoom reset
  // ------------------------------------------------------------

  void _resetZoom() {
    if (!_isZoomed) return;

    setState(() {
      _zoomScale = 1.0;
      _zoomOffset = Offset.zero;
    });
  }
  Offset _clampZoomOffset(
    Offset offset,
    double scale,
    Size viewport,
  ) {
    if (scale <= 1.0) {
      return Offset.zero;
    }

    final maxX = (viewport.width * (scale - 1)) / 2;
    final maxY = (viewport.height * (scale - 1)) / 2;

    return Offset(
      offset.dx.clamp(-maxX, maxX),
      offset.dy.clamp(-maxY, maxY),
    );
  }
  // ------------------------------------------------------------
  // Build
  // ------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final keepCfg =
        actionConfig[PhotoAction.keep]!;

    final delCfg =
        actionConfig[PhotoAction.delete]!;

      return LayoutBuilder(
        builder: (context, constraints) {
          _viewportSize = Size(
            constraints.maxWidth,
            constraints.maxHeight,
          );

          return GestureDetector(
      // IMPORTANT:
      // Do NOT add onPanStart/onPanUpdate/onPanEnd here.
      //
      // Scale is a superset of pan, so one scale recognizer
      // handles both:
      //   1 finger -> swipe
      //   2 fingers -> zoom/pan
      onDoubleTap: _onDoubleTap,
      onScaleStart: _onScaleStart,
      onScaleUpdate: _onScaleUpdate,
      onScaleEnd: _onScaleEnd,

      child: AnimatedBuilder(
        animation: Listenable.merge([
          _xCtrl,
          _yCtrl,
          _entrance,
        ]),
        builder: (context, child) {
          return Opacity(
            opacity: _entrance.value,
            child: Transform.translate(
              offset: Offset(
                _xCtrl.value,
                _yCtrl.value,
              ),
              child: child,
            ),
          );
        },

        child: Container(
          color: const Color(0xFF111111),
          width: double.infinity,
          height: double.infinity,

          child: Stack(
            fit: StackFit.expand,
            children: [
              // ------------------------------------------------
              // MEDIA
              // ------------------------------------------------

              Transform(
                alignment: Alignment.center,
                transform: Matrix4.identity()
                  ..translate(
                    _zoomOffset.dx,
                    _zoomOffset.dy,
                  )
                  ..scale(_zoomScale),

                child: MediaPreview(
                  asset: widget.photo.asset,
                  url: widget.photo.url,
                  fit: BoxFit.contain,
                ),
              ),

              // ------------------------------------------------
              // FAVORITE HEART
              // ------------------------------------------------

              if (_showHeart)
                IgnorePointer(
                  child: Center(
                    child: Transform.scale(
                      scale: 1.0,
                      child: const Icon(
                        Icons.favorite,
                        color: Colors.red,
                        size: 90,
                      ),
                    ),
                  ),
                ),

              // ------------------------------------------------
              // KEEP HINT
              // ------------------------------------------------

              if (_dragDir == _DragDir.up)
                Positioned(
                  bottom: 28,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Opacity(
                      opacity: _intensity,
                      child: _ActionPill(
                        color: keepCfg.color,
                        bg: keepCfg.bgColor,
                        icon: keepCfg.icon,
                        label: 'KEEP',
                      ),
                    ),
                  ),
                ),

              // ------------------------------------------------
              // DELETE HINT
              // ------------------------------------------------

              if (_dragDir == _DragDir.down)
                Positioned(
                  top: 28,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Opacity(
                      opacity: _intensity,
                      child: _ActionPill(
                        color: delCfg.color,
                        bg: delCfg.bgColor,
                        icon: delCfg.icon,
                        label: 'DELETE',
                      ),
                    ),
                  ),
                ),

              // ------------------------------------------------
              // DETAILS HINT
              // ------------------------------------------------

              if (_dragDir == _DragDir.right)
                Positioned(
                  left: 20,
                  top: 0,
                  bottom: 0,
                  child: Center(
                    child: Opacity(
                      opacity: _intensity,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.3),
                          borderRadius:
                              BorderRadius.circular(999),
                          border: Border.all(
                            color:
                                Colors.white.withOpacity(0.7),
                            width: 2,
                          ),
                        ),
                        child: const Text(
                          'DETAILS',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 1.4,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

              // ------------------------------------------------
              // FOR LATER HINT
              // ------------------------------------------------

              if (_dragDir == _DragDir.left)
                Positioned(
                  right: 20,
                  top: 0,
                  bottom: 0,
                  child: Center(
                    child: Opacity(
                      opacity: _intensity,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.3),
                          borderRadius:
                              BorderRadius.circular(999),
                          border: Border.all(
                            color:
                                Colors.white.withOpacity(0.7),
                            width: 2,
                          ),
                        ),
                        child: const Text(
                          'FOR LATER',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 1.4,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

              // ------------------------------------------------
              // OPTIONAL ZOOM RESET BUTTON
              // ------------------------------------------------

              if (_isZoomed)
                Positioned(
                  top: 18,
                  right: 18,
                  child: SafeArea(
                    child: GestureDetector(
                      onTap: _resetZoom,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 7,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.55),
                          borderRadius:
                              BorderRadius.circular(999),
                          border: Border.all(
                            color:
                                Colors.white.withOpacity(0.4),
                          ),
                        ),
                        child: const Text(
                          'RESET',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
          ),
        );
      },
    );
  }
}

class _ActionPill extends StatelessWidget {
  final Color color;
  final Color bg;
  final IconData icon;
  final String label;

  const _ActionPill({
    required this.color,
    required this.bg,
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: color,
          width: 2,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 11,
            color: color,
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}
