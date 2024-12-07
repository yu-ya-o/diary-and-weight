import 'dart:io';

import 'package:disiry_weight_mng/main.dart';
import 'package:disiry_weight_mng/pages/diary-writing-page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import '../entity/weight.dart';
import '../entity/diary.dart';
import 'package:month_picker_dialog/month_picker_dialog.dart';
import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:disiry_weight_mng/provider/theme-color.dart';
import 'dart:async';
import 'package:in_app_review/in_app_review.dart';
import 'package:flutter/cupertino.dart';

class CalendarPage extends ConsumerStatefulWidget {
  const CalendarPage({super.key});

  @override
  _CalendarPageState createState() => _CalendarPageState();
}

class _CalendarPageState extends ConsumerState<CalendarPage> {
  // 日記なしメッセージ
  final String unWritingDiary = 'どんな一日でしたか？\n１行だけでも書いてみましょう';

  String randomMorningMessage = '';

  final List<String> scrollMorningMessages = [
    'おはようございます。暖かくしてお出かけしましょうね！',
    'Good Morning! 良い一日になりますように！',
    'Mucho gusto! スペイン語の"はじめまして"です。',
    'おはようございます。今日は何をしたいですか？',
    // '食欲の秋、読書の秋、スポーツの秋！たのしい季節ですね！'
  ];

  String getScrollMorningMessage() {
    final random = Random();
    final index = random.nextInt(scrollMorningMessages.length);
    return randomMorningMessage = scrollMorningMessages[index];
  }

  String randomDayMessage = '';

  final List<String> scrollDayMessages = [
    '年末はなんだか寂しい気持ちになることありますよね',
    'こんにちは。マイペースにやっていきましょうね！',
    'こんにちは。疲れたときは甘いもの食べて休憩しましょう。',
    // '食欲の秋、読書の秋、スポーツの秋！たのしい季節ですね！'
  ];

  String getScrollDayMessage() {
    final random = Random();
    final index = random.nextInt(scrollDayMessages.length);
    return randomDayMessage = scrollDayMessages[index];
  }

  String randomNightMessage = '';

  final List<String> scrollNightMessages = [
    '今年もあと少し。どんな一年でしたか？',
    'Mucho gusto! スペイン語の”はじめまして”です。',
    'こんばんは！寒くなってきたので、暖かくして過ごしましょうね。',
    '年末はなんだか寂しい気持ちになることありますよね'
  ];

  String getScrollNightMessage() {
    final random = Random();
    final index = random.nextInt(scrollNightMessages.length);
    return randomNightMessage = scrollNightMessages[index];
  }

  // スクロールメッセージ
  String scrollMessage = '';
  int nowHour = DateTime.now().hour;

