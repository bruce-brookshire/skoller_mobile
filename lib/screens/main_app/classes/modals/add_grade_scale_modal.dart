import 'package:dropdown_banner/dropdown_banner.dart';
import 'package:flutter/cupertino.dart';
import 'package:skoller/screens/main_app/classes/grade_scale_view.dart';

import 'create_single_scale_modal.dart';
import 'package:flutter/material.dart';
import 'package:skoller/tools.dart';

class AddGradeScaleModal extends StatefulWidget {
  final int classId;
  final bool onCompletionShowGradeScale;

  AddGradeScaleModal({
    required this.classId,
    required this.onCompletionShowGradeScale,
  });

  @override
  State createState() => _AddGradeScaleModalState();
}

class _AddGradeScaleModalState extends State<AddGradeScaleModal> {
  final scaleMapper = (List<String> scale, bool isSelected) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: scale
            .map((elem) => Text(
                  elem,
                  style: TextStyle(
                      color: isSelected ? Colors.white : SKColors.dark_gray),
                ))
            .toList(),
      );

  final selection_scales = [
    [
      ['A', 'B', 'C', 'D'],
      ['90', '80', '70', '60']
    ],
    [
      ['A+', 'A', 'B+', 'B', 'B-', 'C+', 'C', 'C-', 'D'],
      ['93', '90', '87', '83', '80', '77', '73', '70', '60'],
    ],
    [
      ['A+', 'A', 'B+', 'B', 'B-', 'C+', 'C', 'C-', 'D+', 'D', 'D-'],
      ['93', '90', '87', '83', '80', '77', '73', '70', '67', '63', '60'],
    ],
  ];

  int selectedIndex = 0;
  List<Map> scales = [];
  bool isCustom = false;

  final SCALE_MAP_KEY = 'letter';
  final SCALE_MAP_VAL = 'number';

  void tappedAdd(_) async {
    final result = await showDialog(
      context: context,
      builder: (context) => CreateSingleScaleModal(),
    );

    if (result is Map) {
      final index = scales.indexWhere(
        (e) => int.parse(e[SCALE_MAP_VAL]) < int.parse(result[SCALE_MAP_VAL]),
      );

      final updateIndex = scales.indexWhere(
        (e) => e[SCALE_MAP_KEY] == result[SCALE_MAP_KEY],
      );

      // If the letter grade is the same, just update the number
      if (updateIndex != -1)
        setState(
            () => scales[updateIndex][SCALE_MAP_VAL] = result[SCALE_MAP_VAL]);
      //Else, update the entry
      else
        scales.insert(index == -1 ? scales.length : index, result);
    }
  }

  void tappedRemoveScale(elem) {
    final index = scales.indexOf(elem);

    if (index != -1)
      setState(() {
        scales.removeAt(index);
      });
    else
      print('something went wrong! ${elem} ${index}');
  }

  void tappedSubmit(_) async {
    final studentClass = StudentClass.currentClasses[widget.classId];

   late Future<RequestResponse> response;

    if (isCustom) {
      final entries = scales.map(
        (e) => MapEntry(e[SCALE_MAP_KEY], e[SCALE_MAP_VAL]),
      );

      response = studentClass!.addGradeScale(Map.fromEntries(entries));
    } else if (selectedIndex > -1) {
      final scale = Map.fromIterables(selection_scales[selectedIndex][0],
          selection_scales[selectedIndex][1]);
      response = studentClass!.addGradeScale(scale);
    }

    if (response != null) {
      final result = await response;

      if (result.wasSuccessful()) {
        if (widget.onCompletionShowGradeScale) {
          Navigator.pushReplacement(
            context,
            CupertinoPageRoute(
              builder: (context) => GradeScaleView(studentClass!.id),
            ),
          );
        } else {
          Navigator.pop(context, true);
        }
      } else
        DropdownBanner.showBanner(
          text: 'Failed to add grade scale',
          color: SKColors.warning_red,
          textStyle: TextStyle(color: Colors.white),
        );
    }
  }

  void tappedDismiss(_) => Navigator.pop(context);

  void tappedCustom(_) => setState(() => isCustom = !isCustom);

  @override
  Widget build(BuildContext context) {
    if (isCustom) {
      return Material(
        color: Colors.black.withOpacity(0.3),
        type: MaterialType.transparency,
        child: SafeArea(
          child: Container(
            margin: EdgeInsets.all(24),
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: SKColors.border_gray),
              color: Colors.white,
              boxShadow: UIAssets.boxShadow,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTapUp: tappedCustom,
                      child: Container(
                        width: 32,
                        height: 32,
                        alignment: Alignment.center,
                        child: Image.asset(ImageNames.navArrowImages.left),
                      ),
                    ),
                    Text(
                      'Custom Grade Scale',
                      style: TextStyle(fontSize: 16),
                    ),
                    GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTapUp: tappedAdd,
                      child: Container(
                        width: 32,
                        height: 32,
                        alignment: Alignment.center,
                        child: Image.asset(ImageNames.rightNavImages.plus),
                      ),
                    ),
                  ],
                ),
                ...createGradeScale(),
              ],
            ),
          ),
        ),
      );
    } else {
      return Column(
        children: [
          Material(
            color: Colors.black.withOpacity(0.3),
            type: MaterialType.transparency,
            child: SafeArea(
              child: Container(
                margin: EdgeInsets.all(24),
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: SKColors.border_gray),
                  color: Colors.white,
                  boxShadow: UIAssets.boxShadow,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTapUp: tappedDismiss,
                          child: Container(
                            width: 32,
                            height: 32,
                            alignment: Alignment.center,
                            child: Image.asset(isCustom
                                ? ImageNames.navArrowImages.left
                                : ImageNames.navArrowImages.down),
                          ),
                        ),
                        Text(
                          'Select Grade Scale',
                          style: TextStyle(fontSize: 16),
                        ),
                        SizedBox(
                          width: 32,
                          height: 32,
                        ),
                      ],
                    ),
                    ...selectGradeScale(),
                  ],
                ),
              ),
            ),
          ),
        ],
      );
    }
  }

  List<Widget> selectGradeScale() {
    int curIndex = 0;
    List<Widget> containers = [];

    for (final scale in selection_scales) {
      int curTemp = curIndex.toInt();

      containers.add(
        Expanded(
          child: GestureDetector(
            onTapUp: (details) {
              if (selectedIndex != curTemp) {
                setState(() {
                  selectedIndex = curTemp;
                });
              }
            },
            child: Container(
              height: 220,
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              margin: EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(
                border: Border.all(color: SKColors.border_gray),
                borderRadius: BorderRadius.circular(5),
                boxShadow: UIAssets.boxShadow,
                color: selectedIndex == curTemp
                    ? SKColors.skoller_blue
                    : Colors.white,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: scale
                    .map((elem) => scaleMapper(elem, selectedIndex == curTemp))
                    .toList(),
              ),
            ),
          ),
        ),
      );

      curIndex += 1;
    }

    return [
      Container(
        margin: EdgeInsets.fromLTRB(8, 8, 8, 16),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          textBaseline: TextBaseline.alphabetic,
          children: containers,
        ),
      ),
      GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapUp: tappedCustom,
        child: Container(
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5),
              border: Border.all(color: SKColors.skoller_blue),
              boxShadow: UIAssets.boxShadow,
              color: Colors.white),
          padding: EdgeInsets.symmetric(vertical: 8),
          margin: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          alignment: Alignment.center,
          child: Text(
            'Create custom',
            style: TextStyle(color: SKColors.skoller_blue),
          ),
        ),
      ),
      GestureDetector(
        onTapUp: tappedSubmit,
        child: Container(
          alignment: Alignment.center,
          padding: EdgeInsets.symmetric(vertical: 8),
          margin: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5),
            color:
                selectedIndex == -1 ? SKColors.inactive_gray : SKColors.success,
            boxShadow: UIAssets.boxShadow,
          ),
          child: Text(
            'Submit',
            style: TextStyle(
              color: Colors.white,
            ),
          ),
        ),
      ),
    ];
  }

  List<Widget> createGradeScale() {
    final scaleWidgets = scales
        .map(
          (e) => Container(
            padding: EdgeInsets.symmetric(vertical: 6, horizontal: 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Row(children: [
                  GestureDetector(
                    onTapUp: (_) => tappedRemoveScale(e),
                    child: Padding(
                      padding: EdgeInsets.only(right: 8),
                      child:
                          Image.asset(ImageNames.assignmentInfoImages.circle_x),
                    ),
                  ),
                  Text(e[SCALE_MAP_KEY], style: TextStyle(fontSize: 16))
                ]),
                Text(
                  '≥ ${e[SCALE_MAP_VAL]}',
                  style: TextStyle(fontWeight: FontWeight.normal, fontSize: 16),
                ),
              ],
            ),
          ),
        )
        .toList();

    return [
      Expanded(
        child: ListView(
          padding: EdgeInsets.only(top: 8, left: 12, right: 12),
          children: [
            if (scales.length > 0)
              Container(
                padding: EdgeInsets.only(bottom: 4),
                margin: EdgeInsets.only(bottom: 4),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: SKColors.border_gray),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(
                      'letter grade...',
                      style: TextStyle(
                          fontSize: 12, fontWeight: FontWeight.normal),
                    ),
                    Text(
                      '...at least',
                      style: TextStyle(
                          fontSize: 12, fontWeight: FontWeight.normal),
                    ),
                  ],
                ),
              ),
            if (scales.length == 0)
              Container(
                alignment: Alignment.center,
                padding: EdgeInsets.only(top: 12),
                child: Text(
                  'Tap + to add a scale!',
                  style: TextStyle(fontWeight: FontWeight.normal, fontSize: 14),
                ),
              ),
            ...scaleWidgets,
          ],
        ),
      ),
      if (scales.length > 0)
        GestureDetector(
          onTapUp: tappedSubmit,
          behavior: HitTestBehavior.opaque,
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 8),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: SKColors.success,
              borderRadius: BorderRadius.circular(5),
              boxShadow: UIAssets.boxShadow,
            ),
            child: Text(
              'Submit',
              style: TextStyle(color: Colors.white),
            ),
          ),
        )
    ];
  }
}
