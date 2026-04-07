import 'dart:math';
import 'package:flutter/material.dart';

class AnimatedBackground extends StatelessWidget {
  const AnimatedBackground({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        const Positioned.fill(child: AnimatedGradient()),
        onBottom(const AnimatedWave(
          height: 100,
          speed: 0.3,
        )),
        onBottom(const AnimatedWave(
          height: 120,
          speed: 0.4,
          offset: pi,
        )),
        onBottom(const AnimatedWave(
          height: 140,
          speed: 0.4,
          offset: pi / 2,
        )),
        Positioned.fill(child: child),
      ],
    );
  }

  onBottom(Widget child) => Positioned.fill(
        child: Align(
          alignment: Alignment.bottomCenter,
          child: child,
        ),
      );
}

class AnimatedWave extends StatefulWidget {
  final double height;
  final double speed;
  final double offset;

  const AnimatedWave({
    super.key,
    required this.height,
    required this.speed,
    this.offset = 0.0,
  });

  @override
  State<AnimatedWave> createState() => _AnimatedWaveState();
}

class _AnimatedWaveState extends State<AnimatedWave>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: (5000 / widget.speed).round()),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      return SizedBox(
        height: widget.height,
        width: constraints.biggest.width,
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            final value = _controller.value * 2 * pi + widget.offset;
            return CustomPaint(
              foregroundPainter: CurvePainter(context: context, value: value),
            );
          },
        ),
      );
    });
  }
}

class CurvePainter extends CustomPainter {
  CurvePainter({required this.value, required this.context});

  final double value;
  final BuildContext context;

  @override
  void paint(Canvas canvas, Size size) {
    final color = Paint()..color = Theme.of(context).primaryColor.withAlpha(60);
    final path = Path();

    final y1 = sin(value);
    final y2 = sin(value + pi / 2);
    final y3 = sin(value + pi);

    final startPointY = size.height * (0.5 + 0.4 * y1);
    final controlPointY = size.height * (0.5 + 0.4 * y2);
    final endPointY = size.height * (0.5 + 0.4 * y3);

    path.moveTo(size.width * 0, startPointY);
    path.quadraticBezierTo(
        size.width * 0.5, controlPointY, size.width, endPointY);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();
    canvas.drawPath(path, color);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}

class AnimatedGradient extends StatelessWidget {
  const AnimatedGradient({super.key});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: 1),
      duration: const Duration(seconds: 3),
      curve: Curves.easeInOut,
      onEnd: () {},
      builder: (context, value, _) {
        final surface = Theme.of(context).colorScheme.surface;
        final primary = Theme.of(context).colorScheme.primary;
        final color1 = Color.lerp(surface, primary, value) ?? surface;
        return Container(
          decoration: BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment.center,
                  end: Alignment.bottomCenter,
                  colors: [
                    surface,
                    surface,
                    color1,
                  ])),
        );
      },
    );
  }
}