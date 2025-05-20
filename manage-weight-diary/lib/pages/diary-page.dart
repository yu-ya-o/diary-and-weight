import 'package:disiry_weight_mng/main.dart';
import 'package:disiry_weight_mng/pages/diary-writing-page.dart';
import 'package:disiry_weight_mng/pages/news-letter.dart';
import 'package:flutter/material.dart';
import '../entity/diary.dart';
import 'package:month_picker_dialog/month_picker_dialog.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:disiry_weight_mng/provider/theme-color.dart';

class DiaryPage extends ConsumerStatefulWidget {
  const DiaryPage({super.key});

  @override
  _DiaryPageState createState() => _DiaryPageState();
}

class _DiaryPageState extends ConsumerState<DiaryPage> {
  List<Diary> diaryList = List.empty();
  DateTime displayDate = DateTime(DateTime.now().year, DateTime.now().month, 1);

  Color themeColor = Colors.blue;

  void pushWithReloadByDiaryWriting(
      BuildContext context, DateTime datetime) async {
    await Navigator.push(
      context,
      MaterialPageRoute<bool>(
        builder: (BuildContext context) =>
            DiaryWritingPage(focusedDay: datetime),
      ),
    );

    setState(() {
      displayDate = DateTime(datetime.year, datetime.month, 1);
      diaryList = objectBox.diaryRepository.getDiaryForDateTime(displayDate);
    });
  }

  Future<void> _showStartDialog() async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: Row(
            children: [
              Text(
                "「日記と体重」運営者の日記",
                style: TextStyle(color: Colors.black54, fontSize: 20),
              )
            ],
          ),
          content: Container(
            height: 200,
            child: Column(
              children: [
                Container(
                    padding: EdgeInsets.fromLTRB(25, 0, 25, 0),
                    child: Image.asset('assets/newsletter.png')),
                Text(
                  "「日記と体重」運営者の日記を不定期でお届けしています。",
                  style: TextStyle(color: Colors.black54),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            // ボタン領域
            TextButton(
              child: Text(
                "閉じる",
                style: TextStyle(color: themeColor),
              ),
              onPressed: () => Navigator.pop(context),
            ),
            TextButton(
              child: Text("確認する", style: TextStyle(color: themeColor)),
              onPressed: () {
                Navigator.pop(context);
                Navigator.of(context).push<void>(
                  MaterialPageRoute(
                    builder: (context) => NewsLetterPage(),
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    displayDate = DateTime.now();
    diaryList = objectBox.diaryRepository.getDiaryForDateTime(displayDate);

    // WidgetsBinding.instance.addPostFrameCallback((_) => _showStartDialog());
  }

  @override
  Widget build(BuildContext context) {
    final days = ["", "月", "火", "水", "木", "金", "土", "日"];
    // displayDate = DateTime.now();
    diaryList = objectBox.diaryRepository.getDiaryForDateTime(displayDate);

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
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        toolbarHeight: 50,
        backgroundColor: Colors.white,
        automaticallyImplyLeading: false,
        leading: IconButton(
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
              });
            }
          },
          icon: const Icon(
            Icons.edit_calendar,
            color: Colors.black54,
          ),
          alignment: Alignment.topLeft,
        ),
        title: Text(
          '${displayDate.toString().substring(0, 4)}年${displayDate.toString().substring(5, 7)}月の日記',
          style: const TextStyle(color: Colors.black54, fontSize: 18),
        ),
        centerTitle: true,
      ),
      body: ListView.builder(
        itemCount: diaryList.length,
        itemBuilder: (context, index) {
          return GestureDetector(
              onTap: () {
                pushWithReloadByDiaryWriting(context,
                    DateTime.parse(diaryList[index].datetime.toString()));
              },
              behavior: HitTestBehavior.opaque,
              child: Container(
                margin: const EdgeInsets.fromLTRB(15, 15, 15, 0),
                height: 130,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Column(children: [
                  Container(
                    alignment: Alignment.topLeft,
                    padding: const EdgeInsets.fromLTRB(15, 10, 10, 10),
                    child: Text(
                      "${diaryList[index].datetime.month}/${diaryList[index].datetime.day}(${days[diaryList[index].datetime.weekday]})",
                      style: const TextStyle(
                        color: Colors.black54,
                        fontSize: 20,
                      ),
                    ),
                  ),
                  Container(
                    alignment: Alignment.topLeft,
                    padding: const EdgeInsets.fromLTRB(35, 0, 35, 0),
                    // width: 330,
                    child: Text(
                      diaryList[index].content.toString(),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 3,
                      style: const TextStyle(
                          color: Colors.black54,
                          letterSpacing: 1,
                          fontSize: 15),
                    ),
                  )
                ]),
              ));
        },
      ),
    );
  }
}
