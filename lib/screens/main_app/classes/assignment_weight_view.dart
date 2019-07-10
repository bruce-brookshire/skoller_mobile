import 'package:dart_notification_center/dart_notification_center.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../../../requests/requests_core.dart';
import '../../../constants/constants.dart';
import 'assignment_add_view.dart';
import 'assignment_batch_add_view.dart';

class AssignmentWeightView extends StatefulWidget {
  final int class_id;

  AssignmentWeightView(this.class_id);

  @override
  State createState() => _AssignmentWeightViewState();
}

class _AssignmentWeightViewState extends State<AssignmentWeightView> {
  List<Weight> weights;
  Map<int, int> weightAssignmentDensity = {};

  @override
  void initState() {
    refreshAndSortWeights();

    DartNotificationCenter.subscribe(
        channel: NotificationChannels.assignmentChanged,
        observer: this,
        onNotification: updateState);

    super.initState();
  }

  @override
  void dispose() {
    DartNotificationCenter.unsubscribe(observer: this);

    super.dispose();
  }

  void updateState(dynamic options) {
    refreshAndSortWeights();
    setState(() {});
  }

  void refreshAndSortWeights() {
    weights =
        (StudentClass.currentClasses[widget.class_id].weights ?? []).toList();

    final studentClass = StudentClass.currentClasses[widget.class_id];

    for (var assignment in studentClass.assignments) {
      if (assignment.weight_id != null) {
        if (weightAssignmentDensity[assignment.weight_id] == null) {
          weightAssignmentDensity[assignment.weight_id] = 0;
        } else {
          weightAssignmentDensity[assignment.weight_id] += 1;
        }
      }
    }

    weights.sort((w1, w2) {
      final w1_d = weightAssignmentDensity[w1.id];
      final w2_d = weightAssignmentDensity[w2.id];

      if (w1_d == null && w1_d != w2_d) {
        // W1 is null and W2 is not, sort W1 before W2
        return -1;
      } else if (w2_d == null && w1_d != w2_d) {
        // W2 is null and W1 is not, sort W2 before W1
        return 1;
      } else {
        // Both are same type, sort by names
        return w1.name.compareTo(w2.name);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final studentClass = StudentClass.currentClasses[widget.class_id];

    return SKNavView(
      title: studentClass.name,
      titleColor: studentClass.getColor(),
      children: [
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              boxShadow: [UIAssets.boxShadow],
              border: Border.all(color: SKColors.border_gray),
              color: Colors.white,
            ),
            margin: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  padding: EdgeInsets.fromLTRB(12, 12, 12, 8),
                  decoration: BoxDecoration(
                      color: SKColors.selected_gray,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(10),
                        topRight: Radius.circular(10),
                      )),
                  child: Text('What type of assignment?'),
                ),
                Expanded(
                  child: ListView.builder(
                    padding: EdgeInsets.only(top: 4),
                    itemCount: weights.length + 1,
                    itemBuilder: (context, index) {
                      return index == weights.length
                          ? GestureDetector(
                              behavior: HitTestBehavior.opaque,
                              onTapUp: (details) {
                                Navigator.push(
                                  context,
                                  CupertinoPageRoute(
                                    builder: (context) => AssignmentAddView(
                                        widget.class_id, null),
                                  ),
                                );
                              },
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 8),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Container(
                                            margin: EdgeInsets.only(bottom: 12),
                                            child: null,
                                            decoration: BoxDecoration(
                                              border: Border(
                                                bottom: BorderSide(
                                                  color: SKColors.border_gray,
                                                ),
                                              ),
                                            ),
                                          ),
                                          Text('Not weighted'),
                                          Container(
                                            padding: EdgeInsets.only(
                                                left: 12, top: 2),
                                            child: Text(
                                              'Assignments in this category do not count towards your grade',
                                              style: TextStyle(
                                                fontSize: 13,
                                                fontWeight: FontWeight.normal,
                                                color: SKColors.text_light_gray,
                                              ),
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                    Image.asset(ImageNames.navArrowImages.right)
                                  ],
                                ),
                              ),
                            )
                          : GestureDetector(
                              behavior: HitTestBehavior.opaque,
                              onTapUp: (details) {
                                final weight = weights[index];

                                if (weightAssignmentDensity[weight.id] !=
                                    null) {
                                  // This weight has assignments. Send to single add page
                                  Navigator.push(
                                    context,
                                    CupertinoPageRoute(
                                      builder: (context) => AssignmentAddView(
                                        widget.class_id,
                                        weights[index],
                                      ),
                                    ),
                                  );
                                } else {
                                  Navigator.push(
                                    context,
                                    CupertinoPageRoute(
                                      builder: (context) =>
                                          AssignmentBatchAddView(
                                        class_id: widget.class_id,
                                        weight: weight,
                                      ),
                                    ),
                                  );
                                }
                              },
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: weightAssignmentDensity[
                                                weights[index].id] ==
                                            null
                                        ? 6
                                        : 12),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(weights[index].name),
                                          Container(
                                            padding: EdgeInsets.only(
                                                left: 12, top: 2),
                                            child: weightAssignmentDensity[
                                                        weights[index].id] ==
                                                    null
                                                ? Text(
                                                    'Add assignments',
                                                    style: TextStyle(
                                                      fontSize: 13,
                                                      fontWeight:
                                                          FontWeight.normal,
                                                      color:
                                                          SKColors.skoller_blue,
                                                    ),
                                                  )
                                                : null,
                                          )
                                        ],
                                      ),
                                    ),
                                    Image.asset(ImageNames.navArrowImages.right)
                                  ],
                                ),
                              ),
                            );
                    },
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
