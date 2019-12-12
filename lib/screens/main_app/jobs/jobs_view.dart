import 'package:dart_notification_center/dart_notification_center.dart';
import 'package:dropdown_banner/dropdown_banner.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:skoller/screens/main_app/menu/major_search_modal.dart';
import 'package:skoller/tools.dart';

class JobsView extends StatefulWidget {
  State createState() => _JobsViewState();
}

enum _ProfileState { intro, start, resume, profile }

class _JobsViewState extends State<JobsView> {
  _ProfileState profileState;

  TypeObject jobType;
  DateTime graduationDate;

  @override
  void initState() {
    super.initState();

    if (JobProfile.currentProfile == null) profileState = _ProfileState.intro;
  }

  void tappedMonth(_) {}

  void tappedMajors(_) async {
    final loader = SKLoadingScreen.fadeIn(context);
    final response = await FieldsOfStudy.getFieldsOfStudy();
    loader.fadeOut();

    if (response.wasSuccessful()) {
      await Navigator.push(context,
          SKNavOverlayRoute(builder: (_) => MajorSelector(response.obj)));
      setState(() {});
    } else
      DropdownBanner.showBanner(
          text: 'Failed to fetch fields of study',
          textStyle: TextStyle(color: Colors.white),
          color: SKColors.warning_red);
  }

  void tappedDegree(_) async {
    final loader = SKLoadingScreen.fadeIn(context);
    final response = await TypeObject.getDegreeTypes();
    loader.fadeOut();

    if (response.wasSuccessful()) {
      final items = response.obj as List<TypeObject>;
      showDialog(
        context: context,
        builder: (_) => SKPickerModal(
          title: 'Degree type',
          subtitle: 'What degree are you pursuing?',
          items: items.map((t) => t.name).toList(),
          onSelect: (index) async {
            final loader = SKLoadingScreen.fadeIn(context);
            await SKUser.current.update(degreeType: items[index]);
            loader.fadeOut();

            setState(() {});
          },
        ),
      );
    } else
      DropdownBanner.showBanner(
          text: 'Failed to get degree types',
          color: SKColors.warning_red,
          textStyle: TextStyle(color: SKColors.warning_red));
  }

  void tappedJobType(_) async {
    final loader = SKLoadingScreen.fadeIn(context);
    final response = await TypeObject.getJobTypes();
    loader.fadeOut();

    if (response.wasSuccessful()) {
      final items = response.obj as List<TypeObject>;
      showDialog(
        context: context,
        builder: (_) => SKPickerModal(
          title: 'Job type',
          subtitle: 'What kind of job are you looking for?',
          items: items.map((t) => t.name).toList(),
          onSelect: (index) async {
            setState(() {
              jobType = items[index];
            });
          },
        ),
      );
    } else
      DropdownBanner.showBanner(
          text: 'Failed to get job types',
          color: SKColors.warning_red,
          textStyle: TextStyle(color: SKColors.warning_red));
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> children;

    switch (profileState) {
      case _ProfileState.intro:
        children = createIntro();
        break;
      case _ProfileState.start:
        children = createStart();
        break;
      case _ProfileState.resume:
        children = createIntro();
        break;
      case _ProfileState.profile:
        children = createIntro();
        break;
    }

    return SKNavView(
      title: 'Jobs',
      isPop: false,
      leftBtn: SKHeaderProfilePhoto(),
      callbackLeft: () =>
          DartNotificationCenter.post(channel: NotificationChannels.toggleMenu),
      children: children,
    );
  }

