import 'package:flutter/material.dart';
import 'package:my_events/app/shared/widgets/widgets.dart';

class SignInButton extends CustomRaisedButton {
  SignInButton({
    super.key,
    required String text,
    required Color color,
    required Color textColor,
    required VoidCallback onPressed,
  }) : super(
          child: Text(
            text,
            style: TextStyle(color: textColor, fontSize: 15.0),
          ),
          color: color,
          onPressed: onPressed,
        );
}