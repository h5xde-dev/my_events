import 'package:flutter/material.dart';

class CustomRaisedButton extends StatelessWidget {
  
  CustomRaisedButton({
    this.child,
    this.color,
    this.borderRaius: 8.0,
    this.onPressed,
    this.height: 50.0,
  }) : assert(borderRaius != null);

  final Widget child;
  final Color color;
  final double borderRaius;
  final double height;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50.0,
      child: RaisedButton(
        child: child,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(borderRaius)
          )
        ),
        color: color,
        onPressed: onPressed,
      ),
    );
  }
}