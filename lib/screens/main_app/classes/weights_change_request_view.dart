import 'dart:collection';

import 'package:dropdown_banner/dropdown_banner.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:skoller/tools.dart';

class WeightsChangeRequestView extends StatefulWidget {
  final int classId;

  WeightsChangeRequestView(this.classId);

  @override
  State<StatefulWidget> createState() => _WeightsChangeRequestState();
}

class _WeightsChangeRequestState extends State<WeightsChangeRequestView> {
  List<Map> weights;
  bool isPoints;
  int selectedSegment = 0;

  @override
  void initState() {
    StudentClass studentClass = StudentClass.currentClasses[widget.classId];

    isPoints = studentClass.isPoints;
    weights = (StudentClass.currentClasses[widget.classId].weights ?? [])
        .map((weight) => {'name': weight.name, 'value': weight.weight})
        .toList();

    super.initState();
  }

  void editWeight(int weightIndex) async {
    final weight = weights[weightIndex];

    final nameController = TextEditingController(text: weight['name']);
    final valueController = TextEditingController(text: '${weight['value']}');

    final results =
        await showWeightMaker(nameController, valueController, false);

    if (results != null && results is bool && results) {
      final name = nameController.text.trim();
      final value = valueController.text.trim();

      if (name != '' &&
          value != '' &&
          int.tryParse(value) != null) {
        setState(() {
          weights[weightIndex]['name'] = name;
          weights[weightIndex]['value'] = int.parse(value);
        });
      }
    }
  }

  void addWeight(TapUpDetails details) async {
    final nameController = TextEditingController();
    final valueController = TextEditingController();

    final results =
        await showWeightMaker(nameController, valueController, true);

    if (results != null && results is bool && results) {
      final name = nameController.text.trim();
      final value = valueController.text.trim();

      if (name != '' &&
          value != '' &&
          int.tryParse(value) != null) {
        setState(
          () => weights.add({
            'name': name,
            'value': int.parse(value),
          } as Map),
        );
      }
    }
  }

  void tappedSubmit(TapUpDetails details) {
    final currTotal = weights.fold(0, (val, item) => item['value'] + val);

    if (isPoints || currTotal == 100) {
      final studentClass = StudentClass.currentClasses[widget.classId];
      final loader = SKLoadingScreen.fadeIn(context);
      studentClass.weightChangeRequest(isPoints, weights).then((success) {
        if (success) {
          loader.dismiss();
          DropdownBanner.showBanner(
            text: 'Successfully submitted for review',
            color: SKColors.success,
            textStyle: TextStyle(color: Colors.white),
          );
          Navigator.pop(context);
        } else {
          DropdownBanner.showBanner(
            text: 'Issue submitting change request',
            color: SKColors.warning_red,
            textStyle: TextStyle(color: Colors.white),
          );
        }
      });
    }
  }

