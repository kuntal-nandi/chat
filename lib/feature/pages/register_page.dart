// ignore_for_file: use_build_context_synchronously

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_chat/feature/pages/home_page.dart';
import 'package:firebase_chat/feature/pages/login_page.dart';
import 'package:firebase_chat/service/auth_service.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../../constants/constants.dart';
import '../../helper/helper_functions.dart';
import '../../shared/shared_data.dart';
import '../widgets/custom_button.dart';
import '../widgets/decorations.dart';
import '../widgets/snackBar.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({Key? key}) : super(key: key);

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  bool isLoading = false;
  final formKey = GlobalKey<FormState>();
  String name = '';
  String email = '';
  String password = '';
  bool isShow = true;
  AuthService authService = AuthService();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: isLoading
          ? Center(
            child: CircularProgressIndicator(
                color: Theme.of(context).primaryColor,
              ),
          )
          : Form(
              autovalidateMode: AutovalidateMode.always,
              key: formKey,
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 60),
                child: Column(
                  children: [
                    const Text(
                      'Register Here',
                      style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                          color: Constants.primaryAppColor),
                    ),
                    const SizedBox(
                      height: 30,
                    ),
                    Image.asset(
                      'assets/membership.png',
                      height: 150,
                      fit: BoxFit.fitHeight,
                    ),
                    const SizedBox(
                      height: 30,
                    ),
                    TextFormField(
                      validator: (val) {
                        return val!.length > 4
                            ? null
                            : 'please enter your full name';
                      },
                      onChanged: (value) {
                        name = value;
                      },
                      cursorColor: Constants.primaryAppColor,
                      decoration: textInputDecoration.copyWith(
                          labelText: "Name",
                          prefixIcon: Icon(
                            Icons.person,
                            color: Theme.of(context).primaryColor,
                          )),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    TextFormField(
                      validator: (val) {
                        return HelperFunctions.emailValidate(val!)
                            ? null
                            : 'please enter a valid email';
                      },
                      onChanged: (value) {
                        email = value;
                      },
                      cursorColor: Constants.primaryAppColor,
                      decoration: textInputDecoration.copyWith(
                          labelText: "Email",
                          prefixIcon: Icon(
                            Icons.email,
                            color: Theme.of(context).primaryColor,
                          )),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    TextFormField(
                      validator: (val) {
                        return HelperFunctions.passwordValidate(val!)
                            ? null
                            : 'please enter a valid password';
                      },
                      onChanged: (value) {
                        password = value;
                      },
                      cursorColor: Constants.primaryAppColor,
                      obscureText: isShow,
                      decoration: textInputDecoration.copyWith(
                        labelText: "Password",
                        prefixIcon: Icon(
                          Icons.lock,
                          color: Theme.of(context).primaryColor,
                        ),
                        suffixIcon: InkWell(
                            onTap: () {
                              setState(() {
                                isShow = !isShow;
                              });
                            },
                            child: Icon(
                              isShow ? Icons.visibility_off : Icons.visibility,
                              color: Theme.of(context).primaryColor,
                            )),
                      ),
                    ),
                    const SizedBox(
                      height: 50,
                    ),
                    CustomButton(onPressed: () {
                      register();
                    }, title: 'Register'),
                    const SizedBox(
                      height: 10,
                    ),
                    Text.rich(TextSpan(
                        text: "Already have an account? ",
                        style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color: Constants.black),
                        children: [
                          TextSpan(
                              text: 'LogIn Here',
                              style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: Constants.black,
                                  decoration: TextDecoration.underline),
                              recognizer: TapGestureRecognizer()
                                ..onTap = () {
                                  pushReplaceRoute(context, const LogInPage());
                                })
                        ]))
                  ],
                ),
              ),
            ),
    );
  }

  register() async {
    if (formKey.currentState!.validate()) {
      setState(() {
        isLoading = true;
      });
      await authService.registerUserWithEmailAndPassword(
          fullName: name.trim(), email: email.trim(), password: password).then((value) async{
            if(value==true){
              await HelperFunctions.saveUserLoggedInStatus(true);
              await HelperFunctions.saveUserLoggedInEmail(email.trim());
              await HelperFunctions.saveUserLoggedInName(name.trim());
              await HelperFunctions.saveUserLoggedInUid(FirebaseAuth.instance.currentUser!.uid);
              pushReplaceRoute(context,const HomePage());
            }
            else{
              setState(() {
                isLoading = false;
              });
              showSnackBar(context,value.toString(),Colors.red);
            }
      });
    }
  }
}
