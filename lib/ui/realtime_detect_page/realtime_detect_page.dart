import 'dart:async';

import 'package:face_camera/face_camera.dart';
import 'package:flutter/material.dart';
import 'package:flutterface/ui/realtime_detect_page/realtime_detect_logic.dart';
import 'package:flutterface/ui/realtime_detect_page/realtime_detect_state.dart';
import 'package:get/get.dart';

class RealtimeDetectPage extends StatefulWidget {
  const RealtimeDetectPage({super.key});

  @override
  State<RealtimeDetectPage> createState() => _State();
}

class _State extends State<RealtimeDetectPage> {
  late final RealtimeDetectLogic logic;
  late final RealtimeDetectState state;

  @override
  void initState() {
    super.initState();
    logic = Get.put(RealtimeDetectLogic());
    state = Get.find<RealtimeDetectLogic>().state;
  }

  @override
  Widget build(BuildContext context) {
    logic.context = context;
    return GetBuilder(
      global: false,
      assignId: true,
      init: logic,
      builder: (controller) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('FaceCamera example app'),
            actions: [
              state.imageOriginal == null ? const SizedBox.shrink() : state.imageOriginal!,
              ElevatedButton(
                onPressed: () async {
                  if (state.imageOriginal == null) {
                    await logic.pickImage();
                  } else {
                    await logic.startImageStream();
                  }
                },
                child: Text(
                  state.imageOriginal == null ? '选择待比对照片' : '开启摄像头',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
          body: Builder(
            builder: (context) {
              if (state.capturedImage != null) {
                return Center(
                  child: Stack(
                    alignment: Alignment.bottomCenter,
                    children: [
                      Image.file(
                        state.capturedImage!,
                        width: double.maxFinite,
                        fit: BoxFit.fitWidth,
                      ),
                      ElevatedButton(
                        onPressed: () async {
                          await logic.startImageStream();
                        },
                        child: const Text(
                          '再来一次',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                        ),
                      ),
                    ],
                  ),
                );
              }
              if (state.controller == null) {
                return const Center(
                  child: Text('请先选择一张照片后，再开启摄像头'),
                );
              }
              return SmartFaceCamera(
                controller: state.controller!,
                messageBuilder: (context, face) {
                  if (face == null) {
                    return _message('Place your face in the camera');
                  }
                  if (!face.wellPositioned) {
                    return _message('Center your face in the square');
                  }
                  return _message('请保持不动 3 秒');
                },
              );
            },
          ),
        );
      },
    );
  }

  Widget _message(String msg) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 55, vertical: 15),
        child: Text(
          msg,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            height: 1.5,
            fontWeight: FontWeight.w400,
          ),
        ),
      );

  @override
  void dispose() {
    unawaited(state.controller?.dispose());
    super.dispose();
  }
}