  // カレンダーが表示される日付
  DateTime _focusedDay = DateTime.parse(
      DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day)
          .toString());
  // カレンダー上でマークが表示される日付
  DateTime _currentDay = DateTime.parse(
      DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day)
          .toString());

  // 先月
  DateTime _lastMonth = DateTime.parse(DateTime(
          DateTime.now().year, DateTime.now().month - 1, DateTime.now().day)
      .toString());

  // 去年
  DateTime _lastYear = DateTime.parse(DateTime(
          DateTime.now().year - 1, DateTime.now().month, DateTime.now().day)
      .toString());

  // 選択日の体重
  List<Weight> weightList = List.empty();
  String todayWeight = '';
  // 先月の体重
  List<Weight> lastMonthWeightList = List.empty();
  String lastMonthWeight = '0.00';
  // 去年の体重
  List<Weight> lastYearWeightList = List.empty();
  String lastYearWeight = '0.00';
  // 全体重
  List<Weight> allWeightList = List.empty();
  // 選択日の日記
  List<Diary> diaryList = List.empty();
  String todayDiary = '';

  // 平均体重表示用
  List<Weight> weightsData = [];
  double averageWeight = 0.0;
  double sumWeight = 0.0;

  // 身長
  double myHeight = 0.0;
  // BMI
  double bmi = 0.0;
  // 目標体重
  double targetWeight = 0.0;
  // 目標体重まで
  double untilTarget = 0.0;

  Color themeColor = Colors.blue;

  @override
  void initState() {
    super.initState();
    // 今日の体重取得
    weightList = objectBox.getWeight(selectedDay: _focusedDay.toString());
    // 今日の日記取得
    diaryList = objectBox.getDiary(selectedDay: _focusedDay.toString());
    // 毎日の体重取得（カレンダー表示用）
    allWeightList = objectBox.getAllWeight();

    // 目標体重取得
    targetWeight = double.parse(
        double.parse(objectBox.getTargtWeight()).toStringAsFixed(2));
    // 身長取得
    myHeight =
        double.parse(double.parse(objectBox.getHeight()).toStringAsFixed(2));

    if (weightList.isNotEmpty) {
      // 今日の体重が存在する場合
      todayWeight = weightList.first.weight.toStringAsFixed(2);
      if (todayWeight.isNotEmpty && todayWeight != '00.0') {
        // 00.00kgではない場合
        bmi = myHeight == 0
            ? 0.0
            : double.parse(todayWeight) / ((myHeight / 100) * (myHeight / 100));
        bmi = double.parse(bmi.toStringAsFixed(1));
        untilTarget = double.parse(
            (targetWeight - double.parse(todayWeight)).toStringAsFixed(2));
      } else {
        // 00.00kgの場合
        todayWeight = '00.0';
        bmi = 0.0;
        untilTarget = 0.0;
      }
    } else {
      // 今日の体重が存在しない場合
      todayWeight = '00.0';
      bmi = 0.0;
      untilTarget = 0.0;
    }

    if (diaryList.isNotEmpty) {
      // 今日の日記が存在する場合
      todayDiary = diaryList.first.content.toString();
    } else {
      // 今日の日記が存在しない場合、メッセージ表示
      todayDiary = unWritingDiary;
    }
    if (todayDiary.isEmpty) {
      // 今日の日記が存在しない場合、メッセージ表示
      todayDiary = unWritingDiary;
    }
  }

  @override
  Widget build(BuildContext context) {
    // 今日の体重取得
    weightList = objectBox.getWeight(selectedDay: _focusedDay.toString());
    // 今日の日記取得
    diaryList = objectBox.getDiary(selectedDay: _focusedDay.toString());
    // 先月の体重取得
    _lastMonth = DateTime.parse(
        DateTime(_focusedDay.year, _focusedDay.month - 1, _focusedDay.day)
            .toString());
    lastMonthWeightList =
        objectBox.getWeight(selectedDay: _lastMonth.toString());
    if (lastMonthWeightList.isNotEmpty) {
      lastMonthWeight = lastMonthWeightList.first.weight.toStringAsFixed(2);
    } else {
      lastMonthWeight = '0.00';
    }
    // 去年の体重取得
    _lastYear = DateTime.parse(
        DateTime(_focusedDay.year - 1, _focusedDay.month, _focusedDay.day)
            .toString());
    lastYearWeightList = objectBox.getWeight(selectedDay: _lastYear.toString());
    if (lastYearWeightList.isNotEmpty) {
      lastYearWeight = lastYearWeightList.first.weight.toStringAsFixed(2);
    } else {
      lastYearWeight = '0.00';
    }
    // 毎日の体重取得（カレンダー表示用）
    allWeightList = objectBox.getAllWeight();

    // 平均体重
    weightsData = objectBox.getWeights(
        months: 1,
        datetime: DateTime.parse(
            DateTime(_focusedDay.year, _focusedDay.month, 1).toString()));
    sumWeight = 0.0;
    for (Weight weight in weightsData) {
      sumWeight += weight.weight;
    }
    if (sumWeight != 0.0) {
      averageWeight = sumWeight / weightsData.length;
    } else {
      averageWeight = 0.0;
    }

    // スクロールメッセージ
    int nowHour = DateTime.now().hour;
    if (nowHour >= 4 && nowHour <= 10) {
      scrollMessage = getScrollMorningMessage();
    } else if (nowHour >= 11 && nowHour <= 17) {
      scrollMessage = getScrollDayMessage();
    } else if (nowHour >= 18 && nowHour <= 24) {
      scrollMessage = getScrollNightMessage();
    } else if (nowHour <= 3) {
      scrollMessage = getScrollNightMessage();
    } else {
      scrollMessage = 'こんにちは。良い日になりますように。';
    }

    // 目標体重取得
    targetWeight = double.parse(
        double.parse(objectBox.getTargtWeight()).toStringAsFixed(2));
    // 身長取得
    myHeight =
        double.parse(double.parse(objectBox.getHeight()).toStringAsFixed(2));

    if (weightList.isNotEmpty) {
      // 今日の体重が存在する場合
      todayWeight = weightList.first.weight.toStringAsFixed(2);
      if (todayWeight.isNotEmpty && todayWeight != '00.0') {
        // 00.00kgではない場合
        bmi = myHeight == 0
            ? 0.0
            : double.parse(todayWeight) / ((myHeight / 100) * (myHeight / 100));
        bmi = double.parse(bmi.toStringAsFixed(1));
        untilTarget = double.parse(
            (targetWeight - double.parse(todayWeight)).toStringAsFixed(2));
      } else {
        // 00.00kgの場合
        todayWeight = '00.0';
        bmi = 0.0;
        untilTarget = 0.0;
      }
    } else {
      // 今日の体重が存在しない場合
      todayWeight = '00.0';
      bmi = 0.0;
      untilTarget = 0.0;
    }

    if (diaryList.isNotEmpty) {
      // 今日の日記が存在する場合
      todayDiary = diaryList.first.content.toString();
    } else {
      // 今日の日記が存在しない場合、メッセージ表示
      todayDiary = unWritingDiary;
    }
    if (todayDiary.isEmpty) {
      // 今日の日記が存在しない場合、メッセージ表示
      todayDiary = unWritingDiary;
    }

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
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 0,
        backgroundColor: Colors.white,
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
          child: Column(children: [
        // カレンダー設定
        TableCalendar(
            locale: 'ja_JP',
            firstDay: DateTime.utc(1900, 1, 1),
            lastDay: DateTime.utc(2100, 12, 31),
            focusedDay: _focusedDay,
            currentDay: _currentDay,
            rowHeight: 65,
            daysOfWeekHeight: 25,
            calendarBuilders: CalendarBuilders(
              // カレンダーヘッダー設定（年月ピッカーと年月表示）
              headerTitleBuilder: (context, day) {
                day = DateTime.parse(
                    DateTime(day.year, day.month, day.day).toString());
                return Column(
                  children: [
                    Row(mainAxisAlignment: MainAxisAlignment.start, children: [
                      IconButton(
                        onPressed: () async {
                          var selectedDate = await showMonthPicker(
                              context: context,
                              initialDate: day,
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
                              if (selectedDate.year == DateTime.now().year &&
                                  selectedDate.month == DateTime.now().month) {
                                _focusedDay = DateTime.parse(DateTime(
                                        DateTime.now().year,
                                        DateTime.now().month,
                                        DateTime.now().day)
                                    .toString());
                              } else {
                                _focusedDay = DateTime.parse(DateTime(
                                        selectedDate.year,
                                        selectedDate.month,
                                        selectedDate.day)
                                    .toString());
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
                        '${day.year}年${day.month}月',
                        style: const TextStyle(
                            color: Colors.black54, fontSize: 18),
                      ),
                      if (day.month == 12)
                        Text(
                          '🎅🎄',
                          style: const TextStyle(fontSize: 22),
                        ),
                    ])
                  ],
                );
              },
              // 曜日表示設定
              dowBuilder: (context, day) {
                day = DateTime.parse(
                    DateTime(day.year, day.month, day.day).toString());
                final dowText = DateFormat.E('ja').format(day);
                return Container(
                  decoration: BoxDecoration(
                    // color: Color.fromARGB(255, 221, 206, 197),
                    color: themeColor.withOpacity(0.4),
                  ),
                  alignment: Alignment.topCenter,
                  child: Center(
                    child: Text(
                      dowText.toString(),
                      style: const TextStyle(color: Colors.black54),
                    ),
                  ),
                );
              },
              // 表示月の設定
              defaultBuilder: (context, day, focusedDay) {
                day = DateTime.parse(
                    DateTime(day.year, day.month, day.day).toString());
                Weight weight;
                // 体重全検索
                weight = allWeightList.firstWhere((element) {
                  return element.datetime.toString() == day.toString();
                },
                    orElse: () =>
                        Weight(date: day.toString(), datetime: day, weight: 0));
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  margin: EdgeInsets.zero,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(
                      color: const Color.fromARGB(255, 230, 223, 223),
                      width: 0.5,
                    ),
                  ),
                  alignment: Alignment.center,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        alignment: Alignment.topLeft,
                        padding: const EdgeInsets.fromLTRB(2, 0, 0, 0),
                        child: Text(
                          day.day.toString(),
                          style: const TextStyle(
                            fontSize: 11,
                            color: Colors.black38,
                          ),
                        ),
                      ),
                      Container(
                          alignment: Alignment.center,
                          child: Text(
                            weight.weight == 0 ? '' : weight.weight.toString(),
                            style: const TextStyle(
                              color: Colors.black54,
                            ),
                          )),
                    ],
                  ),
                );
              },
              // 表示月以外の設定
              outsideBuilder: (context, day, focusedDay) {
                day = DateTime.parse(
                    DateTime(day.year, day.month, day.day).toString());
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  margin: EdgeInsets.zero,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(
                      color: const Color.fromARGB(255, 230, 223, 223),
                      width: 0.5,
                    ),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    day.day.toString(),
                    style: const TextStyle(color: Colors.black12),
                  ),
                );
              },
              // 今日の日にちの設定
              todayBuilder: (context, day, focusedDay) {
                day = DateTime.parse(
                    DateTime(day.year, day.month, day.day).toString());
                Weight weight;
                // 体重全検索
                weight = allWeightList.firstWhere((element) {
                  return element.datetime.toString() == day.toString();
                },
                    orElse: () =>
                        Weight(date: day.toString(), datetime: day, weight: 0));
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: themeColor, width: 2),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        alignment: Alignment.topLeft,
                        padding: const EdgeInsets.fromLTRB(2, 0, 0, 0),
                        child: Text(
                          day.day.toString(),
                          style: const TextStyle(
                              color: Colors.black45,
                              fontSize: 12,
                              fontWeight: FontWeight.w600),
                        ),
                      ),
                      Container(
                          alignment: Alignment.center,
                          child: Text(
                            weight.weight == 0 ? '' : weight.weight.toString(),
                            style: const TextStyle(
                              color: Colors.black54,
                            ),
                          )),
                    ],
                  ),
                );
              },
            ),

            // 日にち選択時の状態保持
            onDaySelected: (selectedDay, focusedDay) {
              selectedDay = DateTime.parse(
                  DateTime(selectedDay.year, selectedDay.month, selectedDay.day)
                      .toString());
              weightList =
                  objectBox.getWeight(selectedDay: selectedDay.toString());
              diaryList =
                  objectBox.getDiary(selectedDay: selectedDay.toString());

              setState(() {
                _currentDay = selectedDay;
                _focusedDay = selectedDay;

                // 先月の体重取得
                _lastMonth = DateTime.parse(DateTime(_focusedDay.year,
                        _focusedDay.month - 1, _focusedDay.day)
                    .toString());
                lastMonthWeightList =
                    objectBox.getWeight(selectedDay: _lastMonth.toString());
                if (lastMonthWeightList.isNotEmpty) {
                  lastMonthWeight =
                      lastMonthWeightList.first.weight.toStringAsFixed(2);
                }
                // 去年の体重取得
                _lastYear = DateTime.parse(DateTime(_focusedDay.year - 1,
                        _focusedDay.month, _focusedDay.day)
                    .toString());
                lastYearWeightList =
                    objectBox.getWeight(selectedDay: _lastYear.toString());
                if (lastYearWeightList.isNotEmpty) {
                  lastYearWeight =
                      lastYearWeightList.first.weight.toStringAsFixed(2);
                }

                if (weightList.isNotEmpty) {
                  todayWeight = weightList.first.weight.toStringAsFixed(2);
                  if (todayWeight.isNotEmpty && todayWeight != '00.0') {
                    bmi = myHeight == 0
                        ? 0.0
                        : double.parse(todayWeight) /
                            ((myHeight / 100) * (myHeight / 100));
                    bmi = double.parse(bmi.toStringAsFixed(1));
                    untilTarget = double.parse(
                        (targetWeight - double.parse(todayWeight))
                            .toStringAsFixed(2));
                  } else {
                    todayWeight = '00.0';
                    bmi = 0.0;
                    untilTarget = 0.0;
                  }
                } else {
                  todayWeight = '00.0';
                  bmi = 0.0;
                  untilTarget = 0.0;
                }

                if (diaryList.isNotEmpty) {
                  todayDiary = diaryList.first.content.toString();
                } else {
                  todayDiary = unWritingDiary;
                }
                if (todayDiary.isEmpty) {
                  todayDiary = unWritingDiary;
                }
              });
            },

            // カレンダーヘッダースタイル
            headerStyle: const HeaderStyle(
              formatButtonVisible: false,
              titleCentered: true,
            )),

        // 選択日付表示部分
        Container(
          height: 25,
          alignment: Alignment.topLeft,
          padding: const EdgeInsets.fromLTRB(5, 2, 0, 2),
          // color: const Color.fromARGB(255, 221, 206, 197),
          color: themeColor.withOpacity(0.4),
          child: Text(
            '${_focusedDay.year}年${_focusedDay.month}月${_focusedDay.day}日',
            style: const TextStyle(color: Colors.black54, fontSize: 15),
          ),
        ),
        Container(
          width: MediaQuery.sizeOf(context).width,
          padding: const EdgeInsets.fromLTRB(10, 10, 10, 5),
          decoration: const BoxDecoration(
            color: Color(0xFFF5F5F5),
          ),
          child: ScrollAnimation(
            child: Text(
              '$scrollMessage     今月の平均：${averageWeight.toStringAsFixed(2)}kg     1ヶ月前：${lastMonthWeight}kg     1年前：${lastYearWeight}kg',
              style: const TextStyle(fontSize: 15, color: Colors.black54),
            ),
          ),
        ),
        Container(
          decoration: const BoxDecoration(
            color: Color(0xFFF5F5F5),
          ),
          child: Container(
            margin: const EdgeInsets.fromLTRB(10, 10, 10, 200),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              boxShadow: const [
                BoxShadow(
                  color: Color.fromRGBO(238, 238, 238, 1),
                  spreadRadius: 1,
                  blurRadius: 5,
                  offset: Offset(1, 1),
                ),
              ],
            ),
            child: Column(
              children: [
                // 体重入力部分
                GestureDetector(
                  onTap: () async {
                    await DialogUtils.showEditingDialog(
                        context, todayWeight, _focusedDay);
                    setState(() {
                      allWeightList = objectBox.getAllWeight();
                      weightList = objectBox.getWeight(
                          selectedDay: _focusedDay.toString());
                      if (weightList.isNotEmpty) {
                        todayWeight =
                            weightList.first.weight.toStringAsFixed(2);
                      } else {
                        todayWeight = '00.0';
                      }
                      if (todayWeight.isNotEmpty && todayWeight != '00.0') {
                        bmi = myHeight == 0
                            ? 0.0
                            : double.parse(todayWeight) /
                                ((myHeight / 100) * (myHeight / 100));
                        bmi = double.parse(bmi.toStringAsFixed(1));
                        untilTarget = double.parse(
                            (targetWeight - double.parse(todayWeight))
                                .toStringAsFixed(2));
                      }
                    });
                  },
                  behavior: HitTestBehavior.opaque,
                  child: Container(
                      padding: const EdgeInsets.all(10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.fromLTRB(20, 5, 0, 0),
                            child: Column(
                              children: [
                                const Text(
                                  '今日の体重',
                                  style: TextStyle(
                                      fontSize: 12, color: Colors.black54),
                                ),
                                Text(
                                  '$todayWeight kg',
                                  style: const TextStyle(
                                      fontSize: 30, color: Colors.black54),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            margin: const EdgeInsets.fromLTRB(0, 10, 0, 0),
                            child: Row(
                              children: [
                                Column(children: [
                                  Container(
                                    margin:
                                        const EdgeInsets.fromLTRB(0, 0, 5, 5),
                                    width: 70,
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(5),
                                      color: themeColor.withOpacity(0.7),
                                    ),
                                    child: const Text(
                                      'BMI',
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 13),
                                    ),
                                  ),
                                  Container(
                                    margin:
                                        const EdgeInsets.fromLTRB(0, 0, 5, 5),
                                    width: 70,
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(5),
                                      color: themeColor.withOpacity(0.7),
                                    ),
                                    child: const Text(
                                      '目標まで',
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 13),
                                    ),
                                  ),
                                ]),
                                Column(
                                  children: [
                                    Container(
                                      margin:
                                          const EdgeInsets.fromLTRB(0, 0, 5, 5),
                                      child: Text(
                                        '$bmi',
                                        style: const TextStyle(
                                            color: Colors.black54),
                                      ),
                                    ),
                                    Container(
                                      margin:
                                          const EdgeInsets.fromLTRB(0, 0, 5, 5),
                                      child: Text(
                                        '$untilTarget kg',
                                        style: const TextStyle(
                                            color: Colors.black54),
                                      ),
                                    )
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const Icon(
                            Icons.chevron_right,
                            color: Colors.black38,
                          )
                        ],
                      )),
                ),
                Container(
                    child: const Divider(
                  indent: 10,
                  endIndent: 10,
                  thickness: 1,
                )),
                GestureDetector(
                  onTap: () async {
                    await Navigator.of(context)
                        .push(MaterialPageRoute(builder: (context) {
                      return DiaryWritingPage(
                          focusedDay: DateTime.parse(_focusedDay.toString()));
                    }));
                    setState(() {
                      diaryList = objectBox.getDiary(
                          selectedDay: _focusedDay.toString());
                      if (diaryList.isNotEmpty) {
                        todayDiary = diaryList.first.content.toString();
                      }
                    });
                  },
                  behavior: HitTestBehavior.opaque,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        flex: 7,
                        child: Container(
                          height: 100,
                          padding: const EdgeInsets.all(10),
                          margin: const EdgeInsets.fromLTRB(10, 0, 0, 0),
                          child: Text(
                            todayDiary,
                            style: const TextStyle(
                                color: Colors.black54,
                                letterSpacing: 1,
                                fontSize: 15),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 3,
                          ),
                        ),
                      ),
                      const Expanded(
                        flex: 1,
                        child: Icon(
                          Icons.chevron_right,
                          color: Colors.black38,
                        ),
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ])),
    );
  }
}

