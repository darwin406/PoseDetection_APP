import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/services.dart';
import '../component/stringlist.dart';
import 'cameraPage.dart';

class ChoicePage extends StatefulWidget {
  @override
  State<ChoicePage> createState() => _ChoicePageState();
}

class _ChoicePageState extends State<ChoicePage> {
  final TextEditingController? _targetNumber = TextEditingController(text: '0');
  final TextEditingController? _targetSet = TextEditingController(text: '0');
  final TextEditingController? _targetSeconds =
      TextEditingController(text: '0');
  bool _targetLimit = false;
  List image = [
    'assets/lunge_960_555.jpg',
    'assets/sideplank_512_296.jpg',
    'assets/squat_640_370.jpg'
  ];
  List name = ['런지', '사이드플랭크', '스쿼트'];

  @override
  void dispose() {
    _targetNumber?.dispose();
    _targetSet?.dispose();
    _targetSeconds?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(children: <Widget>[
        Column(
          children: <Widget>[
            Center(
              child: Container(
                width: 300.w,
                height: 70.h,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text('\n운동 선택하기',
                        style: TextStyle(
                            fontSize: 25.sp, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ),
            SizedBox(height: 30.h),
            buildStack(context, 0),
            SizedBox(height: 15.h),
            buildStack(context, 1),
            SizedBox(height: 15.h),
            buildStack(context, 2),
            SizedBox(height: 30.h),
          ],
        ),
      ]),
    );
  }

  Stack buildStack(BuildContext context, int index) {
    return Stack(children: <Widget>[
      GestureDetector(
        onTap: () {
          showDialog(
            context: context,
            barrierDismissible: true,
            builder: (context) {
              return StatefulBuilder(
                  builder: (BuildContext context, StateSetter setState) {
                return AlertDialog(
                  content: SizedBox(
                      width: 200.w,
                      height: 200.h,
                      child: Column(children: <Widget>[
                        SizedBox(
                            height: 30.h,
                            width: 200.w,
                            child: const Text('목표치 설정')),
                        SizedBox(height: 30.h),
                        Row(children: <Widget>[
                          SizedBox(width: 10.w),
                          SizedBox(
                              width: 50.w,
                              height: 50.h,
                              child: TextField(
                                keyboardType: TextInputType.number,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly
                                ],
                                controller: _targetNumber,
                                maxLines: 1,
                                decoration: const InputDecoration(
                                    border: OutlineInputBorder()),
                              )),
                          SizedBox(
                              width: 50.w,
                              child: index == 1
                                  ? const Text(' 초 씩')
                                  : const Text(' 회 씩')),
                          SizedBox(
                              width: 50.w,
                              height: 50.h,
                              child: TextField(
                                keyboardType: TextInputType.number,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly
                                ],
                                controller: _targetSet,
                                maxLines: 1,
                                decoration: const InputDecoration(
                                    border: OutlineInputBorder()),
                              )),
                          SizedBox(width: 50.w, child: const Text(' 세트'))
                        ]),
                        SizedBox(height: 10.h),
                        SizedBox(
                            height: 30.h,
                            width: 200.w,
                            child: Row(children: <Widget>[
                              Checkbox(
                                value: _targetLimit,
                                onChanged: (value) {
                                  setState(() {
                                    _targetLimit = value!;
                                    print('$_targetLimit');
                                  });
                                },
                              ),
                              const Text('제한 없음'),
                            ])),
                        Padding(
                          padding: EdgeInsets.fromLTRB(100.0.w, 0.0, 0.0, 0.0),
                          child: SizedBox(
                            height: 40.h,
                            child: ElevatedButton(
                                onPressed: (() {
                                  var num =
                                      int.parse(_targetNumber!.text, radix: 10);
                                  var set =
                                      int.parse(_targetSet!.text, radix: 10);
                                  if ((num == null ||
                                          num == 0 ||
                                          set == null ||
                                          set == 0) &&
                                      _targetLimit == false) {
                                    showDialog(
                                        context: context,
                                        barrierDismissible: true,
                                        builder: (BuildContext ctx) {
                                          return AlertDialog(
                                              content: SizedBox(
                                            width: 60.w,
                                            height: 40.h,
                                            child: const Align(
                                                alignment: Alignment.center,
                                                child: Text('다시 입력해주세요',
                                                    textAlign:
                                                        TextAlign.center)),
                                          ));
                                        });
                                  } else {
                                    //_onTapCamera(context);
                                    Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => CameraPage(
                                                targetnumber:
                                                    _targetNumber == null ||
                                                            _targetLimit == true
                                                        ? -1
                                                        : int.parse(
                                                            _targetNumber!.text,
                                                            radix: 10),
                                                targetset: _targetSet == null ||
                                                        _targetLimit == true
                                                    ? 1
                                                    : int.parse(
                                                        _targetSet!.text,
                                                        radix: 10),
                                                index: index)));
                                  }
                                }),
                                child: const Icon(Icons.arrow_forward,
                                    color: Colors.white)),
                          ),
                        ),
                      ])),
                );
              });
            },
          );
        },
        child: Container(
          width: 330.w,
          height: 200.h,
          child: ClipRRect(
            child: Image.asset(image[index], fit: BoxFit.fill),
            borderRadius: BorderRadius.circular(10),
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: const Color(0xff26D8D3)),
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
      Positioned(
          top: 140.0.h,
          left: 20.0.w,
          child: GestureDetector(
              onTap: () {
                //Navigator.of(context).pushReplacementNamed('/fifth');
              },
              child: Stack(
                children: [Text(name[index],
                  style: TextStyle(
                    fontSize: 20,
                    foreground: Paint()
                      ..style = PaintingStyle.stroke
                      ..strokeWidth = 2
                      ..color = Colors.black,
                  ),
                ),
                  Text(name[index],
                      style: TextStyle(
                        fontSize: 20,
                        color: Colors.white,
                      ))]
              ))),
      Positioned(
        top: 0.0.h,
        left: 280.0.w,
        child: IconButton(
            icon: Stack(
              children: const [
                Icon(Icons.info_rounded, color: Color(0xff26D8D3), size: 30),
                Icon(Icons.info_outline_rounded, color: Colors.white, size: 30)
              ],
            ),
            onPressed: (() {
              showDialog(
                  context: context,
                  barrierDismissible: true,
                  builder: (BuildContext ctx) {
                    return AlertDialog(content: buildSizedBox(index), actions: [
                      TextButton(
                          child: const Text('확인'),
                          onPressed: () {
                            Navigator.of(ctx).pop();
                          }),
                    ]);
                  });
              //Navigator.of(context).pushReplacementNamed('/lunge');
            })),
      )
    ]);
  }

  SizedBox buildSizedBox(int index) {
    return SizedBox(
        width: 200.w,
        height: 280.h,
        child: Column(children: <Widget>[
          ClipRRect(
            child: Image.asset(image[index]),
            borderRadius: BorderRadius.circular(5),
          ),
          SizedBox(height: 10.h),
          SizedBox(
              height: 30.h, width: 200.w, child: Text('${name[index]} 가이드')),
          SizedBox(
              height: 100.h,
              width: 200.w,
              child: Text(
                  exerciseExplain[index],
                  style: TextStyle(fontSize: 10)))
        ]));
  }
}
