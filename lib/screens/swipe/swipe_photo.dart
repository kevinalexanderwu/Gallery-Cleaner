import 'package:flutter/material.dart';
import '../../models/models.dart';
import '../../theme.dart';
import '../../widgets/net_image.dart';
import 'package:flutter/physics.dart';
import 'package:flutter/services.dart';
import '../../widgets/media_preview.dart';

enum _DragDir { up, down, left, right }

enum DragAxis {
  none,
  horizontal,
  vertical,
}

/// Fullscreen, draggable photo card.
///
/// - Drag up past threshold (or fast flick up)     -> "keep"
/// - Drag down past threshold (or fast flick down) -> "delete"
/// - Drag right past threshold (or fast flick right) -> opens the details panel
///
/// Mirrors the drag physics of the original Framer Motion component:
/// a 72px / 380px-per-second threshold, and a spring-back for cancelled
/// drags.
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

class _SwipePhotoState extends State<SwipePhoto> with TickerProviderStateMixin {
  late final AnimationController _xCtrl = AnimationController.unbounded(vsync: this, value: 0);
  late final AnimationController _yCtrl = AnimationController.unbounded(vsync: this, value: 0);
  late final AnimationController _entrance =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 180))..forward();
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

  @override
  void dispose() {
    _xCtrl.dispose();
    _yCtrl.dispose();
    _entrance.dispose();
    super.dispose();
    _heartCtrl.dispose();
  }

  void _onPanStart(DragStartDetails d) {
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

    _axis = DragAxis.none;
  }
  void _onPanUpdate(DragUpdateDetails d) {
    if (_axis == DragAxis.none) {
      if (d.delta.dx.abs() > 2 || d.delta.dy.abs() > 2) {
        if (d.delta.dx.abs() > d.delta.dy.abs()) {
          _axis = DragAxis.horizontal;
        } else {
          _axis = DragAxis.vertical;
        }
      }
    }

    if (_axis == DragAxis.horizontal) {
      _xCtrl.value += d.delta.dx;
    }

    if (_axis == DragAxis.vertical) {
      _yCtrl.value += d.delta.dy;
    }

    final ox = _xCtrl.value;
    final oy = _yCtrl.value;

    final absX = ox.abs();
    final absY = oy.abs();

    final dist = absX > absY ? absX : absY;

    setState(() {
      _intensity = (dist / 88).clamp(0, 1);

      if (_axis == DragAxis.vertical) {
        _dragDir = oy < 0 ? _DragDir.up : _DragDir.down;
      } else {
        _dragDir = ox > 0 ? _DragDir.right : _DragDir.left;
      }
    });
  }

  void _springTo(AnimationController ctrl, double target, double velocity) {
    final spring = SpringDescription(mass: 1, stiffness: 380, damping: 32);
    ctrl.animateWith(SpringSimulation(spring, ctrl.value, target, velocity));
  }

  void _flyAndFire(PhotoAction action, double targetY) async {
    setState(() {
      _dragDir = null;
      _intensity = 0;
    });
    final flyCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 260));
    final anim = Tween<double>(begin: _yCtrl.value, end: targetY)
        .animate(CurvedAnimation(parent: flyCtrl, curve: Curves.easeOut));
    void listener() => _yCtrl.value = anim.value;
    anim.addListener(listener);
    await flyCtrl.forward();
    anim.removeListener(listener);
    flyCtrl.dispose();
    _xCtrl.value = 0;
    _yCtrl.value = 0;
    _axis = DragAxis.none;
    if (!mounted) return;

    if (action == PhotoAction.favorite) {
      widget.onFavorite();
    } else {
      widget.onAction(action);
    }
  }
  Future<void> playFavoriteAnimation() async {
    await _heartCtrl.forward(from: 0);
  }

  void _onPanEnd(DragEndDetails d) {
    final ox = _xCtrl.value;
    final oy = _yCtrl.value;

    final absX = ox.abs();
    final absY = oy.abs();

    final v = d.velocity.pixelsPerSecond;

    if (absY >= absX) {
      // Swipe UP → KEEP
      if (oy < -_dist || v.dy < -_vel) {
        _flyAndFire(
          PhotoAction.keep,
          -900,
        );
      }

      // Swipe DOWN → DELETE
      else if (oy > _dist || v.dy > _vel) {
        _flyAndFire(
          PhotoAction.delete,
          900,
        );
      }

      // Not far enough → return to center
      else {
        setState(() {
          _dragDir = null;
          _intensity = 0;
        });

        _springTo(
          _yCtrl,
          0,
          v.dy,
        );

        _springTo(
          _xCtrl,
          0,
          v.dx,
        );
      }
    } else {
      // Swipe LEFT → FOR LATER
      if (ox < -_dist || v.dx < -_vel) {
        _flyAndFire(
          PhotoAction.later,
          -900,
        );
      }

      // Swipe RIGHT → DETAILS
      else if (ox > 52 || v.dx > 280) {
        _springTo(
          _xCtrl,
          0,
          v.dx,
        );

        setState(() {
          _dragDir = null;
          _intensity = 0;
        });

        widget.onOpenDetails();
      }

      // Not far enough → return to center
      else {
        setState(() {
          _dragDir = null;
          _intensity = 0;
        });

        _springTo(
          _xCtrl,
          0,
          v.dx,
        );

        _springTo(
          _yCtrl,
          0,
          v.dy,
        );
      }
    }

    _axis = DragAxis.none;
  }

  @override
  Widget build(BuildContext context) {
    final keepCfg = actionConfig[PhotoAction.keep]!;
    final delCfg = actionConfig[PhotoAction.delete]!;


    return GestureDetector(
    onDoubleTap: () async {
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
    },
      onPanStart: _onPanStart,
      onPanUpdate: _onPanUpdate,
      onPanEnd: _onPanEnd,
      child: AnimatedBuilder(
        animation: Listenable.merge([_xCtrl, _yCtrl, _entrance]),
        builder: (context, child) {
          return Opacity(
            opacity: _entrance.value,
            child: Transform.translate(
              offset: Offset(_xCtrl.value, _yCtrl.value),
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
              MediaPreview(
                asset: widget.photo.asset,
                url: widget.photo.url,
                fit: BoxFit.contain,
              ),
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

              if (_dragDir == _DragDir.up)
                Positioned(
                  bottom: 28,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Opacity(
                      opacity: _intensity,
                      child: _ActionPill(color: keepCfg.color, bg: keepCfg.bgColor, icon: keepCfg.icon, label: 'KEEP'),
                    ),
                  ),
                ),
              if (_dragDir == _DragDir.down)
                Positioned(
                  top: 28,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Opacity(
                      opacity: _intensity,
                      child: _ActionPill(color: delCfg.color, bg: delCfg.bgColor, icon: delCfg.icon, label: 'DELETE'),
                    ),
                  ),
                ),
              if (_dragDir == _DragDir.right)
                Positioned(
                  left: 20,
                  top: 0,
                  bottom: 0,
                  child: Center(
                    child: Opacity(
                      opacity: _intensity,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(color: Colors.white.withOpacity(0.7), width: 2),
                        ),
                        child: const Text(
                          'DETAILS',
                          style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 1.4),
                        ),
                      ),
                    ),
                  ),
                ),
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
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.7),
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
            ],
          ),
        ),
      ),
    );
  }
}

class _ActionPill extends StatelessWidget {
  final Color color;
  final Color bg;
  final IconData icon;
  final String label;
  const _ActionPill({required this.color, required this.bg, required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color, width: 2),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: color),
          const SizedBox(width: 6),
          Text(label, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 1.4)),
        ],
      ),
    );
  }
}
