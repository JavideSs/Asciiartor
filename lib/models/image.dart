import "dart:ui" as ui;

import "package:flutter/material.dart";
import "package:flutter/foundation.dart";

enum AsciiImageStyle{
  classic("@%#*+=-:. "),
  simple("@#:. "),
  dots("●●○○••··  ",),
  blocks("█▓▒░ "),
  binary("@ "),
  binaryBlock("█ ",),
  detailed(r"""$@B%8&WM#*oahkbdpqwmZO0QLCJUYXzcvunxrjft/\\\\|()1{}[]?-_+~<>i!lI;:,\"^`'. """,),
  dense("@@##88&&WWMMBBQRRNNXXGGEE00SSZZccvvuuJJFFLLii11ttff//\\\\||()[]{} ",);

  final String characters;
  const AsciiImageStyle(this.characters);
}

class AsciiImage{
  final String name;
  final ui.Image original;
  final int width;
  final int height;
  AsciiImageStyle style;
  int resolution;
  String string;
  ui.Image image;

  AsciiImage({
    required this.name,
    required this.original,
    required this.width,
    required this.height,
    required this.style,
    required this.resolution,
    required this.string,
    required this.image,
  });

  static Future<AsciiImage> fromBytes(String name, Uint8List imageBytes, {AsciiImageStyle style = AsciiImageStyle.classic, int resolution = 10}) async{
    final image = await decodeImageFromList(imageBytes);
    return fromImage(name, image, style:style, resolution:resolution);
  }

  static Future<AsciiImage> fromImage(String name, ui.Image image, {AsciiImageStyle style = AsciiImageStyle.classic, int resolution = 10}) async{
    final asciiartString = await getAsciiart(image, style, resolution);
    final asciiartImage = await getImageFromAsciiart(asciiartString, image.width, image.height);

    return AsciiImage(
      name: name,
      original: image,
      width: image.width,
      height: image.height,
      style: style,
      resolution: resolution,
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
      style: AsciiImageStyle.classic,
      resolution: 3,
      string: msg1,
      image: textImage(msg1),
    );
  }

  Future<void> config({AsciiImageStyle? style, int? resolution}) async{
    if (name == "error") return;

    style ??= this.style;
    resolution ??= this.resolution;

    final oldimage = image;

    string = await getAsciiart(original, style, resolution);
    image = await getImageFromAsciiart(string, width, height);
    this.style = style;
    this.resolution = resolution;

    oldimage.dispose();
  }

  void dispose(){
    original.dispose();
    image.dispose();
  }
}

class AsciiImageData{
  final Uint8List bytes;
  final int width;
  final int height;
  final String characters;
  final int resolution;
  final double aspectRatioChar;

  const AsciiImageData({
    required this.bytes,
    required this.width,
    required this.height,
    required this.characters,
    required this.resolution,
    required this.aspectRatioChar,
  });
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

final double aspectRatioChar = (){
  final textPainter = TextPainter(
    text: const TextSpan(
      text: "W",
      style: TextStyle(
        fontFamily: "FiraMono",
      ),
    ),
    textDirection: TextDirection.ltr,
  );

  textPainter.layout();

  return textPainter.width / textPainter.height;
}();

double luminance(int r, int g, int b){
  return ((0.299 * r + 0.587 * g + 0.114 * b).round() / 255);
}

Future<String> getAsciiart(ui.Image image, AsciiImageStyle style, int resolution) async{
  final imageData = await image.toByteData(format: ui.ImageByteFormat.rawRgba);
  if (imageData == null) return "";

  String generateAsciiart(AsciiImageData imageData){
    final cols = (imageData.resolution/100 * imageData.width).round().clamp(1, imageData.width);
    final rows = (((imageData.height/imageData.width) * cols).round() * imageData.aspectRatioChar).round();

    final cellWidth = imageData.width / cols;
    final cellHeight = imageData.height / rows;

    final buffer = StringBuffer();

    for (int y=0; y<rows; y++){
      for (int x=0; x<cols; x++){
        double sumLuma = 0;
        int count = 0;

        for (int cy=0; cy<cellHeight; cy++){
          final py = (y * cellHeight + cy).floor();
          if (py >= imageData.height) continue;

          for (int cx=0; cx<cellWidth; cx++){
            final px = (x * cellWidth + cx).floor();
            if (px >= imageData.width) continue;

            final offset = (py * imageData.width + px) * 4;
            final r = imageData.bytes[offset];
            final g = imageData.bytes[offset + 1];
            final b = imageData.bytes[offset + 2];
            //final a = imageData.bytes[offset + 3];

            sumLuma += luminance(r,g,b);
            count++;
          }
        }
        final avgLuma = count > 0 ? sumLuma / count : 0.0;

        final charIndex = (avgLuma * (imageData.characters.length-1)).round();
        buffer.write(imageData.characters[charIndex]);
      }
      if (y < rows-1){
        buffer.writeln();
      }
    }
    return buffer.toString();
  }

  return compute(
    generateAsciiart,
    AsciiImageData(
      bytes: imageData.buffer.asUint8List(),
      width: image.width,
      height: image.height,
      characters: style.characters,
      resolution: resolution,
      aspectRatioChar: aspectRatioChar,
    ),
  );
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

  final sw = Stopwatch()..start();
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

      if (sw.elapsedMilliseconds > 8){
        await Future<void>.delayed(Duration.zero);
        sw.reset();
      }
    }
  }

  final picture = recorder.endRecording();
  return picture.toImage(width, height);
}