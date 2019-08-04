import 'package:dart_notification_center/dart_notification_center.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:skoller/tools.dart';
import './menu/school_search_view.dart';

class PrimarySchoolModal extends StatefulWidget {
  @override
  State createState() => _PrimarySchoolState();
}

class _PrimarySchoolState extends State<PrimarySchoolModal> {
  List<School> eligibleSchools;

  int selectedSchoolId;
  Period selectedPeriod;

  @override
  void initState() {
    super.initState();

    if (SKUser.current.student.primarySchool != null) {
      eligibleSchools = [SKUser.current.student.primarySchool];
      selectedPeriod = eligibleSchools.first.getBestCurrentPeriod();
    } else {
      SKUser.current.checkEmailDomain().then((response) async {
        if (response.wasSuccessful()) {
          final List<School> obj = response.obj;

          if (obj.length == 1) {
            await SKUser.current.update(primarySchool: obj.first);
            selectedSchoolId = obj.first.id;
            selectedPeriod = obj.first.getBestCurrentPeriod();
          }

          setState(() {
            eligibleSchools = obj;
          });
        }
      });
    }
  }

  void tappedSearch(TapUpDetails details) async {
    await Navigator.push(
      context,
      SKNavFadeUpRoute(builder: (context) => SchoolSearchView()),
    );

    if (SKUser.current.student.primarySchool != null &&
        SKUser.current.student.primaryPeriod != null)
      Navigator.pop(context);
    else if (SKUser.current.student.primarySchool != null)
      setState(() {
        eligibleSchools = [SKUser.current.student.primarySchool];
        selectedPeriod = eligibleSchools.first.getBestCurrentPeriod();
      });
  }

  void tappedPeriodSelect(TapUpDetails detail) {
    final now = DateTime.now();

    final eligiblePeriods = eligibleSchools.first.periods == null
        ? null
        : eligibleSchools.first.periods.toList()
      ..removeWhere((period) => now.isAfter(period.endDate))
      ..sort(
        (period1, period2) {
          return period2.startDate != null
              ? (period1.startDate?.compareTo(period2.startDate) ?? -1)
              : 1;
        },
      );

    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) => SKPickerModal(
        title: 'Active term',
        subtitle: 'Which term are you using Skoller for right now?',
        onSelect: (index) =>
            setState(() => selectedPeriod = eligiblePeriods[index]),
        items: eligiblePeriods.toList().map((p) => p.name).toList(),
      ),
    );
  }

  void tappedSchoolSelect(TapUpDetails details) async {
    if (selectedPeriod != null) {
      final loader = SKLoadingScreen.fadeIn(context);
      await SKUser.current.update(primaryPeriod: selectedPeriod);
      loader.dismiss();

      Navigator.pop(context);
    } else if (selectedSchoolId != null) {
      final school =
          eligibleSchools.firstWhere((school) => school.id == selectedSchoolId);

      await SKUser.current.update(primarySchool: school);

      if (SKUser.current.student.primaryPeriod != null &&
          SKUser.current.student.primarySchool != null)
        Navigator.pop(context);
      else
        setState(() {
          eligibleSchools = [SKUser.current.student.primarySchool];
          selectedPeriod = eligibleSchools.first.getBestCurrentPeriod();
        });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      padding: EdgeInsets.fromLTRB(24, 0, 24, 64),
      child: Material(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: BorderSide(color: SKColors.border_gray),
        ),
        color: SKColors.background_gray,
        child: Padding(
          padding: EdgeInsets.all(12),
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
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
                if ((eligibleSchools?.length ?? -1) == 1) ...buildSingle(),
                if ((eligibleSchools?.length ?? -1) > 1) ...buildMultiple(),
              ]),
        ),
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

  List<Widget> buildSingle() {
    final school = eligibleSchools[0];
    final period = selectedPeriod;

    final formatter = DateFormat('MMMM');
    final start =
        period?.startDate == null ? null : formatter.format(period.startDate);
    final end =
        period?.endDate == null ? null : formatter.format(period.endDate);

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
              text: 'Hi! I\'ll help you get set up.',
              style: TextStyle(fontWeight: FontWeight.normal),
              children: [
                TextSpan(
                    text: ' Is this correct?',
                    style: TextStyle(fontWeight: FontWeight.bold))
              ],
            ),
          )),
      Padding(
        padding: EdgeInsets.only(top: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: EdgeInsets.only(left: 6),
              child: Text(
                'School',
                style: TextStyle(fontSize: 14),
              ),
            ),
            GestureDetector(
              onTapUp: tappedSearch,
              child: Container(
                margin: EdgeInsets.symmetric(vertical: 4, horizontal: 4),
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(5),
                    border: Border.all(color: SKColors.border_gray),
                    boxShadow: [UIAssets.boxShadow]),
                child: Row(
                  children: [
                    Expanded(
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
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 4),
                      child:
                          Image.asset(ImageNames.navArrowImages.dropdown_blue),
                    )
                  ],
                ),
              ),
            ),
            if (period != null)
              Padding(
                padding: EdgeInsets.only(left: 6, top: 8),
                child: Text(
                  'Term',
                  style: TextStyle(fontSize: 14),
                ),
              ),
            if (period != null)
              GestureDetector(
                onTapUp: tappedPeriodSelect,
                child: Container(
                  margin: EdgeInsets.symmetric(vertical: 4, horizontal: 4),
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(5),
                      border: Border.all(color: SKColors.border_gray),
                      boxShadow: [UIAssets.boxShadow]),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(period.name),
                            Text(
                              '${start ?? ''} to ${end ?? 'N/A'}',
                              style: TextStyle(
                                  color: SKColors.light_gray,
                                  fontSize: 14,
                                  fontWeight: FontWeight.normal),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 4),
                        child: Image.asset(
                            ImageNames.navArrowImages.dropdown_blue),
                      )
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
      GestureDetector(
        onTapUp: (details) {
          tappedSchoolSelect(null);
        },
        child: Container(
          alignment: Alignment.center,
          margin: EdgeInsets.fromLTRB(24, 24, 24, 16),
          padding: EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: SKColors.skoller_blue,
            borderRadius: BorderRadius.circular(5),
            boxShadow: [UIAssets.boxShadow],
          ),
          child: Text(
            'That\'s right! 👉',
            style: TextStyle(color: Colors.white),
          ),
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
        onTapUp: tappedSearch,
        child: Padding(
          padding: EdgeInsets.only(top: 8, bottom: 4),
          child: Text(
            'Search for your school',
            textAlign: TextAlign.center,
            style: TextStyle(color: SKColors.skoller_blue),
          ),
        ),
      ),
      GestureDetector(
        onTapUp: tappedSchoolSelect,
        child: Container(
          alignment: Alignment.center,
          margin: EdgeInsets.fromLTRB(24, 12, 24, 4),
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
    ];
  }
}
