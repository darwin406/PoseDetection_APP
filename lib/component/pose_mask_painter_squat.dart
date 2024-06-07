import 'dart:ui' as ui;

import 'package:flutter/widgets.dart';
import 'package:body_detection/models/pose.dart';
import 'package:body_detection/models/pose_landmark.dart';
import 'package:body_detection/models/pose_landmark_type.dart';
import 'dart:math';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:flutter/material.dart';

bool downPosition = false;
bool upPosition = true;
var reps_squat = 0;
double? result;

class PoseMaskPainterSquat extends CustomPainter {
  final FlutterTts flutterTts = FlutterTts();

  PoseMaskPainterSquat({
    required this.notifyParent,
    required this.pose,
    required this.imageSize,
  }) {
    flutterTts.setLanguage('en');
    flutterTts.setSpeechRate(0.4);
  }

  final Function() notifyParent;
  final Pose? pose;
  final Size imageSize;
  final pointPaint = Paint()..color = const Color.fromRGBO(255, 255, 255, 1);

  var linePaint = Paint()
    ..color = const Color.fromRGBO(255, 255, 255, 1)
    ..strokeWidth = 3;

  var paintRed = Paint()
    ..color = const Color.fromRGBO(255, 0, 0, 0.9)
    ..strokeWidth = 5; // 틀린 부분은 width를 넓게 해서 덮어씌우기

  var paintGreen = Paint()
    ..color = const Color.fromRGBO(0, 255, 0, 0.9)
    ..strokeWidth = 3;
  var maskPaint = Paint()
    ..colorFilter = const ColorFilter.mode(
        Color.fromRGBO(0, 0, 255, 0.5), BlendMode.srcOut);

  @override
  void paint(Canvas canvas, Size size) {
    _paintPose(canvas, size);
  }

  void _paintPose(Canvas canvas, Size size) {
    if (pose == null) return;

    final double hRatio =
        imageSize.width == 0 ? 1 : size.width / imageSize.width;
    final double vRatio =
        imageSize.height == 0 ? 1 : size.height / imageSize.height;

    offsetForPart(PoseLandmark part) =>
        Offset(part.position.x * hRatio, part.position.y * vRatio);

    var myList = [];
// calculate angles from three points
    final angleLandmarksByType = {
      for (final it in pose!.landmarks) it.type: it
    };

    for (final angle in angles) {
      final start = offsetForPart(angleLandmarksByType[angle[0]]!);
      final mid = offsetForPart(angleLandmarksByType[angle[1]]!);
      final end = offsetForPart(angleLandmarksByType[angle[2]]!);
      result = calculateAngle(start, mid, end);

      TextSpan span = TextSpan(
        text: result?.toStringAsFixed(2),
        style: const TextStyle(
          color: Color.fromARGB(255, 255, 0, 43),
          fontSize: 18,
        ),
      );
      TextPainter tp = TextPainter(text: span, textAlign: TextAlign.left);
      tp.textDirection = TextDirection.ltr;
      tp.layout();
      tp.paint(canvas, mid);

      myList.add(result);
      // print(hipAngles.toString());
    }

    Paint returnPaint(dynamic list) {
      if (isCorrectAngle1(list[0]) == false || (100<=list[1] && list[1]<=160)) {
        print('draw white');
        return linePaint;
      }
      print('draw green');
      return paintGreen;
    }

    // Landmark connections
    final landmarksByType = {for (final it in pose!.landmarks) it.type: it};
    for (final connection in connections) {
      final point1 = offsetForPart(landmarksByType[connection[0]]!);
      final point2 = offsetForPart(landmarksByType[connection[1]]!);
      canvas.drawLine(point1, point2, returnPaint(myList));
    }

    for (final part in pose!.landmarks) {
      canvas.drawCircle(offsetForPart(part), 5, pointPaint);
    }
    inDownPosition(myList);
    inUpPosition(myList);
  }

  @override
  bool shouldRepaint(PoseMaskPainterSquat oldDelegate) {
    return oldDelegate.pose != pose ||
        // oldDelegate.mask != mask ||
        oldDelegate.imageSize != imageSize;
  }

  List<List<PoseLandmarkType>> get angles => [
        [
          PoseLandmarkType.leftKnee,
          PoseLandmarkType.leftHeel,
          PoseLandmarkType.leftToe
        ],
        [
          PoseLandmarkType.leftAnkle,
          PoseLandmarkType.leftKnee,
          PoseLandmarkType.leftHip,
        ],
      ];

