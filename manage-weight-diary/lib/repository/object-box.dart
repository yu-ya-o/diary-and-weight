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
