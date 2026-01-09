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
  
  final gradient = Gradient.radial(radius: planetRadius);
  gradient.add(ColorRgb8(200, 200, 200));
  gradient.add(ColorRgb8(100, 100, 100));
  gradient.add(ColorRgb8(50, 50, 50));
  
  fillRect(image, x1: 0, y1: 0, x2: width, y2: height, mask: gradient);

  for (var i = 0; i < 3; i++) {
    final radius = planetRadius - 60 - (i * 40);
    final ringGradient = Gradient.radial(radius: radius, from: Point(centerX, centerY));
    ringGradient.add(ColorRgb8(0, 255, 255));
    ringGradient.add(ColorRgb8(0, 100, 200));
    fillRect(image, x1: 0, y1: 0, x2: width, y2: height, mask: ringGradient);
  }

  try {
      final font = BitmapFont.fromZip(File('tools/font.zip').readAsBytesSync());
      drawString(image, 'M C', font: font, x: (centerX - 120).toInt(), y: (centerY - 60).toInt());
  } catch(e) {
      // Font file not found. Skipping text.
  }

  File('assets/icon/app_icon.png').writeAsBytesSync(encodePng(image));
}
