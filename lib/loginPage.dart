import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:crypto/crypto.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LoginPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _LoginPage();
}

class _LoginPage extends State<LoginPage> with SingleTickerProviderStateMixin {
  FirebaseDatabase? _database;
  DatabaseReference? reference;
  String _databaseURL = 'https://ugrp-884ff-default-rtdb.firebaseio.com/';

  double opacity = 0;

  void _tryValidation() {
    final isValid = _formKey.currentState!.validate();
    if (isValid) {
      _formKey.currentState!.save();
    }
  }

  TextEditingController? _idTextController;
  TextEditingController? _pwTextController;

  String userEmail = '';
  String userPW = '';
  final _formKey = GlobalKey<FormState>();
  final _authentication = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    _idTextController = TextEditingController();
    _pwTextController = TextEditingController();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: GestureDetector(
          onTap: () {FocusScope.of(context).unfocus();},
          child: Scaffold(
          backgroundColor: Colors.white,
              body: ListView(children: <Widget>[
            Container(
              child: Form(
                key: _formKey,
                child: Column(
                  children: <Widget>[
                    SizedBox(height: 100.h),
                    SizedBox(
                      height: 70.h,
                      child: Image.asset('assets/login_logo.png'),
                    ),
                    SizedBox(height: 100.h),
                    Column(
                      children: <Widget>[
                        SizedBox(
                          width: 250.w,
                          height: 50.h,
                          child: TextFormField(
                            key: ValueKey(1),
                            validator: (value) {
                              if (value!.isEmpty || !value.contains('@')) {
                                return '올바른 이메일 주소를 입력해주세요';
                              }
                            },
                            onSaved: (value) {
                              userEmail = value!;
                            },
                            onChanged: (value) {
                              userEmail = value;
                            },
                            controller: _idTextController,
                            maxLines: 1,
                            decoration: InputDecoration(
                                labelText: 'Email', border: OutlineInputBorder()),
                          ),
                        ),
                        SizedBox(
                          height: 40.h,
                        ),
                        SizedBox(
                          width: 250.w,
                          height: 50.h,
                          child: TextFormField(
                            key: ValueKey(2),
                            validator: (value) {
                              if (value!.isEmpty || value.length < 6) {
                                return '6자 이상 입력해주세요';
                              }
                            },
                            onSaved: (value) {
                              userPW = value!;
                            },
                            onChanged: (value) {
                              userPW = value;
                            },
                            controller: _pwTextController,
                            obscureText: true,
                            maxLines: 1,
                            decoration: const InputDecoration(
                                labelText: 'Password',
                                border: OutlineInputBorder()),
                          ),
                        ),
                        SizedBox(height: 50.h),
                        SizedBox(
                            width: 300.w,
                            height: 50.h,
                            child: ElevatedButton(
                                onPressed: (() async {
                                  _tryValidation();
                                  try {
                                    final newUser = await _authentication
                                        .signInWithEmailAndPassword(
                                            email: userEmail, password: userPW);

                                    if (newUser.user != null) {
                                      Navigator.of(context).pushReplacementNamed(
                                          '/second',
                                          arguments: _idTextController!.value.text);
                                    }
                                  } catch (e) {
                                    print(e);
                                    if (_formKey.currentState!.validate()) {
                                      makeDialog('이메일이 존재하지 않습니다.');
                                    } else {
                                      makeDialog('입력 형식을 확인해주세요');
                                    }
                                  }
                                }),
                                child: const Text('로그인',
                                    style: TextStyle(color: Colors.white,
                                        fontSize: 15, fontWeight: FontWeight.bold)),
                                style: ElevatedButton.styleFrom(
                                  primary: const Color(0xff26D8D3),
                                ))),
                        SizedBox(height: 100.h),
                        SizedBox(height: 30.h, child: Text('회원이 아니신가요?')),
                        SizedBox(
                            width: 300.w,
                            height: 50.h,
                            child: ElevatedButton(
                                onPressed: (() {
                                  Navigator.of(context).pushNamed('/sign');
                                }),
                                child: const Text('회원가입',
                                    style: TextStyle(color: Colors.white,
                                        fontSize: 15, fontWeight: FontWeight.bold)),
                                style: ElevatedButton.styleFrom(
                                    primary: Colors.grey))),
                      ],
                    ),
                    //)
                  ],
                  mainAxisAlignment: MainAxisAlignment.start,
                ),
              ),
            ),
          ])),
        ),
      );
  }

  void makeDialog(String text) {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            content: Text(text),
          );
        });
  }
}
