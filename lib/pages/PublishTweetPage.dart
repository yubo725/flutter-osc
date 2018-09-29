import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:async/async.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import '../api/Api.dart';
import 'package:http/http.dart' as http;
import '../util/DataUtils.dart';
import 'package:image_picker/image_picker.dart';

class PublishTweetPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return new PublishTweetPageState();
  }
}

class PublishTweetPageState extends State<PublishTweetPage> {

  TextEditingController _controller = new TextEditingController();
  List<File> fileList = new List();
  Future<File> _imageFile;
  bool isLoading = false;
  String msg = "";

  Widget getBody() {
    // 输入框
    var textField = new TextField(
      decoration: new InputDecoration(
        hintText: "说点什么吧～",
        hintStyle: new TextStyle(
          color: const Color(0xFF808080)
        ),
        border: new OutlineInputBorder(
          borderRadius: const BorderRadius.all(const Radius.circular(10.0))
        )
      ),
      maxLines: 6,
      maxLength: 150,
      controller: _controller,
    );
    // gridView用来显示选择的图片
    var gridView = new Builder(
      builder: (ctx) {
        return new GridView.count(
          // 分4列显示
          crossAxisCount: 4,
          children: new List.generate(fileList.length + 1, (index) {
            // 这个方法体用于生成GridView中的一个item
            var content;
            if (index == 0) {
              // 添加图片按钮
              var addCell = new Center(
                  child: new Image.asset('./images/ic_add_pics.png', width: 80.0, height: 80.0,)
              );
              content = new GestureDetector(
                onTap: () {
                  // 添加图片
                  pickImage(ctx);
                },
                child: addCell,
              );
            } else {
              // 被选中的图片
              content = new Center(
                  child: new Image.file(fileList[index - 1], width: 80.0, height: 80.0, fit: BoxFit.cover,)
              );
            }
            return new Container(
              margin: const EdgeInsets.all(2.0),
              width: 80.0,
              height: 80.0,
              color: const Color(0xFFECECEC),
              child: content,
            );
          }),
        );
      },
    );
    var children = [
      new Text("提示：由于OSC的openapi限制，发布动弹的接口只支持上传一张图片，本项目可添加最多9张图片，但OSC只会接收最后一张图片。", style: new TextStyle(fontSize: 12.0),),
      textField,
      new Container(
          margin: const EdgeInsets.fromLTRB(0.0, 10.0, 0.0, 0.0),
          height: 200.0,
          child: gridView
      )
    ];
    if (isLoading) {
      children.add(new Container(
        margin: const EdgeInsets.fromLTRB(0.0, 20.0, 0.0, 0.0),
        child: new Center(
          child: new CircularProgressIndicator(),
        ),
      ));
    } else {
      children.add(new Container(
        margin: const EdgeInsets.fromLTRB(0.0, 20.0, 0.0, 0.0),
        child: new Center(
          child: new Text(msg),
        )
      ));
    }
    return new Container(
      padding: const EdgeInsets.all(5.0),
      child: new Column(
        children: children,
      ),
    );
  }

  // 相机拍照或者从图库选择图片
  pickImage(ctx) {
    // 如果已添加了9张图片，则提示不允许添加更多
    num size = fileList.length;
    if (size >= 9) {
      Scaffold.of(ctx).showSnackBar(new SnackBar(
        content: new Text("最多只能添加9张图片！"),
      ));
      return;
    }
    showModalBottomSheet<void>(context: context, builder: _bottomSheetBuilder);
  }

  Widget _bottomSheetBuilder(BuildContext context) {
    return new Container(
      height: 182.0,
      child: new Padding(
        padding: const EdgeInsets.fromLTRB(0.0, 30.0, 0.0, 30.0),
        child: new Column(
          children: <Widget>[
            _renderBottomMenuItem("相机拍照", ImageSource.camera),
            new Divider(height: 2.0,),
            _renderBottomMenuItem("图库选择照片", ImageSource.gallery)
          ],
        ),
      )
    );
  }

  _renderBottomMenuItem(title, ImageSource source) {
    var item = new Container(
      height: 60.0,
      child: new Center(
        child: new Text(title)
      ),
    );
    return new InkWell(
      child: item,
      onTap: () {
        Navigator.of(context).pop();
        setState(() {
          _imageFile = ImagePicker.pickImage(source: source);
        });
      },
    );
  }

  sendTweet(ctx, token) async {
    // 未登录或者未输入动弹内容时，使用SnackBar提示用户
    if (token == null) {
      Scaffold.of(ctx).showSnackBar(new SnackBar(
        content: new Text("未登录！"),
      ));
      return;
    }
    String content = _controller.text;
    if (content == null || content.length == 0 || content.trim().length == 0) {
      Scaffold.of(ctx).showSnackBar(new SnackBar(
        content: new Text("请输入动弹内容！"),
      ));
    }
    // 下面是调用接口发布动弹的逻辑
    try {
      Map<String, String> params = new Map();
      params['msg'] = content;
      params['access_token'] = token;
      // 构造一个MultipartRequest对象用于上传图片
      var request = new MultipartRequest('POST', Uri.parse(Api.PUB_TWEET));
      request.fields.addAll(params);
      if (fileList != null && fileList.length > 0) {
        // 这里虽然是添加了多个图片文件，但是开源中国提供的接口只接收一张图片
        for (File f in fileList) {
          // 文件流
          var stream = new http.ByteStream(
              DelegatingStream.typed(f.openRead()));
          // 文件长度
          var length = await f.length();
          // 文件名
          var filename = f.path.substring(f.path.lastIndexOf("/") + 1);
          // 将文件加入到请求体中
          request.files.add(new http.MultipartFile(
              'img', stream, length, filename: filename));
        }
      }
      setState(() {
        isLoading = true;
      });
      // 发送请求
      var response = await request.send();
      // 解析请求返回的数据
      response.stream.transform(utf8.decoder).listen((value) {
        print(value);
        if (value != null) {
          var obj = json.decode(value);
          var error = obj['error'];
          setState(() {
            if (error != null && error == '200') {
              // 成功
              setState(() {
                isLoading = false;
                msg = "发布成功";
                fileList.clear();
              });
              _controller.clear();
            } else {
              setState(() {
                isLoading = false;
                msg = "发布失败：$error";
              });
            }
          });
        }
      });
    } catch (exception) {
      print(exception);
    }
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text("发布动弹", style: new TextStyle(color: Colors.white)),
        iconTheme: new IconThemeData(color: Colors.white),
        actions: <Widget>[
          new Builder(
            builder: (ctx) {
              return new IconButton(icon: new Icon(Icons.send), onPressed: () {
                // 发送动弹
                DataUtils.isLogin().then((isLogin) {
                  if (isLogin) {
                    return DataUtils.getAccessToken();
                  } else {
                    return null;
                  }
                }).then((token) {
                  sendTweet(ctx, token);
                });
              });
            },
          )
        ],
      ),
      // 在这里接收选择的图片
      body: new FutureBuilder(
        future: _imageFile,
        builder: (BuildContext context, AsyncSnapshot<File> snapshot) {
          if (snapshot.connectionState == ConnectionState.done &&
              snapshot.data != null && _imageFile != null) {
            // 选择了图片（拍照或图库选择），添加到List中
            fileList.add(snapshot.data);
            _imageFile = null;
          }
          // 返回的widget
          return getBody();
        },
      ),
    );
  }
}