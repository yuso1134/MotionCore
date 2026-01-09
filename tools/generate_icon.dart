import 'dart:io';
import 'dart:math' as math;
import 'package:image/image.dart';

void main() {
  const width = 1024;
  const height = 1024;
  final image = Image(width: width, height: height);

  fill(image, color: ColorRgb8(0, 5, 16));

  final centerX = width / 2;
  final centerY = height / 2;

  final random = math.Random();
  for (var i = 0; i < 200; i++) {
    final x = random.nextInt(width);
    final y = random.nextInt(height);
    final size = random.nextDouble() * 2 + 1;
    final alpha = random.nextDouble() * 0.5 + 0.5;
    drawCircle(image, x: x, y: y, radius: size.toInt(), color: ColorRgba8(255, 255, 255, (255 * alpha).toInt()));
  }

  const planetRadius = 300.0;

  for (var i = 0; i < 5; i++) {
    final radius = planetRadius + 40 + (i * 20);
    final color = ColorRgba8(0, 255, 255, 50 - i * 10);
    drawCircle(image, x: centerX.toInt(), y: centerY.toInt(), radius: radius.toInt(), color: color, antialias: true);
  }
  
  for (var y = -planetRadius; y < planetRadius; y++) {
    for (var x = -planetRadius; x < planetRadius; x++) {
      if (x * x + y * y <= planetRadius * planetRadius) {
        final distance = math.sqrt(x * x + y * y) / planetRadius;
        final colorValue = 200 - (distance * 150).toInt();
        final color = ColorRgb8(colorValue, colorValue, colorValue);
        drawPixel(image, (centerX + x).toInt(), (centerY + y).toInt(), color);
      }
    }
  }

  for (var i = 0; i < 3; i++) {
    final radius = planetRadius - 60 - (i * 40);
    final ringWidth = 10.0;
    for (var y = -radius; y < radius; y++) {
      for (var x = -radius; x < radius; x++) {
        final distance = math.sqrt(x * x + y * y);
        if (distance >= radius - ringWidth && distance <= radius) {
          final t = (distance - (radius - ringWidth)) / ringWidth;
          final r = (0 * (1 - t) + 0 * t).toInt();
          final g = (255 * (1 - t) + 100 * t).toInt();
          final b = (255 * (1 - t) + 200 * t).toInt();
          final color = ColorRgb8(r, g, b);
          drawPixel(image, (centerX + x).toInt(), (centerY + y).toInt(), color);
        }
      }
    }
  }

  try {
      final font = BitmapFont.fromZip(File('tools/font.zip').readAsBytesSync());
      drawString(image, 'M C', font: font, x: (centerX - 120).toInt(), y: (centerY - 60).toInt());
  } catch(e) {
      // Font file not found. Skipping text.
  }

  File('assets/icon/app_icon.png').writeAsBytesSync(encodePng(image));
}
