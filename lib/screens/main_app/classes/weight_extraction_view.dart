import 'package:dart_notification_center/dart_notification_center.dart';
import 'package:dropdown_banner/dropdown_banner.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:skoller/tools.dart';

import 'dart:collection';

import 'package:skoller/screens/main_app/classes/assignment_weight_view.dart';

class _StateKeeper {
  bool isPoints = false;
  int numPoints = 100;

  List<Map<String, dynamic>> weights = [];
}

class WeightExtractionView extends StatefulWidget {
  final int classId;

  WeightExtractionView(this.classId);

  @override
  State createState() => _WeightExtractionState();
}

class _WeightExtractionState extends State<WeightExtractionView> {
  final pageController = PageController(initialPage: 0);

  StudentClass studentClass;

  int currentView = 0;
  _StateKeeper state;

  @override
  void initState() {
    studentClass = StudentClass.currentClasses[widget.classId];
    state = _StateKeeper();
    studentClass.acquireWeightLock();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    pageController.dispose();
  }

  void forwardState() {
    if (currentView < 2) {
      final newView = currentView + 1;
      pageController
          .animateToPage(
            newView,
            duration: Duration(milliseconds: 300),
            curve: Curves.decelerate,
          )
          .then((val) => setState(() => currentView = newView));
    }
  }

  void backwardState() {
    if (currentView > 0) {
      final newView = currentView - 1;
      pageController
          .animateToPage(
            newView,
            duration: Duration(milliseconds: 300),
            curve: Curves.decelerate,
          )
          .then((val) => setState(() => currentView = newView));
    }
  }

