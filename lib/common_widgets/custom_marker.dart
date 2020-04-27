import 'dart:async';
import 'dart:ui' as ui;
import 'dart:typed_data';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

Future<ui.Image> getImageFromPath(String imagePath) async {  
  final data = await rootBundle.load(imagePath);
  final list = Uint8List.view(data.buffer);
  final completer = Completer<ui.Image>();
  ui.decodeImageFromList(list, completer.complete);
  print(completer.future.toString());
  return completer.future;
}

Future<BitmapDescriptor> getMarkerIcon(String imagePath, Size size, BuildContext context) async {
    final ui.PictureRecorder pictureRecorder = ui.PictureRecorder();
    final Canvas canvas = Canvas(pictureRecorder);

    final Radius radius = Radius.circular(size.width / 2);

    final Paint tagPaint = Paint()..color = Theme.of(context).primaryColor;
    final double tagWidth = 40.0;

    final Paint shadowPaint = Paint()..color = Theme.of(context).primaryColor.withAlpha(100);
    final double shadowWidth = 15.0;

    final Paint borderPaint = Paint()..color = Theme.of(context).backgroundColor;
    final double borderWidth = 3.0;

    final double imageOffset = shadowWidth + borderWidth;

    // Add shadow circle
    canvas.drawRRect(
        RRect.fromRectAndCorners(
          Rect.fromLTWH(
              0.0,
              0.0,
              size.width,
              size.height
          ),
          topLeft: radius,
          topRight: radius,
          bottomLeft: radius,
          bottomRight: radius,
        ),
        shadowPaint);

    // Add border circle
    canvas.drawRRect(
        RRect.fromRectAndCorners(
          Rect.fromLTWH(
              shadowWidth,
              shadowWidth,
              size.width - (shadowWidth * 2),
              size.height - (shadowWidth * 2)
          ),
          topLeft: radius,
          topRight: radius,
          bottomLeft: radius,
          bottomRight: radius,
        ),
        borderPaint);

    // Add tag circle
    canvas.drawRRect(
        RRect.fromRectAndCorners(
          Rect.fromLTWH(
              size.width - tagWidth,
              0.0,
              tagWidth,
              tagWidth
          ),
          topLeft: radius,
          topRight: radius,
          bottomLeft: radius,
          bottomRight: radius,
        ),
        tagPaint);

    // Add tag text
    TextPainter textPainter = TextPainter(textDirection: TextDirection.ltr);
    textPainter.text = TextSpan(
      text: '1',
      style: TextStyle(fontSize: 20.0, color: Colors.white),
    );

    textPainter.layout();
    textPainter.paint(
        canvas,
        Offset(
            size.width - tagWidth / 2 - textPainter.width / 2,
            tagWidth / 2 - textPainter.height / 2
        )
    );

    // Oval for the image
    Rect oval = Rect.fromLTWH(
        imageOffset,
        imageOffset,
        size.width - (imageOffset * 2),
        size.height - (imageOffset * 2)
    );

    // Add path for oval image
    canvas.clipPath(Path()
      ..addOval(oval));

    // Add image
    ui.Image image = await getImageFromPath(imagePath); // Alternatively use your own method to get the image
    paintImage(canvas: canvas, image: image, rect: oval, fit: BoxFit.fill);

    // Convert canvas to image
    final ui.Image markerAsImage = await pictureRecorder.endRecording().toImage(
        size.width.toInt(),
        size.height.toInt()
    );

    // Convert image to bytes
    final ByteData byteData = await markerAsImage.toByteData(format: ui.ImageByteFormat.png);
    final Uint8List uint8List = byteData.buffer.asUint8List();

    return BitmapDescriptor.fromBytes(uint8List);
}