// ---------------------------
// 体重入力クラス
// ---------------------------
class DialogUtils {
  DialogUtils._();

  static Future<void> showOnlyTitleDialog(
    BuildContext context,
    String title,
  ) async {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
        );
      },
    );
  }

  /// 入力した文字列を返すダイアログを表示する
  static Future<String?> showEditingDialog(
      BuildContext context, String weight, DateTime focusedDay) async {
    return showDialog<String>(
      context: context,
      builder: (context) {
        return TextEditingDialog(weight: weight, focusedDay: focusedDay);
      },
    );
  }
}

class TextEditingDialog extends ConsumerStatefulWidget {
  const TextEditingDialog(
      {super.key, required this.weight, required this.focusedDay});
  final String weight;
  final DateTime focusedDay;

  @override
  _TextEditingDialogState createState() => _TextEditingDialogState();
}

class _TextEditingDialogState extends ConsumerState<TextEditingDialog> {
  final controller = TextEditingController();
  final focusNode = FocusNode();
  final InAppReview inAppReview = InAppReview.instance;

  Color themeColor = Colors.blue;

  String randomMessage = '';
  final List<String> weightMessages = [
    '今日も測定してえらいです！',
    '今日も体重測ってえらいです！',
    '体重管理ステキですね！',
    '体重管理がんばってますね！',
    '今日も体重計に乗りましたね！',
    '体重測る努力偉いです！',
    '体重測るの頑張ってますね。',
    '体重チェック頑張りました！',
    '体重計も喜んでますね！',
    '体重測定よく頑張りました！',
    '努力は必ず報われます！',
    '体重測定したあなたに拍手！',
    '体重測定、素敵な習慣ですね。',
    'マイペースに行きましょうね！',
    'コツコツとやっていきましょう！',
    '体重管理するあなたはすでにステキですよ！',
    'Congulatulation!今日も頑張りました。',
    'Good Luck!体重管理ステキですね。',
    '体重管理、立派です！',
    '体重測るあなた、ステキな人です。',
  ];

