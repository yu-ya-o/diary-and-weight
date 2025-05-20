import 'dart:io';

import 'package:disiry_weight_mng/entity/bodyFatRate.dart';
import 'package:disiry_weight_mng/main.dart';
import 'package:disiry_weight_mng/pages/weight-writing-page.dart';
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
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_native_timezone/flutter_native_timezone.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

class CalendarPage extends ConsumerStatefulWidget {
  const CalendarPage({super.key});

  @override
  _CalendarPageState createState() => _CalendarPageState();
}

class _CalendarPageState extends ConsumerState<CalendarPage> {
  // ----------
  // 定数定義
  // ----------
  final String defaultDiaryMessage = '今日は何した？何食べた？';

  // ----------
  // 変数定義
  // ----------
  double myHeight = 00.00; // 身長
  double bmi = 00.00; // BMI
  double targetWeight = 00.00; // 目標体重
  double untilTarget = 00.00; // 目標差

  Color themeColor = Colors.blue; // 初期テーマカラー
  int countConsecutiveDates = 0; // 継続日数

  String todayWeight = ''; // 選択日の体重
  String lastMonthWeight = ''; // 先月の体重
  String lastYearWeight = ''; // 去年の体重
  String todayBodyFatRate = ''; // 選択日の体脂肪率
  String todayDiary = ''; // 選択日の日記

  List<Weight> weightList = List.empty(); // 選択日の体重リスト
  List<Weight> lastMonthWeightList = List.empty(); // 先月の体重リスト
  List<Weight> lastYearWeightList = List.empty(); // 去年の体重リスト
  List<Weight> allWeightList = List.empty(); // 全ての体重リスト
  List<BodyFatRate> bodyFatRateList = List.empty(); // 選択日の体脂肪率リスト
  List<Diary> diaryList = List.empty(); // 日記リスト

