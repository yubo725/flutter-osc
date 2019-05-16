import 'dart:async';
import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_osc/constants/Constants.dart';
import 'package:flutter_osc/pages/LoginPage.dart';
import 'package:flutter_osc/util/DataUtils.dart';
import 'package:flutter_osc/util/ThemeUtils.dart';
import 'package:flutter_osc/widgets/CommonButton.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';

import 'AboutPage.dart';

// 新的登录界面，隐藏WebView登录页面
class NewLoginPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => NewLoginPageState();
}

class NewLoginPageState extends State<NewLoginPage> {
  // 首次加载登录页
  static const int stateFirstLoad = 1;
  // 加载完毕登录页，且当前页面是输入账号密码的页面
  static const int stateLoadedInputPage = 2;
  // 加载完毕登录页，且当前页面不是输入账号密码的页面
  static const int stateLoadedNotInputPage = 3;

  int curState = stateFirstLoad;

  // 标记是否是加载中
  bool loading = true;
  // 标记当前页面是否是我们自定义的回调页面
  bool isLoadingCallbackPage = false;
  // 是否正在登录
  bool isOnLogin = false;
  // 是否隐藏输入的文本
  bool obscureText = true;
  // 是否解析了结果
  bool parsedResult = false;

  final usernameCtrl = TextEditingController(text: '');
  final passwordCtrl = TextEditingController(text: '');

  // 检查当前是否是输入账号密码界面，返回1表示是，0表示否
  final scriptCheckIsInputAccountPage = "document.getElementById('f_email') != null";

  final jsCtrl = TextEditingController(text: 'document.getElementById(\'f_email\') != null');
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();

  // URL变化监听器
  StreamSubscription<String> _onUrlChanged;
  // WebView加载状态变化监听器
  StreamSubscription<WebViewStateChanged> _onStateChanged;
  // 插件提供的对象，该对象用于WebView的各种操作
  FlutterWebviewPlugin flutterWebViewPlugin = FlutterWebviewPlugin();

  @override
  void initState() {
    super.initState();
    // 监听WebView的加载事件
    _onStateChanged = flutterWebViewPlugin.onStateChanged.listen((WebViewStateChanged state) {
      // state.type是一个枚举类型，取值有：WebViewState.shouldStart, WebViewState.startLoad, WebViewState.finishLoad
      switch (state.type) {
        case WebViewState.shouldStart:
          // 准备加载
          setState(() {
            loading = true;
          });
          break;
        case WebViewState.startLoad:
          // 开始加载
          break;
        case WebViewState.finishLoad:
          // 加载完成
          setState(() {
            loading = false;
          });
          if (isLoadingCallbackPage) {
            // 当前是回调页面，则调用js方法获取数据，延迟加载防止get()获取不到数据
            Timer(const Duration(seconds: 1), () {
              parseResult();
            });
            return;
          }
          switch (curState) {
            case stateFirstLoad:
            case stateLoadedInputPage:
              // 首次加载完登录页，判断是否是输入账号密码的界面
              isInputPage().then((result) {
                if ("true".compareTo(result) == 0) {
                  // 是输入账号的页面，则直接填入账号密码并模拟点击登录按钮
//                  autoLogin();
                } else {
                  // 不是输入账号的页面，则需要模拟点击"换个账号"按钮
                  redirectToInputPage();
                }
              });
              break;
            case stateLoadedNotInputPage:
              // 不是输入账号密码的界面，则需要模拟点击"换个账号"按钮
              break;
          }
          break;
        case WebViewState.abortLoad:
          break;
      }
    });
    _onUrlChanged = flutterWebViewPlugin.onUrlChanged.listen((url) {
      // 登录成功会跳转到自定义的回调页面，该页面地址为http://yubo725.top/osc/osc.php?code=xxx
      // 该页面会接收code，然后根据code换取AccessToken，并将获取到的token及其他信息，通过js的get()方法返回
      if (url != null && url.length > 0 && url.contains("/logincallback?")) {
        isLoadingCallbackPage = true;
      }
    });
  }

  // 检查当前WebView是否是输入账号密码的页面
  Future<String> isInputPage() async {
    return await flutterWebViewPlugin.evalJavascript("document.getElementById('f_email') != null");
  }

  // 跳转到输入界面
  redirectToInputPage() {
    curState = stateLoadedInputPage;
    String js = "document.getElementsByClassName('userbar')[0].getElementsByTagName('a')[1].click()";
    flutterWebViewPlugin.evalJavascript(js);
  }

