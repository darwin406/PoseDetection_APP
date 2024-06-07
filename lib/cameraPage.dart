import 'package:flutter/material.dart';
import 'dart:ui' as ui;

import 'package:body_detection/models/pose.dart';
import 'package:body_detection/models/image_result.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ugrp/resultPage.dart';
import '../component/pose_mask_painter_lunge.dart';
import '../component/pose_mask_painter_side.dart';
import '../component/pose_mask_painter_squat.dart';

import 'package:permission_handler/permission_handler.dart';
import 'package:body_detection/body_detection.dart';
import 'component/stringlist.dart';
import 'package:flutter_displaymode/flutter_displaymode.dart';

class CameraPage extends StatefulWidget {
  final int targetset;
  final int targetnumber;
  final int index;

  const CameraPage(
      {Key? key,
      required this.targetset,
      required this.targetnumber,
      required this.index})
      : super(key: key);

  @override
  State<CameraPage> createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  bool _isDetectingPose = false;
  Stopwatch stopwatch = new Stopwatch()..stop();
  Pose? _detectedPose;
  Image? _cameraImage;
  Size _imageSize = Size.zero;
  int mykcal = 0;
  int curnum = 0;
  int curset = 0;
  int mytime = 0;
  bool isFinished = false;

  void stopwatchStart() => stopwatch.start();

  void stopwatchStop() => stopwatch.stop();

  void _incrementCounter() => curnum++;

  String setNumber(int i){
    if(widget.targetnumber == -1){
      return i==1? '${(stopwatch.elapsedMilliseconds / 1000).floor()} 초' : '${curnum} 회';
    } else if(i == 1){
      return '${(stopwatch.elapsedMilliseconds / 1000).floor() % widget.targetnumber} / ${widget.targetnumber} 초';
    } else{
      return '${curnum % widget.targetnumber} / ${widget.targetnumber} 회';
    }
  }

  Future<void> _startCameraStream() async {
    final request = await Permission.camera.request();
    if (request.isGranted) {
      await BodyDetection.startCameraStream(
        onFrameAvailable: _handleCameraImage,
        onPoseAvailable: (pose) {
          if (!_isDetectingPose) return;
          _handlePose(pose);
        },
      );
    }
  }

  void _handleCameraImage(ImageResult result) {
    if (!mounted) return;

    // To avoid a memory leak issue.
    // https://github.com/flutter/flutter/issues/60160
    PaintingBinding.instance.imageCache.clear();
    PaintingBinding.instance.imageCache.clearLiveImages();

    final image = Image.memory(
      result.bytes,
      gaplessPlayback: true,
      fit: BoxFit.contain,
    );

    setState(() {
      _cameraImage = image;
      _imageSize = result.size;
    });
  }

  void _handlePose(Pose? pose) {
    // Ignore if navigated out of the page.
    if (!mounted) return;

    setState(() {
      _detectedPose = pose;
    });
  }

