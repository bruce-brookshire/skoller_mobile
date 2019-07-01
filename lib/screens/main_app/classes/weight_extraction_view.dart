
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:skoller/constants/constants.dart';
import 'package:skoller/requests/requests_core.dart';

import 'dart:collection';

class WeightExtractionView extends StatefulWidget {
  final int classId;

  WeightExtractionView(this.classId);

  @override
  State createState() => _WeightExtractionViewState();
}

class _WeightExtractionViewState extends State<WeightExtractionView> {
  StudentClass studentClass;
  int currentState = 0;

  @override
  void initState() {
    studentClass = StudentClass.currentClasses[widget.classId];
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SKNavView(
      title: studentClass.name,
      titleColor: studentClass.getColor(),
      children: <Widget>[
        SammiSpeechBubble(
          sammiPersonality: SammiPersonality.smile,
          speechBubbleContents: currentState < 2
              ? Text.rich(
                  TextSpan(
                    text: 'Instant setup involves 2 easy steps. ',
                    style: TextStyle(fontWeight: FontWeight.normal),
                    children: [
                      TextSpan(
                        text: 'First, setup weights!',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                )
              : TextSpan(
                  text: 'Add these weights for the entire class.',
                  style: TextStyle(fontWeight: FontWeight.normal),
                  children: [
                    TextSpan(
                      text: 'Accuracy is key!',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
        ),
        Expanded(
          child: Container(
            margin: EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: SKColors.border_gray),
              borderRadius: BorderRadius.circular(10),
            ),
            child: PageView(
              children: <Widget>[
                _SubviewOne(),
                _SubviewTwo(),
                _SubviewThree(),
              ],
            ),
          ),
        )
      ],
    );
  }
}

class _SubviewOne extends StatefulWidget {
  @override
  State createState() => _SubviewOneState();
}

class _SubviewOneState extends State<_SubviewOne> {
  @override
  Widget build(BuildContext context) => Column(
        children: <Widget>[
          CupertinoSegmentedControl(
            children: LinkedHashMap.fromIterables(
              [0, 1],
              [
                Text('Points', style: TextStyle(fontSize: 14)),
                Text('Percentage', style: TextStyle(fontSize: 14))
              ],
            ),
            onValueChanged: print,
          )
        ],
      );
}

class _SubviewTwo extends StatefulWidget {
  @override
  State createState() => _SubviewTwoState();
}

class _SubviewTwoState extends State<_SubviewTwo> {
  @override
  Widget build(BuildContext context) => Container();
}

class _SubviewThree extends StatefulWidget {
  @override
  State createState() => _SubviewThreeState();
}

class _SubviewThreeState extends State<_SubviewThree> {
  @override
  Widget build(BuildContext context) => Container();
}
