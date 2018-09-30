import 'package:flutter/material.dart';

class SlideViewIndicator extends StatefulWidget {
  int count;
  int selectedIndex = 0;
  SlideViewIndicatorState state;

  SlideViewIndicator(count) {
    this.count = count;
    this.state = new SlideViewIndicatorState();
  }

//  setSelectedIndex(int index) {
//    this.state.setSelectedIndex(index);
//  }

  @override
  State<StatefulWidget> createState() => this.state;
}

class SlideViewIndicatorState extends State<SlideViewIndicator> {

  final double dotWidth = 8.0;

  setSelectedIndex(int index) {
    setState(() {
      this.widget.selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> dots = [];
    for (int i = 0; i < this.widget.count; i++) {
      if (i == this.widget.selectedIndex) {
        // 选中的dot
        dots.add(new Container(
          width: dotWidth,
          height: dotWidth,
          decoration: new BoxDecoration(
            color: const Color(0xffffffff),
            shape: BoxShape.circle
          ),
          margin: const EdgeInsets.all(8.0),
        ));
      } else {
        // 未选中的dot
        dots.add(new Container(
          width: dotWidth,
          height: dotWidth,
          decoration: new BoxDecoration(
            color: const Color(0xff888888),
            shape: BoxShape.circle
          ),
          margin: const EdgeInsets.all(8.0),
        ));
      }
    }
    return new Container(
      height: 30.0,
      color: const Color(0x00000000),
      margin: const EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 5.0),
      child: new Center(
        child: new Row(
          children: dots,
          mainAxisAlignment: MainAxisAlignment.center,
        )
      ),
    );
  }
}