  List<List<PoseLandmarkType>> get connections => [
        [PoseLandmarkType.leftEar, PoseLandmarkType.leftEyeOuter],
        [PoseLandmarkType.leftEyeOuter, PoseLandmarkType.leftEye],
        [PoseLandmarkType.leftEye, PoseLandmarkType.leftEyeInner],
        [PoseLandmarkType.leftEyeInner, PoseLandmarkType.nose],
        [PoseLandmarkType.nose, PoseLandmarkType.rightEyeInner],
        [PoseLandmarkType.rightEyeInner, PoseLandmarkType.rightEye],
        [PoseLandmarkType.rightEye, PoseLandmarkType.rightEyeOuter],
        [PoseLandmarkType.rightEyeOuter, PoseLandmarkType.rightEar],
        [PoseLandmarkType.mouthLeft, PoseLandmarkType.mouthRight],
        [PoseLandmarkType.leftShoulder, PoseLandmarkType.rightShoulder],
        [PoseLandmarkType.leftShoulder, PoseLandmarkType.leftHip],
        [PoseLandmarkType.rightShoulder, PoseLandmarkType.rightHip],
        [PoseLandmarkType.rightShoulder, PoseLandmarkType.rightElbow],
        [PoseLandmarkType.rightWrist, PoseLandmarkType.rightElbow],
        [PoseLandmarkType.rightWrist, PoseLandmarkType.rightThumb],
        [PoseLandmarkType.rightWrist, PoseLandmarkType.rightIndexFinger],
        [PoseLandmarkType.rightWrist, PoseLandmarkType.rightPinkyFinger],
        [PoseLandmarkType.leftHip, PoseLandmarkType.rightHip],
        [PoseLandmarkType.leftHip, PoseLandmarkType.leftKnee],
        [PoseLandmarkType.rightHip, PoseLandmarkType.rightKnee],
        [PoseLandmarkType.rightKnee, PoseLandmarkType.rightAnkle],
        [PoseLandmarkType.leftKnee, PoseLandmarkType.leftAnkle],
        [PoseLandmarkType.leftElbow, PoseLandmarkType.leftShoulder],
        [PoseLandmarkType.leftWrist, PoseLandmarkType.leftElbow],
        [PoseLandmarkType.leftWrist, PoseLandmarkType.leftThumb],
        [PoseLandmarkType.leftWrist, PoseLandmarkType.leftIndexFinger],
        [PoseLandmarkType.leftWrist, PoseLandmarkType.leftPinkyFinger],
        [PoseLandmarkType.leftAnkle, PoseLandmarkType.leftHeel],
        [PoseLandmarkType.leftAnkle, PoseLandmarkType.leftToe],
        [PoseLandmarkType.rightAnkle, PoseLandmarkType.rightHeel],
        [PoseLandmarkType.rightAnkle, PoseLandmarkType.rightToe],
        [PoseLandmarkType.rightHeel, PoseLandmarkType.rightToe],
        [PoseLandmarkType.leftHeel, PoseLandmarkType.leftToe],
        [PoseLandmarkType.rightIndexFinger, PoseLandmarkType.rightPinkyFinger],
        [PoseLandmarkType.leftIndexFinger, PoseLandmarkType.leftPinkyFinger],
      ];

  void inDownPosition(list) {
    if (isCorrectAngle1(list[0]) == true && list[1] < 100) {
      downPosition = true;
      if (upPosition == true) {
        flutterTts.speak('Down');
        upPosition = false;
      }
    }
  }

  void inUpPosition(list) {
    if (isCorrectAngle1(list[0]) == true && list[1] > 160) {
      if (downPosition == true) {
        notifyParent();
        flutterTts.speak('Up');
        downPosition = false;
      }
      upPosition = true;
    }
  }

  bool isCorrectAngle1(_angle) {
    // 무릎이 발 앞으로 안나가게 만드는 각도
    return _angle > 70 ? true : false;
  }

  bool isCorrectAngle2(_angle) {
    // 스쿼트 하나를 하는걸 측정하는 무릎 각도
    return _angle < 100 ? true : false;
  }

  double? calculateAngle(Offset a, Offset b, Offset c) {
    var radians =
        atan2(c.dy - b.dy, c.dx - b.dx) - atan2(a.dy - b.dy, a.dx - b.dx);
    var angle = (radians * 180.0 / pi).abs();

    if (angle > 180.0) {
      angle = 360 - angle;
    }
    return angle;
  }
}
