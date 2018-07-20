import 'dart:async';
import 'package:flutter/material.dart';
import '../constants/Constants.dart';
import 'package:flutter/cupertino.dart';
import 'dart:convert';
import '../util/DataUtils.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';

class LoginPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new LoginPageState();
}

class LoginPageState extends State<LoginPage> {
  int count = 0;
  final int MAX_COUNT = 5;
  bool loading = true;
  GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey();
  StreamSubscription<String> _onUrlChanged;
  StreamSubscription<WebViewStateChanged> _onStateChanged;
  FlutterWebviewPlugin flutterWebViewPlugin = new FlutterWebviewPlugin();

  @override
  void initState() {
    super.initState();
    // 监听WebView的加载事件，该监听器已不起作用，不回调
    _onStateChanged = flutterWebViewPlugin.onStateChanged.listen((state) {});
    _onUrlChanged = flutterWebViewPlugin.onUrlChanged.listen((url) {
      setState(() {
        loading = false;
      });
      if (url != null && url.length > 0 && url.contains("osc/osc.php?code=")) {
        // android中onUrlChanged回调时页面已加载完成，由于onStateChanged回调不能用，这里延迟1秒去拿js中的数据，没拿到就再延迟1秒，最多取5次
        new Timer(const Duration(seconds: 1), parseResult);
      }
    });
  }

  // 解析webview中的数据
  void parseResult() {
    if (count > MAX_COUNT) {
      return;
    }
    flutterWebViewPlugin.evalJavascript("get();").then((result) {
      ++count;
      // result json字符串，包含token信息
      if (result != null && result.length > 0) {
        // 拿到了js中的数据
        try {
          // what the fuck?? need twice decode??
          var map = json.decode(result); // s is String
          if (map is String) {
            map = json.decode(map); // map is Map
          }
          if (map != null) {
            // 登录成功，取到了token，关闭当前页面
            DataUtils.saveLoginInfo(map);
            Navigator.pop(context, "refresh");
          }
        } catch (e) {
          print("parse login result error: $e");
        }
      } else {
        // 没拿到js中的数据，延迟一秒再拿
        new Timer(const Duration(seconds: 1), parseResult);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> titleContent = [];
    titleContent.add(new Text(
      "登录开源中国",
      style: new TextStyle(color: Colors.white),
    ));
    if (loading) {
      titleContent.add(new CupertinoActivityIndicator());
    }
    titleContent.add(new Container(width: 50.0));
    return new WebviewScaffold(
      key: _scaffoldKey,
      url: Constants.LOGIN_URL,
      appBar: new AppBar(
        title: new Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: titleContent,
        ),
        iconTheme: new IconThemeData(color: Colors.white),
      ),
      withZoom: true,
      withLocalStorage: true,
      withJavascript: true,
    );
  }

  @override
  void dispose() {
    // Every listener should be canceled, the same should be done with this stream.
    _onUrlChanged.cancel();
    _onStateChanged.cancel();

    flutterWebViewPlugin.dispose();

    super.dispose();
  }
}
