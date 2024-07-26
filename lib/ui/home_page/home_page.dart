import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutterface/services/face_ml/face_ml_service.dart';
import 'package:flutterface/ui/home_page/home_logic.dart';
import 'package:flutterface/ui/home_page/home_state.dart';
import 'package:flutterface/ui/image_pick_page/image_pick_view.dart';
import 'package:get/get.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _State();
}

class _State extends State<HomePage> {
  late final HomeLogic logic;
  late final HomeState state;

  @override
  void initState() {
    logic = Get.put(HomeLogic());
    state = Get.find<HomeLogic>().state;
    super.initState();
    unawaited(FaceMlService.instance.init());
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder(
      assignId: true,
      init: logic,
      builder: (controller) {
        return Scaffold(
          appBar: AppBar(
            backgroundColor: Theme.of(context).colorScheme.surface,
            title: Text(
              'FlutterFaceDemo',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            centerTitle: true,
          ),
          body: ListView(
            children: [
              const ImagePickView(tag: '1'),
              const SizedBox(height: 32),
              const ImagePickView(tag: '2'),
              const SizedBox(height: 16),
              state.similarity == null ? const SizedBox.shrink() : buildSimilarity(),
              buildCompareButton(context),
              const SizedBox(height: 16),
              buildGoCameraDetectButton(),
            ],
          ),
        );
      },
    );
  }

  Widget buildCompareButton(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: () => unawaited(logic.compare(context)),
      icon: const Icon(Icons.account_box),
      label: const Text('比较'),
    );
  }

  Widget buildSimilarity() {
    return Text('${state.similarity!}');
  }

  Widget buildGoCameraDetectButton() {
    return ElevatedButton.icon(
      onPressed: () => logic.goRealtimeDetect(),
      icon: const Icon(Icons.account_box),
      label: const Text('摄像头检测人脸'),
    );
  }
}