  Future<bool> showWeightMaker(
    TextEditingController nameController,
    TextEditingController valueController,
    bool isCreate,
  ) {
    return showDialog(
      context: context,
      builder: (context) => Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
              side: BorderSide(color: SKColors.border_gray),
            ),
            child: Padding(
              padding: EdgeInsets.all(12),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Text(
                    isCreate ? 'Create weight' : 'Update weight',
                    style: TextStyle(fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 16),
                    child: Text('Name'),
                  ),
                  CupertinoTextField(
                    placeholder: 'Exams',
                    controller: nameController,
                    padding: EdgeInsets.fromLTRB(6, 8, 6, 4),
                    textCapitalization: TextCapitalization.words,
                    cursorColor: SKColors.skoller_blue,
                    placeholderStyle: TextStyle(
                        fontSize: 14, color: SKColors.text_light_gray),
                    style: TextStyle(color: SKColors.dark_gray, fontSize: 15),
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 12),
                    child: Text('Value'),
                  ),
                  Row(
                    children: <Widget>[
                      SizedBox(
                          width: 60,
                          child: CupertinoTextField(
                            controller: valueController,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(5),
                              border: Border.all(color: SKColors.border_gray),
                            ),
                            padding: EdgeInsets.fromLTRB(6, 8, 6, 4),
                            cursorColor: SKColors.skoller_blue,
                            placeholder: '25',
                            placeholderStyle: TextStyle(
                                fontSize: 14, color: SKColors.text_light_gray),
                            style: TextStyle(
                                color: SKColors.dark_gray, fontSize: 15),
                          )),
                      Padding(
                        padding: EdgeInsets.only(left: 8),
                        child: Text('${isPoints ? 'pts.' : '%'}'),
                      ),
                      Spacer(),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Material(
            color: Colors.white.withAlpha(0),
            child: GestureDetector(
              onTapUp: (details) => Navigator.pop(context, true),
              child: Container(
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(5),
                    boxShadow: [UIAssets.boxShadow]),
                padding: EdgeInsets.symmetric(vertical: 12, horizontal: 56),
                child: Text(
                  'Done',
                  style: TextStyle(color: SKColors.skoller_blue),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    StudentClass studentClass = StudentClass.currentClasses[widget.classId];

    final currTotal = weights.fold(0, (val, item) => item['value'] + val);

    return SKNavView(
      title: studentClass.name,
      titleColor: studentClass.getColor(),
      leftBtn: Image.asset(ImageNames.navArrowImages.down),
      backgroundColor: SKColors.background_gray,
      children: <Widget>[
        Expanded(
          child: Container(
            margin: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: SKColors.border_gray),
              boxShadow: [UIAssets.boxShadow],
            ),
            child: Column(
              children: <Widget>[
                Container(
                  padding: EdgeInsets.fromLTRB(12, 12, 12, 8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(10),
                      topRight: Radius.circular(10),
                    ),
                    color: SKColors.selected_gray,
                  ),
                  child: Row(
                    children: <Widget>[
                      Text(
                        'Editing class weights',
                        style: TextStyle(fontSize: 17),
                      ),
                    ],
                  ),
                ),
                ...[
                  CupertinoSegmentedControl(
                    children: LinkedHashMap.fromIterables(
                      [0, 1],
                      [
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16),
                          child: Text('Percentage',
                              style: TextStyle(fontSize: 14)),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16),
                          child: Text('Points', style: TextStyle(fontSize: 14)),
                        ),
                      ],
                    ),
                    onValueChanged: (index) {
                      isPoints = index == 1;
                      setState(() => selectedSegment = index);
                    },
                    selectedColor: SKColors.skoller_blue,
                    unselectedColor: Colors.white,
                    borderColor: SKColors.skoller_blue,
                    pressedColor: SKColors.skoller_blue.withOpacity(0.2),
                    padding: EdgeInsets.symmetric(vertical: 16),
                    groupValue: selectedSegment,
                  ),
                  Expanded(
                    child: Container(
                      margin: EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                          border: Border.all(color: SKColors.border_gray),
                          borderRadius: BorderRadius.circular(5)),
                      child: ListView.builder(
                          itemCount: weights.length,
                          itemBuilder: (context, index) {
                            final weight = weights[index];
                            return GestureDetector(
                              onTapUp: (details) => editWeight(index),
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 12),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    GestureDetector(
                                      onTapUp: (details) {
                                        setState(() {
                                          weights.removeAt(index);
                                        });
                                      },
                                      child: Padding(
                                        padding: EdgeInsets.only(right: 12),
                                        child: Image.asset(ImageNames
                                            .assignmentInfoImages.circle_x),
                                      ),
                                    ),
                                    Expanded(child: Text(weight['name'])),
                                    Text('${weight['value']}'),
                                  ],
                                ),
                              ),
                            );
                          }),
                    ),
                  ),
                  GestureDetector(
                    onTapUp: addWeight,
                    child: Container(
                      alignment: Alignment.center,
                      margin: EdgeInsets.symmetric(vertical: 12),
                      width: 160,
                      height: 36,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5),
                          color: SKColors.skoller_blue),
                      child: Text(
                        'Add weight',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: <Widget>[
                        Text(
                          'Total',
                          style: TextStyle(fontSize: 20),
                        ),
                        GestureDetector(
                          // onTapUp: (details) =>
                          //     widget.subviewParent.backwardState(),
                          child: Text(
                            '$currTotal${isPoints ? '' : ' / 100'}${isPoints ? ' pts.' : '%'}',
                            style: TextStyle(
                                fontSize: 20, color: SKColors.dark_gray),
                          ),
                        )
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 18),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          '${isPoints ? 'points' : 'percentage'}',
                          style: TextStyle(
                              fontSize: 15, fontWeight: FontWeight.normal),
                        ),
                        if (!isPoints)
                          Text(
                            'Weights must sum to 100',
                            style: TextStyle(
                                fontSize: 13, fontWeight: FontWeight.normal),
                          ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 18, horizontal: 16),
                    child: Row(
                      children: <Widget>[
                        Expanded(
                          child: GestureDetector(
                            onTapUp: tappedSubmit,
                            child: Container(
                              alignment: Alignment.center,
                              padding: EdgeInsets.symmetric(vertical: 8),
                              decoration: BoxDecoration(
                                  color: (isPoints || currTotal == 100)
                                      ? SKColors.success
                                      : SKColors.inactive_gray,
                                  borderRadius: BorderRadius.circular(5),
                                  boxShadow: [UIAssets.boxShadow]),
                              child: Text(
                                'Submit weights',
                                style: TextStyle(
                                    color: (isPoints || currTotal == 100)
                                        ? Colors.white
                                        : SKColors.dark_gray),
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}
