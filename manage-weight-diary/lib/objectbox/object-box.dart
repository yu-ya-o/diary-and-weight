import 'package:disiry_weight_mng/repository/body_fat_rate_repository.dart';
import 'package:disiry_weight_mng/repository/diary_repository.dart';
import 'package:disiry_weight_mng/repository/setting_repository.dart';
import 'package:disiry_weight_mng/repository/weight_repository.dart';

import 'objectbox.g.dart';

class ObjectBox {
  late final Store store;
  late final WeightRepository weightRepository;
  late final DiaryRepository diaryRepository;
  late final BodyFatRateRepository bodyFatRateRepository;
  late final SettingRepository settingRepository;

  ObjectBox._create(this.store) {
    weightRepository = WeightRepository(store);
    bodyFatRateRepository = BodyFatRateRepository(store);
    diaryRepository = DiaryRepository(store);
    settingRepository = SettingRepository(store);
  }

  static Future<ObjectBox> create() async {
    final store = await openStore();
    return ObjectBox._create(store);
  }

  // List<Weight> getWeight({required String selectedDay}) {
  //   return weightDataSource.getWeight(selectedDay);
  // }

  // List<Weight> getWeights({required int months, required DateTime datetime}) {
  //   return weightDataSource.getWeights(months, datetime);
  // }

  // List<Weight> getAllWeight() {
  //   return weightDataSource.getAllWeights();
  // }

  // void addWeight(
  //     {required String focusedDay,
  //     required double weight,
  //     required DateTime datetime}) {
  //   weightDataSource.addWeight(
  //       focusedDay: focusedDay, weight: weight, datetime: datetime);
  // }

  // int countConsecutiveDates() {
  //   return weightDataSource.countConsecutiveDates();
  // }

  // List<BodyFatRate> getBodyFatRate({required String selectedDay}) {
  //   Query<BodyFatRate> bodyFatRateQuery =
  //       bodyFatRateBox.query(BodyFatRate_.date.equals(selectedDay)).build();
  //   return bodyFatRateQuery.find();
  // }

  // List<BodyFatRate> getBodyFatRates(
  //     {required int months, required DateTime datetime}) {
  //   DateTime nextMonth = datetime;
  //   if (months == 1) {
  //     nextMonth = DateTime(datetime.year, datetime.month + 1, 1);
  //   } else if (months == 3) {
  //     nextMonth = DateTime(datetime.year, datetime.month + 3, 1);
  //   } else if (months == 6) {
  //     nextMonth = DateTime(datetime.year, datetime.month + 6, 1);
  //   } else if (months == 12) {
  //     nextMonth = DateTime(datetime.year, datetime.month + 12, 1);
  //   }
  //   Query<BodyFatRate> bodyFatRateQuery = (bodyFatRateBox
  //           .query(BodyFatRate_.datetime
  //               .greaterOrEqual(datetime.millisecondsSinceEpoch)
  //               .and(BodyFatRate_.datetime
  //                   .lessThan(nextMonth.millisecondsSinceEpoch)))
  //           .order(BodyFatRate_.datetime))
  //       .build();
  //   return bodyFatRateQuery.find();
  // }

  // List<BodyFatRate> getAllBodyFatRate() {
  //   return bodyFatRateBox.getAll();
  // }

  // void addBodyFatRate(
  //     {required String focusedDay,
  //     required double bodyFatRate,
  //     required DateTime datetime}) {
  //   bodyFatRateBox.put(BodyFatRate(
  //       date: focusedDay, bodyFatRate: bodyFatRate, datetime: datetime));
  // }

  // List<Diary> getDiary({required String selectedDay}) {
  //   Query<Diary> diaryQuery =
  //       diaryBox.query(Diary_.writingDate.equals(selectedDay)).build();
  //   return diaryQuery.find();
  // }

  // List<Diary> getAllDiary() {
  //   Query<Diary> diaryQuery = diaryBox
  //       .query(Diary_.content.notEquals('').or(Diary_.content.notNull()))
  //       .build();
  //   return diaryQuery.find();
  // }

  // List<Diary> getDiaryForDateTime(DateTime selectedDateTime) {
  //   Query<Diary> diaryQuery = (diaryBox.query(Diary_.writingDate
  //           .contains(selectedDateTime.toString().substring(0, 7).toString())
  //           .and(Diary_.content.notEquals('')))
  //         ..order(Diary_.writingDate, flags: Order.descending))
  //       .build();
  //   return diaryQuery.find();
  // }

  // void addDiary(
  //     {required String writingDate,
  //     required String content,
  //     required DateTime datetime}) {
  //   diaryBox.put(
  //       Diary(writingDate: writingDate, content: content, datetime: datetime));
  // }

  // String getTargtWeight() {
  //   Query<Setting> settingQuery =
  //       settingBox.query(Setting_.ruleId.equals('targetWeight')).build();
  //   List<Setting> targetWeight = settingQuery.find();
  //   if (targetWeight.isEmpty) {
  //     return '0.0';
  //   }
  //   return targetWeight.first.ruleVal;
  // }

  // void addTargetWeight({required String targetWeight}) {
  //   settingBox.put(Setting(ruleId: 'targetWeight', ruleVal: targetWeight));
  // }

  // String getHeight() {
  //   Query<Setting> settingQuery =
  //       settingBox.query(Setting_.ruleId.equals('height')).build();
  //   List<Setting> height = settingQuery.find();
  //   if (height.isEmpty) {
  //     return '0.0';
  //   }
  //   return height.first.ruleVal;
  // }

  // void addHeight({required String height}) {
  //   settingBox.put(Setting(ruleId: 'height', ruleVal: height));
  // }

  // String getThemeColor() {
  //   Query<Setting> settingQuery =
  //       settingBox.query(Setting_.ruleId.equals('color')).build();
  //   List<Setting> color = settingQuery.find();
  //   if (color.isEmpty) {
  //     return 'blue';
  //   }
  //   return color.first.ruleVal;
  // }

  // void addThemeColor({required String color}) {
  //   settingBox.put(Setting(ruleId: 'color', ruleVal: color));
  // }
}
