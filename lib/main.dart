import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:page_transition/page_transition.dart';
import 'package:ugrp/component/primaryColor.dart';

import 'loginPage.dart';
import 'package:ugrp/signUpPage.dart';
import 'mainPage.dart';
import 'choicePage.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  await Firebase.initializeApp();
  await initializeDateFormatting();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(392.7, 737.4), //숫자 뒤에 .w, .h, .sp 를 쓰면 designSize 기준 가로, 세로, 폰트 크기가 된다.
      builder: (_, child) => MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'app title',
        theme: ThemeData(
          primarySwatch:createMaterialColor(const Color(0xff26D8D3)),
        ),
        initialRoute: '/',
        routes: {
          '/': (context) =>AnimatedSplashScreen(splash: Image.asset('assets/splashscreen.png'), nextScreen: LoginPage(), backgroundColor: const Color(0xff26D8D3), duration: 2000, pageTransitionType: PageTransitionType.bottomToTop),
          '/sign': (context) => SignUpPage(),
          '/second': (context) => MainPage(0, 0, 0),
          '/third': (context) => ChoicePage(),
        },
      ),
    );
  }
}

