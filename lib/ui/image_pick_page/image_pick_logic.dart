import 'dart:developer' as devtools show log;
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutterface/services/face_ml/face_detection/detection.dart';
import 'package:flutterface/services/face_ml/face_ml_service.dart';
import 'package:flutterface/utils/image_ml_util.dart';
import 'package:flutterface/utils/snackbar_message.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import 'image_pick_state.dart';

class ImagePickLogic extends GetxController {
  final state = ImagePickState();
  final ImagePicker picker = ImagePicker();

  Future<void> pickImage() async {
    cleanResult();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      state.imageOriginalData = await image.readAsBytes();
      final stopwatchImageDecoding = Stopwatch()..start();
      final decodedImage = await decodeImageFromList(state.imageOriginalData!);
      final imagePath = image.path;

      state.imageOriginal = Image.file(File(imagePath));
      stopwatchImageDecoding.stop();
      devtools.log('Image decoding took ${stopwatchImageDecoding.elapsedMilliseconds} ms');
      state.imageSize = Size(decodedImage.width.toDouble(), decodedImage.height.toDouble());
      update();
    } else {
      devtools.log('No image selected');
    }
  }

  Future<void> stockImage() async {
    cleanResult();
    final byteData = await rootBundle.load(state.stockImagePaths[state.stockImageCounter]);
    state.imageOriginalData = byteData.buffer.asUint8List();
    final decodedImage = await decodeImageFromList(state.imageOriginalData!);
    state.imageOriginal = Image.asset(state.stockImagePaths[state.stockImageCounter]);
    state.imageSize = Size(decodedImage.width.toDouble(), decodedImage.height.toDouble());
    state.stockImageCounter = (state.stockImageCounter + 1) % state.stockImagePaths.length;
    update();
  }

  void cleanResult() {
    state.isAnalyzed = false;
    state.faceDetectionResultsAbsolute = <FaceDetectionAbsolute>[];
    state.faceDetectionResultsRelative = <FaceDetectionRelative>[];
    state.isAligned = false;
    state.isFaceCropped = false;
    state.faceAlignedData1 = null;
    state.faceFocusCounter = 0;
    state.isEmbedded = false;
    state.embeddingStartIndex = 0;
    state.faceEmbeddingResult = [];
    update();
  }

  Future<void> detectFaces(BuildContext context) async {
    if (state.imageOriginalData == null) {
      showResponseSnackbar(context, 'Please select an image first');
      return;
    }
    if (state.isAnalyzed || state.isPredicting) {
      return;
    }

    state.isPredicting = true;
    update();

    state.faceDetectionResultsRelative = await FaceMlService.instance.detectFaces(state.imageOriginalData!);

    state.faceDetectionResultsAbsolute = relativeToAbsoluteDetections(
      relativeDetections: state.faceDetectionResultsRelative,
      imageWidth: state.imageSize.width.round(),
      imageHeight: state.imageSize.height.round(),
    );

    state.isPredicting = false;
    state.isAnalyzed = true;
    update();
  }

  Future<void> cropDetectedFace(BuildContext context) async {
    if (state.imageOriginalData == null) {
      showResponseSnackbar(context, 'Please select an image first');
      return;
    }
    if (!state.isAnalyzed) {
      showResponseSnackbar(context, 'Please detect faces first');
      return;
    }
    if (state.faceDetectionResultsAbsolute.isEmpty) {
      showResponseSnackbar(context, 'No face detected, nothing to crop');
      return;
    }
    if (state.faceDetectionResultsAbsolute.length == 1 && state.isAligned) {
      showResponseSnackbar(context, 'This is the only face found in the image');
      return;
    }

    final face = state.faceDetectionResultsAbsolute[state.faceFocusCounter];
    try {
      final facesList = await generateFaceThumbnails(state.imageOriginalData!, faceDetections: [face]);
      state.faceCroppedData = facesList[0];
    } catch (e) {
      devtools.log('Alignment of face failed: $e');
      return;
    }

    state.isFaceCropped = true;
    state.faceEmbeddingResult = [];
    state.embeddingStartIndex = 0;
    state.isEmbedded = false;
    state.faceCropped = Image.memory(state.faceCroppedData!);
    state.showingFaceCounter = state.faceFocusCounter;
    state.faceFocusCounter = (state.faceFocusCounter + 1) % state.faceDetectionResultsAbsolute.length;
    update();
  }

  Future<void> alignFaceCustomInterpolation(BuildContext context) async {
    if (state.imageOriginalData == null) {
      showResponseSnackbar(context, 'Please select an image first');
      return;
    }
    if (!state.isAnalyzed) {
      showResponseSnackbar(context, 'Please detect faces first');
      return;
    }
    if (state.faceDetectionResultsAbsolute.isEmpty) {
      showResponseSnackbar(context, 'No face detected, nothing to align');
      return;
    }
    if (state.faceDetectionResultsAbsolute.length == 1 && state.isAligned) {
      showResponseSnackbar(context, 'This is the only face found in the image');
      return;
    }

    final face = state.faceDetectionResultsAbsolute[state.faceFocusCounter];
    try {
      final bothFaces = await FaceMlService.instance.alignSingleFaceCustomInterpolation(state.imageOriginalData!, face);
      state.faceAlignedData1 = bothFaces[0];
      state.faceAlignedData2 = bothFaces[1];
    } catch (e) {
      devtools.log('Alignment of face failed: $e');
      return;
    }

    state.isAligned = true;
    state.faceEmbeddingResult = [];
    state.embeddingStartIndex = 0;
    state.isEmbedded = false;
    state.faceAligned1 = Image.memory(state.faceAlignedData1!);
    state.faceAligned2 = Image.memory(state.faceAlignedData2!);
    state.showingFaceCounter = state.faceFocusCounter;
    state.faceFocusCounter = (state.faceFocusCounter + 1) % state.faceDetectionResultsAbsolute.length;
    update();
  }

  Future<void> alignFaceCanvasInterpolation(BuildContext context) async {
    if (state.imageOriginalData == null) {
      showResponseSnackbar(context, 'Please select an image first');
      return;
    }
    if (!state.isAnalyzed) {
      showResponseSnackbar(context, 'Please detect faces first');
      return;
    }
    if (state.faceDetectionResultsAbsolute.isEmpty) {
      showResponseSnackbar(context, 'No face detected, nothing to align');
      return;
    }
    if (state.faceDetectionResultsAbsolute.length == 1 && state.isAligned) {
      showResponseSnackbar(context, 'This is the only face found in the image');
      return;
    }

    final face = state.faceDetectionResultsAbsolute[state.faceFocusCounter];
    try {
      state.faceAlignedData1 =
          await FaceMlService.instance.alignSingleFaceCanvasInterpolation(state.imageOriginalData!, face);
    } catch (e) {
      devtools.log('Alignment of face failed: $e');
      return;
    }

    state.isAligned = true;
    state.faceEmbeddingResult = [];
    state.embeddingStartIndex = 0;
    state.isEmbedded = false;
    state.faceAligned1 = Image.memory(state.faceAlignedData1!);
    state.showingFaceCounter = state.faceFocusCounter;
    state.faceFocusCounter = (state.faceFocusCounter + 1) % state.faceDetectionResultsAbsolute.length;
    update();
  }

  Future<void> embedFace(BuildContext context) async {
    // if (state.isAligned == false) {
    //   showResponseSnackbar(context, 'Please align face first');
    //   return;
    // }

    state.isPredicting = true;
    update();

    final (faceEmbeddingResultLocal, isBlurLocal, blurValueLocal) = await FaceMlService.instance.embedSingleFace(
      state.imageOriginalData!,
      state.faceDetectionResultsRelative[state.showingFaceCounter],
    );
    state.faceEmbeddingResult = faceEmbeddingResultLocal;
    state.blurValue = blurValueLocal;
    devtools.log('Blur detected: $isBlurLocal, blur value: $blurValueLocal');
    // devtools.log('Embedding: $faceEmbeddingResult');

    state.isPredicting = false;
    state.isEmbedded = true;
    update();
  }

  void nextEmbedding() {
    state.embeddingStartIndex = (state.embeddingStartIndex + 2) % state.faceEmbeddingResult.length;
    update();
  }

  void prevEmbedding() {
    state.embeddingStartIndex = (state.embeddingStartIndex - 2) % state.faceEmbeddingResult.length;
    update();
  }
}
