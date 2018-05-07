import 'package:flutter/material.dart';
import 'package:flutter_osc/constants/Constants.dart';
import 'package:flutter_osc/events/LogoutEvent.dart';
import '../util/DataUtils.dart';

class SettingsPage extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text("设置", style: new TextStyle(color: Colors.white)),
        iconTheme: new IconThemeData(color: Colors.white),
      ),
      body: new Center(
        child: new InkWell(
          child: new Container(
            padding: const EdgeInsets.fromLTRB(10.0, 6.0, 10.0, 6.0),
            decoration: new BoxDecoration(
              borderRadius: BorderRadius.all(new Radius.circular(5.0)),
              border: new Border.all(
                color: Colors.black,
                width: 1.0
              )
            ),
            child: new Text("退出登录"),
          ),
          onTap: () {
            DataUtils.clearLoginInfo().then((arg) {
              Navigator.of(context).pop();
              Constants.eventBus.fire(new LogoutEvent());
              print("event fired!");
            });
          },
        ),
      ),
    );
  }
}