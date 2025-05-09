import 'package:disiry_weight_mng/entity/weight.dart';
import 'package:disiry_weight_mng/main.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:month_picker_dialog/month_picker_dialog.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:disiry_weight_mng/provider/theme-color.dart';

class GraphPageCopy extends ConsumerStatefulWidget {
  const GraphPageCopy({super.key});

  @override
  _GraphPageCopyState createState() => _GraphPageCopyState();
}

class _GraphPageCopyState extends ConsumerState<GraphPageCopy> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        toolbarHeight: 40,
        backgroundColor: Colors.white,
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: const Text(
          '体重グラフ',
          style: TextStyle(color: Colors.black54, fontSize: 17),
        ),
      ),
      body: const WeightChart(),
    );
  }
}

class WeightChart extends ConsumerStatefulWidget {
  const WeightChart({super.key});

  @override
  _WeightChartState createState() => _WeightChartState();
}

class _WeightChartState extends ConsumerState<WeightChart> {
  // デフォルト選択期間
  DateTime displayDate = DateTime(DateTime.now().year, DateTime.now().month, 1);
  final List<bool> _isSelected = [true, false, false, false];
  int selectedIndex = 0;
  int selectedPeriod = 1;
  double maxX = 31;
  double averageWeight = 0.0;
  double sumWeight = 0.0;

  // 体重データのリスト
  List<double> weights = [];
  List<Weight> weightsData = [];
  List<DateTime> dates = [];

  double targetWeight = 0.0;

  Color themeColor = Colors.blue;

  @override
  void initState() {
    super.initState();
    weightsData =
        objectBox.getWeights(months: selectedPeriod, datetime: displayDate);
    weights.clear();
    dates.clear();
    for (Weight weight in weightsData) {
      weights.add(weight.weight);
      dates.add(weight.datetime);
    }
    targetWeight = double.parse(objectBox.getTargtWeight());
  }

