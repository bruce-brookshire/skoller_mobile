import 'package:dart_notification_center/dart_notification_center.dart';
import 'package:dropdown_banner/dropdown_banner.dart';
import 'package:skoller/screens/main_app/classes/modals/change_request_explanation_modal.dart';
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
        await studentClass.refetchSelf();

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

  void tappedChangeRequestExplanation(_) => showDialog(
      context: context, builder: (_) => ChangeRequestExplanationModal());

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

    final changeRequests = studentClass.gradeScaleChangeRequests
        .map(
          (c) => SKHeaderCard(
            margin: EdgeInsets.fromLTRB(16, 16, 16, 0),
            padding: EdgeInsets.symmetric(vertical: 16, horizontal: 24),
            leftHeaderItem: Row(children: [
              Padding(
                padding: EdgeInsets.only(right: 4),
                child: Icon(
                  Icons.access_time,
                  size: 22,
                  color: SKColors.alert_orange,
                ),
              ),
              Text(
                'Pending change request',
                style: TextStyle(color: SKColors.alert_orange),
              ),
            ]),
            rightHeaderItem: GestureDetector(
              onTapUp: tappedChangeRequestExplanation,
              behavior: HitTestBehavior.opaque,
              child: Container(
                child: Icon(
                  Icons.help_outline,
                  color: SKColors.skoller_blue,
                ),
              ),
            ),
            children: buildChangeRequestMembers(c.members.toList()),
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
          child: SingleChildScrollView(
            child: Column(
              children: [
                ...changeRequests,
                Container(
                  margin: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: SKColors.border_gray),
                    boxShadow: UIAssets.boxShadow,
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
                                        fontWeight: FontWeight.normal,
                                        fontSize: 12),
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
                      Padding(
                        padding: EdgeInsets.fromLTRB(12, 8, 12, 12),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Padding(
                              padding: EdgeInsets.only(bottom: 4),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  Text(
                                    'To make...',
                                    style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.normal),
                                  ),
                                  Text(
                                    'must score...',
                                    style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.normal),
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
              ],
            ),
          ),
        ),
      ],
    );
  }

  List<Widget> buildChangeRequestMembers(List<ChangeRequestMember> members) {
    final studentClass = StudentClass.currentClasses[widget.classId];
    final scaleTesterMap = Map.fromEntries(studentClass.gradeScale.entries);
    final newOrChangedMembers = members.map((m) {
      final testGrade = scaleTesterMap.remove(m.name);

      if (testGrade == null)
        return {'name': m.name, 'type': 'new', 'new_val': m.value};
      else if (testGrade != m.value)
        return {
          'name': m.name,
          'type': 'change',
          'old_val': '$testGrade',
          'new_val': m.value,
        };
      else
        return null;
    }).toList()
      ..removeWhere((w) => w == null);

    final removedMembers = scaleTesterMap.entries
        .map((m) => {'name': m.key, 'type': 'delete', 'new_val': '${m.value}'});

    return [...newOrChangedMembers, ...removedMembers]
        .map(buildChangeRequestMemberRow)
        .toList();
  }

  Widget buildChangeRequestMemberRow(Map member) {
    Widget icon;

    switch (member['type']) {
      case 'new':
        icon = Icon(
          Icons.add,
          color: SKColors.success,
        );
        break;
      case 'change':
        icon = Icon(
          Icons.arrow_forward,
          color: SKColors.dark_gray,
        );
        break;
      case 'delete':
        icon = Icon(
          Icons.remove,
          color: SKColors.warning_red,
        );
        break;
    }
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Text(
              member['name'],
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          if (member['old_val'] != null)
            Text(
              member['old_val'],
              textAlign: TextAlign.right,
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
          icon,
          if (member['new_val'] != null)
            Text(
              member['new_val'],
              textAlign: TextAlign.right,
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
        ],
      ),
    );
  }
}