  void popUnsuccessfully() async {
    final result = await showDialog(
      context: context,
      builder: (context) => SKAlertDialog(
        title: 'Lose progress',
        subTitle: 'Are you sure you want to abandon progress?',
        confirmText: 'Confirm',
        cancelText: 'Cancel',
      ),
    );

    if (result is bool && result) {
      studentClass.releaseDIYLock(isCompleted: false);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SKNavView(
      title: studentClass.name,
      titleColor: studentClass.getColor(),
      callbackLeft: popUnsuccessfully,
      children: <Widget>[
        Padding(
          padding: EdgeInsets.symmetric(vertical: 12),
          child: SammiSpeechBubble(
            sammiPersonality: SammiPersonality.smile,
            speechBubbleContents: Text.rich(
              currentView < 2
                  ? TextSpan(
                      text: 'Instant setup involves 2 easy steps. ',
                      style: TextStyle(fontWeight: FontWeight.normal),
                      children: [
                        TextSpan(
                          text: 'First, set up weights!',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    )
                  : TextSpan(
                      text: 'Add these weights for the entire class. ',
                      style: TextStyle(fontWeight: FontWeight.normal),
                      children: [
                        TextSpan(
                          text: 'Accuracy is key!',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
            ),
          ),
        ),
        Expanded(
          child: SafeArea(
            top: false,
            child: Container(
              margin: EdgeInsets.fromLTRB(16, 4, 16, 12),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: SKColors.border_gray),
                borderRadius: BorderRadius.circular(10),
                boxShadow: [UIAssets.boxShadow],
              ),
              child: Column(children: [
                Container(
                  alignment: Alignment.centerLeft,
                  padding: EdgeInsets.fromLTRB(12, 12, 12, 8),
                  decoration: BoxDecoration(
                    color: SKColors.selected_gray,
                    borderRadius: BorderRadius.only(
                      topRight: Radius.circular(10),
                      topLeft: Radius.circular(10),
                    ),
                  ),
                  child: Text(
                    'Step 1: Set up weights',
                    style: TextStyle(fontSize: 17),
                  ),
                ),
                Expanded(
                  child: PageView(
                    physics: NeverScrollableScrollPhysics(),
                    controller: pageController,
                    children: <Widget>[
                      _SubviewOne(this),
                      _SubviewTwo(this),
                      _SubviewThree(this),
                    ],
                  ),
                ),
              ]),
            ),
          ),
        )
      ],
    );
  }
}

class _SubviewOne extends StatefulWidget {
  final _WeightExtractionState subviewParent;

  _SubviewOne(this.subviewParent);

  @override
  State createState() => _SubviewOneState();
}

class _SubviewOneState extends State<_SubviewOne> {
  @override
  Widget build(BuildContext context) => Column(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(top: 16),
            child: Text(
              'For example, Exams are worth 60% of your grade.',
              style: TextStyle(
                  fontSize: 13,
                  // color: SKColors.text_light_gray,
                  fontWeight: FontWeight.normal),
              textAlign: TextAlign.center,
            ),
          ),
          Spacer(),
          GestureDetector(
            onTapUp: (details) => widget.subviewParent.forwardState(),
            child: Container(
              alignment: Alignment.center,
              width: 160,
              height: 36,
              margin: EdgeInsets.symmetric(vertical: 24),
              decoration: BoxDecoration(
                color: SKColors.skoller_blue,
                borderRadius: BorderRadius.circular(5),
                boxShadow: [UIAssets.boxShadow],
              ),
              child: Text(
                'Start',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
          Spacer(),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 16, horizontal: 24),
            child: Text(
              'This class does not have weighted assignments.',
              style: TextStyle(
                  color: SKColors.skoller_blue, fontWeight: FontWeight.normal),
              textAlign: TextAlign.center,
            ),
          )
        ],
      );
}

class _SubviewTwo extends StatefulWidget {
  final _WeightExtractionState subviewParent;

  _SubviewTwo(this.subviewParent);
  @override
  State createState() => _SubviewTwoState();
}

class _SubviewTwoState extends State<_SubviewTwo> {
  int selectedSegment = 0;
  bool get isPoints => selectedSegment == 1;

  void updateType(int index) {
    widget.subviewParent.state.isPoints = index == 1;
    setState(() => selectedSegment = index);
  }

  void updatePointsVal(String pointsStr) {
    final pointsVal = int.parse(pointsStr);
    widget.subviewParent.state.numPoints = pointsVal;
  }

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Text(
              'Is this class based on percentages or points?',
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.normal),
            ),
          ),
          CupertinoSegmentedControl(
            children: LinkedHashMap.fromIterables(
              [0, 1],
              [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Text('Percentage', style: TextStyle(fontSize: 14)),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Text('Points', style: TextStyle(fontSize: 14)),
                ),
              ],
            ),
            onValueChanged: updateType,
            selectedColor: SKColors.skoller_blue,
            unselectedColor: Colors.white,
            borderColor: SKColors.skoller_blue,
            pressedColor: SKColors.skoller_blue.withOpacity(0.2),
            padding: EdgeInsets.symmetric(vertical: 16),
            groupValue: selectedSegment,
          ),
          ...isPoints
              ? [
                  Text(
                    'Total points available',
                    style: TextStyle(fontWeight: FontWeight.normal),
                  ),
                  Container(
                    margin: EdgeInsets.symmetric(vertical: 6),
                    width: 140,
                    height: 36,
                    child: CupertinoTextField(
                      keyboardType: TextInputType.number,
                      onChanged: updatePointsVal,
                      placeholder: 'e.g. 50',
                      textAlign: TextAlign.center,
                      decoration: BoxDecoration(
                        border: Border.all(color: SKColors.border_gray),
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                  ),
                ]
              : [],
          GestureDetector(
            onTapUp: (details) => widget.subviewParent.forwardState(),
            child: Container(
              alignment: Alignment.center,
              margin: EdgeInsets.symmetric(vertical: 16),
              width: 120,
              height: 36,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5),
                  color: SKColors.skoller_blue,
                  boxShadow: [UIAssets.boxShadow]),
              child: Text(
                'Next',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
        ],
      );
}

class _SubviewThree extends StatefulWidget {
  final _WeightExtractionState subviewParent;

  _SubviewThree(this.subviewParent);
  @override
  State createState() => _SubviewThreeState();
}

class _SubviewThreeState extends State<_SubviewThree> {
  int selectedSegment = 0;
  int numPoints = 0;
  bool get isPoints => selectedSegment == 1;

