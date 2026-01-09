import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import '../utils/constants.dart';

/// Celebration Overlay Widget
/// Shows full-screen celebration with confetti effect
class CelebrationOverlay extends StatefulWidget {
  final String message;
  final IconData? icon;
  final Duration duration;

  const CelebrationOverlay({
    super.key,
    required this.message,
    this.icon,
    this.duration = const Duration(seconds: 2),
  });

  /// Show celebration overlay
  static Future<void> show(
    BuildContext context, {
    required String message,
    IconData? icon,
    Duration duration = const Duration(seconds: 2),
  }) async {
    await showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black26,
      builder: (context) => CelebrationOverlay(
        message: message,
        icon: icon,
        duration: duration,
      ),
    );
  }

  @override
  State<CelebrationOverlay> createState() => _CelebrationOverlayState();
}

class _CelebrationOverlayState extends State<CelebrationOverlay>
    with SingleTickerProviderStateMixin {
  late ConfettiController _confettiController;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    // Confetti controller
    _confettiController = ConfettiController(
      duration: const Duration(seconds: 2),
    );

    // Animation controller
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    // Scale animation (bounce effect)
    _scaleAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    );

    // Fade animation
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.3, curve: Curves.easeIn),
      ),
    );

    // Start animations
    _confettiController.play();
    _animationController.forward();

    // Auto dismiss
    Future.delayed(widget.duration, () {
      if (mounted) {
        Navigator.of(context).pop();
      }
    });
  }

  @override
  void dispose() {
    _confettiController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: () => Navigator.of(context).pop(),
      child: Material(
        color: Colors.transparent,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Confetti
            Align(
              alignment: Alignment.topCenter,
              child: ConfettiWidget(
                confettiController: _confettiController,
                blastDirection: 3.14 / 2, // Down
                emissionFrequency: 0.05,
                numberOfParticles: 20,
                gravity: 0.3,
                shouldLoop: false,
                colors: const [
                  Colors.red,
                  Colors.blue,
                  Colors.green,
                  Colors.yellow,
                  Colors.pink,
                  Colors.orange,
                  Colors.purple,
                ],
              ),
            ),

            // Message Card
            FadeTransition(
              opacity: _fadeAnimation,
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 40),
                  padding: const EdgeInsets.all(UIConstants.paddingLarge),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(UIConstants.radiusLarge),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (widget.icon != null) ...[
                        Icon(
                          widget.icon,
                          size: 64,
                          color: theme.colorScheme.primary,
                        ),
                        const SizedBox(height: UIConstants.paddingMedium),
                      ],
                      Text(
                        widget.message,
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: UIConstants.paddingSmall),
                      Text(
                        'Tap to dismiss',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.textTheme.bodySmall?.color?.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
