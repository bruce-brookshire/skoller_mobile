import 'package:dart_notification_center/dart_notification_center.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:skoller/screens/main_app/classes/modals/change_request_explanation_modal.dart';
import 'package:skoller/screens/main_app/classes/weights_change_request_view.dart';
import 'package:skoller/tools.dart';
import 'assignment_weight_view.dart';

class WeightsInfoView extends StatefulWidget {
  final int classId;

  WeightsInfoView(this.classId);

  @override
  State createState() => _WeightsInfoState();
}

class _WeightsInfoState extends State<WeightsInfoView> {
  @override
  void initState() {
    DartNotificationCenter.subscribe(
      observer: this,
      channel: NotificationChannels.classChanged,
      onNotification: (_) => setState(() {}),
    );

    super.initState();
  }

  @override
  void dispose() {
    DartNotificationCenter.unsubscribe(observer: this);
    
    super.dispose();
  }

  void tappedFAQ(_) {
    showDialog(context: context, builder: (_) => _WeightFAQModal());
  }

  void tappedChangeRequestExplanation(_) => showDialog(
        context: context,
        builder: (context) => ChangeRequestExplanationModal(),
      );

  @override
  Widget build(BuildContext context) {
    final studentClass = StudentClass.currentClasses[widget.classId];

    int assignmentCount = 0;

    Map<int, int> assignmentsPerWeight = {};

    for (final Assignment assignment in (studentClass!.assignments ?? [])) {
      if (assignment.weight_id != null) {
        assignmentCount++;
        assignmentsPerWeight.update(
          assignment.weight_id,
          (existing) => existing + 1,
          ifAbsent: () => 1,
        );
      }
    }

    final weightRows = (studentClass.weights ?? []).map(
      (weight) {
        int assignmentCount = assignmentsPerWeight[weight.id] ?? 0;

        int weightNum = weight.weight.toInt();
        num fractionalWeight;

        if (studentClass.isPoints) {
          fractionalWeight =
              assignmentCount > 0 ? weightNum ~/ assignmentCount : 0;
        } else {
          fractionalWeight =
              ((weightNum * 10) / assignmentCount).truncateToDouble() / 10;
        }

        return Container(
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            children: <Widget>[
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(weight.name),
                    Padding(
                      padding: EdgeInsets.only(left: 16),
                      child: assignmentCount == 0
                          ? Text(
                              'This category has no assignments',
                              style: TextStyle(
                                color: SKColors.warning_red,
                                fontWeight: FontWeight.normal,
                                fontSize: 13,
                              ),
                            )
                          : Text(
                              '${assignmentCount} assignment${assignmentCount == 1 ? '' : 's'} worth ${fractionalWeight}${studentClass.isPoints ? ' pts.' : '%'} ${assignmentCount == 1 ? '' : 'each'}',
                              style: TextStyle(
                                fontWeight: FontWeight.normal,
                                fontSize: 13,
                              ),
                            ),
                    )
                  ],
                ),
              ),
              Text(
                '${weightNum}${studentClass.isPoints ? ' pt${weightNum == 1 ? '' : 's'}.' : '%'}',
                style: TextStyle(
                  fontSize: 16,
                ),
              )
            ],
          ),
        );
      },
    );

    final changeRequests = studentClass.weightChangeRequests
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
      title: studentClass.name!,
      titleColor: studentClass.getColor(),
      backgroundColor: Colors.white,
      children: <Widget>[
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: [
                ...changeRequests,
                SKHeaderCard(
                  leftHeaderItem:
                      Text('Weights', style: TextStyle(fontSize: 17)),
                  rightHeaderItem: GestureDetector(
                    onTapUp: (_) => Navigator.push(
                      context,
                      CupertinoPageRoute(
                        builder: (context) =>
                            WeightsChangeRequestView(widget.classId),
                        settings:
                            RouteSettings(name: 'WeightsChangeRequestView'),
                        fullscreenDialog: true,
                      ),
                    ),
                    child: Text(
                      'Edit',
                      style: TextStyle(color: SKColors.skoller_blue),
                    ),
                  ),
                  children: <Widget>[
                    Container(
                      margin: EdgeInsets.symmetric(vertical: 8),
                      padding: EdgeInsets.fromLTRB(8, 0, 8, 12),
                      decoration: BoxDecoration(
                          border: Border(
                              bottom: BorderSide(color: SKColors.border_gray))),
                      child: Text.rich(
                        TextSpan(
                          text:
                              'Currently, there ${assignmentCount == 1 ? 'is' : 'are'} ',
                          children: [
                            TextSpan(
                              text:
                                  '$assignmentCount assignment${assignmentCount == 1 ? '' : 's'}',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            TextSpan(
                              text:
                                  ' that will\ncount towards your final grade.',
                            ),
                          ],
                          style: TextStyle(
                            fontWeight: FontWeight.normal,
                            fontSize: 13,
                          ),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    ...weightRows,
                    Container(
                      decoration: BoxDecoration(
                        border: Border(
                            top: BorderSide(color: SKColors.border_gray)),
                      ),
                      margin: EdgeInsets.symmetric(vertical: 8),
                      padding: EdgeInsets.fromLTRB(8, 16, 8, 0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          SizedBox(width: 32),
                          GestureDetector(
                            onTapUp: (details) {
                              Navigator.push(
                                context,
                                CupertinoPageRoute(
                                  builder: (context) =>
                                      AssignmentWeightView(studentClass.id),
                                  settings: RouteSettings(
                                      name: 'AssignmentWeightView'),
                                ),
                              );
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                  vertical: 6, horizontal: 24),
                              margin: EdgeInsets.symmetric(horizontal: 24),
                              decoration: BoxDecoration(
                                color: SKColors.skoller_blue,
                                borderRadius: BorderRadius.circular(5),
                                // boxShadow: UIAssets.boxShadow,
                              ),
                              child: Text(
                                'Add an assignment',
                                textAlign: TextAlign.center,
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ),
                          GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTapUp: tappedFAQ,
                            child: SizedBox(
                              width: 32,
                              child: Icon(
                                Icons.help_outline,
                                color: SKColors.skoller_blue,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
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

    final pointsChangeIndex = members.indexWhere((m) => m.name == 'is_points');
    final pointsChange =
        pointsChangeIndex == null ? null : members.removeAt(pointsChangeIndex);

    List<Map<String, dynamic>> rowValues = [];

    if (pointsChange != null) {
      final isPoints = pointsChange.value == 'true' ? true : false;
      final oldIsPoints = studentClass!.isPoints;

      final converter = (bool isPoints) => isPoints ? 'Pts.' : '%';

      rowValues.add(
        {
          'name': 'Weight scheme',
          'type': 'change',
          'old_val': converter(oldIsPoints),
          'new_val': converter(isPoints)
        },
      );
    }

    final weightEntries =
        studentClass!.weights?.map((w) => MapEntry(w.name, w.weight));

    final weightTesterMap = Map.fromEntries(weightEntries!);

    final newOrChangedMembers = members.map((m) {
      final testWeight = weightTesterMap.remove(m.name);

      if (testWeight == null)
        return {'name': m.name, 'type': 'new', 'new_val': m.value};
      else if (testWeight != double.tryParse(m.value))
        return {
          'name': m.name,
          'type': 'change',
          'old_val': '$testWeight',
          'new_val': '${double.tryParse(m.value)}',
        };
      else
        return null;
    }).toList()
      ..removeWhere((w) => w == null);

    final removedMembers = weightTesterMap.entries
        .map((m) => {'name': m.key, 'type': 'delete', 'old_val': '${m.value}'});

    rowValues..addAll(newOrChangedMembers as Iterable<Map<String,dynamic>>)..addAll(removedMembers);

    return [...rowValues.map(buildChangeRequestMemberRow)];
  }

  Widget buildChangeRequestMemberRow(Map member) {
   late Widget icon;

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

class _WeightFAQModal extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(
          color: SKColors.border_gray,
        ),
      ),
      child: Scrollbar(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    GestureDetector(
                      onTapUp: (_) => Navigator.pop(context),
                      behavior: HitTestBehavior.opaque,
                      child: SizedBox(
                        width: 28,
                        height: 28,
                        child: Image.asset(ImageNames.navArrowImages.down),
                      ),
                    ),
                    Text(
                      'Weight FAQs',
                      style: TextStyle(fontSize: 18),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(width: 28, height: 28),
                  ],
                ),
                Padding(
                  padding: EdgeInsets.only(top: 12),
                  child: Text(
                    'Question 1: ',
                    style: TextStyle(fontSize: 14),
                  ),
                ),
                Text(
                  'Are all assignments within a category equally weighted?',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 12),
                  child: Text(
                    'Answer 1:',
                    style: TextStyle(color: SKColors.light_gray, fontSize: 14),
                  ),
                ),
                Container(
                  padding: EdgeInsets.only(bottom: 12),
                  margin: EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                      border: Border(
                          bottom: BorderSide(color: SKColors.border_gray))),
                  child: Text(
                    'Yes. For example, if the weight category \'Exams\' is 40% of your final grade, and there are 4 exams, each is worth 10% of your final grade. (40%/4 = 10%)',
                    style: TextStyle(
                        color: SKColors.light_gray,
                        fontSize: 14,
                        fontWeight: FontWeight.w500),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 12),
                  child: Text(
                    'Question 2: ',
                    style: TextStyle(fontSize: 14),
                  ),
                ),
                Text(
                  'What should I do if assignments in the same category are NOT equally weighted?',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 12),
                  child: Text(
                    'Answer 2:',
                    style: TextStyle(color: SKColors.light_gray, fontSize: 14),
                  ),
                ),
                Container(
                  padding: EdgeInsets.only(bottom: 12),
                  margin: EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                      border: Border(
                          bottom: BorderSide(color: SKColors.border_gray))),
                  child: Text(
                    'In this case, you should create TWO separate weight categories. Let\'s assume you have 4 exams total. 2 of them are worth 12% each. The other 2 are worth 8% each.\n\nYou should create two weight categories like this:\n\nLarge Exams = 24%\nSmall Exams = 16%\n\nThis will fix your grade calculator!',
                    style: TextStyle(
                        color: SKColors.light_gray,
                        fontSize: 14,
                        fontWeight: FontWeight.w500),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 12),
                  child: Text(
                    'Question 3: ',
                    style: TextStyle(fontSize: 14),
                  ),
                ),
                Text(
                  'How does Skoller handle extra credit?',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 12),
                  child: Text(
                    'Answer 3:',
                    style: TextStyle(color: SKColors.light_gray, fontSize: 14),
                  ),
                ),
                Text(
                  'We do NOT advise you to make a weight category for extra credit. This skews the weights for the rest of the assignments. If you receive extra credit for an assignment, you should add it to your grade when entering that assignment\'s grade in Skoller.\n\nFor example, I made an 84% on an assignment. The teacher gave us 5% extra credit for writing answers in cursive.\n\nYou should record your grade as 89%',
                  style: TextStyle(
                      color: SKColors.light_gray,
                      fontSize: 14,
                      fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