  @override
  Widget build(BuildContext context) {
    sumWeight = 0.0;
    weightsData =
        objectBox.getWeights(months: selectedPeriod, datetime: displayDate);
    weights.clear();
    dates.clear();
    for (Weight weight in weightsData) {
      sumWeight += weight.weight;
      weights.add(weight.weight);
      dates.add(weight.datetime);
    }
    if (sumWeight != 0.0) {
      averageWeight = sumWeight / weightsData.length;
    } else {
      averageWeight = 0.0;
    }

    targetWeight = double.parse(objectBox.getTargtWeight());

    // テーマカラーのプロバイダーを監視
    themeColor = ref.watch(themeColorProvider);
    var themeColorString = objectBox.getThemeColor();

    if (themeColorString == 'lime') {
      themeColor = Colors.lime;
    } else if (themeColorString == 'lime-shade') {
      themeColor = Colors.lime.shade300;
    } else if (themeColorString == 'orange') {
      themeColor = Colors.orange;
    } else if (themeColorString == 'orange-shade') {
      themeColor = Colors.orange.shade300;
    } else if (themeColorString == 'red') {
      themeColor = Colors.red;
    } else if (themeColorString == 'red-shade') {
      themeColor = Colors.red.shade300;
    } else if (themeColorString == 'purple') {
      themeColor = Colors.purple;
    } else if (themeColorString == 'purple-shade') {
      themeColor = Colors.purple.shade300;
    } else if (themeColorString == 'green') {
      themeColor = Colors.green;
    } else if (themeColorString == 'green-shade') {
      themeColor = Colors.green.shade300;
    } else if (themeColorString == 'blue') {
      themeColor = Colors.blue;
    } else if (themeColorString == 'blue-shade') {
      themeColor = Colors.blue.shade300;
    }

    double maxWeight =
        weights.isEmpty ? 60 : weights.reduce((a, b) => a > b ? a : b) + 2.0;
    double minWeight = targetWeight - 2.0;
    if (weights.isNotEmpty) {
      if (targetWeight > weights.reduce((a, b) => a > b ? a : b)) {
        maxWeight = targetWeight + 2.0;
        minWeight = weights.isEmpty
            ? 50
            : weights.reduce((a, b) => a < b ? a : b) - 5.0;
      }

      if (targetWeight > weights.reduce((a, b) => a < b ? a : b)) {
        minWeight = weights.isEmpty
            ? 50
            : weights.reduce((a, b) => a < b ? a : b) - 5.0;
      }
    }

    // 折れ線グラフのデータを生成
    List<FlSpot> spots = weights.asMap().entries.map((entry) {
      int x = entry.key + 1;
      double y = entry.value;
      return FlSpot(x.toDouble(), y);
    }).toList();

    // 日付フォーマッタ
    final DateFormat formatter = DateFormat('d');
    return Column(
      children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Row(
            children: [
              IconButton(
                onPressed: () async {
                  var selectedDate = await showMonthPicker(
                      context: context,
                      initialDate: displayDate,
                      firstDate: DateTime(2000, 12),
                      lastDate: DateTime(2050, 12),
                      locale: const Locale('ja', ''),
                      headerColor: themeColor,
                      selectedMonthTextColor: Colors.white,
                      unselectedMonthTextColor: themeColor,
                      selectedMonthBackgroundColor: themeColor,
                      backgroundColor: Colors.white,
                      roundedCornersRadius: 30,
                      confirmWidget: Text(
                        '完了',
                        style: TextStyle(color: themeColor),
                      ),
                      cancelWidget: Text(
                        'キャンセル',
                        style: TextStyle(color: themeColor),
                      ));
                  if (selectedDate != null) {
                    setState(() {
                      displayDate = DateTime.parse(
                          DateTime(selectedDate.year, selectedDate.month, 1)
                              .toString());
                      weightsData = objectBox.getWeights(
                          months: selectedPeriod, datetime: displayDate);
                      weights.clear();
                      dates.clear();
                      for (Weight weight in weightsData) {
                        weights.add(weight.weight);
                        dates.add(weight.datetime);
                      }
                    });
                  }
                },
                icon: const Icon(
                  Icons.edit_calendar,
                  color: Colors.black54,
                ),
              ),
              Text(
                '${displayDate.year}年${displayDate.month}月 ~',
                style: const TextStyle(color: Colors.black54, fontSize: 16),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.fromLTRB(0, 0, 30, 0),
            child: Text(
              '期間平均：${averageWeight.toStringAsFixed(2)} kg',
              style: const TextStyle(color: Colors.black54, fontSize: 16),
            ),
          ),
        ]),
        Container(
          child: ToggleButtons(
            fillColor: themeColor.withOpacity(0.7),
            selectedColor: Colors.white,
            color: themeColor,
            onPressed: (int index) {
              setState(() {
                if (selectedIndex != index) {
                  _isSelected[selectedIndex] = false;
                  _isSelected[index] = true;
                  selectedIndex = index;
                }

                if (index == 0) {
                  selectedPeriod = 1;
                  maxX = 31;
                  weightsData = objectBox.getWeights(
                      months: selectedPeriod, datetime: displayDate);
                  weights.clear();
                  dates.clear();
                  for (Weight weight in weightsData) {
                    weights.add(weight.weight);
                    dates.add(weight.datetime);
                  }
                } else if (index == 1) {
                  selectedPeriod = 3;
                  maxX = 92;
                  weightsData = objectBox.getWeights(
                      months: selectedPeriod, datetime: displayDate);
                  weights.clear();
                  dates.clear();
                  for (Weight weight in weightsData) {
                    weights.add(weight.weight);
                    dates.add(weight.datetime);
                  }
                } else if (index == 2) {
                  selectedPeriod = 6;
                  maxX = 184;
                  weightsData = objectBox.getWeights(
                      months: selectedPeriod, datetime: displayDate);
                  weights.clear();
                  dates.clear();
                  for (Weight weight in weightsData) {
                    weights.add(weight.weight);
                    dates.add(weight.datetime);
                  }
                } else if (index == 3) {
                  selectedPeriod = 12;
                  maxX = 366;
                  weightsData = objectBox.getWeights(
                      months: selectedPeriod, datetime: displayDate);
                  weights.clear();
                  dates.clear();
                  for (Weight weight in weightsData) {
                    weights.add(weight.weight);
                    dates.add(weight.datetime);
                  }
                }
              });
            },
            isSelected: _isSelected,
            constraints: BoxConstraints(
                minHeight: 30,
                minWidth: (MediaQuery.of(context).size.width - 100) / 4),
            borderRadius: const BorderRadius.all(Radius.circular(10)),
            children: const [
              Text("1ヶ月"),
              Text("3ヶ月"),
              Text("6ヶ月"),
              Text("1年"),
            ],
          ),
        ),
        Expanded(
          child: Row(
            children: [
              // 縦軸のラベル部分
              Container(
                margin: const EdgeInsets.fromLTRB(10, 0, 0, 0),
                padding: const EdgeInsets.fromLTRB(0, 20, 5, 120),
                width: 35,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(5, (index) {
                    String value =
                        (maxWeight - (maxWeight - minWeight) * index / 4)
                            .toStringAsFixed(1);
                    if (index == 4) {
                      value = '';
                    }
                    return Text(
                      value,
                      style: const TextStyle(fontSize: 12),
                    );
                  }),
                ),
              ),
              // グラフ部分
              Expanded(
                child: SizedBox(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(0, 20, 15, 100),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal, // 横スクロールを有効にする
                      child: SizedBox(
                        width: 1000, // 必要な横幅を指定（例: maxXの値に基づいて調整）
                        child: LineChart(
                          LineChartData(
                            gridData: FlGridData(
                              show: true,
                              verticalInterval: maxX / 10,
                              drawHorizontalLine: false,
                              getDrawingVerticalLine: (value) {
                                return const FlLine(
                                    color: Colors.grey, strokeWidth: 0.5);
                              },
                            ),
                            titlesData: FlTitlesData(
                              topTitles: const AxisTitles(
                                  sideTitles: SideTitles(showTitles: false)),
                              bottomTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: false,
                                  reservedSize: 40,
                                  interval: weights.length < 4
                                      ? 1
                                      : double.parse((weights.length / 7)
                                          .round()
                                          .toString()),
                                  getTitlesWidget: (value, meta) {
                                    if (value <= 0 ||
                                        value >= dates.length ||
                                        value == weights.length) {
                                      return Container();
                                    } else {
                                      return SideTitleWidget(
                                        axisSide: meta.axisSide,
                                        child: Text(formatter
                                            .format(dates[value.toInt() - 1])),
                                      );
                                    }
                                  },
                                ),
                              ),
                              rightTitles: const AxisTitles(
                                sideTitles: SideTitles(showTitles: false),
                              ),
                              leftTitles: const AxisTitles(
                                sideTitles: SideTitles(showTitles: false),
                              ),
                            ),
                            borderData: FlBorderData(
                              show: true,
                              border:
                                  Border.all(color: Colors.black12, width: 1),
                            ),
                            extraLinesData: ExtraLinesData(horizontalLines: [
                              HorizontalLine(
                                  y: targetWeight,
                                  color: Colors.black38,
                                  dashArray: [5, 10],
                                  label: HorizontalLineLabel(
                                    show: true,
                                    alignment: Alignment.topLeft,
                                    padding: const EdgeInsets.only(
                                        right: 5, bottom: 5),
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    labelResolver: (line) => '目標：${line.y} kg',
                                  ))
                            ]),
                            minX: 1,
                            maxX: maxX,
                            minY: weights.isEmpty ? 1 : minWeight,
                            maxY: weights.isEmpty ? 1 : maxWeight,
                            lineBarsData: [
                              LineChartBarData(
                                spots: spots,
                                isCurved: true,
                                color: themeColor,
                                barWidth:
                                    selectedIndex == 2 || selectedIndex == 3
                                        ? 1.0
                                        : 1.5,
                                dotData: FlDotData(
                                  show: selectedIndex == 0 || selectedIndex == 0
                                      ? true
                                      : false,
                                  getDotPainter:
                                      (spot, percent, barData, index) =>
                                          FlDotCirclePainter(
                                    radius: selectedIndex == 0 ? 1.0 : 0.5,
                                    color: themeColor,
                                    strokeWidth: 2.0,
                                    strokeColor: themeColor,
                                  ),
                                ),
                              ),
                            ],
                            lineTouchData: LineTouchData(
                              enabled: true,
                              getTouchedSpotIndicator:
                                  (LineChartBarData barData,
                                      List<int> spotIndexes) {
                                return spotIndexes.map((spotIndex) {}).toList();
                              },
                              touchTooltipData: LineTouchTooltipData(
                                tooltipRoundedRadius: 20.0,
                                fitInsideHorizontally: true,
                                tooltipMargin: 0,
                                getTooltipColor: (touchedSpot) => themeColor,
                                getTooltipItems: (touchedSpots) {
                                  return touchedSpots.map(
                                    (LineBarSpot touchedSpot) {
                                      const textStyle = TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.white,
                                      );
                                      return LineTooltipItem(
                                        ' ${dates[touchedSpot.x.toInt() - 1].year}/${dates[touchedSpot.x.toInt() - 1].month}/${dates[touchedSpot.x.toInt() - 1].day}'
                                        ' ${touchedSpot.y.toStringAsFixed(2)}kg',
                                        textStyle,
                                      );
                                    },
                                  ).toList();
                                },
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
