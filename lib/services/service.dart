import "package:asciiartor/models/image.dart";

import "dart:ui" as ui;
import "dart:io" as io;

import "package:flutter/foundation.dart" show kIsWeb;
import "package:path/path.dart";

import "package:file_saver/file_saver.dart";
import "package:gal/gal.dart";

class Service{
  Future<String?> saveImage(AsciiImage image) async{
    final imageData = await image.image.toByteData(format: ui.ImageByteFormat.png);
    if (imageData == null) return null;
    final imageBytes = imageData.buffer.asUint8List();

    final imageName = "${basenameWithoutExtension(image.name)}_asciilized";
    final imageExtension = "png";
    final imageFile = "$imageName.$imageExtension";

    if (kIsWeb){
      await FileSaver.instance.saveFile(
        name: imageName,
        bytes: imageBytes,
        fileExtension: imageExtension,
        mimeType: MimeType.png,
      );
      return "web-download-path:$imageFile";
    }
    if (io.Platform.isWindows || io.Platform.isMacOS || io.Platform.isLinux){
      return FileSaver.instance.saveFile(
        name: imageName,
        bytes: imageBytes,
        fileExtension: imageExtension,
        mimeType: MimeType.png,
      );
    }
    if (io.Platform.isAndroid || io.Platform.isIOS){
      try{
        if (!await Gal.hasAccess()){
          if (!await Gal.requestAccess()) return null;
        }
        await Gal.putImageBytes(imageBytes, name: imageName);
        return imageFile;
      } on GalException{
        return null;
      }
    }
    if (io.Platform.isFuchsia){
      final dir = io.Directory.current;
      if (!dir.existsSync()) dir.createSync(recursive: true);
      final file = io.File(join(dir.path, imageFile));
      file.writeAsBytes(imageBytes);
      return file.path;
    }
    return null;
  }
}