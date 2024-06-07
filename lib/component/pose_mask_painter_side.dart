import 'dart:ui' as ui;

import 'package:flutter/widgets.dart';
import 'package:body_detection/models/pose.dart';
import 'package:body_detection/models/pose_landmark.dart';
import 'package:body_detection/models/pose_landmark_type.dart';
import 'dart:math';
import 'package:flutter_tts/flutter_tts.dart';

bool downPosition = false;
bool upPosition = true;
bool isCorrectPose = true;

class PoseMaskPainterSide extends CustomPainter {
  final FlutterTts flutterTts = FlutterTts();

  PoseMaskPainterSide({
    required this.pose,
    required this.imageSize,
    required this.cameraStart,
    required this.cameraStop,
  }) {
    flutterTts.setLanguage('en');
    flutterTts.setSpeechRate(0.4);
  }

  final Pose? pose;
  final Size imageSize;
  final Function() cameraStart;
  final Function() cameraStop;
  final pointPaint = Paint()..color = const Color.fromRGBO(255, 255, 255, 1);
  final leftPointPaint = Paint()..color = const Color.fromRGBO(223, 157, 80, 1);
  final rightPointPaint = Paint()
    ..color = const Color.fromRGBO(100, 208, 218, 1);
  final linePaint = Paint()
    ..color = const Color.fromRGBO(255, 255, 255, 0.9)
    ..strokeWidth = 3;
  final wrongPaint = Paint()
    ..color = const Color.fromRGBO(255, 0, 0, 0.9)
    ..strokeWidth = 5;
  final maskPaint = Paint()
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
      final leftShoulder = offsetForPart(angleLandmarksByType[angle[0]]!);
      final leftElbow = offsetForPart(angleLandmarksByType[angle[1]]!);
      final leftWrist = offsetForPart(angleLandmarksByType[angle[2]]!);
      var hipAngles =
          (atan2((leftWrist.dy - leftElbow.dy), (leftWrist.dx - leftElbow.dx)) -
              atan2((leftShoulder.dy - leftElbow.dy),
                  (leftShoulder.dx - leftElbow.dx)))
              .abs() *
              (180 / pi);
      if (hipAngles > 180) {
        hipAngles = 360 - hipAngles;
      }

      TextSpan span = TextSpan(
        text: hipAngles.toStringAsFixed(2),
        style: const TextStyle(
          color: Color.fromARGB(255, 255, 0, 43),
          fontSize: 18,
        ),
      );
      TextPainter tp = TextPainter(text: span, textAlign: TextAlign.left);
      tp.textDirection = TextDirection.ltr;
      tp.layout();
      tp.paint(canvas, leftElbow);

      myList.add(hipAngles);
      // print(hipAngles.toString());
    }

    // Landmark connections
    final landmarksByType = {for (final it in pose!.landmarks) it.type: it};
    for (final connection in connections) {
      final point1 = offsetForPart(landmarksByType[connection[0]]!);
      final point2 = offsetForPart(landmarksByType[connection[1]]!);
      canvas.drawLine(point1, point2, linePaint);
    }
    if (checkAngle(myList) == false) {
      for (final anglelist in anglelists) {
        final pointOne = offsetForPart(landmarksByType[anglelist[0]]!);
        final pointTwo = offsetForPart(landmarksByType[anglelist[1]]!);
        canvas.drawLine(pointOne, pointTwo, wrongPaint);
      }
    }

    for (final part in pose!.landmarks) {
      // Landmark points
      canvas.drawCircle(offsetForPart(part), 5, pointPaint);

    }

    checkAngle(myList);

  }

  @override
  bool shouldRepaint(PoseMaskPainterSide oldDelegate) {
    return oldDelegate.pose != pose ||
        oldDelegate.imageSize != imageSize;
  }

  List<List<PoseLandmarkType>> get angles => [
    [
      PoseLandmarkType.leftShoulder,
      PoseLandmarkType.leftHip,
      PoseLandmarkType.leftKnee,
      // 왼쪽 허리 각도
    ], //List[0]
    [
      PoseLandmarkType.rightShoulder,
      PoseLandmarkType.rightHip,
      PoseLandmarkType.rightKnee,
      //오른쪽 허리 각도
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

  List<List<PoseLandmarkType>> get anglelists => [
    [PoseLandmarkType.leftShoulder, PoseLandmarkType.leftHip],
    [PoseLandmarkType.rightShoulder, PoseLandmarkType.rightHip],
    [PoseLandmarkType.leftHip, PoseLandmarkType.leftKnee],
    [PoseLandmarkType.rightHip, PoseLandmarkType.rightKnee],
  ]; // 골격 포인트 끼리 연결한 선

  bool checkAngle(list) {
    if (list[0] > 160 && list[1] > 160) {
      cameraStart();
      isCorrectPose = true;
      return true;
    } else {
      cameraStop();
      if(isCorrectPose == true)
        {
          flutterTts.speak('correct your pose');
          isCorrectPose = false;
        }
      return false;
    }
  }
}