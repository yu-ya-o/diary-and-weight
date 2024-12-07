import 'package:objectbox/objectbox.dart';

@Entity()
class Diary {
  Diary({required this.writingDate, required this.content, required this.datetime});
  @Id()
  int id = 0;
  @Unique(onConflict: ConflictStrategy.replace)
  String writingDate;
  String content;
  DateTime datetime;
}