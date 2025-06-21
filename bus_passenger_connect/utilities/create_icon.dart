// A simple Dart script to generate a bus icon PNG file
import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';

void main() async {
  // Setup a recorder and canvas
  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder);

  // Define the size
  const size = Size(1024, 1024);

  // Draw the background
  final bgPaint = Paint()..color = Colors.blue;
  canvas.drawCircle(
    Offset(size.width / 2, size.height / 2),
    size.width / 2,
    bgPaint,
  );

  // Draw the bus body
  final bodyPaint = Paint()..color = Colors.white;
  final bodyRect = Rect.fromLTWH(160, 300, 704, 300);
  canvas.drawRRect(
    RRect.fromRectAndRadius(bodyRect, Radius.circular(50)),
    bodyPaint,
  );

  // Draw windows
  final windowPaint = Paint()..color = Colors.lightBlue.shade100;
  final windowPositions = [210, 310, 410, 510, 610, 710];
  for (final x in windowPositions) {
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(x.toDouble(), 350, 80, 100),
        Radius.circular(10),
      ),
      windowPaint,
    );
  }

  // Draw door
  final doorPaint = Paint()..color = Colors.blue.shade900;
  canvas.drawRRect(
    RRect.fromRectAndRadius(
      Rect.fromLTWH(510, 500, 80, 100),
      Radius.circular(10),
    ),
    doorPaint,
  );

  // Draw wheels
  final wheelPaint = Paint()..color = Colors.grey.shade800;
  canvas.drawCircle(Offset(250, 650), 70, wheelPaint);
  canvas.drawCircle(Offset(774, 650), 70, wheelPaint);

  final hubcapPaint = Paint()..color = Colors.grey;
  canvas.drawCircle(Offset(250, 650), 40, hubcapPaint);
  canvas.drawCircle(Offset(774, 650), 40, hubcapPaint);

  // Draw headlights
  final headlightPaint = Paint()..color = Colors.yellow;
  canvas.drawCircle(Offset(190, 300), 20, headlightPaint);
  canvas.drawCircle(Offset(834, 300), 20, headlightPaint);

  // Convert to an image
  final picture = recorder.endRecording();
  final img = await picture.toImage(size.width.toInt(), size.height.toInt());
  final pngBytes = await img.toByteData(format: ui.ImageByteFormat.png);

  // Save to a file
  File(
    'assets/images/bus_icon.png',
  ).writeAsBytesSync(pngBytes!.buffer.asUint8List());
}
