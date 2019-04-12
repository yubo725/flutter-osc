import 'package:flutter/material.dart';
import 'package:flutter_osc/constants/Constants.dart';
import 'package:flutter_osc/events/ChangeThemeEvent.dart';
import 'package:flutter_osc/util/DataUtils.dart';
import 'package:flutter_osc/util/ThemeUtils.dart';

class ChangeThemePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => ChangeThemePageState();
}

class ChangeThemePageState extends State<ChangeThemePage> {

  List<Color> colors = ThemeUtils.supportColors;

  changeColorTheme(Color c) {
    Constants.eventBus.fire(ChangeThemeEvent(c));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('切换主题', style: TextStyle(color: Colors.white)),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(4.0),
        child: GridView.count(
          crossAxisCount: 4,
          children: List.generate(colors.length, (index) {
            return InkWell(
              onTap: () {
                ThemeUtils.currentColorTheme = colors[index];
                DataUtils.setColorTheme(index);
                changeColorTheme(colors[index]);
              },
              child: Container(
                color: colors[index],
                margin: const EdgeInsets.all(3.0),
              ),
            );
          }),
        )
      )
    );
  }

}