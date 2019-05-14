import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../../../requests/requests_core.dart';
import '../../../constants/constants.dart';
import 'assignment_add_view.dart';
import 'assignment_batch_add_view.dart';

class AssignmentWeightView extends StatelessWidget {
  final int class_id;

  final Map<int, int> weightAssignmentDensity = {};

  AssignmentWeightView(this.class_id, {Key key}) : super(key: key) {
    final studentClass = StudentClass.currentClasses[class_id];

    for (var assignment in studentClass.assignments) {
      if (assignment.weight_id != null) {
        if (weightAssignmentDensity[assignment.weight_id] == null) {
          weightAssignmentDensity[assignment.weight_id] = 0;
        } else {
          weightAssignmentDensity[assignment.weight_id] += 1;
        }
      }
    }
  }

  Widget build(BuildContext context) {
    final studentClass = StudentClass.currentClasses[class_id];
    final weights = studentClass.weights ?? [];
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
                                    builder: (context) =>
                                        AssignmentAddView(class_id, null),
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
                                          Text(
                                            'Assignments in this category do not count towards your grade',
                                            style: TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.normal,
                                              color: SKColors.text_light_gray,
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
                                            class_id,
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
                                            class_id: class_id,
                                            weight: weight,
                                          ),
                                    ),
                                  );
                                }
                              },
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 8),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(weights[index].name),
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
