import 'dart:io';
import 'dart:typed_data';

import 'package:flutterface/services/face_ml/face_detection/detection.dart';
import 'package:flutterface/services/face_ml/face_ml_service.dart';
import 'package:flutterface/ui/vector_helper.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

class FaceHelper {
  static Future<List<Face>> detectFacesWithML(File file) async {
    final options = FaceDetectorOptions();
    final faceDetector = FaceDetector(options: options);
    final List<Face> faces = await faceDetector.processImage(InputImage.fromFile(file));
    await faceDetector.close();
    return faces;
  }

  static Future<List<FaceDetectionRelative>> detectFaces(Uint8List imageOriginalData) async {
    final List<FaceDetectionRelative> faceDetectionRelatives =
        await FaceMlService.instance.detectFaces(imageOriginalData);
    return faceDetectionRelatives;
  }

  static Future<List<double>> embedFace(Uint8List imageOriginalData, FaceDetectionRelative face) async {
    final (embedding, _, _) = await FaceMlService.instance.embedSingleFace(imageOriginalData, face);
    return embedding;
  }

  static Future<double> cosineSimilarity(List<double> embedding1, List<double> embedding2) async {
    final double similarity = VectorHelper.cosineSimilarity(embedding1, embedding2);
    return similarity;
  }
}
