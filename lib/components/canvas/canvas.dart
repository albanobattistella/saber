
import 'dart:async';

import 'package:flutter/material.dart';

import 'package:saber/components/canvas/_canvas_painter.dart';
import '_stroke.dart';

class Canvas extends StatefulWidget {
  const Canvas({Key? key}) : super(key: key);

  static const double canvasWidth = 1000;
  static const double canvasHeight = canvasWidth * 1.4;

  @override
  State<Canvas> createState() => _CanvasState();

}

class _CanvasState extends State<Canvas> {
  List<Stroke> strokes = [];
  List<Stroke> strokesRedoStack = [];
  Stroke? currentStroke;

  final TransformationController _transformationController = TransformationController();

  // used to prevent accidentally drawing when pinch zooming
  int _lastSeenPointerCount = 0;
  Timer? _lastSeenPointerCountTimer;
  int get lastSeenPointerCount => _lastSeenPointerCount;
  set lastSeenPointerCount(int value) {
    _lastSeenPointerCount = value;

    // reset after 1ms to keep track of the same gesture only
    _lastSeenPointerCountTimer?.cancel();
    _lastSeenPointerCountTimer = Timer(const Duration(milliseconds: 1), () {
      _lastSeenPointerCount = 0;
    });
  }

  undo() {
    if (strokes.isNotEmpty) {
      setState(() {
        strokesRedoStack.add(strokes.removeLast());
      });
    }
  }

  redo() {
    if (strokesRedoStack.isNotEmpty) {
      setState(() {
        strokes.add(strokesRedoStack.removeLast());
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return FittedBox(
      child: GestureDetector(
        onSecondaryTapUp: (TapUpDetails details) {
          undo();
        },
        onTertiaryTapUp: (TapUpDetails details) {
          redo();
        },
        child: InteractiveViewer(
          transformationController: _transformationController,
          panEnabled: false,

          onInteractionStart: (ScaleStartDetails details) {
            if (lastSeenPointerCount >= 2) { // was a zoom gesture, ignore
              lastSeenPointerCount = lastSeenPointerCount;
              return;
            } else if (details.pointerCount >= 2) { // is a zoom gesture, remove accidental stroke
              if (lastSeenPointerCount == 1) {
                strokes.removeLast();
              }
              _lastSeenPointerCount = details.pointerCount;
              return;
            } else { // is a stroke
              _lastSeenPointerCount = details.pointerCount;
            }

            currentStroke = Stroke(
              color: Colors.black,
              strokeWidth: 2,
            )..addPoint(_transformationController.toScene(details.localFocalPoint));
          },
          onInteractionUpdate: (ScaleUpdateDetails details) {
            if (currentStroke == null) return;
            setState(() {
              currentStroke!.addPoint(_transformationController.toScene(details.localFocalPoint));
            });
          },
          onInteractionEnd: (ScaleEndDetails details) {
            if (currentStroke == null) return;
            setState(() {
              strokes.add(currentStroke!..isComplete = true);
              currentStroke = null;
            });
          },

          child: CustomPaint(
            foregroundPainter: CanvasPainter(
              strokes: strokes,
              currentStroke: currentStroke,
            ),
            isComplex: true,
            willChange: currentStroke != null,
            child: Container(
              width: Canvas.canvasWidth,
              height: Canvas.canvasHeight,
              color: const Color.fromRGBO(245, 245, 245, 1),
            ),
          ),
        ),
      ),
    );
  }
}
