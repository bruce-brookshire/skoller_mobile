import 'package:flutter/material.dart';
import '../../../requests/requests_core.dart';
import 'package:skoller/constants/constants.dart';

class ActivityView extends StatefulWidget {
  @override
  State createState() => _ActivityViewState();
}

class _ActivityViewState extends State<ActivityView> {
  List<Mod> currentMods = [];

  @override
  void initState() {
    super.initState();

    currentMods = Mod.currentMods;

    Mod.fetchMods().then((response) {
      if (response.wasSuccessful()) {
        setState(() {
          currentMods = response.obj;
        });
      }
    });
  }

  String getDescrImageName(Mod mod) {
    switch (mod.modType) {
      case ModType.name:
        return '';
        break;
      case ModType.weight:
        return ImageNames.activityImages.weight_white;
        break;
      case ModType.due:
        return ImageNames.activityImages.due_white;
        break;
      case ModType.newAssignment:
        return ImageNames.activityImages.add_white;
        break;
      case ModType.delete:
        return ImageNames.activityImages.delete_white;
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SKNavView(
      title: 'Activity',
      isBack: false,
      children: <Widget>[
        Expanded(
          child: ListView.builder(
            padding: EdgeInsets.only(top: 4),
            itemCount: currentMods.length,
            itemBuilder: buildListItem,
          ),
        )
      ],
    );
  }

  Widget buildListItem(BuildContext context, int index) {
    Mod mod = currentMods[index];

    return Container(
      margin: EdgeInsets.fromLTRB(7, 3, 7, 4),
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [UIAssets.boxShadow],
        borderRadius: BorderRadius.circular(5),
        border: Border.all(color: SKColors.border_gray),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 28,
            height: 28,
            margin: EdgeInsets.only(right: 6),
            decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: mod.isAccepted == null
                    ? mod.parentClass.getColor()
                    : SKColors.light_gray),
            child: Image.asset(this.getDescrImageName(mod)),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      mod.parentClass.name,
                      style: TextStyle(
                          color: mod.isAccepted == null
                              ? mod.parentClass.getColor()
                              : SKColors.light_gray),
                    ),
                    Text(
                      '1 hr.',
                      style: TextStyle(
                          color: SKColors.text_light_gray,
                          fontSize: 13,
                          fontWeight: FontWeight.normal),
                    ),
                  ],
                ),
                Text(
                  mod.isAccepted == null
                      ? mod.shortMsg
                      : '${mod.isAccepted ? 'Copied:' : 'Dismissed:'} ${mod.shortMsg}',
                  style: TextStyle(
                      fontWeight: FontWeight.normal,
                      fontSize: 13,
                      color: mod.isAccepted == null
                          ? SKColors.dark_gray
                          : SKColors.light_gray),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
