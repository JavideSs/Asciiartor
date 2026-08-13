import "dart:typed_data";
import "dart:ui" as ui;

import "package:flutter/material.dart";

class AsciiImage{
  static const asciiChars = "@%#*+=-:. ";

  final String name;
  final ui.Image original;
  final int width;
  final int height;
  final String string;
  final ui.Image image;

  AsciiImage({
    required this.name,
    required this.original,
    required this.width,
    required this.height,
    required this.string,
    required this.image,
  });

  static Future<AsciiImage> fromBytes(String name, Uint8List imageBytes) async{
    final image = await decodeImageFromList(imageBytes);
    final asciiartString = await getAsciiart(image, quality:10);
    final asciiartImage = await getImageFromAsciiart(asciiartString, image.width, image.height);

    return AsciiImage(
      name: name,
      original: image,
      width: image.width,
      height: image.height,
      string: asciiartString,
      image: asciiartImage,
    );
  }

  static AsciiImage error(){
    const msg1 = "Hello friend...";
    const msg2 = "We need help, we are lost";

    return AsciiImage(
      name: "error",
      original: textImage(msg2),
      width: 0,
      height: 0,
      string: msg1,
      image: textImage(msg1),
    );
  }
}

ui.Image textImage(String text){
  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder);
  final textPainter = TextPainter(
    text: TextSpan(
      text: text,
      style: const TextStyle(fontFamily: "FiraMono"),
    ),
    textDirection: TextDirection.ltr,
  );
  textPainter.layout();

  final width = textPainter.width.round();
  final height = textPainter.height.round();

  textPainter.paint(canvas, Offset.zero);
  final picture = recorder.endRecording();
  return picture.toImageSync(width, height);
}

double luminance(int r, int g, int b){
  return ((0.299 * r + 0.587 * g + 0.114 * b).round() / 255);
}

Future<String> getAsciiart(ui.Image image, {int? quality}) async{
  quality = quality ?? 100;

  final textPainter = TextPainter(
    text: const TextSpan(
      text: "W",
      style: TextStyle(fontFamily: "FiraMono")
    ),
    textDirection: TextDirection.ltr,
  );
  textPainter.layout();
  final aspectRatioChar = textPainter.width / textPainter.height;

  final cols = (quality/100 * image.width).round();
  final rows = (((image.height/image.width) * cols).round() * aspectRatioChar).round();

  final cellWidth = image.width / cols;
  final cellHeight = image.height / rows;

  final imageData = await image.toByteData(format: ui.ImageByteFormat.rawRgba);
  if (imageData == null) return "";

  final buffer = StringBuffer();

  for (int y=0; y<rows; y++){
    for (int x=0; x<cols; x++){
      double sumLuma = 0;
      int count = 0;

      for (int cy=0; cy<cellHeight; cy++){
        final py = (y * cellHeight + cy).floor();
        if (py >= image.height) continue;

        for (int cx=0; cx<cellWidth; cx++){
          final px = (x * cellWidth + cx).floor();
          if (px >= image.width) continue;

          final offset = (py * image.width + px) * 4;
          final r = imageData.getUint8(offset);
          final g = imageData.getUint8(offset + 1);
          final b = imageData.getUint8(offset + 2);
          //final a = imageData.getUint8(offset + 3);

          sumLuma += luminance(r,g,b);
          count++;
        }
      }
      final avgLuma = count > 0 ? sumLuma / count : 0.0;

      final charIndex = (avgLuma * (AsciiImage.asciiChars.length-1)).round();
      buffer.write(AsciiImage.asciiChars[charIndex]);
    }
    buffer.writeln();
  }
  return buffer.toString();
}

Future<ui.Image> getImageFromAsciiart(String asciiart, int width, int height) async{
  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder);
  final textPainter = TextPainter(textDirection: TextDirection.ltr,);

  final lines = asciiart.split("\n");
  final cols = lines.isNotEmpty ? lines[0].length : 1;
  final rows = lines.length;

  final cellWidth = width / cols;
  final cellHeight = height / rows;

  canvas.drawRect(Rect.fromLTWH(0, 0, width.toDouble(), height.toDouble()), Paint()..color = Colors.white);

  for (int y=0; y<lines.length; y++){
    final line = lines[y];
    for (int x=0; x<line.length; x++){
      final char = line[x];

      textPainter.text = TextSpan(
        text: char,
        style: TextStyle(
          fontFamily: "FiraMono",
          color: Colors.black,
          fontSize: cellHeight,
        )
      );
      textPainter.layout();

      final dx = x * cellWidth + ((cellWidth - textPainter.width) / 2);
      final dy = y * cellHeight + ((cellHeight - textPainter.height) / 2);

      textPainter.paint(canvas, Offset(dx, dy));
    }
  }

  final picture = recorder.endRecording();
  return picture.toImage(width, height);
}