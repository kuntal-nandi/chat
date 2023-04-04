import 'package:flutter/material.dart';

import '../../constants/constants.dart';

const textInputDecoration = InputDecoration(
  labelStyle: TextStyle(color: Constants.black),
  focusedBorder: OutlineInputBorder(
    borderSide: BorderSide(color: Constants.primaryAppColor,width: 2),
  ),
  enabledBorder:  OutlineInputBorder(
    borderSide: BorderSide(color: Constants.primaryAppColor,width: 2),
  ),
  border: OutlineInputBorder(
    borderSide: BorderSide(color: Constants.primaryAppColor,width: 2),
  ),
  errorBorder:  OutlineInputBorder(
    borderSide: BorderSide(color: Colors.red,width: 2),
  ),
);