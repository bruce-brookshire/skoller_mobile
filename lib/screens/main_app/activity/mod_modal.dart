import 'package:dart_notification_center/dart_notification_center.dart';
import 'package:dropdown_banner/dropdown_banner.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'package:skoller/tools.dart';

class ModModal extends StatelessWidget {
  final Mod mod;

  ModModal(this.mod);

  void tappedAccept(BuildContext context) async {
    final loader = SKLoadingScreen.fadeIn(context);
    final response = await mod.acceptMod();

    if (!response.wasSuccessful()) {
      loader.fadeOut();
      DropdownBanner.showBanner(
        text:
            'Unable to accept assignment modification. Please try again later',
        color: SKColors.warning_red,
        textStyle: TextStyle(color: Colors.white),
      );
    } else {
      await Mod.fetchMods();
      await mod.parentClass.refetchSelf();

      DartNotificationCenter.post(
        channel: NotificationChannels.assignmentChanged,
      );

      loader.fadeOut();
      Navigator.pop(context);
    }
  }

  void tappedDecline(BuildContext context) async {
    final loader = SKLoadingScreen.fadeIn(context);
    final response = await mod.declineMod();

    if (!response.wasSuccessful()) {
      loader.fadeOut();
      DropdownBanner.showBanner(
        text:
            'Unable to accept assignment modification. Please try again later',
        color: SKColors.warning_red,
        textStyle: TextStyle(color: Colors.white),
      );
    } else {
      await Mod.fetchMods();

      DartNotificationCenter.post(
        channel: NotificationChannels.assignmentChanged,
      );

      loader.fadeOut();
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final parentClass = mod.parentClass;
    final assignment = mod.parentAssignment ?? mod.data as Assignment;

    String typeAction;

    switch (mod.modType) {
      case ModType.name:
        typeAction = 'changed the name for';
        break;
      case ModType.weight:
        typeAction = 'changed the weight for';
        break;
      case ModType.due:
        typeAction = 'changed the due date for';
        break;
      case ModType.newAssignment:
        typeAction = 'added';
        break;
      case ModType.delete:
        typeAction = 'deleted the assignment';
        break;
    }

    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: SKColors.border_gray),
            boxShadow: UIAssets.boxShadow),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(
              parentClass.name!,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: parentClass.getColor(),
                fontWeight: FontWeight.w700,
                fontSize: 18,
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Image.asset(
                ImageNames.peopleImages.people_gray_large,
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: Text(
                'A classmate has $typeAction:',
                style: TextStyle(fontWeight: FontWeight.w300),
                textAlign: TextAlign.center,
              ),
            ),
            Text(
              assignment.name,
              style: TextStyle(
                color: parentClass.getColor(),
                fontWeight: FontWeight.w700,
                fontSize: 18,
              ),
            ),
            Padding(
              padding: EdgeInsets.only(top: 8, bottom: 16),
              child: typeChange(),
            ),
            modActions(context),
          ],
        ),
      ),
    );
  }

  String getOrdinal(DateTime date) {
    final ordinalType = date.day % 10;

    if (date.day ~/ 10 == 1)
      return 'th';
    else if (ordinalType == 1)
      return 'st';
    else if (ordinalType == 2)
      return 'nd';
    else if (ordinalType == 3)
      return 'rd';
    else
      return 'th';
  }

  Widget typeChange() {
    if (mod.modType == ModType.due) {
      final oldDate = mod.parentAssignment.due;
      final newDate = mod.data as DateTime;

      final oldOrdinal = getOrdinal(oldDate!);
      final newOrdinal = getOrdinal(newDate);

      return Row(
        children: [
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Text(
                  'Old',
                  style: TextStyle(
                      color: SKColors.light_gray,
                      fontWeight: FontWeight.w500,
                      fontSize: 13),
                ),
                Text(
                  oldDate == null
                      ? 'No due date'
                      : (DateFormat('MMMM d').format(oldDate) + oldOrdinal),
                  style: TextStyle(color: SKColors.light_gray),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 12),
            child: Icon(Icons.arrow_forward, color: SKColors.dark_gray),
          ),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  'New',
                  style: TextStyle(
                      color: mod.parentClass.getColor(),
                      fontWeight: FontWeight.w500,
                      fontSize: 13),
                ),
                Text(
                  DateFormat('MMMM d').format(newDate) + newOrdinal,
                  style: TextStyle(color: mod.parentClass.getColor()),
                ),
              ],
            ),
          ),
        ],
      );
    } else if (mod.modType == ModType.weight)
      return Row(
        children: [
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Text(
                  'Old',
                  style: TextStyle(
                      color: SKColors.light_gray,
                      fontWeight: FontWeight.w500,
                      fontSize: 13),
                ),
                Text(
                  mod.parentAssignment.weight_id == null
                      ? 'Not graded'
                      : mod.parentAssignment.weightObject.name,
                  style: TextStyle(color: SKColors.light_gray),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 12),
            child: Icon(Icons.arrow_forward, color: SKColors.dark_gray),
          ),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  'New',
                  style: TextStyle(
                      color: mod.parentClass.getColor(),
                      fontWeight: FontWeight.w500,
                      fontSize: 13),
                ),
                Text(
                  (mod.data as Weight).name,
                  style: TextStyle(color: mod.parentClass.getColor()),
                ),
              ],
            ),
          ),
        ],
      );
    else if (mod.modType == ModType.newAssignment)
      return Text(
        'to the schedule.',
        style: TextStyle(fontWeight: FontWeight.w300),
      );
    else
      return Container();
  }

  Widget modActions(BuildContext context) {
    if (mod.modType == ModType.delete)
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          GestureDetector(
            onTapUp: (_) => tappedAccept(context),
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 6, horizontal: 12),
              alignment: Alignment.center,
              margin: EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: SKColors.warning_red,
                borderRadius: BorderRadius.circular(5),
                boxShadow: UIAssets.boxShadow,
              ),
              child: Text(
                'Delete Assignment',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
          GestureDetector(
            onTapUp: (_) => tappedDecline(context),
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 6, horizontal: 12),
              alignment: Alignment.center,
              margin: EdgeInsets.fromLTRB(16, 12, 16, 0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(5),
                border: Border.all(color: SKColors.skoller_blue),
                boxShadow: UIAssets.boxShadow,
              ),
              child: Text(
                'Keep Assignment',
                style: TextStyle(color: SKColors.skoller_blue),
              ),
            ),
          ),
        ],
      );
    else
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          GestureDetector(
            onTapUp: (_) => tappedAccept(context),
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 6, horizontal: 12),
              alignment: Alignment.center,
              margin: EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: SKColors.skoller_blue,
                borderRadius: BorderRadius.circular(5),
                boxShadow: UIAssets.boxShadow,
              ),
              child: Text(
                'Accept',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
          GestureDetector(
            onTapUp: (_) => tappedDecline(context),
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 6, horizontal: 12),
              alignment: Alignment.center,
              margin: EdgeInsets.fromLTRB(16, 12, 16, 0),
              decoration: BoxDecoration(
                color: SKColors.warning_red,
                borderRadius: BorderRadius.circular(5),
                boxShadow: UIAssets.boxShadow,
              ),
              child: Text(
                'Dismiss',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
        ],
      );
  }
}
