import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutterface/app_routes.dart';
import 'package:flutterface/ui/home_page/home_state.dart';
import 'package:flutterface/ui/image_pick_page/image_pick_logic.dart';
import 'package:flutterface/ui/vector_helper.dart';
import 'package:get/get.dart';

class HomeLogic extends GetxController {
  final state = HomeState();

  @override
  Future<void> onInit() async {
    super.onInit();
  }

  Future<void> compare(BuildContext context) async {
    final logic1 = Get.find<ImagePickLogic>(tag: '1');
    final logic2 = Get.find<ImagePickLogic>(tag: '2');

    if (logic1.state.faceDetectionResultsRelative.isEmpty) {
      await logic1.detectFaces(context);
    }
    if (logic1.state.faceEmbeddingResult.isEmpty) {
      if (!context.mounted) return;
      await logic1.embedFace(context);
    }

    if (logic2.state.faceDetectionResultsRelative.isEmpty) {
      if (!context.mounted) return;
      await logic2.detectFaces(context);
    }

    if (logic2.state.faceEmbeddingResult.isEmpty) {
      if (!context.mounted) return;
      await logic2.embedFace(context);
    }

    state.similarity = VectorHelper.cosineSimilarity(
      logic1.state.faceEmbeddingResult,
      logic2.state.faceEmbeddingResult,
    );
    update();
    if (kDebugMode) {
      print('similarity: ${state.similarity}');
    }
  }

  void goRealtimeDetect() {
    unawaited(Get.toNamed(AppRoutes.realtime));
  }
}
