import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_osc/constants/Constants.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';

// 新的登录界面，隐藏WebView登录页面
class NewLoginPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new NewLoginPageState();
}

class NewLoginPageState extends State<NewLoginPage> {
  // 标记是否是加载中
  bool loading = true;
  // 标记当前页面是否是我们自定义的回调页面
  bool isLoadingCallbackPage = false;

  final usernameCtrl = new TextEditingController(text: '');
  final passwordCtrl = new TextEditingController(text: '');

  // 检查当前是否是输入账号密码界面，返回1表示是，0表示否
  final scriptCheckIsInputAccountPage = "document.getElementById('f_email') != null";

  final jsCtrl = new TextEditingController(text: 'document.getElementById(\'f_email\') != null');
//  final jsCtrl = new TextEditingController(text: "document.getElementById('f_email').value='yubo725@qq.com';document.getElementById('f_pwd').value='android#1991'");
  GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey();

  // URL变化监听器
  StreamSubscription<String> _onUrlChanged;
  // WebView加载状态变化监听器
  StreamSubscription<WebViewStateChanged> _onStateChanged;
  // 插件提供的对象，该对象用于WebView的各种操作
  FlutterWebviewPlugin flutterWebViewPlugin = new FlutterWebviewPlugin();

  @override
  void initState() {
    super.initState();
    // 监听WebView的加载事件，该监听器已不起作用，不回调
    _onStateChanged = flutterWebViewPlugin.onStateChanged.listen((WebViewStateChanged state) {
      // state.type是一个枚举类型，取值有：WebViewState.shouldStart, WebViewState.startLoad, WebViewState.finishLoad
      switch (state.type) {
        case WebViewState.shouldStart:
          // 准备加载
          setState(() {
            loading = true;
          });
          print('shouldStart');
          break;
        case WebViewState.startLoad:
          // 开始加载
          print('startLoad');
          break;
        case WebViewState.finishLoad:
          // 加载完成
          setState(() {
            loading = false;
          });
          if (isLoadingCallbackPage) {
            // 当前是回调页面，则调用js方法获取数据
//            parseResult();
          }
          print('finishLoad');
          break;
      }
    });
    _onUrlChanged = flutterWebViewPlugin.onUrlChanged.listen((url) {
      // 登录成功会跳转到自定义的回调页面，该页面地址为http://yubo725.top/osc/osc.php?code=xxx
      // 该页面会接收code，然后根据code换取AccessToken，并将获取到的token及其他信息，通过js的get()方法返回
      if (url != null && url.length > 0 && url.contains("osc/osc.php?code=")) {
        isLoadingCallbackPage = true;
      }
    });
  }

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
            new Container(
              width: MediaQuery.of(context).size.width,
              height: 200.0,
              child: new WebviewScaffold(
                key: _scaffoldKey,
                url: Constants.LOGIN_URL, // 登录的URL
                hidden: false,
                withZoom: true,  // 允许网页缩放
                withLocalStorage: true, // 允许LocalStorage
                withJavascript: true, // 允许执行js代码
              ),
            ),
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
                // 拿到用户输入的账号密码
                String username = usernameCtrl.text;
                String password = passwordCtrl.text;
                // 发送给webview，让webview登录后再取回token
                print("username = $username, password = $password");
              },
            ),
            new TextField(
              controller: jsCtrl,
            ),
            new RaisedButton(
              child: new Text("Eval"),
              onPressed: () {
                var jsStr = jsCtrl.text;
                if (jsStr != null) {
                  flutterWebViewPlugin.evalJavascript(jsStr).then((result) {
                    print(result);
                  });
                }
              },
            )
          ],
        ),
      )
    );
  }

  @override
  void dispose() {
    // 回收相关资源
    // Every listener should be canceled, the same should be done with this stream.
    _onUrlChanged.cancel();
    _onStateChanged.cancel();
    flutterWebViewPlugin.dispose();

    super.dispose();
  }
}