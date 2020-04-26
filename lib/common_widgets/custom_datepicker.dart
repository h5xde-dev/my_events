import 'package:flutter/material.dart';

class CustomDatepicker extends StatelessWidget {
  
  CustomDatepicker({
    this.labelText,
    this.height,
    this.width,
    this.onTap,
    this.onSaved,
    this.textController,
  });

  final String labelText;
  final double height;
  final double width;
  final Function onTap;
  final Function onSaved;
  final TextEditingController textController;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: width,
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: TextFormField(
        controller: textController,
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
        onTap: onTap,
        onSaved: onSaved,
      ),
    );
  }
}