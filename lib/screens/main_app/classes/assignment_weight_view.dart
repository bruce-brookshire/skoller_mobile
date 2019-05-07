import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../../../requests/requests_core.dart';
import '../../../constants/constants.dart';
import 'assignment_add_view.dart';

class AssignmentWeightView extends StatelessWidget {
  final int classId;

  AssignmentWeightView(this.classId, {Key key}) : super(key: key);

  Widget build(BuildContext context) {
    final studentClass = StudentClass.currentClasses[classId];
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
                                        AssignmentAddView(classId, null),
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
                                Navigator.push(
                                  context,
                                  CupertinoPageRoute(
                                    builder: (context) => AssignmentAddView(
                                          classId,
                                          weights[index],
                                        ),
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
