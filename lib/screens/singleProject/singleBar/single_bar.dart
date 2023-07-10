import 'package:flutter/material.dart';
import 'dart:math';

class ExpenseBar extends StatelessWidget {
  final double totalExpenses;
  final double unpaidExpenses;

  const ExpenseBar({
    Key? key,
    required this.totalExpenses,
    required this.unpaidExpenses,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double unpaidPercentage = unpaidExpenses / totalExpenses;
    double paidPercentage = 1 - unpaidPercentage;

    return Container(
      width: 170,
      height: 170,
      child: Row(
        children: [
          Container(
            width: 110,
            height: 110,
            child: CustomPaint(
              painter: PieChartPainter(paidPercentage, unpaidPercentage),
            ),
          ),
          SizedBox(width: 10),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 20,
                height: 20,
                color: Colors.tealAccent.shade100,
              ),
              SizedBox(height: 5),
              Text(
                'Paid',
                style: TextStyle(color: Colors.tealAccent.shade100),
              ),
              SizedBox(height: 10),
              Container(
                width: 20,
                height: 20,
                color: Colors.indigo,
              ),
              SizedBox(height: 5),
              Text(
                'Unpaid',
                style: TextStyle(color: Colors.indigo),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class PieChartPainter extends CustomPainter {
  final double paidPercentage;
  final double unpaidPercentage;

  PieChartPainter(this.paidPercentage, this.unpaidPercentage);

  @override
  void paint(Canvas canvas, Size size) {
    double radius = min(size.width, size.height) / 2;
    Offset center = Offset(size.width / 2, size.height / 2);

    double paidAngle = 2 * pi * paidPercentage;
    double unpaidAngle = 2 * pi * unpaidPercentage;

    final paidPaint = Paint()..color = Colors.tealAccent.shade100;
    final unpaidPaint = Paint()..color = Colors.indigo;

    canvas.drawArc(Rect.fromCircle(center: center, radius: radius), -pi / 2, paidAngle, true, paidPaint);
    canvas.drawArc(Rect.fromCircle(center: center, radius: radius), -pi / 2 + paidAngle, unpaidAngle, true, unpaidPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
