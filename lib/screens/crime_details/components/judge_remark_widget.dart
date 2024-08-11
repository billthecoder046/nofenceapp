// TODO Implement this library.


import 'package:flutter/material.dart';

class JudgeRemarkWidget extends StatelessWidget {
  final String remark;

  const JudgeRemarkWidget({Key? key, required this.remark}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Text(
        '- $remark',
        style: const TextStyle(fontSize: 16),
      ),
    );
  }
}