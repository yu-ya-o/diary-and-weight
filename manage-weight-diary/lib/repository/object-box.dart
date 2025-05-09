import '../objectbox.g.dart';
import '../entity/weight.dart';
import '../entity/diary.dart';
import '../entity/setting.dart';

class ObjectBox {
  late final Store store;
  late final Box<Weight> weightBox;
  late final Box<Diary> diaryBox;
  late final Box<Setting> settingBox;

  ObjectBox._create(this.store) {
    weightBox = Box<Weight>(store);
    diaryBox = Box<Diary>(store);
    settingBox = Box<Setting>(store);
  }

  static Future<ObjectBox> create() async {
    final store = await openStore();
    return ObjectBox._create(store);
  }

  List<Weight> getWeight({required String selectedDay}) {
    Query<Weight> weightQuery =
        weightBox.query(Weight_.date.equals(selectedDay)).build();
    return weightQuery.find();
  }

  List<Weight> getWeights({required int months, required DateTime datetime}) {
    DateTime nextMonth = datetime;
    if (months == 1) {
      nextMonth = DateTime(datetime.year, datetime.month + 1, 1);
    } else if (months == 3) {
      nextMonth = DateTime(datetime.year, datetime.month + 3, 1);
    } else if (months == 6) {
      nextMonth = DateTime(datetime.year, datetime.month + 6, 1);
    } else if (months == 12) {
      nextMonth = DateTime(datetime.year, datetime.month + 12, 1);
    }
    Query<Weight> weightQuery = (weightBox
            .query(Weight_.datetime
                .greaterOrEqual(datetime.millisecondsSinceEpoch)
                .and(Weight_.datetime
                    .lessThan(nextMonth.millisecondsSinceEpoch)))
            .order(Weight_.datetime))
        .build();
    return weightQuery.find();
  }

  List<Weight> getAllWeight() {
    return weightBox.getAll();
  }

  void addWeight(
      {required String focusedDay,
      required double weight,
      required DateTime datetime}) {
    weightBox.put(Weight(date: focusedDay, weight: weight, datetime: datetime));
  }

  int countConsecutiveDates() {
    // 今日の日付（時刻を削除）
    final today = DateTime.now();
    final todayOnly = DateTime(today.year, today.month, today.day);
    final yesterdayOnly = todayOnly.subtract(Duration(days: 1));

    // 今日までのデータを取得し、日付順にソート
    final weights = weightBox
        .query(Weight_.datetime.lessOrEqual(todayOnly.millisecondsSinceEpoch))
        .order(Weight_.datetime)
        .build()
        .find();

    if (weights.isEmpty) {
      return 0; // データがない場合は 0
    }

    // 最新の日付を取得（時刻を削除）
    DateTime lastDate = DateTime(
      weights.last.datetime.year,
      weights.last.datetime.month,
      weights.last.datetime.day,
    );

    // 最新の日付が「今日」または「昨日」でなければ 0 を返す
    if (lastDate != todayOnly && lastDate != yesterdayOnly) {
      return 0;
    }

    int count = 1; // 連続日数（データが1つでもあれば1から開始）

    // 連続する日付をカウント
    for (int i = weights.length - 2; i >= 0; i--) {
      final prevDate = DateTime(
        weights[i].datetime.year,
        weights[i].datetime.month,
        weights[i].datetime.day,
      );

      // 連続している場合のみカウント
      if (lastDate.difference(prevDate).inDays == 1) {
        count++;
        lastDate = prevDate; // 更新
      } else {
        break; // 連続が途切れたら終了
      }
    }

    return count;
  }

  List<Diary> getDiary({required String selectedDay}) {
    Query<Diary> diaryQuery =
        diaryBox.query(Diary_.writingDate.equals(selectedDay)).build();
    return diaryQuery.find();
  }

  List<Diary> getAllDiary() {
    Query<Diary> diaryQuery = diaryBox
        .query(Diary_.content.notEquals('').or(Diary_.content.notNull()))
        .build();
    return diaryQuery.find();
  }

  List<Diary> getDiaryForDateTime(DateTime selectedDateTime) {
    Query<Diary> diaryQuery = (diaryBox.query(Diary_.writingDate
            .contains(selectedDateTime.toString().substring(0, 7).toString())
            .and(Diary_.content.notEquals('')))
          ..order(Diary_.writingDate, flags: Order.descending))
        .build();
    return diaryQuery.find();
  }

  void addDiary(
      {required String writingDate,
      required String content,
      required DateTime datetime}) {
    diaryBox.put(
        Diary(writingDate: writingDate, content: content, datetime: datetime));
  }

  String getTargtWeight() {
    Query<Setting> settingQuery =
        settingBox.query(Setting_.ruleId.equals('targetWeight')).build();
    List<Setting> targetWeight = settingQuery.find();
    if (targetWeight.isEmpty) {
      return '0.0';
    }
    return targetWeight.first.ruleVal;
  }

  void addTargetWeight({required String targetWeight}) {
    settingBox.put(Setting(ruleId: 'targetWeight', ruleVal: targetWeight));
  }

  String getHeight() {
    Query<Setting> settingQuery =
        settingBox.query(Setting_.ruleId.equals('height')).build();
    List<Setting> height = settingQuery.find();
    if (height.isEmpty) {
      return '0.0';
    }
    return height.first.ruleVal;
  }

  void addHeight({required String height}) {
    settingBox.put(Setting(ruleId: 'height', ruleVal: height));
  }

  String getThemeColor() {
    Query<Setting> settingQuery =
        settingBox.query(Setting_.ruleId.equals('color')).build();
    List<Setting> color = settingQuery.find();
    if (color.isEmpty) {
      return 'blue';
    }
    return color.first.ruleVal;
  }

  void addThemeColor({required String color}) {
    settingBox.put(Setting(ruleId: 'color', ruleVal: color));
  }
}
