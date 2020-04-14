import 'dart:math';

import 'package:flutter/material.dart';
import 'package:simple_animations/simple_animations.dart';

class AnimatedBackground extends StatelessWidget {

  AnimatedBackground({
    this.child,
    this.currentTheme
  });

  final Widget child;
  final Map currentTheme;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Positioned.fill(child: AnimatedGradient(currentTheme:currentTheme)),
        onBottom(AnimatedWave(
          height: 100,
          speed: 0.3,
        )),
        onBottom(AnimatedWave(
          height: 120,
          speed: 0.4,
          offset: pi,
        )),
        onBottom(AnimatedWave(
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

class AnimatedWave extends StatelessWidget {
  final double height;
  final double speed;
  final double offset;

  AnimatedWave({
    this.height,
    this.speed,
    this.offset = 0.0
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      return Container(
        height: height,
        width: constraints.biggest.width,
        child: ControlledAnimation(
            playback: Playback.LOOP,
            duration: Duration(milliseconds: (5000 / speed).round()),
            tween: Tween(begin: 0.0, end: 2 * pi),
            builder: (context, value) {
              return CustomPaint(
                foregroundPainter: CurvePainter(context:context, value:value + offset),
              );
            }),
      );
    });
  }
}

class CurvePainter extends CustomPainter {

  CurvePainter({
    this.value,
    this.context
  });

  final double value;
  final context;

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

  AnimatedGradient({
    this.currentTheme
  });

  final Map currentTheme;

  @override
  Widget build(BuildContext context) {
    final tween = MultiTrackTween([
      Track("color1").add(Duration(seconds: 3),
          ColorTween(begin: Theme.of(context).backgroundColor, end: Theme.of(context).primaryColor)),
      Track("color2").add(Duration(seconds: 3),
          ColorTween(begin: Theme.of(context).primaryColor, end: Theme.of(context).accentColor))
    ]);

    return ControlledAnimation(
      playback: Playback.MIRROR,
      tween: tween,
      duration: tween.duration,
      builder: (context, animation) {
        return Container(
          decoration: BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment.center,
                  end: Alignment.bottomCenter,
                  colors: [
                    Theme.of(context).backgroundColor,
                    Theme.of(context).backgroundColor,
                    animation["color1"],
                    //animation["color2"],
                  ])),
        );
      },
    );
  }
}