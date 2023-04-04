// ignore_for_file: use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_chat/constants/constants.dart';
import 'package:firebase_chat/feature/pages/home_page.dart';
import 'package:firebase_chat/feature/pages/register_page.dart';
import 'package:firebase_chat/feature/widgets/custom_button.dart';
import 'package:firebase_chat/helper/helper_functions.dart';
import 'package:firebase_chat/service/auth_service.dart';
import 'package:firebase_chat/service/database_service.dart';
import 'package:firebase_chat/shared/shared_data.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../widgets/decorations.dart';
import '../widgets/snackBar.dart';

class LogInPage extends StatefulWidget {
  const LogInPage({Key? key}) : super(key: key);

  @override
  State<LogInPage> createState() => _LogInPageState();
}

class _LogInPageState extends State<LogInPage> {
  final formKey = GlobalKey<FormState>();
  String email='';
  String password='';
  bool isShow=true;
  bool isLoading = false;
  AuthService authService = AuthService();
  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      resizeToAvoidBottomInset: false,
      body: isLoading ? Center(child: CircularProgressIndicator(color: Theme.of(context).primaryColor,),) : Form(
        autovalidateMode: AutovalidateMode.always,
        key: formKey,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20,vertical: 60),
          child: Column(
            children:  [
              const Text('We Chat',style: TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.bold,
                color: Constants.black
              ),),
              const SizedBox(height: 30,),
              Image.asset('assets/conversation.png',width: 200,fit: BoxFit.fitWidth,),
              const SizedBox(height: 30,),
              TextFormField(
                validator: (val){
                  return HelperFunctions.emailValidate(val!)
                      ? null
                      : 'please enter a valid email';
                },
                onChanged: (value){
                  email=value;
                },
                cursorColor: Constants.primaryAppColor,
                decoration: textInputDecoration.copyWith(
                  labelText: "Email",
                  prefixIcon: Icon(Icons.email,color: Theme.of(context).primaryColor,)
                ),
              ),
              const SizedBox(height: 20,),
              TextFormField(
                validator: (val){
                  return HelperFunctions.passwordValidate(val!)
                      ? null
                      : 'please enter a valid password';
                },
                onChanged: (value){
                  password=value;
                },
                cursorColor: Constants.primaryAppColor,
                obscureText: isShow,
                decoration: textInputDecoration.copyWith(
                    labelText: "Password",
                    prefixIcon: Icon(Icons.lock,color: Theme.of(context).primaryColor,),
                    suffixIcon: InkWell(
                      onTap: (){
                        setState(() {
                          isShow=!isShow;
                        });
                      },
                        child: Icon(isShow ? Icons.visibility_off : Icons.visibility,color: Theme.of(context).primaryColor,)),
                ),
              ),
              const SizedBox(height: 50,),
              CustomButton(onPressed: (){
                login();
              }, title: 'Log In'),
              const SizedBox(height: 10,),
                Text.rich(TextSpan(
                text: "Don't have an account? ",
                style: const TextStyle(fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: Constants.black),
                children: [
                  TextSpan(
                    text: 'Register Here',
                    style: const TextStyle(fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Constants.black,decoration: TextDecoration.underline),
                    recognizer: TapGestureRecognizer()..onTap = (){
                      pushReplaceRoute(context,const RegisterPage());
                    }
                  )
                ]
              ))
            ],
          ),
        ),
      ),
    );
  }
  login()async{
    if (formKey.currentState!.validate()) {
      setState(() {
        isLoading = true;
      });
      await authService.loginUserWithEmailAndPassword(
           email: email, password: password).then((value) async{
        if(value==true){

          List<QueryDocumentSnapshot<Object?>> snapshot = await DatabaseService(FirebaseAuth.instance.currentUser!.uid).gettingUserData(email);
          await HelperFunctions.saveUserLoggedInStatus(true);
          await HelperFunctions.saveUserLoggedInEmail(email.trim());
          await HelperFunctions.saveUserLoggedInName(snapshot[0]['fullName']);
          await HelperFunctions.saveUserLoggedInUid(FirebaseAuth.instance.currentUser!.uid);
          pushReplaceRoute(context,const HomePage());
        }
        else{
          setState(() {
            isLoading = false;
          });
          showSnackBar(context,'please enter correct credential for login',Colors.red);
        }
      });
    }
  }
}
