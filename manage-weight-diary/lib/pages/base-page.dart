import 'package:disiry_weight_mng/pages/calendar-page.dart';
import 'package:disiry_weight_mng/pages/diary-page.dart';
import 'package:disiry_weight_mng/pages/graph-page.dart';
import 'package:disiry_weight_mng/pages/settings-page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:disiry_weight_mng/provider/theme-color.dart';
import 'package:disiry_weight_mng/main.dart';

class BasePage extends ConsumerStatefulWidget {
  const BasePage({super.key});

  @override
  _BasePageState createState() => _BasePageState();
}

class _BasePageState extends ConsumerState<BasePage> {
  final _controller = CupertinoTabController();

  Color themeColor = Colors.blue;

  @override
  Widget build(BuildContext context) {
    // テーマカラーのプロバイダーを監視
    themeColor = ref.watch(themeColorProvider);
    var themeColorString = objectBox.getThemeColor();

    if (themeColorString == 'lime') {
      themeColor = Colors.lime;
    } else if (themeColorString == 'lime-shade') {
      themeColor = Colors.lime.shade300;
    } else if (themeColorString == 'orange') {
      themeColor = Colors.orange;
    } else if (themeColorString == 'orange-shade') {
      themeColor = Colors.orange.shade300;
    } else if (themeColorString == 'red') {
      themeColor = Colors.red;
    } else if (themeColorString == 'red-shade') {
      themeColor = Colors.red.shade300;
    } else if (themeColorString == 'purple') {
      themeColor = Colors.purple;
    } else if (themeColorString == 'purple-shade') {
      themeColor = Colors.purple.shade300;
    } else if (themeColorString == 'green') {
      themeColor = Colors.green;
    } else if (themeColorString == 'green-shade') {
      themeColor = Colors.green.shade300;
    } else if (themeColorString == 'blue') {
      themeColor = Colors.blue;
    } else if (themeColorString == 'blue-shade') {
      themeColor = Colors.blue.shade300;
    }

    return CupertinoTabScaffold(
      tabBar: CupertinoTabBar(
        activeColor: themeColor,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_month_outlined),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list_alt_outlined),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.auto_graph_outlined),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
          ),
        ],
      ),
      tabBuilder: (context, index) {
        return CupertinoTabView(
          builder: (context) {
            switch (index) {
              case 0:
                return const CalendarPage();
              case 1:
                return const DiaryPage();
              case 2:
                return const GraphPage();
              case 3:
                return const SettingsPage();
              default:
                return const CalendarPage();
            }
          },
        );
      },
      controller: _controller,
    );
  }
}
