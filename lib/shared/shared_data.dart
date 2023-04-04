import 'package:flutter/material.dart';

void pushRoute(BuildContext context,dynamic page){
  Navigator.push(context, MaterialPageRoute(builder: (context)=>page));
}

void pop(BuildContext context){
  Navigator.pop(context);
}

void pushReplaceRoute(BuildContext context,dynamic page){
  Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>page));
}