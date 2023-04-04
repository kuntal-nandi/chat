
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_chat/helper/helper_functions.dart';
class DatabaseService{
  final String? userId;
  DatabaseService(this.userId);

  ///reference for our collections
  final CollectionReference userCollection = FirebaseFirestore.instance.collection("users");
  final CollectionReference chatsCollection = FirebaseFirestore.instance.collection("chats");

  ///saving user data
  Future savingUserData(String fullName,String email)async{
    return await userCollection.doc(userId).set({
      "fullName": fullName,
      "email": email,
      "userId": userId,
      "chats": [],
      "profilePic": "",
      "isOnline": false,
      "isTyping": false,
    });
  }

  ///getting user data
  Future<dynamic> gettingUserData(String email)async{
    QuerySnapshot snapshot = await userCollection.where('email',isEqualTo: email).get();
    return snapshot.docs;
  }

  /// get all users
  Future<Stream<QuerySnapshot<Object?>>> getAllUsers()async{
    //snapshot = FirebaseFirestore.instance.collection('users').snapshots();
    Stream<QuerySnapshot<Object?>> snapshot = userCollection.where('email',isNotEqualTo: '').snapshots();
    return snapshot;
  }

  ///update data
  Future updateUserDetails({required String name,required String email})async{
    return await userCollection.doc(userId).update({
      "fullName": name,
      "email": email
    });
  }

  ///upload profile pic
  Future uploadProfilePic({required String url})async{
    return await userCollection.doc(userId).update({
      "profilePic": url,
    });
  }

  ///add chat
  Future updateChat({required String chatId})async {
    return await userCollection.doc(userId).update(
        {"chats": FieldValue.arrayUnion([chatId])});
  }

  /// create chat
  Future createChatWithUser({required String chatId})async{
    await userCollection.doc(userId).update(
        {"chats": FieldValue.arrayUnion([chatId])});
    await userCollection.doc(HelperFunctions.getOtherUserId(chatId)).update(
        {"chats": FieldValue.arrayUnion([chatId])});
    return await chatsCollection.doc(chatId).set({
      "chatId": chatId,
      "lastMessage": '',
      "lastMessageSender": '',
      "lastMessageTime": '',
    });
  }

  /// is chat already available
  Future<bool> isChatAvailable(String chatId)async{
    QuerySnapshot userData = await userCollection.where('userId',isEqualTo: userId).get();
    List<dynamic> chatsList = userData.docs[0]['chats'];
    bool isChatAvailable;
    if(chatsList.contains(chatId) || chatsList.contains(HelperFunctions.getReversedChatId(chatId))){
       isChatAvailable = true;
    }
    else{
      isChatAvailable = false;
    }
    return isChatAvailable;
  }

  ///get chatId
  Future<String> getUserChatId(String chatId)async{
    QuerySnapshot userData = await userCollection.where('userId',isEqualTo: userId).get();
    List<dynamic> chatsList = userData.docs[0]['chats'];
    if(chatsList.contains(chatId)){
      return chatId;
    }
    else if(chatsList.contains(HelperFunctions.getReversedChatId(chatId))){
      String reverse = HelperFunctions.getReversedChatId(chatId);
      return reverse;
    }
    else{
      return '';
    }
  }

  /// send message
  sendMessage({required String chatId,required Map<String,dynamic> messageData})async{
    await chatsCollection.doc(chatId).collection("messages").add(messageData);
    await chatsCollection.doc(chatId).update({
      'lastMessage': messageData['message'],
      'lastMessageSender': messageData['sendBy'],
      'lastMessageTime': messageData['time'],
    });
  }


  /// get chats
  Future<Stream<QuerySnapshot<Map<String, dynamic>>>> getAllChats(String chatId)async{
     Stream<QuerySnapshot<Map<String, dynamic>>> snapshot = chatsCollection.doc(chatId).collection('messages').orderBy('time').snapshots();
    return snapshot;
  }

  /// update online offline
  updateUserStatus(bool status)async{
    return await userCollection.doc(userId).update({
      "isOnline": status,
    });
  }


  /// get online,offline,typing status
  Future<Stream<QuerySnapshot<Object?>>> getUserDetails() async {
    return userCollection.where('userId',isEqualTo: userId).snapshots();
  }

  /// update online offline
  updateTypingStatus(bool status)async{
    return await userCollection.doc(userId).update({
      "isTyping": status,
    });
  }


}