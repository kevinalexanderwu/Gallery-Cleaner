import 'dart:async';
import 'package:flutter/material.dart';
import '../theme.dart';

class SplashScreen extends StatefulWidget {
  final VoidCallback onDone;
  const SplashScreen({super.key, required this.onDone});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  late final AnimationController _logoCtrl;
  late final AnimationController _dotsCtrl;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _logoCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 650))..forward();
    _dotsCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1400))..repeat();
    _timer = Timer(const Duration(milliseconds: 2400), widget.onDone);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _logoCtrl.dispose();
    _dotsCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final curved = CurvedAnimation(parent: _logoCtrl, curve: const Cubic(0.16, 1, 0.3, 1));
    return Container(
      color: Colors.white,
      child: Stack(
        children: [
          Center(
            child: AnimatedBuilder(
              animation: curved,
              builder: (context, child) {
                final t = curved.value;
                return Opacity(
                  opacity: t,
                  child: Transform.scale(
                    scale: 0.84 + 0.16 * t,
                    child: Transform.translate(
                      offset: Offset(0, (1 - t) * 10),
                      child: child,
                    ),
                  ),
                );
              },
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 76,
                    height: 76,
                    decoration: BoxDecoration(
                      color: AppColors.ink,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(Icons.auto_awesome, color: Colors.white, size: 32),
                  ),
                  const SizedBox(height: 28),
                  const Text(
                    'Gallery Cleaner',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600, color: AppColors.ink, letterSpacing: -0.3),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Your photos, organized.',
                    style: TextStyle(fontSize: 14, color: AppColors.grey600),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 96,
            child: Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(3, (i) {
                  return AnimatedBuilder(
                    animation: _dotsCtrl,
                    builder: (context, _) {
                      // stagger each dot by 0.22s / 1.4s of the loop
                      final phase = ((_dotsCtrl.value * 1400 - i * 220) % 1400) / 1400;
                      final double brightness = phase < 0.5 ? phase * 2 : (1 - phase) * 2;
                      final color = Color.lerp(
                        const Color(0xFFECECEC),
                        const Color(0xFF999999),
                        brightness.clamp(0.0, 1.0),
                      )!;
                      return Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: 5,
                        height: 5,
                        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                      );
                    },
                  );
                }),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
