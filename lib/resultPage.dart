import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ugrp/const/colors.dart';
import 'component/stringlist.dart';
import 'mainPage.dart';
import 'package:bubble/bubble.dart';

class ResultPage extends StatefulWidget {
  int index;
  int kcal;
  int number;

  ResultPage(
      {Key? key, required this.kcal, required this.index, required this.number})
      : super(key: key);

  @override
  State<ResultPage> createState() => _ResultPage();
}

class _ResultPage extends State<ResultPage> {
  final _authentication = FirebaseAuth.instance;
  User? loggedUser;

  @override
  void initState() {
    super.initState();
    getCurrentUser();
  }

  void getCurrentUser() {
    try {
      final user = _authentication.currentUser;
      if (user != null) {
        loggedUser = user;
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Center(
          child: Column(
            children: [
              SizedBox(height: 20.h),
              SizedBox(
                  height: 55.h,
                  width: 300.w,
                  child: Text(
                    'Congratulations!',
                    style: TextStyle(
                      fontSize: 35.sp,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  )),
              SizedBox(height: 30.h),
              Container(
                  height: 200.h,
                  width: 350.w,
                  color: PRIMARY_COLOR,
                  child: Column(children: [
                    SizedBox(height: 20.h),
                    Row(children: [
                      SizedBox(
                        height: 160.h,
                        width: 10.w,
                      ),
                      SizedBox(
                          height: 160.h,
                          width: 200.w,
                          child: Bubble(
                              child: Text(
                                printResult(
                                    index: widget.index,
                                    kcal: widget.kcal,
                                    number: widget.number),
                                style: TextStyle(
                                  fontSize: 17.sp,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              nip: BubbleNip.rightCenter)),
                      SizedBox(width: 10.w),
                      SizedBox(
                          height: 160.h,
                          width: 120.w,
                          child: Image.asset('assets/pt_outlined.png'))
                    ])
                  ])),
              SizedBox(
                height: 30.h,
              ),
              SizedBox(height: 30.h, child: Text('오늘의 건강 지식', style: TextStyle(fontSize: 20.sp))),
              Container(
                  width: 300.w,
                  height: 200.h,
                  child: Image.asset(exercisePictures[widget.number % 5])),
              SizedBox(
                height: 30.h,
              ),
              SizedBox(
                  width: 300.w,
                  child: Text(exerciseText[widget.number % 5],
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 17.sp))),
              SizedBox(height: 40.h),
              ElevatedButton(
                  onPressed: (() {
                    Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (context) => MainPage(
                                widget.kcal, widget.number, widget.index)));
                    print('데이터 넘기기 완료');
                  }),
                  child: const Text('메뉴로 돌아가기',
                      style: TextStyle(color: Colors.white)),
                  style:
                      ElevatedButton.styleFrom(minimumSize: Size(280.w, 40.h)))
            ],
          ),
        ),
      ),
    );
  }

  void dispose() {
    super.dispose();
  }
}

String? setExercise(int index) {
  return index == 0
      ? '런지'
      : index == 1
          ? '사이드플랭크'
          : '스쿼트';
}

String printResult({int index = 0, int kcal = 0, int number = 0}) {
  if (index == 1) {
    return '소모 칼로리는 \n\n ${kcal} kcal! \n\n ${exerciseName[index]}를 \n\n ${number}초 했습니다.';
  }
  return '소모 칼로리는 \n\n ${kcal} kcal! \n\n ${exerciseName[index]}를 \n\n ${number}회 했습니다.';
}
