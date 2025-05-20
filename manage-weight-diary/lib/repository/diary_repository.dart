import 'package:disiry_weight_mng/entity/diary.dart';
import 'package:disiry_weight_mng/objectbox/objectbox.g.dart';
import 'package:objectbox/objectbox.dart';

class DiaryRepository {
  final Box<Diary> _diaryBox;

  DiaryRepository(Store store) : _diaryBox = Box<Diary>(store);

  List<Diary> getDiary({required String selectedDay}) {
    Query<Diary> diaryQuery =
        _diaryBox.query(Diary_.writingDate.equals(selectedDay)).build();
    return diaryQuery.find();
  }

  List<Diary> getAllDiary() {
    Query<Diary> diaryQuery = _diaryBox
        .query(Diary_.content.notEquals('').or(Diary_.content.notNull()))
        .build();
    return diaryQuery.find();
  }

  List<Diary> getDiaryForDateTime(DateTime selectedDateTime) {
    Query<Diary> diaryQuery = (_diaryBox.query(Diary_.writingDate
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
    _diaryBox.put(
        Diary(writingDate: writingDate, content: content, datetime: datetime));
  }
}
