import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';
import 'package:ugrp/component/calendar.dart';
import 'package:ugrp/component/schedule_card.dart';
import 'package:ugrp/component/today_banner.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MainPage extends StatefulWidget {
  int kcal = 0;
  int number = 0;
  int index = 0;

  MainPage(this.kcal, this.number, this.index);

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  final _authentication = FirebaseAuth.instance;
  User? loggedUser;

  String username = '';
  int lastkcal = 0;
  int lastlunge = 0;
  int lastplank = 0;
  int lastsquat = 0;
  late List<int> mylist;

  DateTime selectedDay = DateTime.utc(
    DateTime.now().year,
    DateTime.now().month,
    DateTime.now().day,
  );
  DateTime focusedDay = DateTime.now();

  @override
  void initState() {
    super.initState();
    getCurrentUser();
    getandsetdata();
    getusername();
  }

  void getusername() async {
    DocumentReference userRef =
        FirebaseFirestore.instance.collection('user').doc(loggedUser!.uid);

    await userRef.get().then(
      (DocumentSnapshot doc) {
        final data = doc.data() as Map<String, dynamic>;
        username = data['userID'];
      },
      onError: (e) => print("Error getting username: $e"),
    );
  }

  void getandsetdata() async {
    mylist = await getInfor(DateTime.now());
    lastkcal = mylist[0];
    lastlunge = mylist[1];
    lastplank = mylist[2];
    lastsquat = mylist[3];

    if (widget.index == 0) {
      lastlunge += widget.number;
    } else if (widget.index == 1) {
      lastplank += widget.number;
    } else {
      lastsquat += widget.number;
    }

    lastkcal += widget.kcal;

    FirebaseFirestore.instance
        .collection('user')
        .doc(loggedUser!.uid)
        .collection('calendar')
        .doc(DateFormat("yyyy-MM-dd").format(DateTime.now()))
        .set({
      'kcal': lastkcal,
      'lunge': lastlunge,
      'plank': lastplank,
      'squat': lastsquat
    });
    print('업로드 완료');
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

  Future<void> resetPassword(String email) async {
    if (email == 'null') {
      return;
    }
    await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
      child: Container(
          child: Column(children: <Widget>[
        Padding(padding: EdgeInsets.fromLTRB(0.0, 28.0.h, 0.0, 0.0)),
        SizedBox(
          width: 350.w,
          child: IconButton(
              alignment: Alignment.topRight,
              icon: Image.asset('assets/ponix_head.png'),
              onPressed: (() {
                showDialog(
                    context: context,
                    builder: (BuildContext ctx) {
                      return SimpleDialog(
                          insetPadding: EdgeInsets.only(
                            left: 180.w,
                            bottom: 440.h,
                            top: 9.h,
                            right: 20.w,
                          ),
                          contentPadding: EdgeInsets.zero,
                          children: <Widget>[
                            Container(
                                width: 65.w,
                                height: 300.h,
                                child: Column(children: <Widget>[
                                  SizedBox(height: 25.h),
                                  Container(
                                      margin: EdgeInsets.only(left: 132.w),
                                      height: 40.h,
                                      width: 40.w,
                                      child:
                                          Image.asset('assets/ponix_head.png')),
                                  SizedBox(
                                    width: 180.w,
                                    height: 25.h,
                                    child: Text('${username} 님',
                                        maxLines: 1,
                                        style: TextStyle(fontSize: 16.sp),
                                        textAlign: TextAlign.center),
                                  ),
                                  SizedBox(
                                      width: 160.w,
                                      height: 25.h,
                                      child: Text(
                                        '환영합니다.',
                                        textAlign: TextAlign.end,
                                        style: TextStyle(fontSize: 16.sp),
                                      )),
                                  SizedBox(height: 20.h),
                                  SizedBox(
                                      child: GestureDetector(
                                    onTap: (() {
                                      resetPassword(_authentication.currentUser?.email ?? 'null');
                                      showDialog(
                                          context: context,
                                          barrierDismissible: true,
                                          builder: (BuildContext ctx) {
                                            return AlertDialog(
                                              content: Text(
                                                  '회원님의 이메일로 비밀번호 \n재설정 링크를 보냈습니다.',
                                                  style: TextStyle(
                                                      fontSize: 20.sp),
                                                  maxLines: 2),
                                            );
                                          });
                                    }),
                                    child: Container(
                                        decoration: BoxDecoration(
                                            border: Border.all(
                                                color: Colors.black)),
                                        width: 150.w,
                                        height: 25.h,
                                        child: Text('비밀번호 변경',
                                            textAlign: TextAlign.center,
                                            style: TextStyle(fontSize: 15.sp))),
                                  )),
                                  SizedBox(height: 20.h),
                                  SizedBox(
                                      child: GestureDetector(
                                          onTap: (() {
                                            showDialog(
                                                context: context,
                                                barrierDismissible: false,
                                                builder: (BuildContext ctx) {
                                                  return AlertDialog(
                                                      content:
                                                          Text('회원탈퇴하시겠습니까?'),
                                                      actions: [
                                                        ElevatedButton(
                                                          style: TextButton
                                                              .styleFrom(
                                                            backgroundColor:
                                                                Colors.red,
                                                          ),
                                                          child: const Text('예'),
                                                          onPressed: () {
                                                            _authentication
                                                                .currentUser
                                                                ?.delete();
                                                            Navigator.of(context)
                                                                .pushReplacementNamed('/');
                                                          },
                                                        ),
                                                        ElevatedButton(
                                                            style: TextButton
                                                                .styleFrom(
                                                                    backgroundColor:
                                                                        Colors
                                                                            .grey),
                                                            child: Text('아니오'),
                                                            onPressed: () {
                                                              Navigator.of(ctx)
                                                                  .pop();
                                                            }),
                                                      ]);
                                                });
                                          }),
                                          child: Container(
                                            decoration: BoxDecoration(
                                                border: Border.all(
                                                    color: Colors.red)),
                                            height: 25.h,
                                            width: 150.w,
                                            child: Text(
                                              '회원 탈퇴',
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                  color: Colors.redAccent,
                                                  fontSize: 15.sp),
                                            ),
                                          ))),
                                  SizedBox(height: 15.h),
                                  Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: <Widget>[
                                        TextButton(
                                          onPressed: () {
                                            _authentication.signOut();
                                            Navigator.of(context)
                                                .pushReplacementNamed('/');
                                          },
                                          child: Text('로그 아웃',
                                              style:
                                                  TextStyle(fontSize: 15.sp)),
                                        ),
                                        SizedBox(width: 25.w),
                                        TextButton(
                                            onPressed: () {
                                              showDialog(
                                                  context: context,
                                                  barrierDismissible: false,
                                                  builder: (BuildContext ctx) {
                                                    return AlertDialog(
                                                        content: Text(
                                                            '앱을 종료하시겠습니까?'),
                                                        actions: [
                                                          ElevatedButton(
                                                            style: TextButton
                                                                .styleFrom(
                                                              backgroundColor:
                                                                  Colors.red,
                                                            ),
                                                            child: Text('예'),
                                                            onPressed: () {
                                                              SystemChannels
                                                                  .platform
                                                                  .invokeMethod(
                                                                      'SystemNavigator.pop');
                                                            },
                                                          ),
                                                          ElevatedButton(
                                                              style: TextButton
                                                                  .styleFrom(
                                                                backgroundColor:
                                                                    Colors.grey,
                                                              ),
                                                              child:
                                                                  Text('아니오'),
                                                              onPressed: () {
                                                                Navigator.of(
                                                                        ctx)
                                                                    .pop();
                                                              }),
                                                        ]);
                                                  });
                                            },
                                            child: Text('앱 종료',
                                                style: TextStyle(
                                                    fontSize: 15.sp,
                                                    color: Colors.red),
                                                textAlign: TextAlign.end))
                                      ])
                                ]))
                          ]);
                    });
              })),
        ),
        SizedBox(
            width: 350.w,
            height: 30.h,
            child: Text('나의 운동량',
                textAlign: TextAlign.left, style: TextStyle(fontSize: 20))),
        SingleChildScrollView(
          child: Container(
            //height: 550.h,
            width: 350.w,
            child: Column(
              children: [
                Calendar(
                  selectedDay: selectedDay,
                  focusedDay: focusedDay,
                  onDaySelected: onDaySelected,
                ),
                SizedBox(height: 8.0),
                TodayBanner(
                  selectedDay: selectedDay,
                ),
                SizedBox(height: 8.0),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8.0),
                  child: FutureBuilder(
                      future: getInfor(focusedDay),
                      builder: (context, AsyncSnapshot<List<int>> snapshot) {
                        if (snapshot.hasData) {
                          return ScheduleCard(
                            kcal: snapshot.data![0].toInt(),
                            lunge: snapshot.data![1].toInt(),
                            plank: snapshot.data![2].toInt(),
                            squat: snapshot.data![3].toInt(),
                          );
                        } else {
                          return ScheduleCard(
                            kcal: 0,
                            lunge: 0,
                            plank: 0,
                            squat: 0,
                          );
                        }
                      }),
                ),
                SizedBox(height: 50.h),
                SizedBox(
                    width: 300.w,
                    height: 45.h,
                    child: ElevatedButton(
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all<Color>(
                            const Color(0xff26D8D3)),
                      ),
                      child: const Text('운동 시작하기',
                          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                      onPressed: () {
                        Navigator.of(context).pushReplacementNamed('/third');
                      },
                    ))
              ],
            ),
          ),
        ),
      ])),
    ));
  }

  onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    setState(() {
      this.selectedDay = selectedDay;
      this.focusedDay = selectedDay;
    });
  }

  Future<List<int>> getInfor(DateTime date) async {
    DocumentSnapshot snapshot = await FirebaseFirestore.instance
        .collection('user')
        .doc(loggedUser!.uid)
        .collection('calendar')
        .doc(DateFormat("yyyy-MM-dd").format(date))
        .get();

    late List<int> result = [0, 0, 0, 0];

    if (snapshot.data() == null) {
      print('snapshot.data() is null');
      result = [0, 0, 0, 0];
    } else {
      print('snapshot.data() is not null');
      final data = snapshot.data() as Map<String, dynamic>;
      result[0] = data['kcal'];
      result[1] = data['lunge'];
      result[2] = data['plank'];
      result[3] = data['squat'];
    }

    print('kcal is ${result[0]}');
    return (result);
  }
}
