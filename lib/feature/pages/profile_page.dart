// ignore_for_file: use_build_context_synchronously

import 'package:firebase_chat/feature/pages/home_page.dart';
import 'package:firebase_chat/feature/widgets/custom_button.dart';
import 'package:firebase_chat/service/auth_service.dart';
import 'package:flutter/material.dart';

import '../../constants/constants.dart';
import '../../helper/helper_functions.dart';
import '../../service/database_service.dart';
import '../../service/storage_service.dart';
import '../../shared/shared_data.dart';
import '../widgets/decorations.dart';
import 'login_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({
    Key? key,
  }) : super(key: key);
  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  AuthService authService = AuthService();
  String email = '';
  String fullName = '';
  bool isLoadingUpdate = false;
  bool isEditEnable = false;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final formKey = GlobalKey<FormState>();
  Stream? profileData;
  @override
  void initState() {
    getUserProfile();
    gettingUserData();
    super.initState();
  }

  gettingUserData() async {
    await HelperFunctions.getUserLoggedName().then((value) {
      setState(() {
        fullName = value;
      });
    });
    await HelperFunctions.getUserLoggedInEmail().then((value) {
      setState(() {
        email = value;
      });
    });
    _emailController.text = email;
    _nameController.text = fullName;
  }

  getUserProfile() async {
    setState(() {
      isLoadingUpdate = true;
    });
    await DatabaseService(await HelperFunctions.getUserLoggedInUid())
        .getUserDetails()
        .then((value) {
      setState(() {
        profileData = value;
      });
    }).then((value) {
      setState(() {
        isLoadingUpdate = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          backgroundColor: Theme.of(context).primaryColor,
          centerTitle: true,
          title: const Text('Your Profile'),
          actions: [
            GestureDetector(
              onTap: () {
                setState(() {
                  isEditEnable = !isEditEnable;
                  _emailController.text = email;
                  _nameController.text = fullName;
                });
              },
              child: Container(
                padding: const EdgeInsets.all(4),
                margin: const EdgeInsets.only(right: 20),
                decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isEditEnable
                        ? Colors.deepPurple.shade100
                        : Colors.grey.shade400),
                child: Icon(
                  isEditEnable ? Icons.edit : Icons.remove_red_eye,
                  size: 30,
                  color:
                      isEditEnable ? Colors.deepPurple.shade900 : Colors.black,
                ),
              ),
            ),
          ],
        ),
        drawer: Drawer(
          child: ListView(
            padding: const EdgeInsets.symmetric(vertical: 50),
            children: [
              Icon(
                Icons.account_circle,
                size: 150,
                color: Colors.grey[700],
              ),
              const SizedBox(
                height: 15,
              ),
              Text(
                fullName.toUpperCase(),
                textAlign: TextAlign.center,
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(
                height: 10,
              ),
              Text(
                email,
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: Colors.grey[800]),
              ),
              const SizedBox(
                height: 30,
              ),
              const Divider(
                thickness: 2,
              ),
              ListTile(
                onTap: () {
                  pushReplaceRoute(context, const HomePage());
                },
                selectedColor: Colors.deepOrange,
                selected: false,
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 5, horizontal: 20),
                leading: const Icon(Icons.chat_outlined),
                title: const Text(
                  'Chats',
                  style: TextStyle(
                      color: Colors.black, fontWeight: FontWeight.w700),
                ),
              ),
              ListTile(
                onTap: () {
                  pop(context);
                },
                selectedColor: Colors.deepOrange,
                selected: true,
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 5, horizontal: 20),
                leading: const Icon(Icons.person_pin_rounded),
                title: const Text(
                  'Profile',
                  style: TextStyle(
                      color: Colors.black, fontWeight: FontWeight.w700),
                ),
              ),
              ListTile(
                onTap: () async {
                  showDialog(
                      barrierDismissible: false,
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title: const Text('Logout'),
                          content: const Text(
                              'Are you sure you really want to logout?'),
                          actions: [
                            IconButton(
                                onPressed: () {
                                  pop(context);
                                },
                                icon: const Icon(
                                  Icons.cancel_rounded,
                                  color: Colors.red,
                                )),
                            IconButton(
                                onPressed: () async {
                                  await authService.signOut();
                                  pushReplaceRoute(context, const LogInPage());
                                },
                                icon: const Icon(
                                  Icons.done,
                                  color: Colors.green,
                                )),
                          ],
                        );
                      });
                },
                selectedColor: Colors.deepOrange,
                selected: false,
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 5, horizontal: 20),
                leading: const Icon(Icons.exit_to_app),
                title: const Text(
                  'Log Out',
                  style: TextStyle(
                      color: Colors.black, fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
        ),
        body: Center(
          child: isLoadingUpdate
              ? CircularProgressIndicator(
                  color: Theme.of(context).primaryColor,
                )
              : Form(
                  key: formKey,
                  autovalidateMode: AutovalidateMode.always,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      StreamBuilder(
                          stream: profileData,
                          builder: (context, AsyncSnapshot snapshot) {
                            return snapshot.hasData
                                ? Container(
                                    child: snapshot.data.docs[0]
                                                ['profilePic'] ==
                                            ''
                                        ? InkWell(
                                            onTap: isEditEnable
                                                ? () {
                                                    print('select files......');
                                                    HelperFunctions.pickImage()
                                                        .then((value) {
                                                      if (value.isNotEmpty) {
                                                        setState(() {
                                                          isLoadingUpdate =
                                                              true;
                                                        });
                                                        StorageService()
                                                            .uploadFile(
                                                                value[0],
                                                                value[1])
                                                            .then((e) async {
                                                          print(
                                                              '~~~~~~~~~~~~~~~Done');
                                                          String url =
                                                              await StorageService()
                                                                  .getImageUrl(
                                                                      value[1]);
                                                          if (url.isNotEmpty) {
                                                            DatabaseService(
                                                                    await HelperFunctions
                                                                        .getUserLoggedInUid())
                                                                .uploadProfilePic(
                                                                    url: url)
                                                                .then((value) {
                                                              setState(() {
                                                                isLoadingUpdate =
                                                                    false;
                                                              });
                                                              ScaffoldMessenger
                                                                      .of(
                                                                          context)
                                                                  .showSnackBar(
                                                                      const SnackBar(
                                                                          content:
                                                                              Text(('Picture Uploaded Successfully'))));
                                                            });
                                                          } else {
                                                            ScaffoldMessenger
                                                                    .of(context)
                                                                .showSnackBar(
                                                                    const SnackBar(
                                                                        content:
                                                                            Text(('Not able to upload'))));
                                                          }
                                                        });
                                                      } else {
                                                        ScaffoldMessenger.of(
                                                                context)
                                                            .showSnackBar(
                                                                const SnackBar(
                                                                    content: Text(
                                                                        ('No Image Selected'))));
                                                      }
                                                    });
                                                  }
                                                : null,
                                            child: Icon(
                                              Icons.account_circle,
                                              size: 250,
                                              color: isEditEnable
                                                  ? Colors.deepPurple.shade200
                                                  : Colors.grey,
                                            ),
                                          )
                                        : Padding(
                                            padding:
                                                const EdgeInsets.only(top: 15),
                                            child: InkWell(
                                              onTap: isEditEnable
                                                  ? () {
                                                      print(
                                                          'select files......');
                                                      HelperFunctions
                                                              .pickImage()
                                                          .then((value) {
                                                        if (value.isNotEmpty) {
                                                          setState(() {
                                                            isLoadingUpdate =
                                                                true;
                                                          });
                                                          StorageService()
                                                              .uploadFile(
                                                                  value[0],
                                                                  value[1])
                                                              .then((e) async {
                                                            print(
                                                                '~~~~~~~~~~~~~~~Done');
                                                            String url =
                                                                await StorageService()
                                                                    .getImageUrl(
                                                                        value[
                                                                            1]);
                                                            if (url
                                                                .isNotEmpty) {
                                                              DatabaseService(
                                                                      await HelperFunctions
                                                                          .getUserLoggedInUid())
                                                                  .uploadProfilePic(
                                                                      url: url)
                                                                  .then(
                                                                      (value) {
                                                                setState(() {
                                                                  isLoadingUpdate =
                                                                      false;
                                                                });
                                                                ScaffoldMessenger.of(
                                                                        context)
                                                                    .showSnackBar(const SnackBar(
                                                                        content:
                                                                            Text(('Picture Uploaded Successfully'))));
                                                              });
                                                            } else {
                                                              ScaffoldMessenger
                                                                      .of(
                                                                          context)
                                                                  .showSnackBar(
                                                                      const SnackBar(
                                                                          content:
                                                                              Text(('Not able to upload'))));
                                                            }
                                                          });
                                                        } else {
                                                          ScaffoldMessenger.of(
                                                                  context)
                                                              .showSnackBar(
                                                                  const SnackBar(
                                                                      content: Text(
                                                                          ('No Image Selected'))));
                                                        }
                                                      });
                                                    }
                                                  : null,
                                              child: Container(
                                                height: 200,
                                                width: 200,
                                                clipBehavior: Clip.antiAlias,
                                                alignment: Alignment.center,
                                                decoration: BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  image: DecorationImage(
                                                      image: NetworkImage(
                                                        snapshot.data.docs[0]
                                                            ['profilePic'],
                                                      ),
                                                      fit: BoxFit.cover),
                                                ),
                                              ),
                                            ),
                                          ),
                                  )
                                : Container();
                          }),
                      isEditEnable
                          ? Padding(
                              padding:
                                  const EdgeInsets.only(left: 20, right: 20),
                              child: Column(children: [
                                const SizedBox(
                                  height: 20,
                                ),
                                TextFormField(
                                  controller: _nameController,
                                  validator: (val) {
                                    return val!.length > 4
                                        ? null
                                        : 'please enter your full name';
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
                                  controller: _emailController,
                                  validator: (val) {
                                    return HelperFunctions.emailValidate(val!)
                                        ? null
                                        : 'please enter a valid email';
                                  },
                                  cursorColor: Constants.primaryAppColor,
                                  decoration: textInputDecoration.copyWith(
                                      labelText: "Email",
                                      prefixIcon: Icon(
                                        Icons.email,
                                        color: Theme.of(context).primaryColor,
                                      )),
                                ),
                              ]),
                            )
                          : Column(
                              children: [
                                const SizedBox(
                                  height: 15,
                                ),
                                Text(
                                  'Name: ${fullName.toUpperCase()}',
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                Text(
                                  'Email: $email',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w400,
                                      color: Colors.grey[800]),
                                ),
                              ],
                            ),
                      const SizedBox(
                        height: 30,
                      ),
                      const Spacer(),
                      isEditEnable
                          ? Padding(
                              padding: const EdgeInsets.only(
                                  left: 20, right: 20, bottom: 40),
                              child: CustomButton(
                                  onPressed: () async {
                                    if (formKey.currentState!.validate()) {
                                      setState(() {
                                        isLoadingUpdate = true;
                                      });
                                      DatabaseService(await HelperFunctions
                                              .getUserLoggedInUid())
                                          .updateUserDetails(
                                              email:
                                                  _emailController.text.trim(),
                                              name: _nameController.text.trim())
                                          .whenComplete(() {
                                        HelperFunctions.saveUserLoggedInName(
                                            _nameController.text.trim());
                                        HelperFunctions.saveUserLoggedInEmail(
                                            _emailController.text.trim());
                                        pushReplaceRoute(
                                            context, const ProfilePage());
                                      });
                                    }
                                  },
                                  title: 'update'),
                            )
                          : Container()
                    ],
                  ),
                ),
        ));
  }
}