  Future<void> _toggleDetectPose() async {
    if (_isDetectingPose) {
      await BodyDetection.disablePoseDetection();
    } else {
      await BodyDetection.enablePoseDetection();
      //Text(reps.toString());
    }

    setState(() {
      _isDetectingPose = !_isDetectingPose;
      _detectedPose = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    _startCameraStream();

    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: [SystemUiOverlay.bottom]);
    if (((stopwatch.elapsedMilliseconds / 1000).floor() >=
                widget.targetnumber * widget.targetset ||
            curnum >= widget.targetnumber * widget.targetset) &&
        widget.targetnumber * widget.targetset >= 0 &&
        isFinished == false) {
      return AlertDialog(
          content: SizedBox(
              width: 200.w,
              height: 100.h,
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text('그만하시겠습니까?', style: TextStyle(fontSize: 20.sp)),
                    SizedBox(height: 25.h),
                    Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          ElevatedButton(
                              onPressed: (() {
                                setState(() {
                                  isFinished = true;
                                });
                              }),
                              child: const Text('이어하기',
                                  style: TextStyle(
                                    color: Colors.white,
                                  )),
                              style: ButtonStyle(
                                  backgroundColor:
                                      MaterialStateProperty.all<Color>(
                                          Colors.white12),
                                  foregroundColor:
                                      MaterialStateProperty.all<Color>(
                                          Colors.black))),
                          SizedBox(width: 25.w),
                          ElevatedButton(
                            onPressed: (() {
                              Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => ResultPage(
                                          kcal: widget.index == 0
                                              ? curnum ~/ 4
                                              : widget.index == 1
                                                  ? (stopwatch.elapsedMilliseconds /
                                                          1000) ~/
                                                      10
                                                  : curnum ~/ 4,
                                          index: widget.index,
                                          number: widget.index == 1
                                              ? (stopwatch.elapsedMilliseconds /
                                                      1000)
                                                  .floor()
                                              : curnum)));
                            }),
                            child: const Text('그만하기',
                                style: TextStyle(
                                  color: Colors.white,
                                )),
                          )
                        ])
                  ])));
    }

    return Scaffold(
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: [
              SizedBox(
                height: 30.h,
                child: Row(
                  children: [
                    SizedBox(width: 20.w),
                    SizedBox(
                        width: 200.w,
                        child: Text(exerciseName[widget.index],
                            style: TextStyle(fontSize: 20.sp))),
                    SizedBox(width: 70.w),
                    SizedBox(
                        width: 100.w,
                        child: Text(widget.targetnumber == -1
                            ? ''
                            : widget.index == 1
                                ? '${(stopwatch.elapsedMilliseconds / 1000).floor() ~/ widget.targetnumber} / ${widget.targetset}세트'
                                : '${curnum ~/ widget.targetnumber} / ${widget.targetset} 세트', style: TextStyle(fontSize: 20.sp)))
                  ],
                ),
              ),
              SizedBox(
                  height: 60.h,
                  child: Text(setNumber(widget.index),
                      style: TextStyle(fontSize: 30.sp))),
              ClipRect(
                child: CustomPaint(
                  child: Stack(children: <Widget>[
                    Container(child: _cameraImage),
                  ]),
                  foregroundPainter: widget.index == 0
                      ? PoseMaskPainterLunge(
                          notifyParent: _incrementCounter,
                          pose: _detectedPose,
                          imageSize: _imageSize,
                        )
                      : widget.index == 1
                          ? PoseMaskPainterSide(
                              pose: _detectedPose,
                              imageSize: _imageSize,
                              cameraStart: stopwatchStart,
                              cameraStop: stopwatchStop,
                            )
                          : PoseMaskPainterSquat(
                              notifyParent: _incrementCounter,
                              pose: _detectedPose,
                              imageSize: _imageSize,
                            ),
                ),
              ),
              SizedBox(
                  height: 150.h,
                  width: 350.w,
                  child: Row(children: [
                    SizedBox(
                        height: 150.h,
                        width: 100.w,
                        child: Column(children: [
                          SizedBox(height: 80.h),
                          SizedBox(
                            height: 50.h,
                            child: IconButton(
                              onPressed: _toggleDetectPose,
                              icon: _isDetectingPose
                                  ? ImageIcon(AssetImage('assets/s_off.png'))
                                  : ImageIcon(AssetImage('assets/s_on.png')),
                            ),
                          )
                        ])),
                    SizedBox(
                        height: 150.h,
                        width: 150.w,
                        child: Column(children: [
                          SizedBox(height: 10.h),
                          SizedBox(
                              height: 100.h,
                              child: Text(
                                  widget.index == 1
                                      ? '${(stopwatch.elapsedMilliseconds / 1000).floor() ~/ 10}'
                                      : '${curnum ~/ 4}',
                                  style: TextStyle(fontSize: 60.sp))),
                          SizedBox(
                              height: 40.h,
                              child: Text('kcal',
                                  style: TextStyle(fontSize: 20.sp)))
                        ])),
                    SizedBox(
                        height: 150.h,
                        width: 100.w,
                        child: Column(children: [
                          SizedBox(height: 80.h),
                          SizedBox(
                              height: 50.h,
                              child: IconButton(
                                  icon: const Icon(Icons.exit_to_app_sharp),
                                  onPressed: (() {
                                    showDialog(
                                        context: context,
                                        barrierDismissible: true,
                                        builder: (BuildContext ctx) {
                                          return AlertDialog(
                                              content: SizedBox(
                                                  width: 200.w,
                                                  height: 100.h,
                                                  child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .center,
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      children: <Widget>[
                                                        Text('그만하시겠습니까?',
                                                            style: TextStyle(
                                                                fontSize:
                                                                    20.sp)),
                                                        SizedBox(height: 25.h),
                                                        Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .center,
                                                            children: <Widget>[
                                                              ElevatedButton(
                                                                  onPressed:
                                                                      (() {
                                                                    Navigator.of(
                                                                            ctx)
                                                                        .pop();
                                                                  }),
                                                                  child: const Text(
                                                                      '이어하기',
                                                                      style:
                                                                          TextStyle(
                                                                        color: Colors
                                                                            .white,
                                                                      )),
                                                                  style: ButtonStyle(
                                                                      backgroundColor: MaterialStateProperty.all<
                                                                              Color>(
                                                                          Colors
                                                                              .white12),
                                                                      foregroundColor: MaterialStateProperty.all<
                                                                              Color>(
                                                                          Colors
                                                                              .black))),
                                                              SizedBox(
                                                                  width: 25.w),
                                                              ElevatedButton(
                                                                onPressed: (() {
                                                                  Navigator.pushReplacement(
                                                                      context,
                                                                      MaterialPageRoute(
                                                                          builder: (context) => ResultPage(
                                                                              kcal: widget.index == 0
                                                                                  ? curnum ~/ 4
                                                                                  : widget.index == 1
                                                                                      ? (stopwatch.elapsedMilliseconds / 1000) ~/ 10
                                                                                      : curnum ~/ 4,
                                                                              index: widget.index,
                                                                              number: widget.index == 1 ? (stopwatch.elapsedMilliseconds / 1000).floor() : curnum)));
                                                                }),
                                                                child: const Text(
                                                                    '그만하기',
                                                                    style:
                                                                        TextStyle(
                                                                      color: Colors
                                                                          .white,
                                                                    )),
                                                              )
                                                            ])
                                                      ])));
                                        });
                                  })))
                        ]))
                  ])),
            ],
          ),
        ),
      ),
    );
  }
}
