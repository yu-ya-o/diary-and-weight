import 'package:objectbox/objectbox.dart';

@Entity()
class BodyFatRate {
  BodyFatRate(
      {required this.date, required this.bodyFatRate, required this.datetime});
  int id = 0;
  @Unique(onConflict: ConflictStrategy.replace)
  String date;
  double bodyFatRate;
  DateTime datetime;
}