  @override
  void initState() {
    super.initState();

    selectedSegment = widget.subviewParent.state.isPoints ? 1 : 0;
    numPoints = isPoints ? widget.subviewParent.state.numPoints : 100;
  }

  void editWeight(int weightIndex) {
    final weight = widget.subviewParent.state.weights[weightIndex];

    showWeightMaker(weight['name'], '${weight['value']}', false, (name, value) {
      if (name != '' && value != '' && int.tryParse(value) != null) {
        setState(
          () {
            widget.subviewParent.state.weights[weightIndex]['name'] = name;
            widget.subviewParent.state.weights[weightIndex]['value'] =
                int.parse(value);
          },
        );
      }
    });
  }

  void addWeight(TapUpDetails details) {
    showWeightMaker('', '', true, (name, value) {
      if (name != '' && value != '' && int.tryParse(value) != null) {
        setState(
          () => widget.subviewParent.state.weights.add(
            {
              'name': name,
              'value': int.parse(value),
            },
          ),
        );
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
      builder: (context) => _WeightExtractionFormModal(
          isPoints, isCreate, nameStr, valueStr, results),
    );
  }

  void updateType(int index) {
    widget.subviewParent.state.isPoints = index == 1;
    setState(() => selectedSegment = index);
  }

  void updatePointsVal(String pointsStr) {
    final pointsVal = int.parse(pointsStr);
    widget.subviewParent.state.numPoints = pointsVal;
  }

  void tappedSubmit(TapUpDetails details) async {
    final currTotal = widget.subviewParent.state.weights
        .fold(0, (val, item) => item['value'] + val);
    final validTotal = (isPoints ? numPoints : 100) == currTotal;

    if (!validTotal) return;

    final loadingScreen = SKLoadingScreen.fadeIn(context);

    final state = widget.subviewParent.state;
    final studentClass = widget.subviewParent.studentClass;

    studentClass.createWeights(state.isPoints, state.weights).then((success) {
      //After creating
      if (success) {
        return studentClass.releaseDIYLock(isCompleted: true);
      } else {
        throw 'Failed to create weights';
      }
    }).then((response) {
      //After releasing
      if (response.wasSuccessful()) {
        return studentClass.refetchSelf();
      } else {
        throw 'Failed to unlock assignment. Try again in a few minutes';
      }
    }).then((response) {
      DropdownBanner.showBanner(
        text: 'Successfully created weights!',
        color: SKColors.success,
        textStyle: TextStyle(color: Colors.white),
      );

      //After reloading class
      if (response.wasSuccessful()) {
        //New info is available, push to assignments
        DartNotificationCenter.post(channel: NotificationChannels.classChanged);

        loadingScreen.dismiss();

        Navigator.pushReplacement(
          context,
          CupertinoPageRoute(
            builder: (context) => AssignmentWeightView(studentClass.id),
            settings: RouteSettings(name: 'AssignmentWeightView'),
          ),
        );
      } else {
        //Pop because new studentClass info isnt ready yet
        Navigator.pop(context);
      }
    }).catchError((error) {
      loadingScreen.dismiss();

      if (error is String) {
        DropdownBanner.showBanner(
          text: error,
          color: SKColors.warning_red,
          textStyle: TextStyle(color: Colors.white),
        );
      } else {
        DropdownBanner.showBanner(
          text: 'Something went wrong :/',
          color: SKColors.warning_red,
          textStyle: TextStyle(color: Colors.white),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = widget.subviewParent.state;

    final currTotal = state.weights.fold(0, (val, item) => item['value'] + val);
    final validTotal = (isPoints ? numPoints : 100) == currTotal;

    return Column(
      children: <Widget>[
        CupertinoSegmentedControl(
          children: LinkedHashMap.fromIterables(
            [0, 1],
            [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Text('Percentage', style: TextStyle(fontSize: 14)),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Text('Points', style: TextStyle(fontSize: 14)),
              ),
            ],
          ),
          onValueChanged: updateType,
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
                itemCount: state.weights.length,
                itemBuilder: (context, index) {
                  final weight = state.weights[index];
                  return GestureDetector(
                    onTapUp: (details) => editWeight(index),
                    child: Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          GestureDetector(
                            onTapUp: (details) {
                              setState(() {
                                state.weights.removeAt(index);
                              });
                            },
                            child: Padding(
                              padding: EdgeInsets.only(right: 12),
                              child: Image.asset(
                                  ImageNames.assignmentInfoImages.circle_x),
                            ),
                          ),
                          Expanded(child: Text(weight['name'])),
                          Text('${weight['value']}${isPoints ? ' pts.' : '%'}'),
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
                onTapUp: (details) => widget.subviewParent.backwardState(),
                child: Text(
                  '$currTotal / ${isPoints ? numPoints : 100}${isPoints ? '' : '%'}',
                  style: TextStyle(
                      fontSize: 20,
                      color:
                          validTotal ? SKColors.success : SKColors.dark_gray),
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
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.normal),
              ),
              Text(
                'Weights must sum to ${isPoints ? '$numPoints' : '100'}',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.normal),
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
                        color: validTotal
                            ? SKColors.success
                            : SKColors.inactive_gray,
                        borderRadius: BorderRadius.circular(5),
                        boxShadow: [UIAssets.boxShadow]),
                    child: Text(
                      'Submit weights',
                      style: TextStyle(
                          color:
                              validTotal ? Colors.white : SKColors.light_gray),
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ],
    );
  }
}

class _WeightExtractionFormModal extends StatefulWidget {
  final bool isPoints;
  final bool isCreate;

  final String startNameVal;
  final String startValueVal;

  final DoubleStringCallback resultsCallback;

  _WeightExtractionFormModal(this.isPoints, this.isCreate, this.startNameVal,
      this.startValueVal, this.resultsCallback);

  @override
  State createState() => _WeightExtractionFormModalState();
}

class _WeightExtractionFormModalState
    extends State<_WeightExtractionFormModal> {
  final nameFocusNode = FocusNode();
  final valueFocusNode = FocusNode();

  TextEditingController nameController;
  TextEditingController valueController;

  @override
  void initState() {
    nameController = TextEditingController(text: widget.startNameVal);
    valueController = TextEditingController(text: widget.startValueVal);
    super.initState();
  }

  @override
  void dispose() {
    unfocusNodes();

    nameFocusNode.dispose();
    valueFocusNode.dispose();

    nameController.dispose();
    valueController.dispose();

    super.dispose();
  }

  void unfocusNodes() {
    nameFocusNode.unfocus();
    valueFocusNode.unfocus();
  }

  @override
  Widget build(BuildContext context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: BorderSide(color: SKColors.border_gray),
        ),
        child: Padding(
          padding: EdgeInsets.fromLTRB(12, 12, 12, 0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Text(
                widget.isCreate ? 'Create weight' : 'Update weight',
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
                autofocus: true,
                focusNode: nameFocusNode,
                textInputAction: TextInputAction.next,
                placeholderStyle:
                    TextStyle(fontSize: 14, color: SKColors.text_light_gray),
                onSubmitted: (_) => nameFocusNode.nextFocus(),
                style: TextStyle(color: SKColors.dark_gray, fontSize: 15),
              ),
              Padding(
                padding: EdgeInsets.only(top: 12),
                child: Text('Value'),
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
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
                        focusNode: valueFocusNode,
                        keyboardType: TextInputType.number,
                        placeholderStyle: TextStyle(
                            fontSize: 14, color: SKColors.text_light_gray),
                        style:
                            TextStyle(color: SKColors.dark_gray, fontSize: 15),
                      )),
                  Padding(
                    padding: EdgeInsets.only(left: 8),
                    child: Text('${widget.isPoints ? 'pts.' : '%'}'),
                  ),
                  Spacer(),
                ],
              ),
              GestureDetector(
                onTapUp: (details) {
                  widget.resultsCallback(
                      nameController.text, valueController.text);
                  unfocusNodes();
                  Navigator.pop(context);
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: SKColors.skoller_blue,
                    borderRadius: BorderRadius.circular(5),
                  ),
                  padding: EdgeInsets.symmetric(vertical: 8),
                  margin: EdgeInsets.symmetric(vertical: 12),
                  child: Text(
                    'Add',
                    style: TextStyle(color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
}
