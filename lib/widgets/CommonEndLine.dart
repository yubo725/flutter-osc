import 'package:flutter/material.dart';

class CommonEndLine extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new Container(
      color: const Color(0xFFEEEEEE),
      padding: const EdgeInsets.fromLTRB(5.0, 15.0, 5.0, 15.0),
      child: new Row(
        children: <Widget>[
          new Expanded(
            child: new Divider(height: 10.0,),
            flex: 1,
          ),
          new Text("我也是有底线的"),
          new Expanded(
            child: new Divider(height: 10.0,),
            flex: 1,
          ),
        ],
      ),
    );
  }
}