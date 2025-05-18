import 'dart:io';

import 'package:disiry_weight_mng/main.dart';
import 'package:flutter/material.dart';
import '../entity/diary.dart';
import 'dart:async';
import 'package:in_app_review/in_app_review.dart';
import 'package:flutter/cupertino.dart';

class WeightWritingPage extends StatefulWidget {
  const WeightWritingPage(
      {super.key,
      required this.weight,
      required this.bodyFatRate,
      required this.focusedDay});
  final String weight;
  final String bodyFatRate;
  final DateTime focusedDay;

  @override
  _WeightWritingPageState createState() => _WeightWritingPageState();
}

class _WeightWritingPageState extends State<WeightWritingPage> {
  // 体重
  String weight = '';

  // 体脂肪率
  String bodyFatRate = '';

  // 身長
  double myHeight = 00.00;
  // BMI
  double bmi = 00.00;
  // 目標体重
  double targetWeight = 00.00;
  // 目標体重まで
  double untilTarget = 00.00;

  // 日記の内容
  String content = '';

  // TextFormFieldのフォーカスノード
  late FocusNode focusNode;

  bool onFocused = false;

  void _onFocusChange() {
    if (focusNode.hasFocus) {
      // フォーカスが当てられたときの処理
      onFocused = true;
    } else {
      // フォーカスが外れたときの処理
      onFocused = false;
    }
  }

  final InAppReview inAppReview = InAppReview.instance;

  Future<void> requestReview() async {
    if (await inAppReview.isAvailable()) {
      inAppReview.requestReview();
    }
  }