  String getWeightMessage() {
    final random = Random();
    final index = random.nextInt(weightMessages.length);
    return randomMessage = weightMessages[index];
  }

  Future<void> requestReview() async {
    // isAvailableは、iOS 10.3以降, Android 5.2以降&&Google Play Storeがinstallされている場合にtrueを返す
    // SeeAlso: https://pub.dev/packages/in_app_review
    if (await inAppReview.isAvailable()) {
      inAppReview.requestReview();
    }
  }

  @override
  void dispose() {
    controller.dispose();
    focusNode.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    // TextFormFieldに初期値を代入する
    controller.text = widget.weight;
    focusNode.addListener(
      () {
        // フォーカスが当たったときに文字列が選択された状態にする
        if (focusNode.hasFocus) {
          controller.selection = TextSelection(
              baseOffset: 0, extentOffset: controller.text.length);
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
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
    return AlertDialog(
      backgroundColor: Colors.white,
      title: Text(getWeightMessage(),
          style: const TextStyle(
            fontSize: 18,
          )),
      content: TextFormField(
        autofocus: true,
        controller: controller,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.white,
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: themeColor), // フォーカス時の下線のカラー
          ),
        ),
        inputFormatters: [
          FilteringTextInputFormatter.allow(
              RegExp(r'^[1-9]+[0-9]*(\.([0-9]*|[0-9]+))?$'))
        ],
        onFieldSubmitted: (_) {
          // エンターを押したときに実行される
          if (controller.text.isNotEmpty) {
            objectBox.addWeight(
                focusedDay: widget.focusedDay.toString(),
                weight: double.parse(
                    double.parse(controller.text).toStringAsFixed(2)),
                datetime: widget.focusedDay);
          }
          Navigator.of(context).pop(controller.text);
        },
      ),
      actions: [
        TextButton(
          onPressed: () async {
            if (controller.text.isNotEmpty) {
              objectBox.addWeight(
                  focusedDay: widget.focusedDay.toString(),
                  weight: double.parse(
                      double.parse(controller.text).toStringAsFixed(2)),
                  datetime: widget.focusedDay);
            }
            List<Weight> monthWeights = objectBox.getWeights(
                months: 1,
                datetime: DateTime.parse(
                    DateTime(DateTime.now().year, DateTime.now().month, 1)
                        .toString()));
            Navigator.of(context).pop(controller.text);
            if (monthWeights.length == 2) {
              showCupertinoDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return CupertinoAlertDialog(
                      // title: Text('定期的な使い心地調査にご協力ください'),
                      content: const Text(
                          'いつも日記と体重をご利用いただきありがとうございます。定期的な使い心地調査にご協力お願いいたします。アプリの使い心地はいかがですか？'),
                      actions: <Widget>[
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                            showCupertinoDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return CupertinoAlertDialog(
                                    content: const Text(
                                        '評価ありがとうございます。改善に役立てさせていただきます。不具合、ご意見等ありましたら、「お問い合わせ」よりご連絡お願いいたします。'),
                                    actions: <Widget>[
                                      TextButton(
                                        onPressed: () {
                                          Navigator.pop(context);
                                        },
                                        child: const Text(
                                          '閉じる',
                                          style: TextStyle(color: Colors.blue),
                                        ),
                                      ),
                                    ],
                                  );
                                });
                          },
                          child: const Text(
                            'う〜ん',
                            style: TextStyle(color: Colors.blue),
                          ),
                        ),
                        TextButton(
                          onPressed: () async {
                            Navigator.pop(context);
                            await requestReview();
                            sleep(const Duration(seconds: 1));
                            showCupertinoDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return CupertinoAlertDialog(
                                    content: const Text(
                                        '評価ありがとうございます。改善に役立てさせていただきます。不具合、ご意見等ありましたら、「お問い合わせ」よりご連絡お願いいたします。'),
                                    actions: <Widget>[
                                      TextButton(
                                        onPressed: () {
                                          Navigator.pop(context);
                                        },
                                        child: const Text(
                                          '閉じる',
                                          style: TextStyle(color: Colors.blue),
                                        ),
                                      ),
                                    ],
                                  );
                                });
                          },
                          child: const Text('いいね！',
                              style: TextStyle(color: Colors.blue)),
                        ),
                      ],
                    );
                  });
            }
          },
          child: Text(
            '完了',
            style: TextStyle(color: themeColor, fontWeight: FontWeight.bold),
          ),
        )
      ],
    );
  }
}

