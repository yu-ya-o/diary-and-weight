import 'package:disiry_weight_mng/entity/bodyFatRate.dart';
import 'package:disiry_weight_mng/objectbox/objectbox.g.dart';
import 'package:objectbox/objectbox.dart';

class BodyFatRateRepository {
  final Box<BodyFatRate> _bodyFatRateBox;

  BodyFatRateRepository(Store store)
      : _bodyFatRateBox = Box<BodyFatRate>(store);

  List<BodyFatRate> getBodyFatRate({required String selectedDay}) {
    Query<BodyFatRate> bodyFatRateQuery =
        _bodyFatRateBox.query(BodyFatRate_.date.equals(selectedDay)).build();
    return bodyFatRateQuery.find();
  }

  List<BodyFatRate> getBodyFatRates(
      {required int months, required DateTime datetime}) {
    DateTime nextMonth = DateTime(datetime.year, datetime.month + months, 1);

    Query<BodyFatRate> bodyFatRateQuery = (_bodyFatRateBox
            .query(BodyFatRate_.datetime
                .greaterOrEqual(datetime.millisecondsSinceEpoch)
                .and(BodyFatRate_.datetime
                    .lessThan(nextMonth.millisecondsSinceEpoch)))
            .order(BodyFatRate_.datetime))
        .build();
    return bodyFatRateQuery.find();
  }

  List<BodyFatRate> getAllBodyFatRate() {
    return _bodyFatRateBox.getAll();
  }

  void addBodyFatRate(
      {required String focusedDay,
      required double bodyFatRate,
      required DateTime datetime}) {
    _bodyFatRateBox.put(BodyFatRate(
        date: focusedDay, bodyFatRate: bodyFatRate, datetime: datetime));
  }
}
