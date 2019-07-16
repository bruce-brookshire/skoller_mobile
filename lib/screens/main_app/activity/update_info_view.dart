import 'package:dropdown_banner/dropdown_banner.dart';
import 'package:flutter/material.dart';
import 'package:skoller/tools.dart';
import 'package:intl/intl.dart';

class UpdateInfoView extends StatefulWidget {
  final List<Mod> mods;

  UpdateInfoView(this.mods, {Key key}) : super(key: key);

  @override
  State createState() => _UpdateInfoState();
}

class _UpdateInfoState extends State<UpdateInfoView> {
  @override
  Widget build(BuildContext context) {
    StudentClass parentClass = widget.mods[0].parentClass;
    return SKNavView(
      title: parentClass.name,
      titleColor: parentClass.getColor(),
      children: <Widget>[
        Expanded(
          child: ListView.builder(
            padding: EdgeInsets.only(top: 4),
            itemCount: widget.mods.length,
            itemBuilder: createModCell,
          ),
        ),
      ],
    );
  }

  String getDescrImageName(Mod mod) {
    switch (mod.modType) {
      case ModType.name:
        return '';
        break;
      case ModType.weight:
        return ImageNames.activityImages.weight_gray;
        break;
      case ModType.due:
        return ImageNames.activityImages.due_gray;
        break;
      case ModType.newAssignment:
        return ImageNames.activityImages.add_gray;
        break;
      case ModType.delete:
        return ImageNames.activityImages.delete_gray;
        break;
    }

    throw 'Mod type not found';
  }

  String generateLongModDescr(Mod mod) {
    switch (mod.modType) {
      case ModType.name:
        return '\'s name has been changed to ${mod.data as String}';
        break;
      case ModType.weight:
        return '\'s weight category has been changed to ${(mod.data as Weight).name}';
        break;
      case ModType.due:
        return '\'s due date has been changed to ${DateFormat('EEEE MMMM d').format((mod.data as DateTime))}.';
        break;
      case ModType.newAssignment:
        return ' has been added by a classmate. It is due on ${DateFormat('EEEE MMMM d').format((mod.data as Assignment).due)}.';
        break;
      case ModType.delete:
        return ' has been removed from the assignments for this class.';
        break;
    }

    throw 'Mod type not found';
  }

  Widget createModCell(BuildContext context, int index) {
    Mod mod = widget.mods[index];

    bool needsAction = mod.isAccepted == null || !mod.isAccepted;

    return Container(
      margin: EdgeInsets.fromLTRB(7, 6, 7, 6),
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [UIAssets.boxShadow],
          borderRadius: BorderRadius.circular(5),
          border: Border.all(color: SKColors.border_gray)),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.fromLTRB(2, 3, 8, 0),
                child: Image.asset(
                  getDescrImageName(mod),
                ),
              ),
              Expanded(
                  child: Text.rich(TextSpan(children: [
                TextSpan(
                    text: mod.modType == ModType.newAssignment
                        ? (mod.data as Assignment).name
                        : mod.parentAssigment.name,
                    style: TextStyle(color: SKColors.skoller_blue)),
                TextSpan(
                    text: generateLongModDescr(mod),
                    style: TextStyle(fontWeight: FontWeight.normal)),
              ]))),
            ],
          ),
          Container(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Text(
              '${mod.acceptedCount} student${mod.acceptedCount == 1 ? ' has' : 's have'} copied this update',
              style: TextStyle(
                  color: SKColors.light_gray,
                  fontSize: 14,
                  fontWeight: FontWeight.normal),
            ),
          ),
          needsAction
              ? Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTapUp: (details) {
                          if (mod.isAccepted == null) {
                            mod.declineMod().then((response) {
                              if (!response.wasSuccessful()) {
                                DropdownBanner.showBanner(
                                  text:
                                      'Unable to accept assignment modification. Please try again later',
                                  color: SKColors.warning_red,
                                  textStyle: TextStyle(color: Colors.white),
                                );
                                setState(() {
                                  mod.isAccepted = null;
                                });
                              } else {
                                DropdownBanner.showBanner(
                                  text: 'Success!',
                                  color: SKColors.success,
                                  textStyle: TextStyle(color: Colors.white),
                                );
                              }
                            });
                            setState(() {
                              mod.isAccepted = false;
                            });
                          }
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(vertical: 5),
                          margin: EdgeInsets.only(left: 2, right: 5),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: mod.isAccepted == false
                                ? SKColors.inactive_gray
                                : SKColors.warning_red,
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: Text(
                            mod.isAccepted == false
                                ? 'Already Dismissed'
                                : 'Dismiss',
                            style: TextStyle(
                                fontSize: 13,
                                color: mod.isAccepted == false
                                    ? SKColors.dark_gray
                                    : Colors.white),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTapUp: (details) {
                          mod.acceptMod().then((response) {
                            if (!response.wasSuccessful()) {
                              DropdownBanner.showBanner(
                                text: 'Failed to accept assignment modification. Try again later',
                                color: SKColors.warning_red,
                                textStyle: TextStyle(color: Colors.white),
                              );
                              setState(() {
                                mod.isAccepted = null;
                              });
                            } else {
                              DropdownBanner.showBanner(
                                text: 'Success!',
                                color: SKColors.success,
                                textStyle: TextStyle(color: Colors.white),
                              );
                            }
                          });
                          setState(() {
                            mod.isAccepted = true;
                          });
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(vertical: 5),
                          margin: EdgeInsets.only(right: 2, left: 5),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: SKColors.skoller_blue,
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: Text(
                            'Accept change',
                            style: TextStyle(fontSize: 13, color: Colors.white),
                          ),
                        ),
                      ),
                    ),
                  ],
                )
              : Container(
                  child: Text(
                    'You have accepted this update',
                    style:
                        TextStyle(fontSize: 14, fontWeight: FontWeight.normal),
                  ),
                ),
        ],
      ),
    );
  }
}
