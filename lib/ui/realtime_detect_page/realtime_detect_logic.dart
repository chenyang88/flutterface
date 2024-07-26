import 'dart:async';
import 'dart:developer' as devtools show log;
import 'dart:io';

import 'package:face_camera/face_camera.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutterface/services/face_ml/face_detection/detection.dart';
import 'package:flutterface/ui/face_helper.dart';
import 'package:flutterface/ui/realtime_detect_page/realtime_detect_state.dart';
import 'package:flutterface/utils/snackbar_message.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class RealtimeDetectLogic extends GetxController {
  final state = RealtimeDetectState();
  final ImagePicker picker = ImagePicker();
  BuildContext? context;

  Future<void> startImageStream() async {
    state.capturedImage = null;
    update();
    state.controller = FaceCameraController(
      autoCapture: true,
      defaultCameraLens: CameraLens.front,
      onCapture: (File? image) {
        unawaited(captured(image));
      },
      onFaceDetected: (Face? face) {
        print('检查到了人脸=========================');
      },
    );
    await state.controller?.initialize();
    await state.controller?.startImageStream();
  }

  Future<void> captured(File? image) async {
    state.capturedImage = image;
    await state.controller?.stopImageStream();
    await state.controller?.dispose();
    update();

    final int startTime = DateTime.now().millisecondsSinceEpoch;
    final Uint8List imageOriginalData = state.capturedImage!.readAsBytesSync();
    final List<FaceDetectionRelative> faces = await FaceHelper.detectFaces(imageOriginalData);
    final List<double> embedding = await FaceHelper.embedFace(imageOriginalData, faces[0]);
    state.similarity = await FaceHelper.cosineSimilarity(state.originalEmbedding, embedding);
    final int endTime = DateTime.now().millisecondsSinceEpoch;
    if (kDebugMode) {
      print('Detection took ${endTime - startTime} Similarity: ${state.similarity}');
    }
    if (state.similarity! >= 0.5) {
      if (!context!.mounted) return;
      showSnackbar(context!, '人脸比对成功!!!');
    } else {
      if (!context!.mounted) return;
      showSnackbar(context!, '人脸比对失败!!!');
    }
  }

  Future<void> pickImage() async {
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      state.imageOriginalData = await image.readAsBytes();

      final List<FaceDetectionRelative> faces = await FaceHelper.detectFaces(state.imageOriginalData!);
      if (faces.isEmpty) {
        if (!context!.mounted) return;
        showSnackbar(context!, '请选择一张人像的照片');
        return;
      }

      if (faces.length > 1) {
        if (!context!.mounted) return;
        showSnackbar(context!, '您选择的照片包含了多张人像');
        return;
      }

      state.originalEmbedding = await FaceHelper.embedFace(state.imageOriginalData!, faces[0]);
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
}
