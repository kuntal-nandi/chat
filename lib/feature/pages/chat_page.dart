// ignore_for_file: use_build_context_synchronously

import 'package:firebase_chat/feature/widgets/message_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import '../../helper/helper_functions.dart';
import '../../service/database_service.dart';
import '../../service/storage_service.dart';

class ChatPage extends StatefulWidget {
  const ChatPage(
      {Key? key,
      required this.chatName,
      required this.otherId,
      required this.yourId})
      : super(key: key);
  final String chatName;
  final String otherId;
  final String yourId;

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  bool isChatReady = false;
  bool isOnlineStatus = false;
  Stream? chats;
  Stream? online;
  String userChatId = '';
  String messageValue = '';
  TextEditingController messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    getOnlineStatus();
    chatMaking();
    super.initState();
  }

  createChatWithThisUser({required String otherId}) async {
    DatabaseService(widget.yourId)
        .createChatWithUser(
            chatId: HelperFunctions.createChatId(widget.yourId, otherId))
        .whenComplete(() async {
      userChatId = HelperFunctions.createChatId(widget.yourId, otherId);
      DatabaseService(widget.yourId).getAllChats(userChatId).then((value) {
        setState(() {
          chats = value;
        });
      }).then((value) {
        setState(() {
          isChatReady = true;
        });
      });
    });
  }

  void chatMaking() async {
    String chatId = HelperFunctions.createChatId(widget.yourId, widget.otherId);
    bool chatAvailable =
        await DatabaseService(widget.yourId).isChatAvailable(chatId);
    if (chatAvailable == true) {
      getUserChats();
    } else {
      createChatWithThisUser(otherId: widget.otherId);
    }
  }

  getOnlineStatus()async{
    await DatabaseService(widget.otherId).getUserDetails().then((value) {
      setState(() {
        online = value;
      });
    }).then((value) {
      setState(() {
        isOnlineStatus=true;
      });
    });
  }

  getUserChats() async {
    String chatId = HelperFunctions.createChatId(widget.yourId, widget.otherId);
    await DatabaseService(widget.yourId).getUserChatId(chatId).then((cId) {
      DatabaseService(widget.yourId).getAllChats(cId).then((value) {
        setState(() {
          chats = value;
        });
      }).then((value) async {
        userChatId = await DatabaseService(widget.yourId).getUserChatId(chatId);
        setState(() {
          isChatReady = true;
        });
      });
    });
  }

  sendMessageData(String message,int type) async {
    if (userChatId != '') {
      await DatabaseService(widget.yourId).sendMessage(
          chatId: userChatId,
          messageData: {
            'message': message,
            'messageType': type,
            'sendBy': widget.yourId,
            'time': DateTime.now().toString()
          });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        backgroundColor: Theme.of(context).primaryColor,
        title: Row(
          children: [
            const Icon(
              Icons.account_circle,
              size: 40,
              color: Colors.white,
            ),
            const SizedBox(
              width: 10,
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.chatName,
                    maxLines: 1,
                    overflow: TextOverflow.fade,
                  ),
                  isOnlineStatus
                      ? StreamBuilder(
                          stream: online,
                          builder: (context, AsyncSnapshot snapshot) {
                            return snapshot.hasData ? Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                snapshot.data.docs[0]['isTyping'] == true ? Text('Typing...',
                                  style: TextStyle(
                                      fontSize: 12, color: Colors.grey.shade500),
                                ) : Text(
                                  snapshot.data.docs[0]['isOnline'] == true ? 'Online' : 'Offline',
                                  style: TextStyle(
                                      fontSize: 12, color: Colors.grey.shade400),
                                ),
                                const SizedBox(
                                  width: 3,
                                ),
                                snapshot.data.docs[0]['isTyping'] == true ? Container():Container(
                                  height: 8,
                                  width: 8,
                                  decoration:  BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: snapshot.data.docs[0]['isOnline'] == true ?  Colors.green : Colors.grey[400]),
                                )
                              ],
                            ) : Container();
                          })
                      : const SizedBox(
                          height: 10,
                          width: 10,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                ],
              ),
            ),
          ],
        ),
      ),
      body: isChatReady == false
          ? Center(
              child: CircularProgressIndicator(
                color: Theme.of(context).primaryColor,
              ),
            )
          : Stack(
              children: [
                chatMessages(),
                Container(
                  alignment: Alignment.bottomCenter,
                  width: MediaQuery.of(context).size.width,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 15),
                    width: MediaQuery.of(context).size.width,
                    color: Colors.grey[700],
                    child: Row(
                      children: [
                        Expanded(
                            child: TextFormField(
                              onChanged: (value){
                                messageValue=value;
                                DatabaseService(widget.yourId).updateTypingStatus(true);
                                Future.delayed(const Duration(seconds: 3)).then((val) {
                                  if(messageValue==value){
                                    DatabaseService(widget.yourId).updateTypingStatus(false);
                                  }
                                });
                              },
                              onTapOutside: (p){
                                SystemChannels.textInput.invokeMethod('TextInput.hide');
                                DatabaseService(widget.yourId).updateTypingStatus(false);
                              },
                          controller: messageController,
                          style: const TextStyle(color: Colors.white),
                          decoration: const InputDecoration(
                              hintText: 'Send a Message...',
                              hintStyle:
                                  TextStyle(color: Colors.white, fontSize: 16),
                              border: InputBorder.none),
                        )),
                        InkWell(
                          onTap: () async {
                            if (messageController.text.isNotEmpty) {
                              sendMessageData(messageController.text,0);
                              _scrollDown();
                              messageController.clear();
                            }
                          },
                          child: Container(
                            height: 50,
                            width: 50,
                            decoration: BoxDecoration(
                              color: Theme.of(context).primaryColor,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(
                              Icons.send,
                              color: Colors.white,
                              size: 26,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8,),
                        InkWell(
                          onTap: () {
                              print(
                                  'select files......');
                              HelperFunctions
                                  .pickImage()
                                  .then((value) {
                                if (value.isNotEmpty) {
                                  setState(() {
                                    isChatReady = false;
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
                                      setState(() {
                                        isChatReady =
                                        true;
                                      });
                                      sendMessageData(url,1);

                                            // _scrollDown();
                                            // ScaffoldMessenger.of(
                                            //     context)
                                            //     .showSnackBar(const SnackBar(
                                            //     content:
                                            //     Text(('Picture Uploaded Successfully'))));

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
                            },
                          child: Container(
                            height: 50,
                            width: 50,
                            decoration: BoxDecoration(
                              color: Colors.deepPurple.shade300,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(
                              Icons.image,
                              color: Colors.white,
                              size: 26,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              ],
            ),
    );
  }

  chatMessages() {
    return StreamBuilder(
        stream: chats,
        builder: (context, AsyncSnapshot snapshot) {
          return snapshot.hasData
              ? ListView.builder(
                  controller: _scrollController,
                  padding:const EdgeInsets.only(bottom: 80),
                  itemCount: snapshot.data.docs.length,
                  itemBuilder: (BuildContext context, int index) {
                    return Column(
                      children: [
                        index == 0
                            ? Container(
                                width: double.infinity,
                                alignment: Alignment.center,
                                child: Card(
                                    elevation: 5,
                                    color: Colors.blueGrey.shade100,
                                    shadowColor: Theme.of(context).primaryColor,
                                    child: Padding(
                                      padding: const EdgeInsets.all(4.0),
                                      child: Text(
                                        getDate(snapshot
                                            .data.docs[index]['time']
                                            .toString()),
                                        style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w700),
                                      ),
                                    )),
                              )
                            : getDate(snapshot.data.docs[index]['time']
                                        .toString()) !=
                                    getDate(snapshot
                                        .data.docs[index - 1]['time']
                                        .toString())
                                ? Container(
                                    width: double.infinity,
                                    alignment: Alignment.center,
                                    child: Card(
                                        elevation: 5,
                                        color: Colors.blueGrey.shade100,
                                        shadowColor:
                                            Theme.of(context).primaryColor,
                                        child: Padding(
                                          padding: const EdgeInsets.all(4.0),
                                          child: Text(
                                            getDate(snapshot
                                                .data.docs[index]['time']
                                                .toString()),
                                            style: const TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w700),
                                          ),
                                        )),
                                  )
                                : Container(),
                        MessageTile(
                            type: snapshot.data.docs[index]['messageType'],
                            message: snapshot.data.docs[index]['message'],
                            time: DateFormat('hh:mm a')
                                .format(DateTime.parse(
                                    snapshot.data.docs[index]['time']))
                                .toString(),
                            isSendByMe: widget.yourId ==
                                    snapshot.data.docs[index]['sendBy']
                                ? true
                                : false),
                      ],
                    );
                  })
              : const Center(
                  child: CircularProgressIndicator(
                    color: Colors.grey,
                  ),
                );
        });
  }

  String getDate(String time) {
    return time.split(' ').first;
  }

  void _scrollDown() {
    _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
  }
}
