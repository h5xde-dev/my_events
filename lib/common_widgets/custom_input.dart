import 'package:flutter/material.dart';

class CustomInput extends StatelessWidget {
  
  CustomInput({
    this.labelText,
    this.height,
    this.width,
    this.paddingHorizontal = 20,
    this.maxLines,
    this.keyboardType,
    this.validator,
  });

  final String labelText;
  final double height;
  final double width;
  final double paddingHorizontal;
  final int maxLines;
  final TextInputType keyboardType;
  final String Function(String) validator;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: width,
      padding: EdgeInsets.symmetric(horizontal: paddingHorizontal, vertical: 20),
      child: TextFormField(
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: labelText,
          fillColor: Theme.of(context).backgroundColor,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(25.0),
            borderSide: BorderSide(
              color: Theme.of(context).accentColor
            ),
          ),
          //fillColor: Colors.green
        ),
        validator: validator,
        keyboardType: keyboardType,
        style: TextStyle(
          fontFamily: "Poppins",
        ),
      ),
    );
  }
}