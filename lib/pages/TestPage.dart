import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class TestPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: "Test",
      home: new Scaffold(
        appBar: new AppBar(
          title: new Text("Test"),
        ),
        body: new Center(
          child: new Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              new Text("hello"),
              new Text("world")
            ],
          ),
        ),
//        body: new Container(
//          margin: const EdgeInsets.all(10.0),
//          width: 80.0,
//          height: 80.0,
//          decoration: new BoxDecoration(
//            shape: BoxShape.circle,
//            color: Colors.blue,
//            image: new DecorationImage(
//              image: new ExactAssetImage('./images/ic_test.png'),
//              fit: BoxFit.cover
//            ),
//            border: new Border.all(
//              color: Colors.white,
//              width: 2.0,
//            ),
//          ),
//        ),
      ),
    );
  }
}