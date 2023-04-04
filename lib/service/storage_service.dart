// ignore_for_file: use_build_context_synchronously

import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:firebase_core/firebase_core.dart' as firebase_core;

class StorageService{
  final firebase_storage.FirebaseStorage storage = firebase_storage.FirebaseStorage.instance;

  Future uploadFile(String filePath,String fileName)async{
    File file = File(filePath);
    try{
      await storage.ref('userProfilePic/$fileName').putFile(file);
    }
    on firebase_core.FirebaseException catch(e){
      print('error:-------');
      print(e.message);
    }
  }

  Future<String> getImageUrl(String name)async{
    firebase_storage.ListResult results = await storage.ref('userProfilePic').listAll();
    String url='';
    for (var element in results.items) {
      if(element.name==name){
         print('name: ${element.name}');
         url = await element.getDownloadURL();
         print('upload url:----- $url');
         return url;
      }
    }
    throw '';
  }
}