// ignore_for_file: import_of_legacy_library_into_null_safe, use_build_context_synchronously

import 'package:file_picker/file_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HelperFunctions{
  HelperFunctions._();
  /// keys
  static const String userLoggedInKey = 'LoggedInKey';
  static const String userNameKey = 'UserNameKey';
  static const String userEmailKey = 'UserEmailKey';
  static const String userIdKey = 'UserIdKey';

  /// saving the data to shared  preference
  static Future<bool> saveUserLoggedInStatus(bool isUserLoggedIn)async{
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    return sharedPreferences.setBool(userLoggedInKey, isUserLoggedIn);
  }

  static Future<bool> saveUserLoggedInName(String userName)async{
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    if(userName.isNotEmpty){
      return sharedPreferences.setString(userNameKey, userName);
    }
    else{
      return sharedPreferences.setString(userNameKey, 'anonymous');
    }
  }

  static Future<bool> saveUserLoggedInEmail(String userEmail)async{
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    return sharedPreferences.setString(userEmailKey, userEmail);
  }

  static Future<bool> saveUserLoggedInUid(String userId)async{
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    return sharedPreferences.setString(userIdKey, userId);
  }

 /// getting the data from shared  preference
  static Future<bool> getUserLoggedInStatus()async{
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    return sharedPreferences.getBool(userLoggedInKey);
  }


  static Future<String> getUserLoggedName()async{
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    return sharedPreferences.getString(userNameKey);
  }


  static Future<String> getUserLoggedInEmail()async{
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    return sharedPreferences.getString(userEmailKey);
  }

  static Future<String> getUserLoggedInUid()async{
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    return sharedPreferences.getString(userIdKey);
  }



  /// email validation
  static bool emailValidate(String email){
    return RegExp(r"^[a-zA-Z\d.a-zA-Z\d.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z\d]+\.[a-zA-Z]+")
        .hasMatch(email);
  }

  /// password validation
  static bool passwordValidate(String password){
    return RegExp(r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?\d)(?=.*?[!@#$&*~]).{8,}$')
        .hasMatch(password);
  }

  /// get other user Id
  static String getOtherUserId(String uid){
    return uid.split('_').last;
  }

  /// get chats persons ids
  static List<String> getChatUsersIds(String chatId){
    return chatId.split('_');
  }

  /// create chat Id
  static String  createChatId(String yourUid,String otherUid){
    return '${yourUid}_$otherUid';
  }

  /// reverse chat id
  static String getReversedChatId(String chatId){
    String first = chatId.split('_').first;
    String last = chatId.split('_').last;
    return '${last}_$first';
  }

  /// message sender
  static Future<bool> isSentByMe(String senderId)async{
    if(senderId == await HelperFunctions.getUserLoggedInUid()){
      return true;
    }
    else{
      return false;
    }
  }

  /// pick image from gallery
  static Future<List<String>> pickImage()async{
    final FilePickerResult? result = await FilePicker.platform.pickFiles(
      allowMultiple: false,
      type: FileType.custom,
      allowedExtensions: ['png','jpg','jpeg'],
    );
    if(result==null){
      return [];
    }
    else{
      final String path = result.files.single.path!;
      final String fileName = result.files.single.name;
      return [path,fileName];
    }
  }

}