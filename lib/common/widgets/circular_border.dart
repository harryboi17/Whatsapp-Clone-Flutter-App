import 'dart:math';

import 'package:flutter/material.dart';
import 'package:whatsapp_clone/common/utils/colors.dart';

class CircularBorder extends StatelessWidget {
  final List<bool> isSeenStatusList;
  const CircularBorder({Key? key, required this.isSeenStatusList}) : super(key: key);
  final Color color = unSeenMessageColor;
  final double width = 2.5;
  final double size = 60;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: size,
      width: size,
      alignment: Alignment.center,
      child: CustomPaint(
        size: Size(size, size),
        foregroundPainter: MyPainter(
            completeColor: color,
            width: width,
            isSeenStatusList: isSeenStatusList,
        ),
      ),
    );
  }
}

class MyPainter extends CustomPainter {
  Color lineColor =  Colors.transparent;
  Color completeColor;
  double width;
  List<bool> isSeenStatusList;
  MyPainter({ required this.completeColor, required this.width, required this.isSeenStatusList});
  @override
  void paint(Canvas canvas, Size size) {
    int count = isSeenStatusList.length;
    Paint complete = Paint()
      ..color = completeColor
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke
      ..strokeWidth = width;

    Offset center = Offset(size.width / 2, size.height / 2);
    double radius = min(size.width / 2, size.height / 2) + width*1.25;
    // var percent = (size.width *0.001) / 2;
    var subtract = min(0.05, count == 1 ? 0 : 0.3/count);
    var percent = (1/count) - subtract;

    double arcAngle = 2 * pi * percent;

    for (var i = 0; i < count; i++) {
      // var init = (-pi / 2)*(i/2);
      var init = (2*pi / count)*(i) + pi/2+ pi*subtract;
      if(isSeenStatusList[i]) {
        complete.color = Colors.white38;
      }
      else{
        complete.color = completeColor;
      }
      canvas.drawArc(Rect.fromCircle(center: center, radius: radius),
          init, arcAngle, false, complete);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}