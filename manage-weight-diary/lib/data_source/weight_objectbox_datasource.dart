import 'package:objectbox/objectbox.dart';
import '../entity/weight.dart';
import '../objectbox/objectbox.g.dart';

class WeightDataSource {
  final Box<Weight> _weightBox;

  WeightDataSource(Store store) : _weightBox = Box<Weight>(store);

  List<Weight> getWeight(String selectedDay) {
    final query = _weightBox.query(Weight_.date.equals(selectedDay)).build();
    return query.find();
  }

  List<Weight> getWeights(int months, DateTime datetime) {
    DateTime nextMonth = DateTime(datetime.year, datetime.month + months, 1);

    final query = _weightBox
        .query(Weight_.datetime
            .greaterOrEqual(datetime.millisecondsSinceEpoch)
            .and(Weight_.datetime.lessThan(nextMonth.millisecondsSinceEpoch)))
        .order(Weight_.datetime)
        .build();

    return query.find();
  }

  List<Weight> getAllWeights() {
    return _weightBox.getAll();
  }

  void addWeight({
    required String focusedDay,
    required double weight,
    required DateTime datetime,
  }) {
    _weightBox.put(Weight(
      date: focusedDay,
      weight: weight,
      datetime: datetime,
    ));
  }

  int countConsecutiveDates() {
    final today = DateTime.now();
    final todayOnly = DateTime(today.year, today.month, today.day);
    final yesterdayOnly = todayOnly.subtract(Duration(days: 1));

    final weights = _weightBox
        .query(Weight_.datetime.lessOrEqual(todayOnly.millisecondsSinceEpoch))
        .order(Weight_.datetime)
        .build()
        .find();

    if (weights.isEmpty) return 0;

    DateTime lastDate = DateTime(
      weights.last.datetime.year,
      weights.last.datetime.month,
      weights.last.datetime.day,
    );

    if (lastDate != todayOnly && lastDate != yesterdayOnly) return 0;

    int count = 1;

    for (int i = weights.length - 2; i >= 0; i--) {
      final prevDate = DateTime(
        weights[i].datetime.year,
        weights[i].datetime.month,
        weights[i].datetime.day,
      );

      if (lastDate.difference(prevDate).inDays == 1) {
        count++;
        lastDate = prevDate;
      } else {
        break;
      }
    }

    return count;
  }
}
