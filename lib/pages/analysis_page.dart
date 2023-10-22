import 'dart:io';

import 'package:avm_symptom_tracker/model/journal_model.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AnalysisPage extends StatefulWidget {
  final List<Journal> journals;

  const AnalysisPage({super.key, required this.journals});

  @override
  State<StatefulWidget> createState() => _AnalysisPageState();
}

class _AnalysisPageState extends State<AnalysisPage> {
  @override
  void initState() {
    super.initState();
  }

  Widget bottomTitleWidgets(double value, TitleMeta meta) {
    const style = TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 16,
    );
    Widget text;
    switch (value.toInt()) {
      case 2:
        text = const Text('SEPT', style: style);
        break;
      case 7:
        text = const Text('OCT', style: style);
        break;
      case 12:
        text = const Text('DEC', style: style);
        break;
      default:
        text = const Text('');
        break;
    }

    return SideTitleWidget(
      axisSide: meta.axisSide,
      space: 10,
      child: text,
    );
  }

  getRealValue(LineChartBarData bar, int index) {
    // if (bar.spots == spots1) {
    //   return 'Luftdruck: ${real1[index]}';
    // } else if (bar.spots == spots2) {
    //   return 'Temperatur: ${real2[index]}';
    // } else if (bar.spots == spots3) {
    //   return 'Klein: ${real3[index]}';
    // }

    return 'not defined';
  }

  @override
  Widget build(BuildContext context) {
    final lineTouchData = LineTouchData(
      handleBuiltInTouches: true,
      touchTooltipData: LineTouchTooltipData(
        getTooltipItems: (lineBarSpots) => defaultLineTooltipItem(
            lineBarSpots), // lineBarSpots.map((e) =>  LineTooltipItem(getRealValue(e.bar, e.barIndex), TextStyle(color: Colors.black))).toList(),
        tooltipBgColor: Colors.grey.shade200.withOpacity(0.8),
      ),
    );

    final bottomTitles = SideTitles(
      showTitles: true,
      reservedSize: 32,
      interval: 1,
      getTitlesWidget: bottomTitleWidgets,
    );

    // leftTitles() => SideTitles(
    //       getTitlesWidget: leftTitleWidgets,
    //       showTitles: true,
    //       interval: 1,
    //       reservedSize: 40,
    //     );

    final titlesData = FlTitlesData(
      bottomTitles: AxisTitles(
        sideTitles: bottomTitles,
      ),
      rightTitles: const AxisTitles(
        sideTitles: SideTitles(showTitles: false),
      ),
      topTitles: const AxisTitles(
        sideTitles: SideTitles(showTitles: false),
      ),
      leftTitles: const AxisTitles(
        sideTitles: SideTitles(showTitles: false),
      ),
    );

    return WillPopScope(
      onWillPop: () async {
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'Auswertungen',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onPrimary,
            ),
          ),
          backgroundColor: Theme.of(context).colorScheme.primary,
        ),
        body: ListView(
          children: [
            AspectRatio(
              aspectRatio: 1.25,
              child: LineChart(LineChartData(
                lineTouchData: lineTouchData,
                gridData: const FlGridData(show: false),
                titlesData: titlesData,
                lineBarsData: [
                  LineChartBarData(
                    isCurved: false,
                    color: Theme.of(context).primaryColorDark,
                    barWidth: 4,
                    isStrokeCapRound: false,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(show: false),
                    spots: widget.journals.map((j) => FlSpot(1.0 * j.id!, 0.5 * j.pain!)).toList(),
                  ),
                ],
                minX: 0,
                maxX: 15,
                maxY: 10,
                minY: 0,
              )),
            ),
            ...widget.journals.map((j) => ListTile(title: Text(DateFormat.yMd(Platform.localeName).format(j.date)))),
          ],
        ),
      ),
    );
  }
}
