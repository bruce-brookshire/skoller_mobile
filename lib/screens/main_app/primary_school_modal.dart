import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:skoller/screens/main_app/tutorial/calendar_tutorial_view.dart';
import 'package:skoller/tools.dart';

import './menu/school_search_view.dart';

class PrimarySchoolModal extends StatefulWidget {
  @override
  State createState() => _PrimarySchoolState();
}

class _PrimarySchoolState extends State<PrimarySchoolModal> {
  late List<School>? eligibleSchools = null;

  int? selectedSchoolId;
  Period? selectedPeriod;

  bool showingGreeting = true;
  bool loading = false;

  @override
  void initState() {
    super.initState();

    if (SKUser.current?.student.primarySchool != null) {
      eligibleSchools = [SKUser.current!.student.primarySchool!];
      selectedPeriod = eligibleSchools?.first.getBestCurrentPeriod();
      showingGreeting = false;
    } else {
      loading = true;

      SKUser.current?.checkEmailDomain().then((response) async {
        if (response.wasSuccessful()) {
          final List<School> obj = response.obj;

          if (obj.length == 1) {
            selectedSchoolId = obj.first.id;
            selectedPeriod = obj.first.getBestCurrentPeriod();
            await SKUser.current?.update(primarySchool: obj.first);
          } else if (obj.length == 0 && !showingGreeting) tappedSearch(null);

          eligibleSchools = obj;
        }

        setState(() {
          loading = false;
        });
      }).catchError((_) => setState(() => loading = false));
    }
  }

  void tappedSearch(TapUpDetails? details) async {
    await Navigator.push(
      context,
      SKNavFadeUpRoute(builder: (context) => SchoolSearchView()),
    );

    if (SKUser.current?.student.primarySchool != null)
      setState(() {
        eligibleSchools = [SKUser.current!.student.primarySchool!];
        selectedPeriod = eligibleSchools!.first.getBestCurrentPeriod();
      });
  }

