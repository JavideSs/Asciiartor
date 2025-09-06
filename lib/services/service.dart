import "package:Asciiartor/models/image.dart";

import "dart:ui" as ui;
import "dart:io" as io;

import "package:flutter/foundation.dart" show kIsWeb;
import "package:path/path.dart";
import "package:device_info_plus/device_info_plus.dart";
import "package:path_provider/path_provider.dart";
import "package:permission_handler/permission_handler.dart";
import "package:image_gallery_saver/image_gallery_saver.dart";
import "package:universal_html/html.dart";

class Service{
  Future<String?> saveImage(AsciiImage image) async{
    final imageData = await image.image.toByteData(format: ui.ImageByteFormat.png);
    if (imageData == null) return null;
    final imageBytes = imageData.buffer.asUint8List();

    //Simpler with https://pub.dev/packages/file_saver
    if (kIsWeb){
      final blob = Blob([imageBytes]);
      final url = Url.createObjectUrlFromBlob(blob);
      AnchorElement(href: url)
        ..setAttribute("download", image.name)
        ..click();
      Url.revokeObjectUrl(url);
      return "web-download-path://${image.name}";
    }
    if (io.Platform.isWindows || io.Platform.isLinux || io.Platform.isMacOS){
      final dir = await getDownloadsDirectory();
      if (dir == null) return null;
      final file = io.File(join(dir.path, image.name));
      file.writeAsBytes(imageBytes);
      return file.path;
    }
    if (io.Platform.isAndroid || io. Platform.isIOS){
      if (io.Platform.isAndroid){
        final androidInfo = await DeviceInfoPlugin().androidInfo;
        if (androidInfo.version.sdkInt < 30){
          if (!await Permission.storage.request().isGranted) return null;
        }
      }
      else if (io.Platform.isIOS){
        if (!await Permission.photos.request().isGranted) return null;
      }
      final result = await ImageGallerySaver.saveImage(imageBytes, quality: 100, name: image.name, isReturnImagePathOfIOS: true);
      if (!result["isSuccess"]) return null;
      return result["filePath"];
    }
    if (io.Platform.isFuchsia){
      final dir = io.Directory.current;
      if (!dir.existsSync()) dir.createSync(recursive: true);
      final file = io.File(join(dir.path, image.name));
      file.writeAsBytes(imageBytes);
      return file.path;
    }
    return image.name;
  }
}