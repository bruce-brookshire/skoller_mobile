import 'dart:collection';

import 'package:dart_notification_center/dart_notification_center.dart';
import 'package:dropdown_banner/dropdown_banner.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import './modals/weight_creation_modal.dart';
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
  bool isEdited = false;

  int selectedSegment = 0;

  @override
  void initState() {
    StudentClass studentClass = StudentClass.currentClasses[widget.classId];

    isPoints = studentClass.isPoints;
    weights = (StudentClass.currentClasses[widget.classId].weights ?? [])
        .map(
          (weight) => Map<dynamic, dynamic>.fromIterables(
            ['name', 'value'],
            [weight.name, weight.weight],
          ),
        )
        .toList();

    super.initState();
  }

  void checkValid() {
    final studentClass = StudentClass.currentClasses[widget.classId];
    final weights = studentClass.weights ?? [];
    Map<String, double> weightMap = {};
    bool hasChanged = false;

    // Initialize weightMap with class weights
    for (final weight in weights) {
      weightMap[weight.name] = weight.weight;
    }

    for (final weight in this.weights) {
      final name = weight['name'];

      if (weightMap.containsKey(name)) {
        // Remove from weightMap if weightMap contains the key-val
        if (weightMap[name] == weight['value']) {
          weightMap.remove(name);
        } else {
          hasChanged = true;
          break;
        }
      } else {
        hasChanged = true;
        break;
      }
    }

    // If the weightMap has leftover weights, then we have new weights
    if (!hasChanged)
      hasChanged = weightMap.length != 0 || isPoints != studentClass.isPoints;

    if (hasChanged != isEdited) setState(() => isEdited = hasChanged);
  }

  void editWeight(int weightIndex) {
    final weight = weights[weightIndex];

    showWeightMaker(weight['name'], '${weight['value']}', false, (name, value) {
      if (name != '' && value != '' && int.tryParse(value) != null) {
        setState(
          () {
            weights[weightIndex]['name'] = name;
            weights[weightIndex]['value'] = int.parse(value);
          },
        );
        checkValid();
      }
    });
  }

  void addWeight(TapUpDetails details) {
    showWeightMaker('', '', true, (name, value) {
      if (name != '' && value != '' && int.tryParse(value) != null) {
        setState(
          () => weights.add(Map<dynamic, dynamic>.fromIterables(
            ['name', 'value'],
            [name, int.parse(value)],
          )),
        );
        checkValid();
      }
    });
  }

  Future<bool> showWeightMaker(
    String nameStr,
    String valueStr,
    bool isCreate,
    DoubleStringCallback results,
  ) {
    return showDialog(
      context: context,
      builder: (context) =>
          WeightCreationModal(isPoints, isCreate, nameStr, valueStr, results),
    );
  }

  void tappedSubmit(TapUpDetails details) {
    final currTotal = weights.fold(0, (val, item) => item['value'] + val);

    if ((isPoints || currTotal == 100) && isEdited) {
      final studentClass = StudentClass.currentClasses[widget.classId];
      final loader = SKLoadingScreen.fadeIn(context);
      final weights =
          this.weights.map((w) => w..update('value', (v) => '$v')).toList();

      studentClass
          .submitWeightChangeRequest(isPoints, weights)
          .then((success) async {
        if (success) {
          await studentClass.refetchSelf();
          loader.fadeOut();

          DartNotificationCenter.post(
              channel: NotificationChannels.classChanged);

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
    } else if (!isEdited) {
      DropdownBanner.showBanner(
          text: 'Weight structure must change to create a change request.',
          color: SKColors.alert_orange,
          textStyle: TextStyle(color: Colors.white));
    } else {
      DropdownBanner.showBanner(
          text: 'Weights must sum to 100%',
          color: SKColors.alert_orange,
          textStyle: TextStyle(color: Colors.white));
    }
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
              boxShadow: UIAssets.boxShadow,
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
                CupertinoSegmentedControl(
                  children: LinkedHashMap.fromIterables(
                    [0, 1],
                    [
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child:
                            Text('Percentage', style: TextStyle(fontSize: 14)),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: Text('Points', style: TextStyle(fontSize: 14)),
                      ),
                    ],
                  ),
                  onValueChanged: (index) {
                    isPoints = index == 1;
                    checkValid();
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
                                      checkValid();
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
                      isPoints
                          ? GestureDetector(
                              child: Text(
                                '$currTotal pts.',
                                style: TextStyle(
                                    fontSize: 20, color: SKColors.dark_gray),
                              ),
                            )
                          : Text(
                              '$currTotal / 100%',
                              style: TextStyle(
                                  fontSize: 20, color: SKColors.dark_gray),
                            ),
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
                                color:
                                    ((isPoints || currTotal == 100) && isEdited)
                                        ? SKColors.success
                                        : SKColors.inactive_gray,
                                borderRadius: BorderRadius.circular(5),
                                boxShadow: UIAssets.boxShadow),
                            child: Text(
                              'Submit weights',
                              style: TextStyle(
                                  color: ((isPoints || currTotal == 100) &&
                                          isEdited)
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
            ),
          ),
        ),
      ],
    );
  }
}
