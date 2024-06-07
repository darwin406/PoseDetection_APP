import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SignUpPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _SignUpPage();
}

class _SignUpPage extends State<SignUpPage> {
  final _authentication = FirebaseAuth.instance;
  FirebaseDatabase? _database;
  DatabaseReference? reference;
  String _databaseURL = 'https://ugrp-884ff-default-rtdb.firebaseio.com/';

  TextEditingController? _idTextController;
  TextEditingController? _pwTextController;
  TextEditingController? _pwCheckTextController;

  final _formKey = GlobalKey<FormState>();
  String userID = '';
  String userEmail = '';
  String userPW = '';

  bool _tryValidation() {
    final isValid = _formKey.currentState!.validate();
    if (isValid) {
      print('isValid is true');
      _formKey.currentState!.save();
      return true;
    }
    else {
      print('isValid is false');
      return false;
    }
  }

  @override
  void initState() {
    super.initState();
    _database = FirebaseDatabase(databaseURL: _databaseURL);
    reference = _database?.reference().child('user');
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        appBar: AppBar(
          iconTheme: const IconThemeData(color: Colors.white),
          title: const Text('회원 가입', style: TextStyle(color: Colors.white)),
        ),
        body: Container(
            child: Center(
              child: Form(
                key: _formKey,
                child: Column(
                    children: <Widget>[
                      SizedBox(
                        width: 200.w,
                        child: TextFormField(
                          key: const ValueKey(3),
                          validator: (value) {
                            if (value!.isEmpty || value.length < 4) {
                              return '4자 이상 입력해주세요';
                            }
                            return null;
                          },
                          onSaved: (value) {
                            setState(() {userID = value!;});
                          },
                          onChanged: (value) {
                            setState(() {userID = value;});
                          },
                          //controller: _idTextController,
                          maxLines: 1,
                          decoration: const InputDecoration(
                              hintText: '4자 이상 입력해주세요',
                              labelText: 'ID',
                              border: OutlineInputBorder()),
                        ),
                      ),
                      SizedBox(
                        height: 20.h,
                      ),
                      SizedBox(
                        width: 200.w,
                        child: TextFormField(
                          keyboardType: TextInputType.emailAddress,
                          key: const ValueKey(4),
                          validator: (value) {
                            if (value!.isEmpty || !value.contains('@')) {
                              return '올바른 이메일 주소를 입력해주세요';
                            }
                            return null;
                          },
                          onSaved: (value) {
                            setState(() {
                              userEmail = value!;
                            });
                          },
                          onChanged: (value) {
                            setState(() {
                              userEmail = value;
                            });
                          },
                          maxLines: 1,
                          decoration: const InputDecoration(
                              hintText: '@ 를 포함해주세요',
                              labelText: 'Email',
                              border: OutlineInputBorder()),
                        ),
                      ),
                      SizedBox(
                        height: 20.h,
                      ),
                      SizedBox(
                        width: 200.w,
                        child: TextFormField(
                          key: const ValueKey(5),
                          validator: (value) {
                            if (value!.isEmpty || value.length < 6) {
                              return '6자 이상 입력해주세요';
                            }
                            return null;
                          },
                          onSaved: (value) {
                            setState(() {
                              userPW = value!;
                            });
                          },
                          onChanged: (value) {
                            setState(() {
                              userPW = value;
                            });
                          },
                          obscureText: true,
                          maxLines: 1,
                          decoration: const InputDecoration(
                              hintText: '6자 이상 입력해주세요',
                              labelText: 'Password',
                              border: OutlineInputBorder()),
                        ),
                      ),
                      SizedBox(
                        height: 20.h,
                      ),
                      TextButton(
                        onPressed: () async {
                          if(_tryValidation() == true){
                            try {
                              final newUser =
                              await _authentication
                                  .createUserWithEmailAndPassword(
                                  email: userEmail, password: userPW);
                              print('newUser 만들기 완료');

                              if (newUser.user != null) {
                                print('user가 null이 아님');
                                FirebaseFirestore.instance.collection('user')
                                    .doc(newUser.user!.uid)
                                    .set({
                                  'userID': userID,
                                  'email': userEmail,
                                });
                                Navigator.of(context).pop();
                              }
                            } catch (e) {
                              makeDialog('이미 존재하는 이메일입니다.');
                            }
                          } else {
                            if(_formKey.currentState!.validate()){
                            makeDialog('이미 존재하는 이메일입니다.');
                            } else {makeDialog('입력 형식을 확인해주세요');}
                          }
                        },
                        child: Text(
                          '회원 가입',
                          style: TextStyle(color: Colors.white, fontSize: 15.sp),
                        ),
                        style: ButtonStyle(backgroundColor: MaterialStateProperty.all(const Color(0xff26D8D3))),
                      )
                    ],
                    mainAxisAlignment: MainAxisAlignment.center,
                  ),
              ),
            ),
          ),
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
