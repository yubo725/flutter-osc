import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';

//公共的WebView页面，需要标题和URL参数
class CommonWebPage extends StatefulWidget {
  final String title;
  final String url;

  CommonWebPage({Key key, this.title, this.url}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return CommonWebPageState();
  }
}

class CommonWebPageState extends State<CommonWebPage> {
  bool loading = true;

  final flutterWebViewPlugin = FlutterWebviewPlugin();

  @override
  void initState() {
    super.initState();
    // 监听WebView的加载事件
    flutterWebViewPlugin.onStateChanged.listen((state) {
//      if (state.type == WebViewState.finishLoad) {
//        // 加载完成
//        setState(() {
//          loading = false;
//        });
//      } else if (state.type == WebViewState.startLoad) {
//        setState(() {
//          loading = true;
//        });
//      }
    });
    flutterWebViewPlugin.onUrlChanged.listen((url) {
      setState(() {
        loading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> titleContent = [];
    titleContent.add(Text(
      widget.title,
      style: TextStyle(color: Colors.white),
    ));
    if (loading) {
      titleContent.add(CupertinoActivityIndicator());
    }
    titleContent.add(Container(width: 50.0));
    return WebviewScaffold(
      url: widget.url,
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: titleContent,
        ),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      withZoom: true,
      withLocalStorage: true,
      withJavascript: true,
    );
  }
}
