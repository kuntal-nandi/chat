import 'package:firebase_chat/feature/pages/image_view.dart';
import 'package:firebase_chat/shared/shared_data.dart';
import 'package:flutter/material.dart';

import '../../constants/constants.dart';

class MessageTile extends StatefulWidget {
  const MessageTile(
      {Key? key,
      required this.message,
      required this.time,
      required this.isSendByMe, required this.type})
      : super(key: key);
  final String message;
  final String time;
  final bool isSendByMe;
  final int type;

  @override
  State<MessageTile> createState() => _MessageTileState();
}

class _MessageTileState extends State<MessageTile> {
  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: widget.isSendByMe ? Alignment.topRight : Alignment.topLeft,
      child: Container(
          margin: const EdgeInsets.symmetric(vertical: 10,horizontal: 20),
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            borderRadius: widget.isSendByMe
                ? const BorderRadius.only(
                    bottomLeft: Radius.circular(12),
                    bottomRight: Radius.circular(0),
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12))
                : const BorderRadius.only(
                    bottomLeft: Radius.circular(0),
                    bottomRight: Radius.circular(12),
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12)),
            color: widget.isSendByMe
                ? Colors.deepPurpleAccent.shade100.withOpacity(0.5)
                : Colors.grey.shade300,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              widget.type == 1 ? GestureDetector(
                  onTap: (){
                    pushRoute(context, ImageViewPage(url: widget.message));
                  },
                  child: Image.network(widget.message,height: 150,width: 150,fit: BoxFit.cover,)): Text(
                widget.message,
                style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Constants.black),
              ),
              const SizedBox(height: 4,),
              Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(widget.time,style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w400
                  ),),
                  const SizedBox(width: 5,),
                  widget.isSendByMe ? const Icon((Icons.done_all),color: Colors.grey,size: 16,) : Container()
                ],
              )
            ],
          )),
    );
  }
}
