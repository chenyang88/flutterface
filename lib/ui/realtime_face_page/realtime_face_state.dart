import 'dart:io';
import 'dart:typed_data';

import 'package:face_camera/face_camera.dart';
import 'package:flutter/material.dart';

enum Recognize { initial, detecting, focusing, success, failed }

class RealtimeFaceState {
  double? similarity;
  Uint8List? imageOriginalData;
  Image? imageOriginal;
  Size imageSize = const Size(0, 0);

  List<double> originalEmbedding = [];

  File? capturedImage;
  FaceCameraController? controller;

  GlobalKey globalKey = GlobalKey();
}
