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
double? result;

class PoseMaskPainterLunge extends CustomPainter {
  final FlutterTts flutterTts = FlutterTts();

  PoseMaskPainterLunge({
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
  /*var leftPointPaint = Paint()..color = const Color.fromRGBO(255, 0, 0, 1);*/
  final rightPointPaint = Paint()
    ..color = const Color.fromRGBO(255, 0, 0, 1);
  var linePaint = Paint()
    ..color = const Color.fromRGBO(255, 255, 255, 1)
    ..strokeWidth = 3;

  var paintGreen = Paint()
    ..color = const Color.fromRGBO(0, 255, 0, 0.9)
    ..strokeWidth = 3;

  var paintRed = Paint()
    ..color = const Color.fromRGBO(255, 0, 0, 0.9)
    ..strokeWidth = 5; // 틀린 부분은 width를 넓게 해서 덮어씌우기

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
      if (( (list[0] > 170 ) && (list[1] > 170) ) || ((list[0] > 70 && list[0] < 110) && (list[1] > 70 && list[1] < 110))) {
        print('draw green');
        return paintGreen;
      }
      print('draw white');
      return linePaint;
    }
    // Landmark connections
    final landmarksByType = {for (final it in pose!.landmarks) it.type: it};
    for (final connection in connections) {
      final point1 = offsetForPart(landmarksByType[connection[0]]!);
      final point2 = offsetForPart(landmarksByType[connection[1]]!);
      canvas.drawLine(point1, point2, returnPaint(myList));
    }

    for (final part in pose!.landmarks) {
      // Landmark points
      canvas.drawCircle(offsetForPart(part), 5, pointPaint);
    }
    inUpPosition(myList);
    inDownPosition(myList);
  }

  @override
  bool shouldRepaint(PoseMaskPainterLunge oldDelegate) {
    return oldDelegate.pose != pose ||
        oldDelegate.imageSize != imageSize;
  }

  List<List<PoseLandmarkType>> get angles => [
    [
      PoseLandmarkType.leftHip,
      PoseLandmarkType.leftKnee,
      PoseLandmarkType.leftAnkle,
      // 왼쪽 무릎 각도
    ],
    [
      PoseLandmarkType.rightHip,
      PoseLandmarkType.rightKnee,
      PoseLandmarkType.rightAnkle
      // 오른쪽 무릎 각도
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
  ]; // 골격 포인트 끼리 연결한 선

  void inUpPosition(list) {
    if ((list[0] > 170 ) && (list[1] > 170) ) {
      if(downPosition==true){
        notifyParent();
        flutterTts.speak('Up');
        downPosition=false;
      }
      upPosition = true;

    }
  }

  void inDownPosition(list) {
    if ((list[0] > 70 && list[0] < 110) && (list[1] > 70 && list[1] < 110)) {
      downPosition = true;
      if(upPosition==true) {
        flutterTts.speak('down');
        upPosition=false;
      }
    }
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