  @override
  void initState() {
    super.initState();
    // 体重の取得
    weight = widget.weight;
    // 体脂肪率の取得
    bodyFatRate = widget.bodyFatRate;
    // 目標体重取得
    targetWeight = double.parse(
        double.parse(objectBox.getTargtWeight()).toStringAsFixed(2));
    // 身長取得
    myHeight =
        double.parse(double.parse(objectBox.getHeight()).toStringAsFixed(2));
    // BMI, 目標まで
    if (weight != '00.00') {
      // 00.00kgではない場合
      bmi = myHeight == 0
          ? 00.00
          : double.parse(weight) / ((myHeight / 100) * (myHeight / 100));
      bmi = double.parse(bmi.toStringAsFixed(1));
      untilTarget = double.parse(
          (targetWeight - double.parse(weight)).toStringAsFixed(2));
    } else {
      // 00.00kgの場合
      bmi = 00.00;
      untilTarget = 00.00;
    }
    // 日記の取得
    List<Diary> diaryList =
        objectBox.getDiary(selectedDay: widget.focusedDay.toString());
    // TextFormFieldに初期値を代入する
    if (diaryList.isNotEmpty) {
      content = diaryList.first.content;
    }
    focusNode = FocusNode();
    focusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    focusNode.removeListener(_onFocusChange);
    focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        toolbarHeight: 40,
        backgroundColor: Colors.white,
        title: Text(
          '${widget.focusedDay.year}年${widget.focusedDay.month}月${widget.focusedDay.day}日',
          style: const TextStyle(color: Colors.black54, fontSize: 20),
        ),
        // 完了ボタン
        actions: [
          if (onFocused)
            TextButton(
                onPressed: () async {
                  // フォーカスを外す
                  focusNode.unfocus();

                  // 日記を保存
                  objectBox.addDiary(
                      writingDate: widget.focusedDay.toString(),
                      content: content,
                      datetime:
                          DateTime.parse(widget.focusedDay.toString()).toUtc());
                  List<Diary> diaryWeights = objectBox.getDiaryForDateTime(
                      DateTime(DateTime.now().year, DateTime.now().month, 1));
                  if (diaryWeights.length == 10) {
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
                                                style: TextStyle(
                                                    color: Colors.blue),
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
                                                style: TextStyle(
                                                    color: Colors.blue),
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
                child: const Text('完了',
                    style: TextStyle(color: Colors.grey, fontSize: 16)))
        ],
        // 戻るボタンを「×」にカスタマイズ
        leading: IconButton(
          icon: const Icon(
            Icons.close, // 「×」アイコン
            color: Colors.grey,
            size: 20,
          ),
          onPressed: () {
            Navigator.pop(context, true); // 現在の画面を閉じる
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              decoration: const BoxDecoration(
                color: Color(0xFFF5F5F5),
              ),
              child: Column(
                children: [
                  GestureDetector(
                    onTap: () async {
                      weightPicker();
                    },
                    child: Container(
                      margin: const EdgeInsets.fromLTRB(10, 10, 10, 5),
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
                      child: Container(
                        width: double.infinity, // 横幅最大
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment:
                              CrossAxisAlignment.center, // 横方向中央寄せ
                          children: [
                            const Text(
                              '今日の体重',
                              style: TextStyle(
                                  fontSize: 12, color: Colors.black54),
                            ),
                            Text(
                              '$weight kg',
                              style: const TextStyle(
                                  fontSize: 30, color: Colors.black54),
                            ),
                            const Divider(
                              indent: 10,
                              endIndent: 10,
                              thickness: 0.5,
                              color: Color.fromRGBO(238, 238, 238, 1),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                Container(),
                                Column(
                                  children: [
                                    const Text(
                                      'BMI',
                                      style: TextStyle(
                                          fontSize: 11, color: Colors.black54),
                                    ),
                                    Text(
                                      '$bmi',
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
                                      '目標まで',
                                      style: TextStyle(
                                          fontSize: 11, color: Colors.black54),
                                    ),
                                    Text(
                                      '$untilTarget kg',
                                      style: const TextStyle(
                                          fontSize: 13, color: Colors.black54),
                                    )
                                  ],
                                ),
                                Container(),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              decoration: const BoxDecoration(
                color: Color(0xFFF5F5F5),
              ),
              child: GestureDetector(
                onTap: () async {
                  bodyFatRatePicker();
                },
                child: Container(
                  margin: const EdgeInsets.all(10),
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
                  child: Container(
                    width: double.infinity, // 横幅最大
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center, // 横方向中央寄せ
                      children: [
                        const Text(
                          '今日の体脂肪率',
                          style: TextStyle(fontSize: 12, color: Colors.black54),
                        ),
                        Text(
                          '$bodyFatRate %',
                          style: const TextStyle(
                              fontSize: 30, color: Colors.black54),
                        ),
                      ],
                    ),
                  ),
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
                child: Container(
                  margin: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                  padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
                  height: 400,
                  child: Column(
                    children: <Widget>[
                      TextFormField(
                        initialValue: content,
                        focusNode: focusNode,
                        cursorColor: Colors.grey,
                        style: const TextStyle(
                            color: Colors.black87,
                            letterSpacing: 1,
                            height: 1.7),
                        onChanged: (String value) {
                          setState(() {
                            content = value;
                          });
                        },
                        decoration: const InputDecoration(
                            border: InputBorder.none,
                            hintText: '今日は何した？何食べた？',
                            hintStyle: TextStyle(color: Colors.black54)),
                        maxLines: 13,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void weightPicker() {
    int selectedInteger = 50; // 初期値: 50
    int selectedDecimal = 0; // 初期値: .00

    if (double.parse(weight) != 0) {
      // ドラムロールの表示用
      // weightを小数点の右側と左側に分ける
      List<String> parts = weight.split('.');
      selectedInteger = int.parse(parts[0]);
      selectedDecimal = int.parse(parts[1]);
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 10),
              SizedBox(
                height: 200,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // 整数部
                    Expanded(
                      child: CupertinoPicker(
                        scrollController: FixedExtentScrollController(
                            initialItem: selectedInteger),
                        itemExtent: 40,
                        onSelectedItemChanged: (int value) {
                          selectedInteger = value;
                        },
                        children: List.generate(200, (index) {
                          return Center(
                            child: Text(
                              index.toString().padLeft(2, '0'),
                              style: const TextStyle(
                                  fontSize: 30, color: Colors.black),
                            ),
                          );
                        }),
                      ),
                    ),
                    // 小数点
                    const Text(
                      '.',
                      style: TextStyle(fontSize: 30, color: Colors.black),
                    ),
                    // 小数部
                    Expanded(
                      child: CupertinoPicker(
                        scrollController: FixedExtentScrollController(
                            initialItem: selectedDecimal),
                        itemExtent: 40,
                        onSelectedItemChanged: (int value) {
                          selectedDecimal = value;
                        },
                        children: List.generate(100, (index) {
                          return Center(
                            child: Text(
                              index.toString().padLeft(2, '0'),
                              style: const TextStyle(
                                  fontSize: 30, color: Colors.black),
                            ),
                          );
                        }),
                      ),
                    ),
                    const Text(
                      'kg',
                      style: TextStyle(fontSize: 20, color: Colors.black54),
                    ),
                    const SizedBox(
                      width: 10,
                    )
                  ],
                ),
              ),
              const Divider(height: 1),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text(
                        'キャンセル',
                        style: TextStyle(fontSize: 16, color: Colors.black54),
                      ),
                    ),
                  ),
                  const VerticalDivider(width: 1),
                  Expanded(
                    child: TextButton(
                      onPressed: () {
                        String result =
                            '${selectedInteger.toString().padLeft(2, '0')}.${selectedDecimal.toString().padLeft(2, '0')}';
                        setState(() {
                          // ここで状態を更新する（必要に応じて）
                          weight = result;
                          // BMI, 目標まで
                          if (weight != '00.00') {
                            // 00.00kgではない場合
                            bmi = myHeight == 0
                                ? 00.00
                                : double.parse(weight) /
                                    ((myHeight / 100) * (myHeight / 100));
                            bmi = double.parse(bmi.toStringAsFixed(1));
                            untilTarget = double.parse(
                                (targetWeight - double.parse(weight))
                                    .toStringAsFixed(2));
                          } else {
                            // 00.00kgの場合
                            bmi = 00.00;
                            untilTarget = 00.00;
                          }
                        });
                        objectBox.addWeight(
                            focusedDay: widget.focusedDay.toString(),
                            weight: double.parse(
                                double.parse(weight).toStringAsFixed(2)),
                            datetime: widget.focusedDay);
                        Navigator.pop(context);
                      },
                      child: const Text(
                        '完了',
                        style: TextStyle(fontSize: 16, color: Colors.black54),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  void bodyFatRatePicker() {
    int selectedInteger = 20; // 初期値: 20
    int selectedDecimal = 0; // 初期値: .00

    if (double.parse(bodyFatRate) != 0) {
      // ドラムロールの表示用
      // bodyFatRateを小数点の右側と左側に分ける
      List<String> parts = bodyFatRate.split('.');
      selectedInteger = int.parse(parts[0]);
      selectedDecimal = int.parse(parts[1]);
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 10),
              SizedBox(
                height: 200,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // 整数部
                    Expanded(
                      child: CupertinoPicker(
                        scrollController: FixedExtentScrollController(
                            initialItem: selectedInteger),
                        itemExtent: 40,
                        onSelectedItemChanged: (int value) {
                          selectedInteger = value;
                        },
                        children: List.generate(200, (index) {
                          return Center(
                            child: Text(
                              index.toString().padLeft(2, '0'),
                              style: const TextStyle(
                                  fontSize: 30, color: Colors.black),
                            ),
                          );
                        }),
                      ),
                    ),
                    // 小数点
                    const Text(
                      '.',
                      style: TextStyle(fontSize: 30, color: Colors.black),
                    ),
                    // 小数部
                    Expanded(
                      child: CupertinoPicker(
                        scrollController: FixedExtentScrollController(
                            initialItem: selectedDecimal),
                        itemExtent: 40,
                        onSelectedItemChanged: (int value) {
                          selectedDecimal = value;
                        },
                        children: List.generate(100, (index) {
                          return Center(
                            child: Text(
                              index.toString().padLeft(2, '0'),
                              style: const TextStyle(
                                  fontSize: 30, color: Colors.black),
                            ),
                          );
                        }),
                      ),
                    ),
                    const Text(
                      '%',
                      style: TextStyle(fontSize: 20, color: Colors.black54),
                    ),
                    const SizedBox(
                      width: 10,
                    )
                  ],
                ),
              ),
              const Divider(height: 1),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text(
                        'キャンセル',
                        style: TextStyle(fontSize: 16, color: Colors.black54),
                      ),
                    ),
                  ),
                  const VerticalDivider(width: 1),
                  Expanded(
                    child: TextButton(
                      onPressed: () {
                        String result =
                            '${selectedInteger.toString().padLeft(2, '0')}.${selectedDecimal.toString().padLeft(2, '0')}';
                        setState(() {
                          // ここで状態を更新する（必要に応じて）
                          bodyFatRate = result;
                        });
                        objectBox.addBodyFatRate(
                            focusedDay: widget.focusedDay.toString(),
                            bodyFatRate: double.parse(
                                double.parse(bodyFatRate).toStringAsFixed(2)),
                            datetime: widget.focusedDay);
                        Navigator.pop(context);
                      },
                      child: const Text(
                        '完了',
                        style: TextStyle(fontSize: 16, color: Colors.black54),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
