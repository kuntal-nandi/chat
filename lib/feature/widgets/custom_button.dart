import 'package:flutter/material.dart';

import '../../constants/constants.dart';

class CustomButton extends StatelessWidget {
  const CustomButton(
      {Key? key,
      required this.onPressed,
      required this.title,
      this.buttonWidth})
      : super(key: key);
  final void Function() onPressed;
  final String title;
  final double? buttonWidth;
  @override
  Widget build(BuildContext context) {
    return SizedBox(
        width: buttonWidth ?? double.infinity,
        child: ElevatedButton(
           style: ElevatedButton.styleFrom(
             backgroundColor: Theme.of(context).primaryColor,
             elevation: 0,
             shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30))
           ),
            onPressed: onPressed,
            child: Text(
              title,
              style: const TextStyle(fontSize: 16, color: Constants.white),
            )));
  }
}
