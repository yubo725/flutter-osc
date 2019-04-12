import 'package:flutter/material.dart';

class SlideViewIndicator extends StatefulWidget {
  final int count;

  SlideViewIndicator(this.count, { Key key }) : super(key: key);

  @override
  State<StatefulWidget> createState() => SlideViewIndicatorState();
}

class SlideViewIndicatorState extends State<SlideViewIndicator> {

  final double dotWidth = 8.0;
  int selectedIndex = 0;

  setSelectedIndex(int index) {
    setState(() {
      this.selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> dots = [];
    for (int i = 0; i < this.widget.count; i++) {
      if (i == this.selectedIndex) {
        // 选中的dot
        dots.add(Container(
          width: dotWidth,
          height: dotWidth,
          decoration: BoxDecoration(
            color: const Color(0xffffffff),
            shape: BoxShape.circle
          ),
          margin: const EdgeInsets.all(3.0),
        ));
      } else {
        // 未选中的dot
        dots.add(Container(
          width: dotWidth,
          height: dotWidth,
          decoration: BoxDecoration(
            color: const Color(0xff888888),
            shape: BoxShape.circle
          ),
          margin: const EdgeInsets.all(3.0),
        ));
      }
    }
    return Container(
      height: 30.0,
      color: const Color(0x00000000),
      margin: const EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 5.0),
      child: Center(
        child: Row(
          children: dots,
          mainAxisAlignment: MainAxisAlignment.center,
        )
      ),
    );
  }
}