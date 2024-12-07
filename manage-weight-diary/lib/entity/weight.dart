
import 'package:objectbox/objectbox.dart';

@Entity()
class Weight {
  Weight({required this.date, required this.weight, required this.datetime});
  int id = 0;
  @Unique(onConflict: ConflictStrategy.replace)
  String date;
  double weight;
  DateTime datetime;
}