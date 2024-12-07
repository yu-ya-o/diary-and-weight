import 'dart:io';

import 'package:flutter/material.dart';
import 'package:disiry_weight_mng/main.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:disiry_weight_mng/provider/theme-color.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:flutter/cupertino.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  String targetWeight = '';
  String height = '';

  final url = Uri.parse('https://forms.gle/g9tqHzTQdkich1rh9');

  final InAppReview inAppReview = InAppReview.instance;

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
    targetWeight = objectBox.getTargtWeight();
    height = objectBox.getHeight();

    if (targetWeight.isEmpty) {
      targetWeight = '--.-';
    }

    if (height.isEmpty) {
      height = '--.-';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        toolbarHeight: 50,
        backgroundColor: Colors.white,
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: const Text('設定',
            style: TextStyle(color: Colors.black54, fontSize: 18)),
      ),
      body: Container(
          margin: const EdgeInsets.fromLTRB(0, 10, 0, 0),
          padding: const EdgeInsets.all(10),
          child: Column(children: <Widget>[
            GestureDetector(
              onTap: () async {
                await Navigator.of(context)
                    .push(MaterialPageRoute(builder: (context) {
                  return const SelecteThemeColorPage();
                }));
              },
              behavior: HitTestBehavior.opaque,
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                        alignment: Alignment.centerLeft,
                        margin: const EdgeInsets.fromLTRB(10, 0, 0, 0),
                        height: 40,
                        child: const Text(
                          'テーマカラー',
                          style: TextStyle(color: Colors.black54),
                        )),
                  ]),
            ),
            const Divider(
              color: Color.fromRGBO(238, 238, 238, 1),
            ),
            GestureDetector(
              onTap: () async {
                await DialogUtils.showHeightDialog(context, height);
                setState(() {
                  height = objectBox.getHeight();
                });
              },
              behavior: HitTestBehavior.opaque,
              child: SizedBox(
                height: 40,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      margin: const EdgeInsets.fromLTRB(10, 0, 0, 0),
                      child: const Text(
                        '身長　　',
                        style: TextStyle(color: Colors.black54),
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.fromLTRB(200, 0, 10, 0),
                      child: Text(
                        '${double.parse(height).toStringAsFixed(2)}cm',
                        style: const TextStyle(color: Colors.black54),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const Divider(
              color: Color.fromRGBO(238, 238, 238, 1),
            ),
            GestureDetector(
              onTap: () async {
                await DialogUtils.showWeightDialog(context, targetWeight);
                setState(() {
                  targetWeight = objectBox.getTargtWeight();
                });
              },
              behavior: HitTestBehavior.opaque,
              child: SizedBox(
                height: 40,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      margin: const EdgeInsets.fromLTRB(10, 0, 0, 0),
                      child: const Text(
                        '目標体重',
                        style: TextStyle(color: Colors.black54),
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.fromLTRB(200, 0, 10, 0),
                      child: Text(
                        '${double.parse(targetWeight).toStringAsFixed(2)}kg',
                        style: const TextStyle(color: Colors.black54),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // const Divider(
            //   color: Color.fromRGBO(238, 238, 238, 1),
            // ),
            // GestureDetector(
            //   onTap: () async {
            //     await Navigator.of(context)
            //         .push(MaterialPageRoute(builder: (context) {
            //       return const PrimeRegisterPage();
            //     }));
            //   },
            //   behavior: HitTestBehavior.opaque,
            //   child: SizedBox(
            //     height: 40,
            //     child: Row(
            //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //       children: [
            //         Container(
            //           margin: const EdgeInsets.fromLTRB(10, 0, 0, 0),
            //           child: const Text(
            //             'プレミアムサービス',
            //             style: TextStyle(color: Colors.black54),
            //           ),
            //         ),
            //         Container(
            //           child: const Icon(
            //             Icons.chevron_right,
            //             color: Colors.black38,
            //           ),
            //         )
            //       ],
            //     ),
            //   ),
            // ),
            const Divider(
              color: Color.fromRGBO(238, 238, 238, 1),
            ),
            GestureDetector(
              onTap: () async {
                await launchUrl(url);
              },
              behavior: HitTestBehavior.opaque,
              child: SizedBox(
                height: 40,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      margin: const EdgeInsets.fromLTRB(10, 0, 0, 0),
                      child: const Text(
                        'お問い合わせ',
                        style: TextStyle(color: Colors.black54),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const Divider(
              color: Color.fromRGBO(238, 238, 238, 1),
            ),
            GestureDetector(
              onTap: () async {
                showCupertinoDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return CupertinoAlertDialog(
                        // title: Text('アプリの使い心地はいかがですか？'),
                        content: const Text(
                            'いつも日記と体重をご利用いただきありがとうございます。アプリの使い心地はいかがですか？'),
                        actions: <Widget>[
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                              showCupertinoDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return CupertinoAlertDialog(
                                      content: const Text(
                                          '評価ありがとうございます。改善に役立たせていただきます。不具合、ご意見等ありましたら、「お問い合わせ」よりご連絡お願いいたします。'),
                                      actions: <Widget>[
                                        TextButton(
                                          onPressed: () {
                                            Navigator.pop(context);
                                          },
                                          child: const Text(
                                            '閉じる',
                                            style:
                                                TextStyle(color: Colors.blue),
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
                                            style:
                                                TextStyle(color: Colors.blue),
                                          ),
                                        ),
                                      ],
                                    );
                                  });
                            },
                            child: const Text('いいね！',
                                style: TextStyle(color: Colors.blue)),
                          ),
                          // TextButton(
                          //   onPressed: () async {
                          //     /// OKを押した時の処理
                          //     Navigator.pop(context);
                          //     await requestReview();
                          //   },
                          //   child: Text('いいね！',
                          //       style: TextStyle(color: Colors.blue)),
                          // ),
                        ],
                      );
                    });
                // await requestReview();
              },
              behavior: HitTestBehavior.opaque,
              child: SizedBox(
                height: 40,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      margin: const EdgeInsets.fromLTRB(10, 0, 0, 0),
                      child: const Text(
                        'カンタン評価',
                        style: TextStyle(color: Colors.black54),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const Divider(
              color: Color.fromRGBO(238, 238, 238, 1),
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
  static Future<String?> showWeightDialog(
      BuildContext context, String targetWeight) async {
    return showDialog<String>(
      context: context,
      builder: (context) {
        return TargetWeightDialog(targetWeight: targetWeight);
      },
    );
  }

  /// 入力した文字列を返すダイアログを表示する
  static Future<String?> showHeightDialog(
      BuildContext context, String height) async {
    return showDialog<String>(
      context: context,
      builder: (context) {
        return HeightDialog(height: height);
      },
    );
  }
}

class TargetWeightDialog extends ConsumerStatefulWidget {
  const TargetWeightDialog({super.key, required this.targetWeight});
  final String targetWeight;

  @override
  _TargetWeightDialogState createState() => _TargetWeightDialogState();
}

class _TargetWeightDialogState extends ConsumerState<TargetWeightDialog> {
  final controller = TextEditingController();
  final focusNode = FocusNode();

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
    controller.text = widget.targetWeight;
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
      title: const Text('目標立てて素晴らしいですね！',
          style: TextStyle(
            fontSize: 16,
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
              RegExp(r'^[1-9]+[0-9]*(\.([0-9]*|[0-9]+[1-9]+))?$'))
        ],
        onFieldSubmitted: (_) {
          // エンターを押したときに実行される
          if (controller.text.isNotEmpty) {
            objectBox.addTargetWeight(
                targetWeight: double.parse(controller.text).toStringAsFixed(2));
          }
          Navigator.of(context).pop(controller.text);
        },
      ),
      actions: [
        TextButton(
          onPressed: () async {
            if (controller.text.isNotEmpty) {
              objectBox.addTargetWeight(
                  targetWeight:
                      double.parse(controller.text).toStringAsFixed(2));
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

class HeightDialog extends ConsumerStatefulWidget {
  const HeightDialog({super.key, required this.height});
  final String height;

  @override
  _HeightDialogState createState() => _HeightDialogState();
}

class _HeightDialogState extends ConsumerState<HeightDialog> {
  final controller = TextEditingController();
  final focusNode = FocusNode();

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
    controller.text = widget.height;
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
    return AlertDialog(
      backgroundColor: Colors.white,
      title: const Text('BMIを表示できるようになります',
          style: TextStyle(
            fontSize: 16,
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
              RegExp(r'^[1-9]+[0-9]*(\.([0-9]*|[0-9]+[1-9]+))?$'))
        ],
        onFieldSubmitted: (_) {
          // エンターを押したときに実行される
          if (controller.text.isNotEmpty) {
            objectBox.addHeight(
                height: double.parse(controller.text).toStringAsFixed(2));
          }
          Navigator.of(context).pop(controller.text);
        },
      ),
      actions: [
        TextButton(
          onPressed: () async {
            if (controller.text.isNotEmpty) {
              objectBox.addHeight(
                  height: double.parse(controller.text).toStringAsFixed(2));
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

class SelecteThemeColorPage extends ConsumerStatefulWidget {
  const SelecteThemeColorPage({super.key});

  @override
  _SelecteThemeColorPageState createState() => _SelecteThemeColorPageState();
}

class _SelecteThemeColorPageState extends ConsumerState<SelecteThemeColorPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
            toolbarHeight: 40,
            backgroundColor: Colors.white,
            title: const Text(
              'テーマカラー設定',
              style: TextStyle(color: Colors.black54, fontSize: 18),
            ),
            // 戻るボタン
            iconTheme: const IconThemeData(color: Colors.grey, size: 20)),
        body: SingleChildScrollView(
          child: Container(
              margin: const EdgeInsets.fromLTRB(0, 20, 0, 0),
              child: Column(
                children: [
                  GestureDetector(
                    onTap: () async {
                      objectBox.addThemeColor(color: 'lime');
                      ref
                          .read(themeColorProvider.notifier)
                          .updateColor(Colors.lime);
                      await Navigator.of(context)
                          .push(MaterialPageRoute(builder: (context) {
                        return const SettingsPage();
                      }));
                    },
                    behavior: HitTestBehavior.opaque,
                    child: SizedBox(
                      height: 60,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            margin: const EdgeInsets.fromLTRB(30, 10, 0, 10),
                            height: 30,
                            width: 30,
                            decoration: const BoxDecoration(
                              color: Colors.lime,
                            ),
                          ),
                          Container(
                            width: 30,
                          ),
                          const Text(
                            'この色にする',
                            style: TextStyle(
                                color: Colors.lime,
                                fontWeight: FontWeight.bold,
                                fontSize: 18),
                          ),
                          Container(
                            width: 30,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const Divider(
                    color: Color.fromRGBO(238, 238, 238, 1),
                  ),
                  GestureDetector(
                    onTap: () async {
                      objectBox.addThemeColor(color: 'lime-shade');
                      ref
                          .read(themeColorProvider.notifier)
                          .updateColor(Colors.lime.shade300);
                      await Navigator.of(context)
                          .push(MaterialPageRoute(builder: (context) {
                        return const SettingsPage();
                      }));
                    },
                    behavior: HitTestBehavior.opaque,
                    child: SizedBox(
                      height: 60,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            margin: const EdgeInsets.fromLTRB(30, 10, 0, 10),
                            height: 30,
                            width: 30,
                            decoration: BoxDecoration(
                              color: Colors.lime.shade300,
                            ),
                          ),
                          Container(
                            width: 30,
                          ),
                          Text(
                            'この色にする',
                            style: TextStyle(
                                color: Colors.lime.shade300,
                                fontWeight: FontWeight.bold,
                                fontSize: 18),
                          ),
                          Container(
                            width: 30,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const Divider(
                    color: Color.fromRGBO(238, 238, 238, 1),
                  ),
                  GestureDetector(
                    onTap: () async {
                      objectBox.addThemeColor(color: 'orange');
                      ref
                          .read(themeColorProvider.notifier)
                          .updateColor(Colors.orange);
                      await Navigator.of(context)
                          .push(MaterialPageRoute(builder: (context) {
                        return const SettingsPage();
                      }));
                    },
                    child: SizedBox(
                      height: 60,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            margin: const EdgeInsets.fromLTRB(30, 10, 0, 10),
                            height: 30,
                            width: 30,
                            decoration: const BoxDecoration(
                              color: Colors.orange,
                            ),
                          ),
                          Container(
                            width: 30,
                          ),
                          const Text(
                            'この色にする',
                            style: TextStyle(
                                color: Colors.orange,
                                fontWeight: FontWeight.bold,
                                fontSize: 18),
                          ),
                          Container(
                            width: 30,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const Divider(
                    color: Color.fromRGBO(238, 238, 238, 1),
                  ),
                  GestureDetector(
                    onTap: () async {
                      objectBox.addThemeColor(color: 'orange-shade');
                      ref
                          .read(themeColorProvider.notifier)
                          .updateColor(Colors.orange.shade300);
                      await Navigator.of(context)
                          .push(MaterialPageRoute(builder: (context) {
                        return const SettingsPage();
                      }));
                    },
                    child: SizedBox(
                      height: 60,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            margin: const EdgeInsets.fromLTRB(30, 10, 0, 10),
                            height: 30,
                            width: 30,
                            decoration: BoxDecoration(
                              color: Colors.orange.shade300,
                            ),
                          ),
                          Container(
                            width: 30,
                          ),
                          Text(
                            'この色にする',
                            style: TextStyle(
                                color: Colors.orange.shade300,
                                fontWeight: FontWeight.bold,
                                fontSize: 18),
                          ),
                          Container(
                            width: 30,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const Divider(
                    color: Color.fromRGBO(238, 238, 238, 1),
                  ),
                  GestureDetector(
                    onTap: () async {
                      objectBox.addThemeColor(color: 'red');
                      ref
                          .read(themeColorProvider.notifier)
                          .updateColor(Colors.red);
                      await Navigator.of(context)
                          .push(MaterialPageRoute(builder: (context) {
                        return const SettingsPage();
                      }));
                    },
                    child: SizedBox(
                      height: 60,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            margin: const EdgeInsets.fromLTRB(30, 10, 0, 10),
                            height: 30,
                            width: 30,
                            decoration: const BoxDecoration(
                              color: Colors.red,
                            ),
                          ),
                          Container(
                            width: 30,
                          ),
                          const Text(
                            'この色にする',
                            style: TextStyle(
                                color: Colors.red,
                                fontWeight: FontWeight.bold,
                                fontSize: 18),
                          ),
                          Container(
                            width: 30,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const Divider(
                    color: Color.fromRGBO(238, 238, 238, 1),
                  ),
                  GestureDetector(
                    onTap: () async {
                      objectBox.addThemeColor(color: 'red-shade');
                      ref
                          .read(themeColorProvider.notifier)
                          .updateColor(Colors.red.shade300);
                      await Navigator.of(context)
                          .push(MaterialPageRoute(builder: (context) {
                        return const SettingsPage();
                      }));
                    },
                    child: SizedBox(
                      height: 60,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            margin: const EdgeInsets.fromLTRB(30, 10, 0, 10),
                            height: 30,
                            width: 30,
                            decoration:
                                BoxDecoration(color: Colors.red.shade300),
                          ),
                          Container(
                            width: 30,
                          ),
                          Text(
                            'この色にする',
                            style: TextStyle(
                                color: Colors.red.shade300,
                                fontWeight: FontWeight.bold,
                                fontSize: 18),
                          ),
                          Container(
                            width: 30,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const Divider(
                    color: Color.fromRGBO(238, 238, 238, 1),
                  ),
                  GestureDetector(
                    onTap: () async {
                      objectBox.addThemeColor(color: 'purple');
                      ref
                          .read(themeColorProvider.notifier)
                          .updateColor(Colors.purple);
                      await Navigator.of(context)
                          .push(MaterialPageRoute(builder: (context) {
                        return const SettingsPage();
                      }));
                    },
                    child: SizedBox(
                      height: 60,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            margin: const EdgeInsets.fromLTRB(30, 10, 0, 10),
                            height: 30,
                            width: 30,
                            decoration: const BoxDecoration(
                              color: Colors.purple,
                            ),
                          ),
                          Container(
                            width: 30,
                          ),
                          const Text(
                            'この色にする',
                            style: TextStyle(
                                color: Colors.purple,
                                fontWeight: FontWeight.bold,
                                fontSize: 18),
                          ),
                          Container(
                            width: 30,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const Divider(
                    color: Color.fromRGBO(238, 238, 238, 1),
                  ),
                  GestureDetector(
                    onTap: () async {
                      objectBox.addThemeColor(color: 'purple-shade');
                      ref
                          .read(themeColorProvider.notifier)
                          .updateColor(Colors.purple.shade300);
                      await Navigator.of(context)
                          .push(MaterialPageRoute(builder: (context) {
                        return const SettingsPage();
                      }));
                    },
                    child: SizedBox(
                      height: 60,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            margin: const EdgeInsets.fromLTRB(30, 10, 0, 10),
                            height: 30,
                            width: 30,
                            decoration: BoxDecoration(
                              color: Colors.purple.shade300,
                            ),
                          ),
                          Container(
                            width: 30,
                          ),
                          Text(
                            'この色にする',
                            style: TextStyle(
                                color: Colors.purple.shade300,
                                fontWeight: FontWeight.bold,
                                fontSize: 18),
                          ),
                          Container(
                            width: 30,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const Divider(
                    color: Color.fromRGBO(238, 238, 238, 1),
                  ),
                  GestureDetector(
                    onTap: () async {
                      objectBox.addThemeColor(color: 'green');
                      ref
                          .read(themeColorProvider.notifier)
                          .updateColor(Colors.green);
                      await Navigator.of(context)
                          .push(MaterialPageRoute(builder: (context) {
                        return const SettingsPage();
                      }));
                    },
                    child: SizedBox(
                      height: 60,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            margin: const EdgeInsets.fromLTRB(30, 10, 0, 10),
                            height: 30,
                            width: 30,
                            decoration: const BoxDecoration(
                              color: Colors.green,
                            ),
                          ),
                          Container(
                            width: 30,
                          ),
                          const Text(
                            'この色にする',
                            style: TextStyle(
                                color: Colors.green,
                                fontWeight: FontWeight.bold,
                                fontSize: 18),
                          ),
                          Container(
                            width: 30,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const Divider(
                    color: Color.fromRGBO(238, 238, 238, 1),
                  ),
                  GestureDetector(
                    onTap: () async {
                      objectBox.addThemeColor(color: 'green-shade');
                      ref
                          .read(themeColorProvider.notifier)
                          .updateColor(Colors.green.shade300);
                      await Navigator.of(context)
                          .push(MaterialPageRoute(builder: (context) {
                        return const SettingsPage();
                      }));
                    },
                    child: SizedBox(
                      height: 60,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            margin: const EdgeInsets.fromLTRB(30, 10, 0, 10),
                            height: 30,
                            width: 30,
                            decoration: BoxDecoration(
                              color: Colors.green.shade300,
                            ),
                          ),
                          Container(
                            width: 30,
                          ),
                          Text(
                            'この色にする',
                            style: TextStyle(
                                color: Colors.green.shade300,
                                fontWeight: FontWeight.bold,
                                fontSize: 18),
                          ),
                          Container(
                            width: 30,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const Divider(
                    color: Color.fromRGBO(238, 238, 238, 1),
                  ),
                  GestureDetector(
                    onTap: () async {
                      objectBox.addThemeColor(color: 'blue');
                      ref
                          .read(themeColorProvider.notifier)
                          .updateColor(Colors.blue);
                      await Navigator.of(context)
                          .push(MaterialPageRoute(builder: (context) {
                        return const SettingsPage();
                      }));
                    },
                    child: SizedBox(
                      height: 60,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            margin: const EdgeInsets.fromLTRB(30, 10, 0, 10),
                            height: 30,
                            width: 30,
                            decoration: const BoxDecoration(
                              color: Colors.blue,
                            ),
                          ),
                          Container(
                            width: 30,
                          ),
                          const Text(
                            'この色にする',
                            style: TextStyle(
                                color: Colors.blue,
                                fontWeight: FontWeight.bold,
                                fontSize: 18),
                          ),
                          Container(
                            width: 30,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const Divider(
                    color: Color.fromRGBO(238, 238, 238, 1),
                  ),
                  GestureDetector(
                    onTap: () async {
                      objectBox.addThemeColor(color: 'blue-shade');
                      ref
                          .read(themeColorProvider.notifier)
                          .updateColor(Colors.blue.shade300);
                      await Navigator.of(context)
                          .push(MaterialPageRoute(builder: (context) {
                        return const SettingsPage();
                      }));
                    },
                    child: SizedBox(
                      height: 60,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            margin: const EdgeInsets.fromLTRB(30, 10, 0, 10),
                            height: 30,
                            width: 30,
                            decoration: BoxDecoration(
                              color: Colors.blue.shade300,
                            ),
                          ),
                          Container(
                            width: 30,
                          ),
                          Text(
                            'この色にする',
                            style: TextStyle(
                                color: Colors.blue.shade300,
                                fontWeight: FontWeight.bold,
                                fontSize: 18),
                          ),
                          Container(
                            width: 30,
                          ),
                        ],
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () async {},
                    child: const SizedBox(
                      height: 100,
                    ),
                  ),
                ],
              )),
        ));
  }
}

class PrimeRegisterPage extends StatefulWidget {
  const PrimeRegisterPage({super.key});

  @override
  _PrimeRegisterPageState createState() => _PrimeRegisterPageState();
}

class _PrimeRegisterPageState extends State<PrimeRegisterPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5F5F5),
        toolbarHeight: 50,
      ),
      body: Column(
        children: [
          Container(
            color: const Color(0xFFF5F5F5),
            margin: const EdgeInsets.fromLTRB(10, 50, 0, 100),
            child: const Text(
              '現在準備中です。今しばらくお待ちください。',
              style: TextStyle(fontSize: 15),
            ),
          ),
          Container(
              padding: const EdgeInsets.fromLTRB(0, 50, 0, 0),
              alignment: Alignment.center,
              child: const Icon(
                Icons.handyman_outlined,
                size: 150,
                color: Colors.black54,
              ))
        ],
      ),
    );
  }
}
