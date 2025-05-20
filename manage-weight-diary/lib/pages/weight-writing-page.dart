import 'dart:io';
import 'dart:math';

import 'package:disiry_weight_mng/entity/bodyFatRate.dart';
import 'package:disiry_weight_mng/entity/weight.dart';
import 'package:disiry_weight_mng/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../entity/diary.dart';
import 'dart:async';
import 'package:in_app_review/in_app_review.dart';
import 'package:flutter/cupertino.dart';
import 'package:disiry_weight_mng/provider/theme-color.dart';

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
  // 選択日
  DateTime focusedDay = DateTime.now();
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
    // 選択日の取得
    focusedDay = widget.focusedDay;
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
                      // weightPicker();
                      await WeightDialogUtils.showEditingDialog(
                          context, weight, focusedDay);
                      setState(() {
                        List<Weight> weightList = objectBox.weightRepository
                            .getWeight(selectedDay: focusedDay.toString());
                        if (weightList.isNotEmpty) {
                          weight = weightList.first.weight.toString();
                        }
                      });
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
                  // bodyFatRatePicker();
                  await BodyFatRateDialogUtils.showEditingDialog(
                      context, bodyFatRate, focusedDay);
                  setState(() {
                    List<BodyFatRate> bodyFatRateList = objectBox
                        .getBodyFatRate(selectedDay: focusedDay.toString());
                    if (bodyFatRateList.isNotEmpty) {
                      bodyFatRate =
                          bodyFatRateList.first.bodyFatRate.toString();
                    }
                  });
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
}

// ---------------------------
// 体重入力クラス
// ---------------------------
class WeightDialogUtils {
  WeightDialogUtils._();

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
        return WeightEditingDialog(weight: weight, focusedDay: focusedDay);
      },
    );
  }
}

class WeightEditingDialog extends ConsumerStatefulWidget {
  const WeightEditingDialog(
      {super.key, required this.weight, required this.focusedDay});
  final String weight;
  final DateTime focusedDay;

  @override
  _WeightEditingDialogState createState() => _WeightEditingDialogState();
}

class _WeightEditingDialogState extends ConsumerState<WeightEditingDialog> {
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
            if (monthWeights.length == 7) {
              showCupertinoDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return CupertinoAlertDialog(
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

// ---------------------------
// 体脂肪率入力クラス
// ---------------------------
class BodyFatRateDialogUtils {
  BodyFatRateDialogUtils._();

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
      BuildContext context, String bodyFatRate, DateTime focusedDay) async {
    return showDialog<String>(
      context: context,
      builder: (context) {
        return BodyFatRateEditingDialog(
            bodyFatRate: bodyFatRate, focusedDay: focusedDay);
      },
    );
  }
}

class BodyFatRateEditingDialog extends ConsumerStatefulWidget {
  const BodyFatRateEditingDialog(
      {super.key, required this.bodyFatRate, required this.focusedDay});
  final String bodyFatRate;
  final DateTime focusedDay;

  @override
  _BodyFatRateEditingDialogState createState() =>
      _BodyFatRateEditingDialogState();
}

class _BodyFatRateEditingDialogState
    extends ConsumerState<BodyFatRateEditingDialog> {
  final controller = TextEditingController();
  final focusNode = FocusNode();
  final InAppReview inAppReview = InAppReview.instance;

  Color themeColor = Colors.blue;

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
    if (widget.bodyFatRate == '00.00') {
      controller.text = '';
    } else {
      controller.text = widget.bodyFatRate;
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
      title: const Text('体脂肪率を入力しましょう',
          style: TextStyle(
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
            objectBox.addBodyFatRate(
                focusedDay: widget.focusedDay.toString(),
                bodyFatRate: double.parse(
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
              objectBox.addBodyFatRate(
                  focusedDay: widget.focusedDay.toString(),
                  bodyFatRate: double.parse(
                      double.parse(controller.text).toStringAsFixed(2)),
                  datetime: widget.focusedDay);
            }
            Navigator.of(context).pop(controller.text);
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
