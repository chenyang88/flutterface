import 'dart:typed_data' show Uint8List;

import 'package:flutter/material.dart';
import 'package:flutterface/services/face_ml/face_detection/detection.dart';

class ImagePickState {
  Image? imageOriginal;
  Image? faceAligned1;
  Image? faceAligned2;

  Image? faceCropped;
  Uint8List? imageOriginalData;

  Uint8List? faceAlignedData1;
  Uint8List? faceAlignedData2;

  Uint8List? faceCroppedData;
  Size imageSize = const Size(0, 0);

  late Size imageDisplaySize;
  int stockImageCounter = 0;
  int faceFocusCounter = 0;
  int showingFaceCounter = 0;
  int embeddingStartIndex = 0;

  final List<String> stockImagePaths = [
    'assets/images/stock_images/one_person.jpeg',
    'assets/images/stock_images/one_person2.jpeg',
    'assets/images/stock_images/one_person3.jpeg',
    'assets/images/stock_images/one_person4.jpeg',
    'assets/images/stock_images/group_of_people.jpeg',
  ];

  bool isAnalyzed = false;
  bool isBlazeFaceLoaded = false;
  bool isFaceNetLoaded = false;
  bool isPredicting = false;
  bool isAligned = false;
  bool isFaceCropped = false;
  bool isEmbedded = false;
  List<FaceDetectionRelative> faceDetectionResultsRelative = [];
  List<FaceDetectionAbsolute> faceDetectionResultsAbsolute = [];

  List<double> faceEmbeddingResult = <double>[];
  double blurValue = 0;
}
