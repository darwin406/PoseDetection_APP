import 'package:ugrp/const/colors.dart';
import 'package:flutter/material.dart';

class ScheduleCard extends StatelessWidget {
  // 24h
  // 13:00
  final int kcal;
  final int lunge;
  final int plank;
  final int squat;

  const ScheduleCard({
    required this.kcal,
    required this.lunge,
    required this.plank,
    required this.squat,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          width: 1.0,
          color: PRIMARY_COLOR,
        ),
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: IntrinsicHeight(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _Dayinfo(
                kcal: kcal,
                lunge: lunge,
                plank: plank,
                squat: squat,
              ),
              SizedBox(width: 16.0),
            ],
          ),
        ),
      ),
    );
  }
}

class _Dayinfo extends StatelessWidget {
  final int kcal;
  final int lunge;
  final int plank;
  final int squat;

  const _Dayinfo({
    required this.kcal,
    required this.lunge,
    required this.plank,
    required this.squat,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final textStyle = TextStyle(
      fontWeight: FontWeight.w600,
      color: Color(0xff717171),
      fontSize: 16.0,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${kcal}kcal',
          style: textStyle,
        ),
        Text(
          '런지: ${lunge}회',
          style: textStyle,
        ),
        Text(
          '사이드플랭크: ${plank ~/ 60}분 ${plank % 60}초',
          style: textStyle,
        ),
        Text(
          '스쿼트: ${squat}회',
          style: textStyle,
        ),
      ],
    );
  }
}
