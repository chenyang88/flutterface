import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutterface/services/face_ml/face_ml_service.dart';
import 'package:flutterface/ui/image_pick_page/image_pick_logic.dart';
import 'package:flutterface/utils/face_detection_painter.dart';
import 'package:get/get.dart';

import 'image_pick_state.dart';

class ImagePickView extends StatefulWidget {
  const ImagePickView({super.key, required this.tag});

  final String tag;

  @override
  State<ImagePickView> createState() => _ImagePickViewState();
}

class _ImagePickViewState extends State<ImagePickView> {
  late final ImagePickLogic logic;
  late final ImagePickState state;

  @override
  void initState() {
    super.initState();
    unawaited(FaceMlService.instance.init());
    logic = Get.put(ImagePickLogic(), tag: widget.tag);
    state = Get.find<ImagePickLogic>(tag: widget.tag).state;
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder(
      global: false,
      assignId: true,
      init: logic,
      builder: (controller) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    buildImage(context),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    buildEmbeddingsIfNeeded(),
                    buildCleanIconIfNeeded(context),
                    buildAlignFacesIconIfNeeded(context),
                    buildEmbedFaceIconIfNeeded(context),
                  ],
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget buildCleanIconIfNeeded(BuildContext context) {
    return ElevatedButton.icon(
      icon: state.isAnalyzed ? const Icon(Icons.person_remove_outlined) : const Icon(Icons.people_alt_outlined),
      label: state.isAnalyzed ? const Text('Clean result') : const Text('Detect faces'),
      onPressed: state.isAnalyzed ? () => logic.cleanResult() : () => logic.detectFaces(context),
    );
  }

  Widget buildAlignFacesIconIfNeeded(BuildContext context) {
    return state.isAnalyzed
        ? ElevatedButton.icon(
            icon: const Icon(Icons.face_retouching_natural),
            label: const Text('Align faces'),
            onPressed: () => logic.alignFaceCustomInterpolation(context),
          )
        : const SizedBox.shrink();
  }

  Widget buildEmbedFaceIconIfNeeded(BuildContext context) {
    return (state.isAligned && !state.isEmbedded)
        ? ElevatedButton.icon(
            icon: const Icon(Icons.numbers_outlined),
            label: const Text('Embed face'),
            onPressed: () => logic.embedFace(context),
          )
        : const SizedBox.shrink();
  }

  Widget buildEmbeddingsIfNeeded() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        state.embeddingStartIndex > 0
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => logic.prevEmbedding(),
              )
            : const SizedBox(height: 0),
        state.isEmbedded
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Embedding: ${state.faceEmbeddingResult.length}'),
                  Text('${state.faceEmbeddingResult[state.embeddingStartIndex]}'),
                  if (state.embeddingStartIndex + 1 < state.faceEmbeddingResult.length)
                    Text('${state.faceEmbeddingResult[state.embeddingStartIndex + 1]}'),
                  Text('Blur: ${state.blurValue.round()}'),
                ],
              )
            : const SizedBox(height: 0),
        state.embeddingStartIndex + 2 < state.faceEmbeddingResult.length
            ? IconButton(
                icon: const Icon(Icons.arrow_forward),
                onPressed: () => logic.nextEmbedding(),
              )
            : const SizedBox(height: 0),
      ],
    );
  }

  Widget buildImage(BuildContext context) {
    state.imageDisplaySize = Size(
      (MediaQuery.of(context).size.width / 2) * 0.8,
      (MediaQuery.of(context).size.width / 2) * 0.8 * 1.5,
    );
    return Container(
      height: state.imageDisplaySize.height,
      width: state.imageDisplaySize.width,
      color: Colors.black,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          // Image container
          Center(
            child: state.imageOriginal != null
                ? state.isAligned
                    ? Center(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Column(
                              children: [
                                Image(
                                  image: state.faceAligned1!.image,
                                  width: state.imageDisplaySize.width / 2 - 10,
                                ),
                                const Text(
                                  'Bilinear',
                                  style: TextStyle(color: Colors.white),
                                ),
                              ],
                            ),
                            const SizedBox(width: 10),
                            Column(
                              children: [
                                Image(
                                  image: state.faceAligned2!.image,
                                  width: state.imageDisplaySize.width / 2 - 10,
                                ),
                                const Text(
                                  'Bicubic',
                                  style: TextStyle(color: Colors.white),
                                ),
                              ],
                            ),
                          ],
                        ),
                      )
                    : Stack(
                        children: [
                          state.imageOriginal!,
                          if (state.isAnalyzed)
                            CustomPaint(
                              painter: FacePainter(
                                faceDetections: state.faceDetectionResultsAbsolute,
                                imageSize: state.imageSize,
                                availableSize: state.imageDisplaySize,
                              ),
                            ),
                        ],
                      )
                : const Text(
                    'No image selected',
                    style: TextStyle(color: Colors.white),
                  ),
          ),
          Padding(
            padding: const EdgeInsets.all(2.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: () => logic.pickImage(),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(30, 30),
                    backgroundColor: Colors.grey[200], // Button color
                    foregroundColor: Colors.black,
                    elevation: 1,
                  ),
                  child: const Text(
                    'Gallery',
                    style: TextStyle(color: Colors.black, fontSize: 10),
                  ),
                ),
                ElevatedButton(
                  onPressed: () => logic.stockImage(),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(30, 30),
                    backgroundColor: Colors.grey[200], // Button color
                    foregroundColor: Colors.black,
                    elevation: 1, // Elevation (shadow)
                  ),
                  child: const Text(
                    'Stock',
                    style: TextStyle(color: Colors.black, fontSize: 10),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
