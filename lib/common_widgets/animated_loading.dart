import 'package:flutter/material.dart';
import 'package:sleek_circular_slider/sleek_circular_slider.dart';

class AnimatedLoading extends StatelessWidget {

  AnimatedLoading({
    this.currentTheme
  });
  
  final Map currentTheme;

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      child:SleekCircularSlider(
        appearance: CircularSliderAppearance(
          size: 150,
          spinnerMode: true,
          customColors: CustomSliderColors(
            trackColor: Theme.of(context).backgroundColor,
            hideShadow: true,
            progressBarColors: [Theme.of(context).primaryColor, Theme.of(context).primaryColor, Theme.of(context).primaryColor]
          ),
          customWidths: CustomSliderWidths(progressBarWidth: 10)),
      ),
    );
  }
}