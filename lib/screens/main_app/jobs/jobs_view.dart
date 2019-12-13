import 'package:dart_notification_center/dart_notification_center.dart';
import 'package:dropdown_banner/dropdown_banner.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
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

    if (SKUser.current.student.gradYear != null)
      graduationDate =
          DateTime.parse('${SKUser.current.student.gradYear}-05-01');

    if (JobProfile.currentProfile == null)
      profileState = _ProfileState.intro;
    else if (JobProfile.currentProfile.resume_url == null)
      profileState = _ProfileState.resume;
    else
      profileState = _ProfileState.profile;
  }

  void tappedGradDate(_) async {
    final result = await showDialog(
      context: context,
      builder: (_) => _GraduationDatePicker(
        startDate: graduationDate,
      ),
    );

    if (result is DateTime) {
      setState(() {
        graduationDate = result;
      });
    }
  }

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
        children = createResumeInstructions();
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
            padding: EdgeInsets.fromLTRB(16, 8, 16, 16),
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
              GestureDetector(
                onTapUp: tappedGradDate,
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
                        graduationDate == null
                            ? 'Select...'
                            : DateFormat('MMMM yyyy').format(graduationDate),
                        style: TextStyle(
                            color: graduationDate == null
                                ? SKColors.jobs_light_green
                                : SKColors.jobs_dark_green),
                      ),
                      Image.asset(ImageNames.navArrowImages.dropdown_green)
                    ],
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(left: 6, bottom: 4, top: 12),
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
                          style: TextStyle(
                              color: fields.length == 0
                                  ? SKColors.jobs_light_green
                                  : SKColors.jobs_dark_green),
                        ),
                      ),
                      Image.asset(
                          ImageNames.rightNavImages.magnifying_glass_green)
                    ],
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(left: 6, bottom: 4, top: 12),
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
                        style: TextStyle(
                            color:
                                SKUser.current.student.degreeType?.name == null
                                    ? SKColors.jobs_light_green
                                    : SKColors.jobs_dark_green),
                      ),
                      Image.asset(ImageNames.navArrowImages.dropdown_green)
                    ],
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(left: 6, bottom: 4, top: 12),
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
                        style: TextStyle(
                            color: jobType?.name == null
                                ? SKColors.jobs_light_green
                                : SKColors.jobs_dark_green),
                      ),
                      Image.asset(ImageNames.navArrowImages.dropdown_green)
                    ],
                  ),
                ),
              ),
              GestureDetector(
                onTapUp: (_) async {
                  final loader = SKLoadingScreen.fadeIn(context);
                  final response = await JobProfile.createProfile(
                    jobType: jobType,
                    graduationDate: graduationDate,
                  );
                  loader.fadeOut();

                  if (response.wasSuccessful()) {
                    setState(() {
                      profileState = _ProfileState.resume;
                    });
                  }
                },
                child: Container(
                  margin: EdgeInsets.only(top: 24),
                  alignment: Alignment.center,
                  padding: EdgeInsets.symmetric(vertical: 6),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    color: isValid
                        ? SKColors.jobs_light_green
                        : SKColors.inactive_gray,
                    boxShadow: UIAssets.boxShadow,
                  ),
                  child: Text(
                    'Next',
                    style: TextStyle(
                        color: isValid ? Colors.white : SKColors.dark_gray),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ];
  }

  List<Widget> createResumeInstructions() => [
        Padding(
          padding: EdgeInsets.all(16),
          child: SammiSpeechBubble(
            sammiPersonality: SammiPersonality.smile,
            speechBubbleContents: Text('Almost there!'),
          ),
        ),
        SKHeaderCard(
          leftHeaderItem: Text('Submit your resumé', style: TextStyle(fontSize: 17),),
            margin: EdgeInsets.fromLTRB(16, 0, 16, 16),
            // padding: EdgeInsets.fromLTRB(16, 8, 16, 16),
          children: <Widget>[
            Icon(
              Icons.cloud_upload,
              size: 88,
              color: SKColors.jobs_dark_green,
            ),
            Icon(
              Icons.insert_drive_file,
              size: 44,
              color: SKColors.dark_gray,
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(24, 24, 24, 12),
              child: Text.rich(
                TextSpan(
                  text: 'Hop on your computer and login at skoller.co to ',
                  children: [
                    TextSpan(
                      text: 'SUBMIT YOUR RESUMÉ',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    )
                  ],
                  style: TextStyle(fontWeight: FontWeight.w300),
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        )
      ];
}

class _GraduationDatePicker extends StatefulWidget {
  final DateTime startDate;

  _GraduationDatePicker({this.startDate});

  @override
  State createState() => _GraduationDatePickerState();
}

class _GraduationDatePickerState extends State<_GraduationDatePicker> {
  int monthIndex;
  String year;

  List<String> months;
  List<String> years;

  ScrollController monthController;
  ScrollController yearController;

  @override
  void initState() {
    super.initState();

    final currentYear = DateTime.now().year;

    years = List.generate(6, (index) => '${currentYear + index}');

    months = [
      'Jan.',
      'Feb.',
      'Mar.',
      'Apr.',
      'May',
      'Jun.',
      'Jul.',
      'Aug.',
      'Sept.',
      'Oct.',
      'Nov.',
      'Dec.',
    ];

    if (widget.startDate != null) {
      monthIndex = widget.startDate.month - 1;
      year = '${widget.startDate.year}';
    } else {
      monthIndex = 0;
      year = years.first;
    }

    monthController = FixedExtentScrollController(initialItem: monthIndex);
    yearController =
        FixedExtentScrollController(initialItem: years.indexOf(year));
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(color: SKColors.border_gray),
      ),
      backgroundColor: Colors.white,
      child: Padding(
        padding: EdgeInsets.only(top: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(
              'Graduation Date',
              style: TextStyle(fontSize: 16),
            ),
            Text(
              'When do you expect to graduate?',
              style: TextStyle(fontWeight: FontWeight.normal, fontSize: 14),
            ),
            Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: SizedBox(
                height: 96,
                width: 164,
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: CupertinoPicker.builder(
                        backgroundColor: Colors.white,
                        itemExtent: 24,
                        scrollController: monthController,
                        onSelectedItemChanged: (monthIndex) =>
                            this.monthIndex = monthIndex,
                        childCount: 12,
                        itemBuilder: (_, index) => Container(
                          alignment: Alignment.center,
                          child: Text(
                            months[index],
                            style: Theme.of(context)
                                .textTheme
                                .body1
                                .copyWith(fontWeight: FontWeight.normal),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: CupertinoPicker.builder(
                        backgroundColor: Colors.white,
                        itemExtent: 24,
                        scrollController: yearController,
                        onSelectedItemChanged: (yearIndex) =>
                            this.year = years[yearIndex],
                        childCount: years.length,
                        itemBuilder: (_, index) => Container(
                          alignment: Alignment.center,
                          child: Text(
                            years[index],
                            style: Theme.of(context)
                                .textTheme
                                .body1
                                .copyWith(fontWeight: FontWeight.normal),
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
            SizedBox(
              height: 44,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Expanded(
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTapUp: (_) => Navigator.pop(context),
                      child: Container(
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                            border: Border(
                                top: BorderSide(color: SKColors.border_gray))),
                        child: Text(
                          'Cancel',
                          style: TextStyle(
                            fontWeight: FontWeight.normal,
                            color: SKColors.warning_red,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Container(
                    width: 1,
                    color: SKColors.border_gray,
                  ),
                  Expanded(
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTapUp: (_) {
                        final monthNum = monthIndex + 1;
                        String monthStr = '$monthNum';
                        if (monthNum < 10) monthStr = '0$monthNum';

                        final gradDate = DateTime.parse('${year}-$monthStr-01');

                        Navigator.pop(context, gradDate);
                      },
                      child: Container(
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                            border: Border(
                                top: BorderSide(color: SKColors.border_gray))),
                        child: Text(
                          'Select',
                          style: TextStyle(color: SKColors.jobs_light_green),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
