// ignore_for_file: unnecessary_null_comparison

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_chat/helper/helper_functions.dart';
import 'package:firebase_chat/service/database_service.dart';

class AuthService{
  final FirebaseAuth firebaseAuth=FirebaseAuth.instance;

  ///login
  Future<dynamic> loginUserWithEmailAndPassword({required String email,required String password}) async {
    try{
      User user = (await firebaseAuth.signInWithEmailAndPassword(email: email, password: password)).user!;
      if(user!=null){
        return true;
      }
    }
    on FirebaseAuthException catch(e){
      return e.message;
    }
  }



  ///register
 Future<dynamic> registerUserWithEmailAndPassword({required String fullName,required String email,required String password}) async {
   try{
     User user = (await firebaseAuth.createUserWithEmailAndPassword(email: email, password: password)).user!;
     if(user!=null){
       await DatabaseService(user.uid).savingUserData(fullName, email);
       return true;
     }
   }
   on FirebaseAuthException catch(e){
     return e.message;
   }
 }


 ///SignOut
 Future signOut()async{
   try{
     await HelperFunctions.saveUserLoggedInStatus(false);
     await HelperFunctions.saveUserLoggedInName('');
     await HelperFunctions.saveUserLoggedInEmail('');
     await firebaseAuth.signOut();
   }
   catch(e){
     return null;
   }
 }
}