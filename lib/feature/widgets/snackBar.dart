import 'package:firebase_chat/shared/shared_data.dart';
import 'package:flutter/material.dart';

void showSnackBar(BuildContext context, String message, Color color) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    content: Text(
      message,
      style: const TextStyle(fontSize: 14),
    ),
    backgroundColor: color,
    duration: const Duration(seconds: 2),
    action: SnackBarAction(label: 'OK', onPressed: () {
      pop(context);
    },
      textColor: Colors.white,
    ),
  ));
}
