import "package:asciiartor/services/service.dart";
import "package:asciiartor/models/image.dart";

import "package:flutter/material.dart";
import 'package:flutter/services.dart';
import "package:image_picker/image_picker.dart";

class Controller{
  final service = Service();

  Future<AsciiImage> loadImage(XFile imageFile) async{
    final imageBytes = await imageFile.readAsBytes();
    return AsciiImage.fromBytes(imageFile.name, imageBytes);
  }

  Future<XFile?> pickImageFile() async{
    return ImagePicker().pickImage(source: ImageSource.gallery);
  }

  Future<bool> copyImage(AsciiImage image) async{
    try{
      await Clipboard.setData(ClipboardData(text: image.string));
      return true;
    } catch (_){
      return false;
    }
  }

  Future<bool> saveImage(AsciiImage image) async{
    final path = await service.saveImage(image);
    return path != null;
  }
}