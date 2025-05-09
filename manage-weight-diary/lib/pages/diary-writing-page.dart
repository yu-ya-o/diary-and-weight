import 'dart:io';

import 'package:disiry_weight_mng/main.dart';
import 'package:flutter/material.dart';
import '../entity/diary.dart';
import 'dart:math';
import 'dart:async';
import 'package:in_app_review/in_app_review.dart';
import 'package:flutter/cupertino.dart';

class DiaryWritingPage extends StatefulWidget {
  const DiaryWritingPage({super.key, required this.focusedDay});
  final DateTime focusedDay;

  @override
  _DiaryWritingPageState createState() => _DiaryWritingPageState();
}

class _DiaryWritingPageState extends State<DiaryWritingPage> {
  String content = '';

  final InAppReview inAppReview = InAppReview.instance;

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

  String randomMessage = '';
  final List<String> diaryMessages = [
    '今日は何した？',
    'どんな１日だった？',
    '今日は何を感じた？',
    '１日をふりかえってみよう',
    '今日はどう過ごした？',
  ];

  String getDiaryMessage() {
    final random = Random();
    final index = random.nextInt(diaryMessages.length);
    return randomMessage = diaryMessages[index];
  }

  Future<void> requestReview() async {
    // isAvailableは、iOS 10.3以降, Android 5.2以降&&Google Play Storeがinstallされている場合にtrueを返す
    // SeeAlso: https://pub.dev/packages/in_app_review
    if (await inAppReview.isAvailable()) {
      inAppReview.requestReview();
    }
  }

  @override
  void initState() {
    super.initState();
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
                        datetime: DateTime.parse(widget.focusedDay.toString())
                            .toUtc());
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
        // 日記の内容
        body: SingleChildScrollView(
          child: Container(
            margin: const EdgeInsets.fromLTRB(10, 10, 10, 100),
            padding: const EdgeInsets.all(10),
            child: Column(
              children: <Widget>[
                TextFormField(
                  initialValue: content,
                  focusNode: focusNode,
                  cursorColor: Colors.grey,
                  style: const TextStyle(
                      color: Colors.black87, letterSpacing: 1, height: 1.7),
                  onChanged: (String value) {
                    setState(() {
                      content = value;
                    });
                  },
                  decoration: const InputDecoration(
                      border: InputBorder.none, hintText: '今日は何した？'),
                  maxLines: null,
                ),
              ],
            ),
          ),
        ));
  }
}
