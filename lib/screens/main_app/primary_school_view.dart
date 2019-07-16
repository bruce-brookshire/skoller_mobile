import 'package:dart_notification_center/dart_notification_center.dart';
import 'package:flutter/material.dart';
import 'package:skoller/tools.dart';
import './menu/school_search_view.dart';

class PrimarySchoolView extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _PrimarySchoolState();
}

class _PrimarySchoolState extends State<PrimarySchoolView> {
  List<School> eligibleSchools;
  int selectedSchoolId;

  @override
  void initState() {
    SKUser.current.checkEmailDomain().then((response) async {
      if (response.wasSuccessful()) {
        final List<School> obj = response.obj;
        if (obj.length == 1) {
          await SKUser.current.update(primarySchool: obj.first);
          Navigator.pop(context);
          DartNotificationCenter.post(
              channel: NotificationChannels.userChanged, options: obj.first);
        } else {
          setState(() {
            eligibleSchools = response.obj;
          });
        }
      }
    });
    super.initState();
  }

  void tappedSearch(TapUpDetails details) async {
    await Navigator.push(
      context,
      SKNavOverlayRoute(builder: (context) => SchoolSearchView()),
    );

    if (SKUser.current.student.primarySchool != null) {
      Navigator.pop(context);
    }
  }

  void tappedSelect(TapUpDetails details) async {
    if (selectedSchoolId == null) return;

    final school =
        eligibleSchools.firstWhere((school) => school.id == selectedSchoolId);

    await SKUser.current.update(primarySchool: school);
    Navigator.pop(context);
    DartNotificationCenter.post(
        channel: NotificationChannels.userChanged, options: school);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SKColors.background_gray,
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Spacer(flex: 1),
              if (eligibleSchools == null)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    SizedBox(
                        width: 40,
                        height: 40,
                        child: CircularProgressIndicator()),
                  ],
                ),
              if ((eligibleSchools?.length ?? -1) == 0) ...buildSearch(),
              if ((eligibleSchools?.length ?? -1) > 1) ...buildMultiple(),
              Spacer(flex: 2),
            ]),
      ),
    );
  }

  List<Widget> buildSearch() {
    return [
      Padding(
        padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        child: Text(
          'Meet Sammi 👋',
          style: TextStyle(fontSize: 32),
        ),
      ),
      SammiSpeechBubble(
        sammiPersonality: SammiPersonality.smile,
        speechBubbleContents: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Welcome to Skoller! I\'m here to show you around. First up...',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.normal),
            ),
            Padding(
              padding: EdgeInsets.only(top: 4),
              child: Text('Find your school!'),
            ),
          ],
        ),
      ),
      Container(
        margin: EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: SKColors.border_gray),
          boxShadow: [UIAssets.boxShadow],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              decoration: BoxDecoration(
                color: SKColors.selected_gray,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(10),
                  topRight: Radius.circular(10),
                ),
              ),
              padding: EdgeInsets.fromLTRB(12, 12, 12, 8),
              alignment: Alignment.centerLeft,
              child: Text('Search for a school'),
            ),
            GestureDetector(
              onTapUp: tappedSearch,
              child: Container(
                margin: EdgeInsets.all(16),
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                decoration: BoxDecoration(
                  border: Border.all(color: SKColors.border_gray),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: Text(
                        'Search your school...',
                        style: TextStyle(
                            color: SKColors.light_gray,
                            fontWeight: FontWeight.normal),
                      ),
                    ),
                    Image.asset(ImageNames.rightNavImages.magnifying_glass)
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    ];
  }

  List<Widget> buildMultiple() {
    return [
      Padding(
        padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        child: Text(
          'Meet Sammi 👋',
          style: TextStyle(fontSize: 32),
        ),
      ),
      SammiSpeechBubble(
          sammiPersonality: SammiPersonality.smile,
          speechBubbleContents: Text.rich(
            TextSpan(
              text: 'I found some schools that might be yours...',
              style: TextStyle(fontWeight: FontWeight.normal),
              children: [
                TextSpan(
                    text: ' Select your school or search to find correct one.',
                    style: TextStyle(fontWeight: FontWeight.bold))
              ],
            ),
          )),
      Padding(
        padding: EdgeInsets.only(top: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: eligibleSchools
              .map(
                (school) => GestureDetector(
                  onTapUp: (details) =>
                      setState(() => selectedSchoolId = school.id),
                  child: Container(
                    margin: EdgeInsets.symmetric(vertical: 4, horizontal: 4),
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                        color: selectedSchoolId == school.id
                            ? SKColors.menu_blue
                            : Colors.white,
                        borderRadius: BorderRadius.circular(5),
                        border: Border.all(color: SKColors.border_gray),
                        boxShadow: [UIAssets.boxShadow]),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          school.name,
                          style: TextStyle(color: school.color),
                        ),
                        Text(
                          '${school.adrLocality}, ${school.adrRegion}',
                          style: TextStyle(
                              color: SKColors.light_gray,
                              fontSize: 14,
                              fontWeight: FontWeight.normal),
                        ),
                      ],
                    ),
                  ),
                ),
              )
              .toList(),
        ),
      ),
      GestureDetector(
        onTapUp: tappedSelect,
        child: Container(
          alignment: Alignment.center,
          margin: EdgeInsets.fromLTRB(24, 24, 24, 16),
          padding: EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: selectedSchoolId == null
                ? SKColors.inactive_gray
                : SKColors.skoller_blue,
            borderRadius: BorderRadius.circular(5),
            boxShadow: [UIAssets.boxShadow],
          ),
          child: Text(
            'Continue 👉',
            style: TextStyle(
                color: selectedSchoolId == null
                    ? SKColors.dark_gray
                    : Colors.white),
          ),
        ),
      ),
      GestureDetector(
        onTapUp: (details) => setState(() => eligibleSchools = []),
        child: Text(
          'Search for your school',
          textAlign: TextAlign.center,
          style: TextStyle(color: SKColors.skoller_blue),
        ),
      )
    ];
  }
}