  void tappedPeriodSelect(TapUpDetails detail) {
    final now = DateTime.now();

    final eligiblePeriods = (eligibleSchools?.first.periods == null
        ? null
        : eligibleSchools?.first.periods!.toList())!
      ..removeWhere((period) => now.isAfter(period.endDate!))
      ..sort(
        (period1, period2) {
          return period2.startDate != null
              ? (period1.startDate?.compareTo(period2.startDate!) ?? -1)
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

  void tappedSchoolSelect(TapUpDetails? details) async {
    if (selectedPeriod != null) {
      final loader = SKLoadingScreen.fadeIn(context);
      await SKUser.current?.update(primaryPeriod: selectedPeriod!);
      loader.fadeOut();

      Navigator.pop(context);
    } else if (selectedSchoolId != null) {
      final school = eligibleSchools?.firstWhere(
          (school) => school.id == selectedSchoolId,
          orElse: () => eligibleSchools!.first);

      await SKUser.current?.update(primarySchool: school);

      if (SKUser.current?.student.primaryPeriod != null &&
          SKUser.current?.student.primarySchool != null)
        Navigator.pop(context);
      else
        setState(() {
          eligibleSchools = [SKUser.current!.student.primarySchool!];
          selectedPeriod = eligibleSchools!.first.getBestCurrentPeriod();
        });
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget body;
    if (showingGreeting)
      body = createGreeting();
    else
      body = SafeArea(
        child: Container(
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
        ),
      );

    return Stack(
      children: <Widget>[
        Positioned.fill(
          child: Material(
            color: Colors.white,
            child: SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Container(
                    height: 44,
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Color(0x1C000000),
                          offset: Offset(0, 3.5),
                          blurRadius: 2,
                        )
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Image.asset(ImageNames.peopleImages.static_profile),
                        Text(
                          'Calendar',
                          style: TextStyle(fontSize: 18),
                        ),
                        Image.asset(ImageNames.rightNavImages.plus),
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                    child: Text(
                      DateFormat('MMMM, yyyy').format(DateTime(2019, 10, 1)),
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                  Padding(
                      padding: EdgeInsets.only(top: 4, bottom: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: <Widget>[
                          Text('U',
                              style: TextStyle(
                                  color: SKColors.light_gray, fontSize: 14)),
                          Text('M',
                              style: TextStyle(
                                  color: SKColors.light_gray, fontSize: 14)),
                          Text('T',
                              style: TextStyle(
                                  color: SKColors.light_gray, fontSize: 14)),
                          Text('W',
                              style: TextStyle(
                                  color: SKColors.light_gray, fontSize: 14)),
                          Text('R',
                              style: TextStyle(
                                  color: SKColors.light_gray, fontSize: 14)),
                          Text('F',
                              style: TextStyle(
                                  color: SKColors.light_gray, fontSize: 14)),
                          Text('S',
                              style: TextStyle(
                                  color: SKColors.light_gray, fontSize: 14)),
                        ],
                      )),
                  Expanded(
                      child: CalendarTutorialView(() {}, '', showSammi: false)),
                  Container(
                    height: 44,
                    margin: EdgeInsets.only(top: 8),
                    decoration: BoxDecoration(
                        border: Border(
                            top: BorderSide(color: SKColors.border_gray))),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: <Widget>[
                        Image.asset(
                            'image_assets/tab_bar_assets/todos_blue.png'),
                        Image.asset(
                            'image_assets/tab_bar_assets/calendar_gray.png'),
                        Image.asset(
                            'image_assets/tab_bar_assets/classes_gray.png'),
                        Image.asset(
                            'image_assets/tab_bar_assets/activity_gray.png'),
                        Image.asset(
                            'image_assets/tab_bar_assets/jobs_gray.png'),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
        Positioned.fill(
          child: Container(
            color: Colors.black.withOpacity(0.65),
          ),
        ),
        body
      ],
    );
  }

  Widget createGreeting() {
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
          padding: EdgeInsets.symmetric(vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: EdgeInsets.symmetric(vertical: 8, horizontal: 24),
                child: Row(
                  children: [
                    Padding(
                      padding: EdgeInsets.only(right: 16),
                      child: Image.asset(ImageNames.sammiImages.intro),
                    ),
                    Expanded(
                      child: Text(
                        'Welcome to Skoller!',
                        style: TextStyle(fontSize: 32),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.only(right: 16, bottom: 8, left: 4),
                child: SammiSpeechBubble(
                  sammiPersonality: null,
                  speechBubbleContents: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text.rich(
                        TextSpan(
                          text: 'I\'m Sammi. I\'ll be your guide to help you',
                          children: [
                            TextSpan(
                                text: ' get the most ',
                                style: TextStyle(fontWeight: FontWeight.bold)),
                            TextSpan(text: 'out of college!')
                          ],
                          style: TextStyle(
                              fontSize: 17, fontWeight: FontWeight.normal),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              loading
                  ? Padding(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      child: SizedBox(
                        width: 32,
                        height: 32,
                        child: Center(child: CircularProgressIndicator()),
                      ),
                    )
                  : GestureDetector(
                      onTapUp: (details) {
                        if (eligibleSchools?.length == 0) tappedSearch(null);
                        setState(() => showingGreeting = false);
                      },
                      child: Container(
                        alignment: Alignment.center,
                        padding: EdgeInsets.symmetric(vertical: 10),
                        margin:
                            EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(5),
                            color: SKColors.skoller_blue,
                            boxShadow: UIAssets.boxShadow),
                        child: Text(
                          'Get started',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    )
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> buildSearch() {
    return [
      SammiSpeechBubble(
        sammiPersonality: SammiPersonality.school,
        speechBubbleContents: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'First off...',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.normal),
            ),
            Padding(
              padding: EdgeInsets.only(top: 2),
              child: Text(
                'Find your school!',
                style: TextStyle(
                  fontSize: 16,
                ),
              ),
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
          boxShadow: UIAssets.boxShadow,
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
    final school = eligibleSchools![0];
    final period = selectedPeriod;

    final formatter = DateFormat('MMMM');
    final start =
        period?.startDate == null ? null : formatter.format(period!.startDate!);
    final end =
        period?.endDate == null ? null : formatter.format(period!.endDate!);

    return [
      SammiSpeechBubble(
        sammiPersonality: SammiPersonality.school,
        speechBubbleContents: Text(
          'Is this correct?',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ),
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
                    boxShadow: UIAssets.boxShadow),
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
            Padding(
              padding: EdgeInsets.only(left: 6, top: 8),
              child: Text(
                'Term',
                style: TextStyle(fontSize: 14),
              ),
            ),
            GestureDetector(
              onTapUp: tappedPeriodSelect,
              child: Container(
                margin: EdgeInsets.symmetric(vertical: 4, horizontal: 4),
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(5),
                    border: Border.all(color: SKColors.border_gray),
                    boxShadow: UIAssets.boxShadow),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(period?.name ?? 'Select Period'),
                          Text(
                            '${start ?? 'N/A'} to ${end ?? 'N/A'}',
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
            color: SKColors.skoller_blue1,
            borderRadius: BorderRadius.circular(5),
            boxShadow: UIAssets.boxShadow,
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
        padding: EdgeInsets.only(bottom: 16),
        child: SammiSpeechBubble(
          sammiPersonality: SammiPersonality.school,
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
          ),
        ),
      ),
      Flexible(
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) =>
              Scrollbar(
            child: SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ...eligibleSchools!
                        .map(
                          (school) => GestureDetector(
                            onTapUp: (details) =>
                                setState(() => selectedSchoolId = school.id),
                            child: Container(
                              margin: EdgeInsets.symmetric(
                                  vertical: 4, horizontal: 4),
                              padding: EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                  color: selectedSchoolId == school.id
                                      ? SKColors.menu_blue
                                      : Colors.white,
                                  borderRadius: BorderRadius.circular(5),
                                  border:
                                      Border.all(color: SKColors.border_gray),
                                  boxShadow: UIAssets.boxShadow),
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
                    SizedBox(
                      height: 8,
                    )
                  ],
                ),
              ),
            ),
          ),
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
            boxShadow: UIAssets.boxShadow,
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
