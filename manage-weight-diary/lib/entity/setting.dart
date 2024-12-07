
import 'package:objectbox/objectbox.dart';

@Entity()
class Setting {
  Setting({required this.ruleId, required this.ruleVal});
  int id = 0;
  @Unique(onConflict: ConflictStrategy.replace)
  String ruleId;
  String ruleVal;
}