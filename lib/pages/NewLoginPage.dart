import 'package:flutter/material.dart';

// 新的登录界面，隐藏WebView登录页面
class NewLoginPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new NewLoginPageState();
}

class NewLoginPageState extends State<NewLoginPage> {

  final usernameCtrl = new TextEditingController(text: '');
  final passwordCtrl = new TextEditingController(text: '');

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text("登录", style: new TextStyle(color: Colors.white)),
        iconTheme: new IconThemeData(color: Colors.white),
      ),
      body: new Container(
        padding: const EdgeInsets.all(10.0),
        child: new Column(
          children: <Widget>[
            new Center(child: new Text("请使用OSC帐号密码登录")),
            new Container(height: 20.0),
            new Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                new Text("用户名："),
                new Expanded(child: new TextField(
                  controller: usernameCtrl,
                  decoration: new InputDecoration(
                    hintText: "OSC帐号/注册邮箱",
                    hintStyle: new TextStyle(
                        color: const Color(0xFF808080)
                    ),
                    border: new OutlineInputBorder(
                        borderRadius: const BorderRadius.all(const Radius.circular(6.0))
                    ),
                    contentPadding: const EdgeInsets.all(10.0)
                  ),
                ))
              ],
            ),
            new Container(height: 20.0),
            new Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                new Text("密　码："),
                new Expanded(child: new TextField(
                  controller: passwordCtrl,
                  obscureText: true,
                  decoration: new InputDecoration(
                    hintText: "登录密码",
                    hintStyle: new TextStyle(
                        color: const Color(0xFF808080)
                    ),
                    border: new OutlineInputBorder(
                        borderRadius: const BorderRadius.all(const Radius.circular(6.0))
                    ),
                    contentPadding: const EdgeInsets.all(10.0)
                  ),
                ))
              ],
            ),
            new Container(height: 20.0),
            new RaisedButton(
              child: new Text("登录"),
              onPressed: () {

              },
            )
          ],
        ),
      )
    );
  }
}