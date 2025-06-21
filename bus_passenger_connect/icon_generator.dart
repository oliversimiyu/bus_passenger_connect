import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'dart:io';
import 'dart:typed_data';

void main() {
  // Create a 1024x1024 image with blue background
  final image = img.Image(width: 1024, height: 1024);
  img.fill(image, color: img.ColorRgb8(25, 118, 210)); // Blue color

  // Draw bus body (white rectangle)
  drawRect(image, 160, 300, 864, 600, img.ColorRgb8(255, 255, 255));

  // Draw windows (light blue rectangles)
  final windowColor = img.ColorRgb8(179, 229, 252);
  drawRect(image, 210, 350, 290, 450, windowColor);
  drawRect(image, 310, 350, 390, 450, windowColor);
  drawRect(image, 410, 350, 490, 450, windowColor);
  drawRect(image, 510, 350, 590, 450, windowColor);
  drawRect(image, 610, 350, 690, 450, windowColor);
  drawRect(image, 710, 350, 790, 450, windowColor);

  // Draw door (dark blue rectangle)
  drawRect(image, 510, 500, 590, 600, img.ColorRgb8(13, 71, 161));

  // Draw wheels (black circles)
  drawCircle(image, 250, 650, 70, img.ColorRgb8(66, 66, 66));
  drawCircle(image, 774, 650, 70, img.ColorRgb8(66, 66, 66));

  // Draw wheel hubcaps (gray circles)
  drawCircle(image, 250, 650, 40, img.ColorRgb8(158, 158, 158));
  drawCircle(image, 774, 650, 40, img.ColorRgb8(158, 158, 158));

  // Draw headlights (yellow circles)
  drawCircle(image, 190, 300, 20, img.ColorRgb8(255, 235, 59));
  drawCircle(image, 834, 300, 20, img.ColorRgb8(255, 235, 59));

  // Save the images
  File('assets/images/bus_icon.png').writeAsBytesSync(img.encodePng(image));

  // Create a foreground version (transparent background)
  final foregroundImage = img.Image(width: 1024, height: 1024);
  img.fill(foregroundImage, color: img.ColorRgba8(0, 0, 0, 0));

  // Copy the bus elements to the foreground image
  drawRect(foregroundImage, 160, 300, 864, 600, img.ColorRgb8(25, 118, 210));

  // Draw windows on foreground
  drawRect(foregroundImage, 210, 350, 290, 450, windowColor);
  drawRect(foregroundImage, 310, 350, 390, 450, windowColor);
  drawRect(foregroundImage, 410, 350, 490, 450, windowColor);
  drawRect(foregroundImage, 510, 350, 590, 450, windowColor);
  drawRect(foregroundImage, 610, 350, 690, 450, windowColor);
  drawRect(foregroundImage, 710, 350, 790, 450, windowColor);

  // Draw door on foreground
  drawRect(foregroundImage, 510, 500, 590, 600, img.ColorRgb8(13, 71, 161));

  // Draw wheels on foreground
  drawCircle(foregroundImage, 250, 650, 70, img.ColorRgb8(66, 66, 66));
  drawCircle(foregroundImage, 774, 650, 70, img.ColorRgb8(66, 66, 66));

  // Draw wheel hubcaps on foreground
  drawCircle(foregroundImage, 250, 650, 40, img.ColorRgb8(158, 158, 158));
  drawCircle(foregroundImage, 774, 650, 40, img.ColorRgb8(158, 158, 158));

  // Draw headlights on foreground
  drawCircle(foregroundImage, 190, 300, 20, img.ColorRgb8(255, 235, 59));
  drawCircle(foregroundImage, 834, 300, 20, img.ColorRgb8(255, 235, 59));

  // Save the foreground image
  File(
    'assets/images/bus_icon_foreground.png',
  ).writeAsBytesSync(img.encodePng(foregroundImage));
}

void drawRect(
  img.Image image,
  int x1,
  int y1,
  int x2,
  int y2,
  img.Color color,
) {
  img.fillRect(image, x1: x1, y1: y1, x2: x2, y2: y2, color: color);
}

void drawCircle(img.Image image, int x, int y, int radius, img.Color color) {
  img.fillCircle(image, x: x, y: y, radius: radius, color: color);
}