class ScrollAnimation extends StatefulWidget {
  const ScrollAnimation({
    super.key,
    required this.child,
    this.startTime = 1000, // アニメーション開始までの遅延時間
    this.animateTime = 4000, // アニメーションの実行時間
    this.endTime = 2000, // アニメーション終了後の静止時間
  });

  final Widget child;
  final int startTime;
  final int animateTime;
  final int endTime;

  @override
  State<ScrollAnimation> createState() => _ScrollAnimationState();
}

class _ScrollAnimationState extends State<ScrollAnimation> {
  final _controller = ScrollController();

  late final totalTime = widget.startTime + widget.animateTime + widget.endTime;

  late final _timer = Timer.periodic(
    Duration(milliseconds: totalTime),
    (_) => _startAnimation(),
  );

  Future<void> _startAnimation() async {
    await Future.delayed(Duration(milliseconds: widget.startTime));
    return _controller.animateTo(
      _controller.position.maxScrollExtent,
      duration: Duration(milliseconds: widget.animateTime),
      curve: Curves.linear,
    );
  }

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      final position = _controller.position;
      if (position.maxScrollExtent == position.pixels) {
        Future.delayed(Duration(milliseconds: widget.endTime)).then((_) {
          _controller.jumpTo(0);
        });
      }
    });

    _startAnimation().then((_) {
      _timer;
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      controller: _controller,
      scrollDirection: Axis.horizontal,
      child: widget.child,
    );
  }
}