  // 自动登录
  void autoLogin(String account, String pwd) {
    setState(() {
      isOnLogin = true;
    });
    // 填账号
    String jsInputAccount = "document.getElementById('f_email').value='$account'";
    // 填密码
    String jsInputPwd = "document.getElementById('f_pwd').value='$pwd'";
    // 点击"连接"按钮
    String jsClickLoginBtn = "document.getElementsByClassName('rndbutton')[0].click()";
    // 执行上面3条js语句
    flutterWebViewPlugin.evalJavascript("$jsInputAccount;$jsInputPwd;$jsClickLoginBtn");
  }

  // 解析WebView中的数据
  void parseResult() {
    if (parsedResult) {
      return;
    }
    parsedResult = true;
    flutterWebViewPlugin.evalJavascript("window.atob(get())").then((result) {
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
      }
    }).catchError((error) {
      print("get() error: $error");
    });
  }

  @override
  Widget build(BuildContext context) {
    var loginBtn = Builder(builder: (ctx) {
      return CommonButton(text: "登录", onTap: () {
        if (isOnLogin) return;
        // 拿到用户输入的账号密码
        String username = usernameCtrl.text.trim();
        String password = passwordCtrl.text.trim();
        if (username.isEmpty || password.isEmpty) {
          Scaffold.of(ctx).showSnackBar(SnackBar(
            content: Text("账号和密码不能为空！"),
          ));
          return;
        }
        // 关闭键盘
        FocusScope.of(context).requestFocus(FocusNode());
        // 发送给webview，让webview登录后再取回token
        autoLogin(username, password);
      });
    });
    var loadingView;
    if (isOnLogin) {
      loadingView = Center(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(0, 30, 0, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              CupertinoActivityIndicator(),
              Text("登录中，请稍等...")
            ],
          ),
        )
      );
    } else {
      loadingView = Center();
    }
    return Scaffold(
      appBar: AppBar(
        title: Text("登录", style: TextStyle(color: Colors.white)),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Container(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          children: <Widget>[
            Container(
              width: MediaQuery.of(context).size.width,
              height: 0.0,
              child: WebviewScaffold(
                key: _scaffoldKey,
                hidden: true,
                url: Constants.loginUrl, // 登录的URL
                withZoom: true,  // 允许网页缩放
                withLocalStorage: true, // 允许LocalStorage
                withJavascript: true, // 允许执行js代码
              ),
            ),
            Center(child: Text("请使用OSC帐号密码登录")),
            Container(height: 20.0),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Text("用户名："),
                Expanded(child: TextField(
                  controller: usernameCtrl,
                  decoration: InputDecoration(
                    hintText: "OSC帐号/注册邮箱",
                    hintStyle: TextStyle(
                        color: const Color(0xFF808080)
                    ),
                    border: OutlineInputBorder(
                        borderRadius: const BorderRadius.all(const Radius.circular(6.0))
                    ),
                    contentPadding: const EdgeInsets.all(10.0)
                  ),
                ))
              ],
            ),
            Container(height: 20.0),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Text("密　码："),
                Expanded(child: TextField(
                  controller: passwordCtrl,
                  obscureText: obscureText,
                  decoration: InputDecoration(
                    hintText: "登录密码",
                    hintStyle: TextStyle(
                        color: const Color(0xFF808080)
                    ),
                    border: OutlineInputBorder(
                        borderRadius: const BorderRadius.all(const Radius.circular(6.0))
                    ),
                    contentPadding: const EdgeInsets.all(10.0)
                  ),
                )),
                InkWell(
                  child: Container(
                    width: 40,
                    height: 40,
                    alignment: Alignment.center,
                    child: Image.asset("images/ic_eye.png", width: 20, height: 20),
                  ),
                  onTap: () {
                    setState(() {
                      obscureText = !obscureText;
                    });
                  },
                )
              ],
            ),
            Container(height: 20.0),
            loginBtn,
            Expanded(
              child: Column(
                children: <Widget>[
                  Expanded(
                    child: loadingView
                  ),
//                  Container(
//                    margin: const EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 10.0),
//                    alignment: Alignment.bottomCenter,
//                    child: InkWell(
//                      child: Padding(
//                          padding: const EdgeInsets.all(10.0),
//                          child: Text("使用WebView登录方式", style: TextStyle(fontSize: 13.0, color: ThemeUtils.currentColorTheme))
//                      ),
//                      onTap: () async {
//                        // 跳转到LoginPage
//                        final result = await Navigator.push(context, MaterialPageRoute(builder: (context) {
//                          return LoginPage();
//                        }));
//                        if (result != null && result == "refresh") {
//                          Navigator.pop(context, "refresh");
//                        }
//                      },
//                    ),
//                  ),
                ],
              )
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