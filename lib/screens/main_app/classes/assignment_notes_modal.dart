import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:skoller/tools.dart';

class AssignmentNotesModal extends StatefulWidget {
  final int assignmentId;
  final StringCallback onComplete;

  AssignmentNotesModal(this.assignmentId, this.onComplete);

  @override
  State<StatefulWidget> createState() => _AssignmentNotesModal();
}

class _AssignmentNotesModal extends State<AssignmentNotesModal> {
  final focusNode = FocusNode();
  TextEditingController controller;

  @override
  void initState() {
    super.initState();

    controller = TextEditingController(
      text: Assignment.currentAssignments[widget.assignmentId].notes,
    );
  }

  @override
  void dispose() {
    super.dispose();

    controller.dispose();
    focusNode.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(10)),
      ),
      child: Container(
        height: MediaQuery.of(context).size.height / 2,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: SKColors.border_gray)),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            Container(
              padding: EdgeInsets.only(top: 16, bottom: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    flex: 1,
                    child: GestureDetector(
                      onTapUp: (details) {
                        focusNode.unfocus();
                        Navigator.pop(context, false);
                      },
                      child: Container(
                        padding: EdgeInsets.only(left: 8),
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Cancel',
                          style: TextStyle(
                            color: SKColors.warning_red,
                            fontWeight: FontWeight.normal,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      'Assignment notes',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 17),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: GestureDetector(
                      onTapUp: (details) {
                        focusNode.unfocus();
                        widget.onComplete(controller.text.trim());
                        Navigator.pop(context, true);
                      },
                      child: Container(
                        padding: EdgeInsets.only(right: 8),
                        alignment: Alignment.centerRight,
                        child: Text(
                          'Save',
                          style: TextStyle(
                            color: SKColors.skoller_blue,
                            fontWeight: FontWeight.normal,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Container(
                alignment: Alignment.topLeft,
                margin: EdgeInsets.all(8),
                child: CupertinoTextField(
                  decoration: BoxDecoration(border: null),
                  maxLength: 2000,
                  maxLengthEnforced: true,
                  autofocus: true,
                  maxLines: null,
                  keyboardType: TextInputType.multiline,
                  controller: controller,
                  focusNode: focusNode,
                  placeholder: 'Add a note...',
                  style: TextStyle(
                      color: SKColors.dark_gray,
                      fontSize: 15,
                      fontWeight: FontWeight.normal),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
