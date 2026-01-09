import 'package:flutter/material.dart';
import 'dart:math' as math;

/// Streak Celebration Overlay
/// Full-screen flame animation for streak achievements
class StreakCelebrationOverlay extends StatefulWidget {
  final int streakDays;
  final Duration duration;

  const StreakCelebrationOverlay({
    super.key,
    required this.streakDays,
    this.duration = const Duration(seconds: 3),
  });

  static Future<void> show(
    BuildContext context, {
    required int streakDays,
    Duration duration = const Duration(seconds: 3),
  }) async {
    await Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        barrierColor: Colors.black87,
        barrierDismissible: true,
        pageBuilder: (context, animation, secondaryAnimation) {
          return StreakCelebrationOverlay(
            streakDays: streakDays,
            duration: duration,
          );
        },
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
      ),
    );
  }

  @override
  State<StreakCelebrationOverlay> createState() =>
      _StreakCelebrationOverlayState();
}

class _StreakCelebrationOverlayState extends State<StreakCelebrationOverlay>
    with TickerProviderStateMixin {
  late AnimationController _flameController;
  late AnimationController _textController;
  late AnimationController _particleController;
  late Animation<double> _flameScale;
  late Animation<double> _textSlide;
  late Animation<double> _textOpacity;

  @override
  void initState() {
    super.initState();

    // Flame animation
    _flameController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _flameScale = Tween<double>(begin: 0.0, end: 1.2).animate(
      CurvedAnimation(
        parent: _flameController,
        curve: Curves.elasticOut,
      ),
    );

    // Text animation
    _textController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _textSlide = Tween<double>(begin: 100.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _textController,
        curve: Curves.easeOutCubic,
      ),
    );

    _textOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _textController,
        curve: const Interval(0.3, 1.0),
      ),
    );

    // Particle animation  
    _particleController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();

    // Start animations
    _flameController.forward();
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) _textController.forward();
    });

    // Auto dismiss
    Future.delayed(widget.duration, () {
      if (mounted) Navigator.of(context).pop();
    });
  }

  @override
  void dispose() {
    _flameController.dispose();
    _textController.dispose();
    _particleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return GestureDetector(
      onTap: () => Navigator.of(context).pop(),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Stack(
          children: [
            // Animated background gradient
            Container(
              decoration: const BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.center,
                  radius: 1.0,
                  colors: [
                    Color(0xFFFF6B00),
                    Color(0xFFFF0000),
                    Colors.black87,
                  ],
                  stops: [0.0, 0.4, 1.0],
                ),
              ),
            ),

            // Particle embers
            AnimatedBuilder(
              animation: _particleController,
              builder: (context, child) {
                return CustomPaint(
                  painter: EmberParticlePainter(
                    animation: _particleController.value,
                  ),
                  size: size,
                );
              },
            ),

            // Center flame icon
            Center(
              child: AnimatedBuilder(
                animation: _flameController,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _flameScale.value,
                    child: Container(
                      width: 200,
                      height: 200,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.orange.withOpacity(0.6),
                            blurRadius: 100,
                            spreadRadius: 50,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.local_fire_department,
                        size: 150,
                        color: Colors.orange,
                      ),
                    ),
                  );
                },
              ),
            ),

            // Streak text
            AnimatedBuilder(
              animation: _textController,
              builder: (context, child) {
                return Positioned(
                  top: size.height * 0.35 + _textSlide.value,
                  left: 0,
                  right: 0,
                  child: Opacity(
                    opacity: _textOpacity.value,
                    child: Column(
                      children: [
                        Text(
                          '${widget.streakDays}',
                          style: const TextStyle(
                            fontSize: 120,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            shadows: [
                              Shadow(
                                color: Colors.orange,
                                blurRadius: 30,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          widget.streakDays == 1 ? 'DAY STREAK' : 'DAYS STREAK',
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                            letterSpacing: 8,
                            shadows: [
                              Shadow(
                                color: Colors.orange,
                                blurRadius: 20,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          _getStreakMessage(widget.streakDays),
                          style: const TextStyle(
                            fontSize: 24,
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),

            // Tap to dismiss hint
            Positioned(
              bottom: 50,
              left: 0,
              right: 0,
              child: FadeTransition(
                opacity: _textOpacity,
                child: const Text(
                  'Tap anywhere to continue',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getStreakMessage(int days) {
    if (days >= 100) return '👑 LEGENDARY! 👑';
    if (days >= 30) return '🏆 ONE MONTH! 🏆';
    if (days >= 7) return '🔥 ONE WEEK! 🔥';
    if (days >= 3) return '🎯 KEEP GOING! 🎯';
    return '🚀 GREAT START! 🚀';
  }
}

/// Custom painter for floating ember particles
class EmberParticlePainter extends CustomPainter {
  final double animation;
  final math.Random random = math.Random(42);

  EmberParticlePainter({required this.animation});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    // Draw 50 floating particles
    for (int i = 0; i < 50; i++) {
      final x = random.nextDouble() * size.width;
      final baseY = random.nextDouble() * size.height;
      final y = baseY - (animation * size.height * 0.5);

      // Wrap around
      final wrappedY = y % size.height;

      final size_particle = random.nextDouble() * 4 + 2;
      final opacity = (1 - (wrappedY / size.height)) * 0.6;

      paint.color = Color.lerp(
        Colors.orange,
        Colors.red,
        random.nextDouble(),
      )!
          .withOpacity(opacity);

      canvas.drawCircle(
        Offset(x, wrappedY),
        size_particle,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(EmberParticlePainter oldDelegate) => true;
}
