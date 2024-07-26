import 'package:flutter/material.dart';

ElevatedButton myFirstButton({required Widget text, required onPressed,Color? buttonColor, }) {
  return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: buttonColor!=null? buttonColor:Colors.red, // Change background color to red
      ),
      onPressed: onPressed,
      child: text);
}
Container myFirstButton2({required Widget text, required onPressed}) {
  return  Container(
    padding: EdgeInsets.only(left: 20,right: 20),
    width: double.infinity,
    child: ElevatedButton(
      onPressed: onPressed,
      child: text,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.red, // Change background color to red
      ),
    ),
  );
}