  List<Widget> createIntro() => [
        Expanded(
          child: Container(
            margin: EdgeInsets.all(16),
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: SKColors.border_gray),
                color: Colors.white,
                boxShadow: UIAssets.boxShadow),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                Image.asset(ImageNames.sammiImages.big_smile),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Text.rich(
                    TextSpan(
                      text: 'Use your progress in Skoller to help you land the',
                      children: [
                        TextSpan(
                          text: ' job you love!',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                      style: TextStyle(fontWeight: FontWeight.normal),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                Expanded(
                  child: Image.asset(ImageNames.jobsImages.jobs_cover_art),
                ),
                GestureDetector(
                  onTapUp: (_) =>
                      setState(() => profileState = _ProfileState.start),
                  behavior: HitTestBehavior.opaque,
                  child: Container(
                    margin: EdgeInsets.only(top: 24),
                    padding: EdgeInsets.symmetric(vertical: 8),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5),
                      color: SKColors.jobs_dark_green,
                      boxShadow: UIAssets.boxShadow,
                    ),
                    child: Text(
                      'Get Started',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ];

  List<Widget> createStart() {
    final fields = SKUser.current.student.fieldsOfStudy ?? <FieldsOfStudy>[];
    String fieldsBody;

    if (fields.length > 0)
      fieldsBody = fields.map((f) => f.field).join(', ');
    else
      fieldsBody = 'Select...';

    final isValid = graduationDate != null &&
        fields.length > 0 &&
        SKUser.current.student.degreeType != null &&
        jobType != null;

    return [
      Padding(
        padding: EdgeInsets.all(16),
        child: SammiSpeechBubble(
          sammiPersonality: SammiPersonality.cool,
          speechBubbleContents: Text(
            'So... What\'s the plan?',
            style: TextStyle(fontSize: 16),
          ),
        ),
      ),
      Flexible(
        fit: FlexFit.loose,
        child: SingleChildScrollView(
          child: SKHeaderCard(
            leftHeaderItem: Text(
              'Create Profile',
              style: TextStyle(fontSize: 17),
            ),
            margin: EdgeInsets.fromLTRB(16, 0, 16, 16),
            padding: EdgeInsets.all(24),
            children: <Widget>[
              Padding(
                padding: EdgeInsets.only(left: 6, bottom: 4),
                child: Text(
                  'Graduation',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.normal,
                    color: SKColors.light_gray,
                  ),
                ),
              ),
              Row(
                children: <Widget>[
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5),
                        border: Border.all(color: SKColors.jobs_dark_green),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Month',
                            style: TextStyle(color: SKColors.jobs_dark_green),
                          ),
                          Image.asset(ImageNames.navArrowImages.dropdown_blue)
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.all(6),
                      margin: EdgeInsets.only(left: 12),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5),
                        border: Border.all(color: SKColors.jobs_dark_green),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Padding(
                          // padding: EdgeInsets.only(right: 24),
                          // child:
                          Text(
                            'Year',
                            style: TextStyle(color: SKColors.jobs_dark_green),
                          ),
                          // ),
                          Image.asset(ImageNames.navArrowImages.dropdown_blue)
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: EdgeInsets.only(left: 6, bottom: 4, top: 16),
                child: Text(
                  'Major(s)',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.normal,
                    color: SKColors.light_gray,
                  ),
                ),
              ),
              GestureDetector(
                onTapUp: tappedMajors,
                behavior: HitTestBehavior.opaque,
                child: Container(
                  padding: EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    border: Border.all(color: SKColors.jobs_dark_green),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          fieldsBody,
                          style: TextStyle(color: SKColors.jobs_dark_green),
                        ),
                      ),
                      Image.asset(ImageNames.rightNavImages.magnifying_glass)
                    ],
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(left: 6, bottom: 4, top: 16),
                child: Text(
                  'Pursuing degree',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.normal,
                    color: SKColors.light_gray,
                  ),
                ),
              ),
              GestureDetector(
                onTapUp: tappedDegree,
                behavior: HitTestBehavior.opaque,
                child: Container(
                  padding: EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    border: Border.all(color: SKColors.jobs_dark_green),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        SKUser.current.student.degreeType?.name ?? 'Select...',
                        style: TextStyle(color: SKColors.jobs_dark_green),
                      ),
                      Image.asset(ImageNames.navArrowImages.dropdown_blue)
                    ],
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(left: 6, bottom: 4, top: 16),
                child: Text(
                  'Your next job',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.normal,
                    color: SKColors.light_gray,
                  ),
                ),
              ),
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTapUp: tappedJobType,
                child: Container(
                  padding: EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    border: Border.all(color: SKColors.jobs_dark_green),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        jobType?.name ?? 'Select...',
                        style: TextStyle(color: SKColors.jobs_dark_green),
                      ),
                      Image.asset(ImageNames.navArrowImages.dropdown_blue)
                    ],
                  ),
                ),
              ),
              Container(
                margin: EdgeInsets.only(top: 24),
                alignment: Alignment.center,
                padding: EdgeInsets.symmetric(vertical: 6),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5),
                  color: isValid ? SKColors.jobs_dark_green : SKColors.inactive_gray,
                  boxShadow: UIAssets.boxShadow,
                ),
                child: Text(
                  'Next',
                  style: TextStyle(color: isValid ? Colors.white : SKColors.dark_gray),
                ),
              )
            ],
          ),
        ),
      ),
    ];
  }
}
