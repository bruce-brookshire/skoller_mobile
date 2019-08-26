import 'package:intl/intl.dart';
import 'package:skoller/tools.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class AssignmentEditModal extends StatefulWidget {
  final int assignment_id;

  AssignmentEditModal(this.assignment_id);

  @override
  State createState() => _AssignmentEditModalState();
}

class _AssignmentEditModalState extends State<AssignmentEditModal> {
  DateTime selectedDate;
  Weight selectedWeight;

  bool isPrivate = false;
  bool hasChanged = false;
  bool shouldDelete = false;

  Assignment assignment;

  TextEditingController nameController;

  @override
  void initState() {
    super.initState();
    assignment = Assignment.currentAssignments[widget.assignment_id];
    selectedDate = assignment.due;
    nameController = TextEditingController(text: assignment.name);

    for (final Weight weight in assignment.parentClass.weights) {
      if (assignment.weight_id == weight.id) {
        selectedWeight = weight;
        break;
      }
    }
  }

  void checkValid([_]) {
    final dateChanged = (selectedDate == null && assignment.due == null)
        ? false
        : (assignment.due == null
            ? true
            : !(selectedDate?.isAtSameMomentAs(assignment.due) ?? true));

    final weightChanged = selectedWeight.id != assignment.weight_id;
    final nameChanged = nameController.text.trim() != assignment.name.trim();

    final newHasChanged = dateChanged || weightChanged || nameChanged;

    if (newHasChanged != hasChanged) setState(() => hasChanged = newHasChanged);
  }

  void tappedDueDate(TapUpDetails details) async {
    SKCalendarPicker.presentDateSelector(
      title: 'Due date',
      subtitle: 'When is this assignment due?',
      context: context,
      startDate: selectedDate ?? DateTime.now(),
      onSelect: (selectedDate) {
        setState(() {
          this.selectedDate = selectedDate;
          shouldDelete = false;
        });
        checkValid();
      },
    );
  }

