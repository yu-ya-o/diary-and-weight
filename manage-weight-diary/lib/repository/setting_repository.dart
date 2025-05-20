import 'package:disiry_weight_mng/entity/setting.dart';
import 'package:disiry_weight_mng/objectbox/objectbox.g.dart';
import 'package:objectbox/objectbox.dart';

class SettingRepository {
  final Box<Setting> _settingBox;

  SettingRepository(Store store) : _settingBox = Box<Setting>(store);

  String getTargtWeight() {
    Query<Setting> settingQuery =
        _settingBox.query(Setting_.ruleId.equals('targetWeight')).build();
    List<Setting> targetWeight = settingQuery.find();
    if (targetWeight.isEmpty) {
      return '0.0';
    }
    return targetWeight.first.ruleVal;
  }

  void addTargetWeight({required String targetWeight}) {
    _settingBox.put(Setting(ruleId: 'targetWeight', ruleVal: targetWeight));
  }

  String getHeight() {
    Query<Setting> settingQuery =
        _settingBox.query(Setting_.ruleId.equals('height')).build();
    List<Setting> height = settingQuery.find();
    if (height.isEmpty) {
      return '0.0';
    }
    return height.first.ruleVal;
  }

  void addHeight({required String height}) {
    _settingBox.put(Setting(ruleId: 'height', ruleVal: height));
  }

  String getThemeColor() {
    Query<Setting> settingQuery =
        _settingBox.query(Setting_.ruleId.equals('color')).build();
    List<Setting> color = settingQuery.find();
    if (color.isEmpty) {
      return 'blue';
    }
    return color.first.ruleVal;
  }

  void addThemeColor({required String color}) {
    _settingBox.put(Setting(ruleId: 'color', ruleVal: color));
  }
}
