import 'package:flutter/material.dart';
import '../../models/models.dart';
import '../../theme.dart';
import '../../widgets/net_image.dart';
import 'package:flutter/physics.dart';

/// Right-hand slide-over panel showing full EXIF-style metadata for a
/// photo. Swipe right (or tap the scrim) to dismiss.
class DetailsPanel extends StatefulWidget {
  final Photo photo;
  final VoidCallback onClose;

  const DetailsPanel({super.key, required this.photo, required this.onClose});

  @override
  State<DetailsPanel> createState() => _DetailsPanelState();
}

class _DetailsPanelState extends State<DetailsPanel>with TickerProviderStateMixin {
  late final AnimationController _entrance =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 320))..forward();
  late final AnimationController _dragCtrl = AnimationController.unbounded(vsync: this, value: 0);

  @override
  void dispose() {
    _entrance.dispose();
    _dragCtrl.dispose();
    super.dispose();
  }

  void _onDragEnd(DragEndDetails d) {
    final ox = _dragCtrl.value;
    final v = d.velocity.pixelsPerSecond.dx;
    if (ox < -72 || v < -380) {
      widget.onClose();
    } else {
      final spring = SpringDescription(mass: 1, stiffness: 400, damping: 36);
      _dragCtrl.animateWith(SpringSimulation(spring, ox, 0, v));
    }
  }

  @override
  Widget build(BuildContext context) {
    final parts = widget.photo.dateParts;
    final datePart = parts.isNotEmpty ? parts[0] : '';
    final timePart = parts.length > 1 ? parts[1] : null;

    final rows = <MapEntry<String, String?>>[
      MapEntry('Date', datePart),
      MapEntry('Time', timePart),
      MapEntry('Location', widget.photo.location),
      MapEntry('Camera', widget.photo.camera),
      MapEntry('Lens', widget.photo.lens),
      MapEntry('Aperture', widget.photo.aperture),
      MapEntry('Shutter', widget.photo.shutter),
      MapEntry('ISO', widget.photo.iso),
      MapEntry('Resolution', widget.photo.resolution),
      MapEntry('File Size', widget.photo.size),
    ].where((e) => e.value != null && e.value!.isNotEmpty).toList();

    return Stack(
      children: [
        // Scrim
        GestureDetector(
          onTap: widget.onClose,
          child: AnimatedBuilder(
            animation: _entrance,
            builder: (context, _) => Container(color: Colors.black.withOpacity(0.2 * _entrance.value)),
          ),
        ),
        // Panel
        AnimatedBuilder(
          animation: Listenable.merge([_entrance, _dragCtrl]),
          builder: (context, child) {
            final width = MediaQuery.of(context).size.width * 0.88;
            final entranceOffset = -width * (1 - Curves.easeOutCubic.transform(_entrance.value));
            final dragOffset = _dragCtrl.value > 0 ? 0.0 : _dragCtrl.value;
            return Positioned(
              top: 0,
              bottom: 0,
              left: 0,
              width: width,
              child: Transform.translate(
                offset: Offset(entranceOffset + dragOffset, 0),
                child: child,
              ),
            );
          },
          child: GestureDetector(
            onHorizontalDragUpdate: (d) {
              final next = _dragCtrl.value + d.delta.dx;
              _dragCtrl.value = next > 0 ? 0 : next;
            },
            onHorizontalDragEnd: _onDragEnd,
            child: Material(
              color: Colors.white,
              child: SafeArea(
                left: false,
                bottom: false,
                child: Column(
                  children: [
                    const SizedBox(height: 12),
                    Container(width: 32, height: 3, decoration: BoxDecoration(color: const Color(0xFFDEDEDE), borderRadius: BorderRadius.circular(2))),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      decoration: const BoxDecoration(
                        border: Border(
                          bottom: BorderSide(color: Color(0xFFF0F0F0)),
                        ),
                      ),
                      child: Row(
                        children: [
                          IconButton(
                            onPressed: widget.onClose,
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            icon: const Icon(
                              Icons.close,
                              size: 20,
                              color: AppColors.inkSoft,
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Text(
                            'Photo Details',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppColors.ink,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: AspectRatio(
                          aspectRatio: 3 / 2,
                          child: Container(color: const Color(0xFFEBEBEB), child: NetImage(url: widget.photo.url,asset: widget.photo.asset,)),
                        ),
                      ),
                    ),
                    Expanded(
                      child: ListView(
                        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                        children: [
                          for (final r in rows)
                            Container(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Color(0xFFF5F5F5)))),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(r.key.toUpperCase(), style: const TextStyle(fontSize: 10.5, color: AppColors.grey400, fontWeight: FontWeight.w500, letterSpacing: 1.2)),
                                  const SizedBox(height: 2),
                                  Text(r.value!, style: const TextStyle(fontSize: 14, color: AppColors.ink)),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
