import 'package:enough_giphy_flutter/enough_giphy_flutter.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:path_provider/path_provider.dart';

void showSnackBar({required BuildContext context, required String content}) {
  ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text(content)
      )
  );
}

Future<File?> pickImageFromGallery(BuildContext context) async{
  File? image;
  try{
    final pickedImage = await ImagePicker().pickImage(source: ImageSource.gallery);
    if(pickedImage != null){
      image = File(pickedImage.path);
    }
  }
  catch(e){
    showSnackBar(context: context, content: e.toString());
  }
  return image;
}

Future<File?> pickVideoFromGallery(BuildContext context) async{
  File? video;
  try{
    final pickedVideo = await ImagePicker().pickVideo(source: ImageSource.gallery);
    if(pickedVideo != null){
      video = File(pickedVideo.path);
    }
  }
  catch(e){
    showSnackBar(context: context, content: e.toString());
  }
  return video;
}

Future<GiphyGif?> pickGIF(BuildContext context) async{
  GiphyGif? gif;
  try{
    gif = await Giphy.getGif(
      context: context,
      apiKey: "xhbFWDycRhQBdSkTWtPRfxalWF3LhfcR",
      showTypeSwitcher: false,
    );
  }catch(e){
    showSnackBar(context: context, content: e.toString());
  }
  return gif;
}


Future<File> getImageFileFromAssets(String path) async {
  final byteData = await rootBundle.load('assets/$path');

  final file = File('${(await getTemporaryDirectory()).path}/$path');
  await file.writeAsBytes(byteData.buffer.asUint8List(byteData.offsetInBytes, byteData.lengthInBytes));

  return file;
}
