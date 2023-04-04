// ignore_for_file: use_build_context_synchronously, unnecessary_null_comparison

import 'package:firebase_chat/feature/pages/chat_page.dart';
import 'package:firebase_chat/feature/pages/login_page.dart';
import 'package:firebase_chat/feature/pages/profile_page.dart';
import 'package:firebase_chat/service/auth_service.dart';
import 'package:firebase_chat/shared/shared_data.dart';
import 'package:flutter/material.dart';
import '../../helper/helper_functions.dart';
import '../../service/database_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with WidgetsBindingObserver{
  AuthService authService = AuthService();
  String name = '';
  String email = '';
  String uId = '';
  Stream? allUsers;
  bool isLoading=true;
  @override
  void initState() {
    updateOnline();
    WidgetsBinding.instance.addObserver(this);
    gettingUserData();
    getAllUsers();
    super.initState();
  }

  updateOnline()async{
    DatabaseService(await HelperFunctions.getUserLoggedInUid()).updateUserStatus(true);
  }

  @override
  Future<void> didChangeAppLifecycleState(AppLifecycleState state) async {

    switch (state) { // ignore: missing_enum_constant_in_switch
      case AppLifecycleState.paused:
        DatabaseService(await HelperFunctions.getUserLoggedInUid()).updateUserStatus(false);
        break;
      case AppLifecycleState.resumed:
        DatabaseService(await HelperFunctions.getUserLoggedInUid()).updateUserStatus(true);
        break;
      case AppLifecycleState.detached:
        DatabaseService(await HelperFunctions.getUserLoggedInUid()).updateUserStatus(false);
        break;
      case AppLifecycleState.inactive:
        DatabaseService(await HelperFunctions.getUserLoggedInUid()).updateUserStatus(false);
        break;
    }
  }

  getAllUsers() async {
    DatabaseService(await HelperFunctions.getUserLoggedInUid())
        .getAllUsers()
        .then((value) {
      setState(() {
        allUsers = value;
      });
    });
  }

  gettingUserData() async {
    await HelperFunctions.getUserLoggedName().then((value) {
      setState(() {
        name = value;
      });
    });
    await HelperFunctions.getUserLoggedInEmail().then((value) {
      setState(() {
        email = value;
      });
    });
    await HelperFunctions.getUserLoggedInUid().then((value) {
      setState(() {
        uId = value;
      });
    }).then((value) {
      setState(() {
        isLoading=false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        centerTitle: true,
        title: const Text('Your Chats'),
      ),
      drawer: Drawer(
        child: isLoading ? const CircularProgressIndicator() : ListView(
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
              name.toUpperCase(),
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
              height: 10,
            ),
            Text(
              uId,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  color: Colors.grey),
            ),
            const SizedBox(
              height: 30,
            ),
            const Divider(
              thickness: 2,
            ),
            ListTile(
              onTap: () {
                pop(context);
              },
              selectedColor: Colors.deepOrange,
              selected: true,
              contentPadding:
                  const EdgeInsets.symmetric(vertical: 5, horizontal: 20),
              leading: const Icon(Icons.chat_outlined),
              title: const Text(
                'Chats',
                style:
                    TextStyle(color: Colors.black, fontWeight: FontWeight.w700),
              ),
            ),
            ListTile(
              onTap: () {
                pushReplaceRoute(context, const ProfilePage());
              },
              selectedColor: Colors.deepOrange,
              selected: false,
              contentPadding:
                  const EdgeInsets.symmetric(vertical: 5, horizontal: 20),
              leading: const Icon(Icons.person_pin_rounded),
              title: const Text(
                'Profile',
                style:
                    TextStyle(color: Colors.black, fontWeight: FontWeight.w700),
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
                style:
                    TextStyle(color: Colors.black, fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
      ),
      body: allUsersList(),
    );
  }

  allUsersList() {
    return StreamBuilder(
        stream: allUsers,
        builder: (context, AsyncSnapshot snapshot) {
          if (snapshot.hasData) {
            if (snapshot.data != null) {
              return ListView.builder(
                  itemCount: snapshot.data.docs.length,
                  itemBuilder: (context, int index) {
                    return snapshot.data.docs[index]['fullName'] == name &&
                            snapshot.data.docs[index]['email'] == email
                        ? Container()
                        : Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: InkWell(
                              onTap: () {
                                pushRoute(context,  ChatPage(chatName: snapshot.data.docs[index]['fullName'],otherId: snapshot.data.docs[index]['userId'], yourId: uId,));
                              },
                              child: Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                      width: 2,
                                      color: Theme.of(context).primaryColor),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Container(
                                      height: 50,
                                      width: 50,
                                      alignment: Alignment.center,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Colors.deepPurpleAccent.shade100,
                                      ),
                                      child: Text(
                                        snapshot.data.docs[index]['fullName']
                                            .toString()[0]
                                            .toUpperCase(),
                                        style: const TextStyle(
                                            fontSize: 24,
                                            fontWeight: FontWeight.w700),
                                      ),
                                    ),
                                    const SizedBox(
                                      width: 20,
                                    ),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            snapshot.data.docs[index]['fullName']
                                                .toString(),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                                fontSize: 20,
                                                fontWeight: FontWeight.w700),
                                          ),
                                          const SizedBox(
                                            height: 2,
                                          ),
                                          Text(
                                            snapshot.data.docs[index]['email'],
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w400,
                                                color: Colors.grey.shade600),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                        );
                  });
            } else {
              return const Text('No users to Chat');
            }
          } else {
            return Center(
              child: CircularProgressIndicator(
                color: Theme.of(context).primaryColor,
              ),
            );
          }
        });
  }
}