  void tappedWeight(TapUpDetails details) async {
    List<Weight> classWeights = assignment.parentClass.weights;

    Weight tempWeight = classWeights.first;

    final bool result = await showDialog(
      context: context,
      builder: (context) => SKAlertDialog(
        title: 'Grading category',
        subTitle: 'Select how this assignment is graded',
        child: Container(
          height: 160,
          child: CupertinoPicker.builder(
            backgroundColor: Colors.white,
            childCount: classWeights.length,
            itemExtent: 24,
            itemBuilder: (context, index) => Container(
              alignment: Alignment.center,
              child: Text(
                classWeights[index].name,
                style: TextStyle(
                  color: SKColors.dark_gray,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            onSelectedItemChanged: (index) => tempWeight = classWeights[index],
          ),
        ),
      ),
    );

    if (result != null && result) {
      setState(() {
        this.selectedWeight = tempWeight;
        shouldDelete = false;
      });
      checkValid();
    }
  }

  void tappedSubmit(TapUpDetails _) {
    List<Map> requests = [];
    if (shouldDelete) {
      requests.add({
        'request': assignment.delete(isPrivate),
        'mod_type': 'delete',
      });
    } else {
      if ((assignment.due == null && selectedDate != null) ||
          !selectedDate.isAtSameMomentAs(assignment.due)) {
        requests.add({
          'request': assignment.updateDueDate(
            isPrivate,
            selectedDate,
          ),
          'mod_type': 'due_date',
        });
      }
      if (selectedWeight.id != assignment.weight_id) {
        requests.add({
          'request': assignment.updateWeightCategory(
            isPrivate,
            selectedWeight,
          ),
          'mod_type': 'weight',
        });
      }
      final name = nameController.text.trim();
      if (assignment.name.trim() != name)
        requests.add({
          'request': assignment.updateName(name),
          'mod_type': 'name',
        });
    }

    Navigator.pop(context, requests);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24),
      child: Center(
        child: Material(
          color: Colors.white,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
              side: BorderSide(color: SKColors.border_gray)),
          child: Container(
            padding: EdgeInsets.all(14),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    GestureDetector(
                      onTapUp: (details) => Navigator.pop(context),
                      child: SizedBox(
                        width: 32,
                        height: 32,
                        child: Image.asset(ImageNames.navArrowImages.down),
                      ),
                    ),
                    Text(
                      'Edit assignment details',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 17),
                    ),
                    GestureDetector(
                      onTapUp: (details) async {
                        final results = await showDialog(
                          context: context,
                          builder: (context) => SKAlertDialog(
                            title: 'Delete assignment',
                            subTitle: 'Are you absolutely sure?',
                            confirmText: 'Delete',
                            cancelText: 'Cancel',
                          ),
                        );

                        if (results is bool && results) {
                          shouldDelete = true;
                          tappedSubmit(null);
                        }
                      },
                      child: SizedBox(
                        width: 32,
                        height: 32,
                        child:
                            Image.asset(ImageNames.assignmentInfoImages.trash),
                      ),
                    ),
                  ],
                ),
                Container(
                  child: null,
                  margin: EdgeInsets.only(top: 4, bottom: 12),
                  height: 1.25,
                  color: SKColors.border_gray,
                ),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: Container(
                    // margin: EdgeInsets.fromLTRB( 4, 4, 4),
                    padding: EdgeInsets.symmetric(vertical: 4, horizontal: 4),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(5),
                      border: Border.all(color: SKColors.border_gray),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Text(
                          'Subject',
                          style: TextStyle(
                              color: SKColors.light_gray,
                              fontSize: 13,
                              fontWeight: FontWeight.normal),
                        ),
                        CupertinoTextField(
                          cursorColor: SKColors.skoller_blue,
                          padding: EdgeInsets.only(top: 1),
                          placeholder: 'Assignment name',
                          style: TextStyle(
                              fontSize: 15, color: SKColors.dark_gray),
                          decoration: BoxDecoration(border: null),
                          textCapitalization: TextCapitalization.words,
                          controller: nameController,
                          onChanged: checkValid,
                        ),
                      ],
                    ),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Container(
                      padding: EdgeInsets.symmetric(vertical: 6),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            'Due date',
                            style: TextStyle(
                                fontWeight: FontWeight.normal,
                                fontSize: 13,
                                color: SKColors.light_gray),
                          ),
                          GestureDetector(
                            onTapUp: tappedDueDate,
                            child: Text(
                              selectedDate == null
                                  ? 'No due date'
                                  : DateFormat('E, MMM. d')
                                      .format(selectedDate),
                              style: TextStyle(color: SKColors.skoller_blue),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Container(
                        padding: EdgeInsets.symmetric(vertical: 8),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: <Widget>[
                            Text(
                              'Graded as',
                              style: TextStyle(
                                  fontWeight: FontWeight.normal,
                                  fontSize: 13,
                                  color: SKColors.light_gray),
                            ),
                            GestureDetector(
                              onTapUp: tappedWeight,
                              child: Text(
                                selectedWeight?.name ?? 'Not graded',
                                style: TextStyle(color: SKColors.skoller_blue),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Share changes',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                      ),
                      Switch(
                          value: !isPrivate,
                          onChanged: (value) {
                            setState(() {
                              isPrivate = !value;
                            });
                          },
                          activeColor: SKColors.skoller_blue),
                    ],
                  ),
                ),
                createActionButton(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget createActionButton(BuildContext context) {
    Widget child;
    Color backgroundColor;

    if (!hasChanged)
    //Basically, show a gray button if the user has not changed any of the assignment details
    {
      backgroundColor = SKColors.text_light_gray;
      child = Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: EdgeInsets.only(right: 8),
            child: Image.asset(
              isPrivate
                  ? ImageNames.peopleImages.person_white
                  : ImageNames.peopleImages.people_white,
            ),
          ),
          Text(
            isPrivate ? 'Save updates' : 'Share updates',
            style: TextStyle(color: Colors.white),
          ),
        ],
      );
    } else {
      backgroundColor = isPrivate ? SKColors.skoller_blue : SKColors.success;
      child = Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: EdgeInsets.only(right: 8),
            child: Image.asset(
              isPrivate
                  ? ImageNames.peopleImages.person_white
                  : ImageNames.peopleImages
                      .people_white, /*scale: isPrivate ? 1.35 : 1,*/
            ),
          ),
          Text(
            isPrivate ? 'Save updates' : 'Share updates',
            style: TextStyle(color: Colors.white),
          ),
        ],
      );
    }

    return GestureDetector(
      onTapUp: tappedSubmit,
      child: Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(5),
            border: Border.all(color: SKColors.border_gray),
          ),
          height: 32,
          margin: EdgeInsets.only(top: 12),
          child: child),
    );
  }
}
