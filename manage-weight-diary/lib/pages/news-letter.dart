import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:url_launcher/url_launcher.dart';

class NewsLetterPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            toolbarHeight: 50,
            backgroundColor: Colors.white,
            automaticallyImplyLeading: false,
            centerTitle: true,
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
          body: Container(
            padding: EdgeInsets.all(20),
            child: Column(
              children: [
                Container(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "ニュースレターはじめました",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                ),
                Container(
                  padding: EdgeInsets.fromLTRB(0, 10, 0, 0),
                  child: Text(
                    "ゆるく続ける楽しさを、一緒に共有できたら嬉しいです。",
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
                  ),
                ),
                Center(child: Image.asset('assets/newsletter.png')),
                Container(
                  child: Text(
                    "「日記と体重」運営者の日記を不定期でお届けします。趣味の読書や映画の感想、美味しかったもの、楽しかったこと、日々の気づきやちょっとした出来事を気ままに記録します。ゆるく続ける楽しさを、一緒に共有できたら嬉しいです。",
                    style: TextStyle(fontSize: 15, height: 2.5),
                  ),
                ),
                Container(
                  padding: EdgeInsets.fromLTRB(0, 10, 0, 0),
                  child: OutlinedButton(
                    child: const Text(
                      '確認してみる',
                      style: TextStyle(color: Colors.black),
                    ),
                    style: OutlinedButton.styleFrom(
                      // primary: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      side: const BorderSide(),
                    ),
                    onPressed: () async {
                      await launchUrl(Uri.parse(
                          'https://nikki-to-taijuu.m-newsletter.com/subscribe'));
                    },
                  ),
                )
              ],
            ),
          )),
    );
  }
}
