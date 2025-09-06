import "package:Asciiartor/services/service.dart";
import "package:Asciiartor/models/image.dart";

import "package:flutter/material.dart";
import 'package:flutter/services.dart';
import "package:image_picker/image_picker.dart";

class Controller extends ChangeNotifier{
  final service = Service();

  Future<AsciiImage> loadImage(XFile imageFile) async{
    final imageBytes = await imageFile.readAsBytes();
    return AsciiImage.fromBytes(imageFile.name, imageBytes);
  }

  Future<XFile?> pickImageFile() async{
    return ImagePicker().pickImage(source: ImageSource.gallery);
  }

  Future<bool> copyImage(AsciiImage image) async{
    await Clipboard.setData(ClipboardData(text: image.string));
    return true;
  }

  Future<bool> saveImage(AsciiImage image) async{
    final path = await service.saveImage(image);
    if(path == null) return false;
    return true;
  }
}