import 'package:dart_notification_center/dart_notification_center.dart';
import 'package:dropdown_banner/dropdown_banner.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'package:skoller/screens/main_app/menu/major_search_modal.dart';
import 'package:skoller/tools.dart';
import 'dart:math';

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

    updateProfileState();

    DartNotificationCenter.subscribe(
        observer: this,
        channel: NotificationChannels.newTabSelected,
        onNotification: (index) {
          if (index == JOBS_TAB)
            SKUser.current.getJobProfile().then((response) {
              if (response.wasSuccessful()) {
                updateProfileState();
                setState(() {});
              }
            });
        });
  }

  @override
  void dispose() {
    DartNotificationCenter.unsubscribe(observer: this);

    super.dispose();
  }

  void updateProfileState() {
    final currentProfile = JobProfile.currentProfile;

    if (currentProfile == null)
      profileState = _ProfileState.intro;
    else if (currentProfile.job_search_type == null)
      profileState = _ProfileState.start;
    else if (currentProfile.resume_url == null)
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

  void tappedCreate(_) async {
    final loader = SKLoadingScreen.fadeIn(context);
    RequestResponse response;

    if (JobProfile.currentProfile == null) {
      response = await JobProfile.createProfile(
        jobType: jobType,
        graduationDate: graduationDate,
      );
    } else {
      response = await JobProfile.currentProfile.updateProfile(
        jobSearchType: jobType,
        gradDate: graduationDate,
      );
    }

    loader.fadeOut();

    if (response.wasSuccessful()) {
      setState(() {
        profileState = JobProfile.currentProfile.resume_url == null
            ? _ProfileState.resume
            : _ProfileState.profile;
      });
    }
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
        children = createProfile();
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
                Image.asset(ImageNames.sammiJobsImages.big_smile),
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
          sammiPersonality: SammiPersonality.jobsCool,
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
                onTapUp: tappedCreate,
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
            sammiPersonality: SammiPersonality.jobsSmile,
            speechBubbleContents: Text('Almost there!'),
          ),
        ),
        SKHeaderCard(
          leftHeaderItem: Text(
            'Submit your resumé',
            style: TextStyle(fontSize: 17),
          ),
          margin: EdgeInsets.fromLTRB(16, 0, 16, 16),
          children: <Widget>[
            Padding(
              padding: EdgeInsets.symmetric(vertical: 12, horizontal: 48),
              child: Image.asset(ImageNames.jobsImages.submit_resume_graphic),
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

  List<Widget> createProfile() => [
        Padding(
          padding: EdgeInsets.all(16),
          child: SammiSpeechBubble(
            sammiPersonality: SammiPersonality.jobsLargeSmile,
            speechBubbleContents: Text.rich(
              TextSpan(
                text: 'You are ',
                children: [
                  TextSpan(
                    text: 'ACTIVE',
                    style: TextStyle(color: SKColors.jobs_dark_green),
                  ),
                  TextSpan(text: ' on Skoller Jobs')
                ],
              ),
            ),
          ),
        ),
        SKHeaderCard(
          padding: EdgeInsets.all(16),
          margin: EdgeInsets.fromLTRB(16, 0, 16, 16),
          leftHeaderItem: Text(
            'Profile Strength',
            style: TextStyle(fontSize: 17),
          ),
          rightHeaderItem: Text(
            'Active',
            style: TextStyle(color: SKColors.jobs_dark_green),
          ),
          children: <Widget>[
            Padding(
              padding: EdgeInsets.fromLTRB(72, 16, 72, 32),
              child: AspectRatio(
                aspectRatio: 1,
                child: Container(
                  alignment: Alignment.center,
                  child: _SKJobProfileCompletionCircle(
                    completion: JobProfile.currentProfile.profile_score,
                  ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                children: <Widget>[
                  Icon(
                    Icons.computer,
                    size: 56,
                    color: SKColors.dark_gray,
                  ),
                  SizedBox(
                    width: 24,
                  ),
                  Expanded(
                    child: Text(
                      'Hop on your computer and log in at skoller.co to get the full experience for jobs!',
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
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
  void dispose() {
    monthController.dispose();
    yearController.dispose();

    super.dispose();
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

class _SKJobProfileCompletionCircle extends StatefulWidget {
  final num completion;

  _SKJobProfileCompletionCircle({this.completion});

  @override
  State createState() => _SKJobProfileCompletionCircleState();
}

class _SKJobProfileCompletionCircleState
    extends State<_SKJobProfileCompletionCircle>
    with SingleTickerProviderStateMixin {
  AnimationController animationController;
  Animation<double> animation;

  @override
  void initState() {
    super.initState();

    animationController =
        AnimationController(vsync: this, duration: Duration(seconds: 1));
    animation = Tween<double>(begin: 0, end: widget.completion).animate(
      CurvedAnimation(parent: animationController, curve: Curves.easeOutCubic),
    )..addListener(
        () => setState(() {}),
      );

    animationController.forward();

    DartNotificationCenter.subscribe(
        observer: this,
        channel: NotificationChannels.newTabSelected,
        onNotification: (index) {
          if (index == JOBS_TAB && !animationController.isAnimating) {
            animationController.forward(from: 0);
          }
        });
  }

  @override
  void dispose() {
    DartNotificationCenter.unsubscribe(observer: this);
    animationController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final completion = animation.value;
    return CustomPaint(
      painter: _SKCompletionCirclePainter(completion),
      child: Container(
        alignment: Alignment.center,
        child: Text(
          '${completion * 100 ~/ 1}%',
          style: TextStyle(
              color: SKColors.jobs_dark_green,
              fontWeight: FontWeight.w800,
              fontSize: 28),
        ),
      ),
    );
  }
}

class _SKCompletionCirclePainter extends CustomPainter {
  final num completion;

  _SKCompletionCirclePainter(this.completion);

  @override
  void paint(Canvas canvas, Size size) {
    final fillPaint = Paint()
      ..color = SKColors.jobs_dark_green
      ..style = PaintingStyle.stroke
      ..strokeWidth = 18
      ..strokeCap = StrokeCap.round
      ..isAntiAlias = true;

    final inactivePaint = Paint()
      ..color = SKColors.border_gray
      ..style = PaintingStyle.stroke
      ..strokeWidth = 18
      ..isAntiAlias = true;

    final outerRadius = (size.width);
    final half_pi = pi / 2;
    final sweepAngle = (2 * pi * completion);
    final rect = Rect.fromLTWH(0, 0, outerRadius, outerRadius);
    final adjustmentAngle = 0.02;

    canvas.drawArc(
      rect,
      sweepAngle - half_pi - adjustmentAngle,
      (2 * pi) - sweepAngle + adjustmentAngle,
      false,
      inactivePaint,
    );

    canvas.drawArc(
      rect,
      -half_pi + adjustmentAngle,
      sweepAngle - adjustmentAngle,
      false,
      fillPaint,
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) =>
      oldDelegate is _SKCompletionCirclePainter &&
      oldDelegate.completion != this.completion;
}
