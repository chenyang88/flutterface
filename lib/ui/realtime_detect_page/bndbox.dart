import 'dart:math' as math;

import 'package:flutter/material.dart';

class BndBox extends StatelessWidget {
  final double? left;
  final double? top;
  final double? width;
  final double? height;
  final String? indicateText;

  const BndBox({this.left, this.top, this.width, this.height, this.indicateText, super.key});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: math.max(0, left ?? 0),
      top: math.max(0, top ?? 0),
      width: width ?? 0,
      height: height ?? 0,
      child: Container(
        padding: const EdgeInsets.only(top: 5.0, left: 5.0),
        decoration: BoxDecoration(
          border: Border.all(
            color: const Color.fromRGBO(37, 213, 253, 1.0),
            width: 3.0,
          ),
        ),
        child: Text(
          indicateText ?? 'ok',
          style: const TextStyle(
            color: Color.fromRGBO(37, 213, 253, 1.0),
            fontSize: 14.0,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
