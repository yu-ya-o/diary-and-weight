import 'package:disiry_weight_mng/pages/base-page.dart';
import 'package:disiry_weight_mng/objectbox/object-box.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timezone/data/latest.dart' as tz;

// late Store store;
late ObjectBox objectBox;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  objectBox = await ObjectBox.create();
  tz.initializeTimeZones();
  initializeDateFormatting('ja')
      .then((_) => runApp(const ProviderScope(child: MyApp())));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: '日記と体重',
      home: BasePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}
