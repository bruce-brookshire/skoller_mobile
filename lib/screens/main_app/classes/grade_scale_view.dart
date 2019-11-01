import 'package:dropdown_banner/dropdown_banner.dart';
import './modals/create_single_scale_modal.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:skoller/tools.dart';

class GradeScaleView extends StatefulWidget {
  final int classId;

  GradeScaleView(this.classId);

  @override
  State createState() => _GradeScaleViewState();
}

class _GradeScaleViewState extends State<GradeScaleView> {
  bool isEditing = false;
  List<Map> scales;

  @override
  void initState() {
    super.initState();

    scales =
        (StudentClass.currentClasses[widget.classId].gradeScale.entries.toList()
              ..sort(
                (e1, e2) => e2.value.compareTo(e1.value),
              ))
            .map((e) => {'letter': e.key, 'number': e.value})
            .toList();
  }

  void toggleEditing([_]) {
    if (isEditing)
      scales = (StudentClass.currentClasses[widget.classId].gradeScale.entries
              .toList()
                ..sort(
                  (e1, e2) => e2.value.compareTo(e1.value),
                ))
          .map((e) => {'letter': e.key, 'number': e.value})
          .toList();

    setState(() {
      isEditing = !isEditing;
    });
  }

  void tappedAdd(_) async {
    final result = await showDialog(
      context: context,
      builder: (context) => CreateSingleScaleModal(),
    );

    if (result is Map) {
      final index = scales.indexWhere(
        (e) => int.parse(e['number']) < int.parse(result['number']),
      );

      final updateIndex = scales.indexWhere(
        (e) => e['letter'] == result['letter'],
      );

      // If the letter grade is the same, just update the number
      if (updateIndex != -1)
        setState(() => scales[updateIndex]['number'] = result['number']);
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
    final gradeScale = studentClass.gradeScale;

    final newMap = scales.fold<Map<String, dynamic>>(
        {}, (map, elem) => map..[elem['letter']] = elem['number']);

    if (newMap.length != gradeScale.length ||
        newMap.keys.toList().any((s_k) => newMap[s_k] != gradeScale[s_k])) {
      final loader = SKLoadingScreen.fadeIn(context);

      final response = await studentClass.submitGradeScaleChangeRequest(newMap);

      if (response) {
        setState(() => isEditing = null);
        DropdownBanner.showBanner(
          text:
              'Sucessfully submitted change request. Please wait for the Skoller team to review it!',
          color: SKColors.success,
          textStyle: TextStyle(color: Colors.white),
        );
      } else {
        DropdownBanner.showBanner(
          text:
              'Failed to submit change request. Please try again a little later :( ',
          color: SKColors.warning_red,
          textStyle: TextStyle(color: Colors.white),
        );
      }
      loader.fadeOut();
      //Save
    } else {
      DropdownBanner.showBanner(
          text: 'You must make a change to submit a change request.',
          color: SKColors.alert_orange);
    }
  }

  @override
  Widget build(BuildContext context) {
    final studentClass = StudentClass.currentClasses[widget.classId];

    final scaleWidgets = scales
        .map(
          (e) => Container(
            padding: EdgeInsets.symmetric(vertical: 6, horizontal: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Row(children: [
                  if (isEditing != null && isEditing)
                    GestureDetector(
                      onTapUp: (_) => tappedRemoveScale(e),
                      child: Padding(
                        padding: EdgeInsets.only(right: 8),
                        child: Image.asset(
                            ImageNames.assignmentInfoImages.circle_x),
                      ),
                    ),
                  Text(e['letter'], style: TextStyle(fontSize: 16))
                ]),
                Text(
                  '≥ ${e['number']}',
                  style: TextStyle(fontWeight: FontWeight.normal, fontSize: 16),
                ),
              ],
            ),
          ),
        )
        .toList();

    return SKNavView(
      title: studentClass.name,
      titleColor: studentClass.getColor(),
      leftBtn: isEditing != null && isEditing
          ? Text(
              'Cancel',
              style: TextStyle(
                  color: SKColors.warning_red,
                  fontWeight: FontWeight.normal,
                  fontSize: 12),
            )
          : null,
      callbackLeft: isEditing != null && isEditing ? toggleEditing : null,
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
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Container(
                  padding: EdgeInsets.fromLTRB(12, 12, 12, 8),
                  decoration: BoxDecoration(
                      color: SKColors.selected_gray,
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(10),
                          topRight: Radius.circular(10))),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Grade scale',
                              style: TextStyle(fontSize: 17),
                            ),
                            Text(
                              'Used to speculate your grade',
                              style: TextStyle(
                                  fontWeight: FontWeight.normal, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                      if (isEditing != null)
                        !isEditing
                            ? GestureDetector(
                                behavior: HitTestBehavior.opaque,
                                onTapUp: toggleEditing,
                                child: Text(
                                  'Edit',
                                  style: TextStyle(
                                    color: SKColors.skoller_blue,
                                    fontSize: 15,
                                  ),
                                ),
                              )
                            : GestureDetector(
                                behavior: HitTestBehavior.opaque,
                                onTapUp: tappedAdd,
                                child: Image.asset(
                                    ImageNames.rightNavImages.plus)),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView(
                    padding: EdgeInsets.only(top: 8, left: 12, right: 12),
                    children: [
                      Padding(
                        padding: EdgeInsets.only(bottom: 4),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Text(
                              'To make...',
                              style: TextStyle(
                                  fontSize: 12, fontWeight: FontWeight.normal),
                            ),
                            Text(
                              'must score...',
                              style: TextStyle(
                                  fontSize: 12, fontWeight: FontWeight.normal),
                            ),
                          ],
                        ),
                      ),
                      ...scaleWidgets,
                    ],
                  ),
                ),
                if (isEditing != null && isEditing)
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTapUp: tappedSubmit,
                    child: Container(
                      margin: EdgeInsets.fromLTRB(8, 4, 8, 8),
                      padding: EdgeInsets.symmetric(vertical: 6),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5),
                        color: SKColors.success,
                      ),
                      child: Text(
                        'Submit',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  )
              ],
            ),
          ),
        ),
      ],
    );
  }
}
