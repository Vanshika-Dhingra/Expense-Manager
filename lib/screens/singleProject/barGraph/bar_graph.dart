import 'package:expensetracking/screens/singleProject/barGraph/bar_data.dart';
import 'package:fl_chart/fl_chart.dart';
import'package:flutter/material.dart';

class MyBarGraph extends StatelessWidget{
  final List<double> weeklySummary;
  const MyBarGraph({super.key,required this.weeklySummary});
  @override
  Widget build(BuildContext context){
    BarData myBarData=BarData(sunAmount: weeklySummary[0], monAmount: weeklySummary[1], tueAmount: weeklySummary[2], wedAmount: weeklySummary[3], thuAmount: weeklySummary[4], friAmount: weeklySummary[5], satAmount: weeklySummary[6]);
    myBarData.initialiseData();
    return  BarChart(
      BarChartData(
        gridData: FlGridData(show: false),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          show: true,
          topTitles: AxisTitles(sideTitles:SideTitles(showTitles: false)),
          //leftTitles: AxisTitles(sideTitles:SideTitles(showTitles: false)),
          rightTitles: AxisTitles(sideTitles:SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(sideTitles:SideTitles(showTitles: true,getTitlesWidget: getBottomTitles)),
        ),
        maxY: 2000,
        minY: 0,
        barGroups: myBarData.barData.map((data) => BarChartGroupData(
            x: data.x,barRods: [BarChartRodData(toY: data.y,color: Colors.indigo,width: 20,backDrawRodData: BackgroundBarChartRodData(
          show: true,
          toY: 2000,
          color: Colors.tealAccent.shade100
        ),borderRadius: BorderRadius.circular(5))])).toList(),
      ),
    );
  }
}

Widget getBottomTitles(double value,TitleMeta meta)
{
  const style=TextStyle(color: Colors.white,fontWeight: FontWeight.bold,fontSize: 14,);
  Widget text;
  switch(value.toInt()){
    case 0:
      text=const Text('S',style: style);
          break;
    case 1:
      text=const Text('M',style: style);
      break;
    case 2:
      text=const Text('T',style: style);
      break;
    case 3:
      text=const Text('W',style: style);
      break;
    case 4:
      text=const Text('T',style: style);
      break;
    case 5:
      text=const Text('F',style: style);
      break;
    case 6:
      text=const Text('Sa',style: style);
      break;
    default:
      text=const Text(' ',style: style);
      break;
  }
  return SideTitleWidget(axisSide: meta.axisSide, child: text);
}