  // 今日の日付
  DateTime _currentDay = DateTime.parse(
      DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day)
          .toString());

  // 選択されている日付
  DateTime _focusedDay = DateTime.parse(
      DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day)
          .toString());

  // 1ヶ月前の日付
  DateTime _lastMonth = DateTime.parse(DateTime(
          DateTime.now().year, DateTime.now().month - 1, DateTime.now().day)
      .toString());

  // 1年前の日付
  DateTime _lastYear = DateTime.parse(DateTime(
          DateTime.now().year - 1, DateTime.now().month, DateTime.now().day)
      .toString());

  // 平均体重表示用
  List<Weight> weightsData = [];
  double averageWeight = 00.00;
  double sumWeight = 00.00;

  // ----------
  // 通知設定
  // ----------
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  // 通知の初期化
  Future<void> _initializeNotifications() async {
    const DarwinInitializationSettings initializationSettingsDarwin =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    const InitializationSettings initializationSettings =
        InitializationSettings(
      iOS: initializationSettingsDarwin,
    );
    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  // 通知の追加
  Future<void> _addNotification() async {
    // ①設定されている全ての通知を削除
    await flutterLocalNotificationsPlugin.cancelAll();

    // Local TimeZone
    String timeZoneName = await FlutterNativeTimezone.getLocalTimezone();
    final location = tz.getLocation(timeZoneName);

    // ②設定時刻(デフォルト20時)
    tz.TZDateTime scheduledTime = tz.TZDateTime.from(
        DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day,
            20, 0),
        location);

    // ③2週間分の通知を設定する
    int noticeDays = 14;

    // 通知タイトル
    const String title = '日記と体重';
    String message = 'お疲れ様です！今日もちょこっとだけ日記と体重を記録しませんか？';

    // ⑤通知を追加する
    for (int i = 0; i < noticeDays; i++) {
      if (i != 0) {
        scheduledTime = scheduledTime.add(const Duration(days: 1));
      } else if (i == 0) {
        if (weightList.isNotEmpty) {
          // 既に入力済みであればスキップ
          continue;
        }

        if (countConsecutiveDates != 0) {
          // 継続中であれば今日の通知メッセージを変更
          message = '体重測定、$countConsecutiveDates日連続継続中！今日も日記と体重を記録しませんか？';
        }
      } else if (i == 1) {
        if (weightList.isNotEmpty) {
          // 継続中かつ今日の体重が入力済みであれば明日の通知メッセージを変更
          message = '体重測定、$countConsecutiveDates日連続継続中！今日も日記と体重を記録しませんか？';
        }
      }
      flutterLocalNotificationsPlugin.zonedSchedule(
        i,
        title,
        message,
        scheduledTime,
        const NotificationDetails(
          iOS: DarwinNotificationDetails(),
        ),
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
    }
  }

  Future<void> _initializeAndScheduleNotifications() async {
    await _initializeNotifications();
    await _addNotification();
  }

  // リロード
  void pushWithReloadByWeightWriting(
      BuildContext context, String weight, String bodyFatRate) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute<bool>(
        builder: (BuildContext context) => WeightWritingPage(
            weight: weight,
            bodyFatRate: bodyFatRate,
            focusedDay: DateTime.parse(_focusedDay.toString())),
      ),
    );

    if (result == true) {
      setState(() {
        if (weightList.isNotEmpty) {
          // 今日の体重が存在する場合
          todayWeight = weightList.first.weight.toStringAsFixed(2);
          if (todayWeight.isNotEmpty && todayWeight != '00.00') {
            // 00.00kgではない場合
            bmi = myHeight == 0
                ? 00.00
                : double.parse(todayWeight) /
                    ((myHeight / 100) * (myHeight / 100));
            bmi = double.parse(bmi.toStringAsFixed(1));
            untilTarget = double.parse(
                (targetWeight - double.parse(todayWeight)).toStringAsFixed(2));
          } else {
            // 00.00kgの場合
            todayWeight = '00.00';
            bmi = 00.00;
            untilTarget = 00.00;
          }
        } else {
          // 今日の体重が存在しない場合
          todayWeight = '00.00';
          bmi = 00.00;
          untilTarget = 00.00;
        }

        if (bodyFatRateList.isNotEmpty) {
          // 今日の体脂肪率が存在する場合
          todayBodyFatRate =
              bodyFatRateList.first.bodyFatRate.toStringAsFixed(2);
          if (todayBodyFatRate.isNotEmpty && todayBodyFatRate == '00.00') {
            // 00.00%の場合
            todayBodyFatRate = '00.00';
          }
        } else {
          // 今日の体重が存在しない場合
          todayBodyFatRate = '00.00';
        }

        if (diaryList.isNotEmpty) {
          // 今日の日記が存在する場合
          todayDiary = diaryList.first.content.toString();
        } else {
          // 今日の日記が存在しない場合、メッセージ表示
          todayDiary = defaultDiaryMessage;
        }
        if (todayDiary.isEmpty) {
          // 今日の日記が存在しない場合、メッセージ表示
          todayDiary = defaultDiaryMessage;
        }
      });
    }
  }

  @override
  void initState() {
    super.initState();
    // 継続日数取得
    countConsecutiveDates = objectBox.weightRepository.countConsecutiveDates();
    // 今日の体重取得
    weightList = objectBox.weightRepository
        .getWeight(selectedDay: _focusedDay.toString());
    // 今日の体脂肪率取得
    bodyFatRateList = objectBox.bodyFatRateRepository
        .getBodyFatRate(selectedDay: _focusedDay.toString());
    // 今日の日記取得
    diaryList =
        objectBox.diaryRepository.getDiary(selectedDay: _focusedDay.toString());
    // 毎日の体重取得（カレンダー表示用）
    allWeightList = objectBox.weightRepository.getAllWeights();

    // 目標体重取得
    targetWeight = double.parse(
        double.parse(objectBox.settingRepository.getTargtWeight())
            .toStringAsFixed(2));
    // 身長取得
    myHeight = double.parse(
        double.parse(objectBox.settingRepository.getHeight())
            .toStringAsFixed(2));

    if (weightList.isNotEmpty) {
      // 今日の体重が存在する場合
      todayWeight = weightList.first.weight.toStringAsFixed(2);
      if (todayWeight.isNotEmpty && todayWeight != '00.00') {
        // 00.00kgではない場合
        bmi = myHeight == 0
            ? 00.00
            : double.parse(todayWeight) / ((myHeight / 100) * (myHeight / 100));
        bmi = double.parse(bmi.toStringAsFixed(1));
        untilTarget = double.parse(
            (targetWeight - double.parse(todayWeight)).toStringAsFixed(2));
      } else {
        // 00.00kgの場合
        todayWeight = '00.00';
        bmi = 00.00;
        untilTarget = 00.00;
      }
    } else {
      // 今日の体重が存在しない場合
      todayWeight = '00.00';
      bmi = 00.00;
      untilTarget = 00.00;
    }

    if (bodyFatRateList.isNotEmpty) {
      // 今日の体脂肪率が存在する場合
      todayBodyFatRate = bodyFatRateList.first.bodyFatRate.toStringAsFixed(2);
      if (todayBodyFatRate.isNotEmpty && todayBodyFatRate == '00.00') {
        // 00.00%の場合
        todayBodyFatRate = '00.00';
      }
    } else {
      // 今日の体重が存在しない場合
      todayBodyFatRate = '00.00';
    }

    if (diaryList.isNotEmpty) {
      // 今日の日記が存在する場合
      todayDiary = diaryList.first.content.toString();
    } else {
      // 今日の日記が存在しない場合、メッセージ表示
      todayDiary = defaultDiaryMessage;
    }
    if (todayDiary.isEmpty) {
      // 今日の日記が存在しない場合、メッセージ表示
      todayDiary = defaultDiaryMessage;
    }

    // 通知追加
    tz.initializeTimeZones();
    _initializeAndScheduleNotifications();
  }

  @override
  Widget build(BuildContext context) {
    // 今日の体重取得
    weightList = objectBox.weightRepository
        .getWeight(selectedDay: _focusedDay.toString());
    // 今日の体脂肪率取得
    bodyFatRateList = objectBox.bodyFatRateRepository
        .getBodyFatRate(selectedDay: _focusedDay.toString());
    // 今日の日記取得
    diaryList =
        objectBox.diaryRepository.getDiary(selectedDay: _focusedDay.toString());
    // 先月の体重取得
    _lastMonth = DateTime.parse(
        DateTime(_focusedDay.year, _focusedDay.month - 1, _focusedDay.day)
            .toString());
    lastMonthWeightList = objectBox.weightRepository
        .getWeight(selectedDay: _lastMonth.toString());
    if (lastMonthWeightList.isNotEmpty) {
      lastMonthWeight = lastMonthWeightList.first.weight.toStringAsFixed(2);
    } else {
      lastMonthWeight = '00.00';
    }
    // 去年の体重取得
    _lastYear = DateTime.parse(
        DateTime(_focusedDay.year - 1, _focusedDay.month, _focusedDay.day)
            .toString());
    lastYearWeightList =
        objectBox.weightRepository.getWeight(selectedDay: _lastYear.toString());
    if (lastYearWeightList.isNotEmpty) {
      lastYearWeight = lastYearWeightList.first.weight.toStringAsFixed(2);
    } else {
      lastYearWeight = '00.00';
    }
    // 毎日の体重取得（カレンダー表示用）
    allWeightList = objectBox.weightRepository.getAllWeights();

    // 平均体重
    weightsData = objectBox.weightRepository.getWeights(
        months: 1,
        datetime: DateTime.parse(
            DateTime(_focusedDay.year, _focusedDay.month, 1).toString()));
    sumWeight = 00.00;
    for (Weight weight in weightsData) {
      sumWeight += weight.weight;
    }
    if (sumWeight != 00.00) {
      averageWeight = sumWeight / weightsData.length;
    } else {
      averageWeight = 00.00;
    }

    // 目標体重取得
    targetWeight = double.parse(
        double.parse(objectBox.settingRepository.getTargtWeight())
            .toStringAsFixed(2));
    // 身長取得
    myHeight = double.parse(
        double.parse(objectBox.settingRepository.getHeight())
            .toStringAsFixed(2));

    if (weightList.isNotEmpty) {
      // 今日の体重が存在する場合
      todayWeight = weightList.first.weight.toStringAsFixed(2);
      if (todayWeight.isNotEmpty && todayWeight != '00.00') {
        // 00.00kgではない場合
        bmi = myHeight == 0
            ? 00.00
            : double.parse(todayWeight) / ((myHeight / 100) * (myHeight / 100));
        bmi = double.parse(bmi.toStringAsFixed(1));
        untilTarget = double.parse(
            (targetWeight - double.parse(todayWeight)).toStringAsFixed(2));
      } else {
        // 00.00kgの場合
        todayWeight = '00.00';
        bmi = 00.00;
        untilTarget = 00.00;
      }
    } else {
      // 今日の体重が存在しない場合
      todayWeight = '00.00';
      bmi = 00.00;
      untilTarget = 00.00;
    }

    if (bodyFatRateList.isNotEmpty) {
      // 今日の体脂肪率が存在する場合
      todayBodyFatRate = bodyFatRateList.first.bodyFatRate.toStringAsFixed(2);
      if (todayBodyFatRate.isNotEmpty && todayBodyFatRate == '00.00') {
        // 00.00%の場合
        todayBodyFatRate = '00.00';
      }
    } else {
      // 今日の体重が存在しない場合
      todayBodyFatRate = '00.00';
    }

    if (diaryList.isNotEmpty) {
      // 今日の日記が存在する場合
      todayDiary = diaryList.first.content.toString();
    } else {
      // 今日の日記が存在しない場合、メッセージ表示
      todayDiary = defaultDiaryMessage;
    }
    if (todayDiary.isEmpty) {
      // 今日の日記が存在しない場合、メッセージ表示
      todayDiary = defaultDiaryMessage;
    }

    // テーマカラーのプロバイダーを監視
    themeColor = ref.watch(themeColorProvider);
    var themeColorString = objectBox.settingRepository.getThemeColor();

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
        toolbarHeight: 20, // 高さを少し調整
        backgroundColor: Colors.white,
        title: Align(
          alignment: Alignment.centerLeft, // 左寄せ
          child: Row(
            children: [
              Icon(
                Icons.tips_and_updates_outlined,
                color: themeColor,
              ),
              const Padding(padding: EdgeInsets.only(right: 5)),
              Text(
                '$countConsecutiveDates日連続継続中',
                style: const TextStyle(color: Colors.black54, fontSize: 15),
              ),
            ],
          ),
        ),
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
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
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
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
                                    if (selectedDate.year ==
                                            DateTime.now().year &&
                                        selectedDate.month ==
                                            DateTime.now().month) {
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
                              '${day.month}月',
                              style: const TextStyle(
                                  color: Colors.black54, fontSize: 18),
                            ),
                            if (day.month == 12)
                              const Text(
                                '🎅🎄',
                                style: TextStyle(fontSize: 22),
                              ),
                          ],
                        )
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
                          // color: Colors.white,
                          color: themeColor.withOpacity(0.3),
                          border: Border.all(
                            color: const Color.fromARGB(255, 230, 223, 223),
                            width: 0.5,
                          )),
                      alignment: Alignment.topCenter,
                      child: Center(
                        child: Text(
                          dowText.toString(),
                          style: const TextStyle(color: Colors.black26),
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
                        orElse: () => Weight(
                            date: day.toString(), datetime: day, weight: 0));
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
                                weight.weight == 0
                                    ? ''
                                    : weight.weight.toString(),
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
                        orElse: () => Weight(
                            date: day.toString(), datetime: day, weight: 0));
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
                                weight.weight == 0
                                    ? ''
                                    : weight.weight.toString(),
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
                  selectedDay = DateTime.parse(DateTime(
                          selectedDay.year, selectedDay.month, selectedDay.day)
                      .toString());
                  weightList = objectBox.weightRepository
                      .getWeight(selectedDay: selectedDay.toString());
                  bodyFatRateList = objectBox.bodyFatRateRepository
                      .getBodyFatRate(selectedDay: _focusedDay.toString());
                  diaryList = objectBox.diaryRepository
                      .getDiary(selectedDay: selectedDay.toString());

                  setState(() {
                    _currentDay = selectedDay;
                    _focusedDay = selectedDay;

                    // 先月の体重取得
                    _lastMonth = DateTime.parse(DateTime(_focusedDay.year,
                            _focusedDay.month - 1, _focusedDay.day)
                        .toString());
                    lastMonthWeightList = objectBox.weightRepository
                        .getWeight(selectedDay: _lastMonth.toString());
                    if (lastMonthWeightList.isNotEmpty) {
                      lastMonthWeight =
                          lastMonthWeightList.first.weight.toStringAsFixed(2);
                    }
                    // 去年の体重取得
                    _lastYear = DateTime.parse(DateTime(_focusedDay.year - 1,
                            _focusedDay.month, _focusedDay.day)
                        .toString());
                    lastYearWeightList = objectBox.weightRepository
                        .getWeight(selectedDay: _lastYear.toString());
                    if (lastYearWeightList.isNotEmpty) {
                      lastYearWeight =
                          lastYearWeightList.first.weight.toStringAsFixed(2);
                    }

                    if (weightList.isNotEmpty) {
                      todayWeight = weightList.first.weight.toStringAsFixed(2);
                      if (todayWeight.isNotEmpty && todayWeight != '00.00') {
                        bmi = myHeight == 0
                            ? 00.00
                            : double.parse(todayWeight) /
                                ((myHeight / 100) * (myHeight / 100));
                        bmi = double.parse(bmi.toStringAsFixed(1));
                        untilTarget = double.parse(
                            (targetWeight - double.parse(todayWeight))
                                .toStringAsFixed(2));
                      } else {
                        todayWeight = '00.00';
                        bmi = 00.00;
                        untilTarget = 00.00;
                      }
                    } else {
                      todayWeight = '00.00';
                      bmi = 00.00;
                      untilTarget = 00.00;
                    }

                    if (bodyFatRateList.isNotEmpty) {
                      // 今日の体脂肪率が存在する場合
                      todayBodyFatRate =
                          bodyFatRateList.first.bodyFatRate.toStringAsFixed(2);
                      if (todayBodyFatRate.isNotEmpty &&
                          todayBodyFatRate == '00.00') {
                        // 00.00%の場合
                        todayBodyFatRate = '00.00';
                      }
                    } else {
                      // 今日の体重が存在しない場合
                      todayBodyFatRate = '00.00';
                    }

                    if (diaryList.isNotEmpty) {
                      todayDiary = diaryList.first.content.toString();
                    } else {
                      todayDiary = defaultDiaryMessage;
                    }
                    if (todayDiary.isEmpty) {
                      todayDiary = defaultDiaryMessage;
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
              padding: const EdgeInsets.fromLTRB(10, 2, 0, 2),
              // color: const Color.fromARGB(255, 221, 206, 197),
              color: themeColor.withOpacity(0.3),
              child: Text(
                '${_focusedDay.year}年${_focusedDay.month}月${_focusedDay.day}日',
                style: const TextStyle(color: Colors.black26, fontSize: 15),
              ),
            ),
            Container(
              decoration: const BoxDecoration(
                color: Color(0xFFF5F5F5),
              ),
              child: Container(
                margin: const EdgeInsets.fromLTRB(20, 20, 20, 10),
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
                        pushWithReloadByWeightWriting(
                            context, todayWeight, todayBodyFatRate);
                        // await DialogUtils.showEditingDialog(
                        //     context, todayWeight, _focusedDay);
                        setState(() {
                          // 継続日数を取得
                          countConsecutiveDates = objectBox.weightRepository
                              .countConsecutiveDates();
                          // 全ての体重を取得
                          allWeightList =
                              objectBox.weightRepository.getAllWeights();
                          // 今日の体重を取得
                          weightList = objectBox.weightRepository
                              .getWeight(selectedDay: _focusedDay.toString());
                          if (weightList.isNotEmpty) {
                            todayWeight =
                                weightList.first.weight.toStringAsFixed(2);
                          } else {
                            todayWeight = '00.00';
                          }
                          if (todayWeight.isNotEmpty &&
                              todayWeight != '00.00') {
                            bmi = myHeight == 0
                                ? 00.00
                                : double.parse(todayWeight) /
                                    ((myHeight / 100) * (myHeight / 100));
                            bmi = double.parse(bmi.toStringAsFixed(1));
                            untilTarget = double.parse(
                                (targetWeight - double.parse(todayWeight))
                                    .toStringAsFixed(2));
                          }
                          // 通知追加
                          tz.initializeTimeZones();
                          _initializeAndScheduleNotifications();
                        });
                      },
                      behavior: HitTestBehavior.opaque,
                      child: Container(
                        padding: const EdgeInsets.fromLTRB(10, 10, 0, 0),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                Container(
                                  padding:
                                      const EdgeInsets.fromLTRB(20, 0, 0, 0),
                                  child: Column(
                                    children: [
                                      const Text(
                                        '今日の体重',
                                        style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.black54),
                                      ),
                                      Text(
                                        '$todayWeight kg',
                                        style: const TextStyle(
                                            fontSize: 30,
                                            color: Colors.black54),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  margin:
                                      const EdgeInsets.fromLTRB(0, 10, 0, 0),
                                  child: Row(
                                    children: [
                                      Column(children: [
                                        Container(
                                          margin: const EdgeInsets.fromLTRB(
                                              0, 0, 5, 5),
                                          width: 70,
                                          alignment: Alignment.center,
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(5),
                                            color: themeColor.withOpacity(0.4),
                                          ),
                                          child: const Text(
                                            'BMI',
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 13),
                                          ),
                                        ),
                                        Container(
                                          margin: const EdgeInsets.fromLTRB(
                                              0, 0, 5, 5),
                                          width: 70,
                                          alignment: Alignment.center,
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(5),
                                            color: themeColor.withOpacity(0.4),
                                          ),
                                          child: const Text(
                                            '目標まで',
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 13),
                                          ),
                                        ),
                                        Container(
                                          margin: const EdgeInsets.fromLTRB(
                                              0, 0, 5, 5),
                                          width: 70,
                                          alignment: Alignment.center,
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(5),
                                            color: themeColor.withOpacity(0.4),
                                          ),
                                          child: const Text(
                                            '体脂肪率',
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 13),
                                          ),
                                        ),
                                      ]),
                                      Column(
                                        children: [
                                          Container(
                                            margin: const EdgeInsets.fromLTRB(
                                                0, 0, 5, 5),
                                            child: Text(
                                              '$bmi',
                                              style: const TextStyle(
                                                  color: Colors.black54),
                                            ),
                                          ),
                                          Container(
                                            margin: const EdgeInsets.fromLTRB(
                                                0, 0, 5, 5),
                                            child: Text(
                                              '$untilTarget kg',
                                              style: const TextStyle(
                                                  color: Colors.black54),
                                            ),
                                          ),
                                          Container(
                                            margin: const EdgeInsets.fromLTRB(
                                                0, 0, 5, 5),
                                            child: Text(
                                              '$todayBodyFatRate %',
                                              style: const TextStyle(
                                                  color: Colors.black54),
                                            ),
                                          )
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                    alignment: Alignment.centerRight,
                                    child: const Icon(
                                      Icons.chevron_right,
                                      color: Colors.black38,
                                    ))
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const Divider(
                      indent: 10,
                      endIndent: 10,
                      thickness: 0.5,
                      color: Color.fromRGBO(238, 238, 238, 1),
                    ),
                    GestureDetector(
                      onTap: () async {
                        // カレンダー画面からの日記入力を無効化
                        // pushWithReloadByDiaryWriting(context);
                        // setState(() {
                        //   diaryList = objectBox.getDiary(
                        //       selectedDay: _focusedDay.toString());
                        //   if (diaryList.isNotEmpty) {
                        //     todayDiary = diaryList.first.content.toString();
                        //   }
                        // });
                      },
                      behavior: HitTestBehavior.opaque,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Expanded(
                            flex: 7,
                            child: Container(
                              height: 100,
                              padding:
                                  const EdgeInsets.fromLTRB(10, 10, 10, 10),
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
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Container(
              decoration: const BoxDecoration(
                color: Color(0xFFF5F5F5),
              ),
              child: Container(
                padding: const EdgeInsets.fromLTRB(0, 5, 0, 5),
                margin: const EdgeInsets.fromLTRB(20, 0, 20, 200),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: const [
                    BoxShadow(
                      color: Color.fromRGBO(238, 238, 238, 1),
                      spreadRadius: 1,
                      blurRadius: 5,
                      offset: Offset(1, 1),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Container(),
                    Column(
                      children: [
                        const Text(
                          '今月の平均',
                          style: TextStyle(fontSize: 11, color: Colors.black54),
                        ),
                        Text(
                          '${averageWeight.toStringAsFixed(2)}kg',
                          style: const TextStyle(
                              fontSize: 13, color: Colors.black54),
                        )
                      ],
                    ),
                    const SizedBox(
                        height: 20,
                        child: VerticalDivider(
                            thickness: 0.5, color: Colors.grey)),
                    Column(
                      children: [
                        const Text(
                          '先月の体重',
                          style: TextStyle(fontSize: 11, color: Colors.black54),
                        ),
                        Text(
                          '${lastMonthWeight}kg',
                          style: const TextStyle(
                              fontSize: 13, color: Colors.black54),
                        )
                      ],
                    ),
                    const SizedBox(
                        height: 20,
                        child: VerticalDivider(
                            thickness: 0.5, color: Colors.grey)),
                    Column(
                      children: [
                        const Text(
                          '去年の体重',
                          style: TextStyle(fontSize: 11, color: Colors.black54),
                        ),
                        Text(
                          '${lastYearWeight}kg',
                          style: const TextStyle(
                              fontSize: 13, color: Colors.black54),
                        )
                      ],
                    ),
                    Container(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
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
    if (widget.weight == '00.00') {
      controller.text = '';
    } else {
      controller.text = widget.weight;
    }
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
    var themeColorString = objectBox.settingRepository.getThemeColor();

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
            objectBox.weightRepository.addWeight(
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
              objectBox.weightRepository.addWeight(
                  focusedDay: widget.focusedDay.toString(),
                  weight: double.parse(
                      double.parse(controller.text).toStringAsFixed(2)),
                  datetime: widget.focusedDay);
            }
            List<Weight> monthWeights = objectBox.weightRepository.getWeights(
                months: 1,
                datetime: DateTime.parse(
                    DateTime(DateTime.now().year, DateTime.now().month, 1)
                        .toString()));
            Navigator.of(context).pop(controller.text);
            if (monthWeights.length == 3) {
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
