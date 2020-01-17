import 'package:dart_notification_center/dart_notification_center.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:skoller/tools.dart';

enum _JobInfoPromptType {
  avatar,
  regions,
  careerInterests,
  stateCode,
  workAuth,
  sponsorshipRequired,
  personality,
  gpa,
  startupInterest
}

class JobInfoPromptModal extends StatelessWidget {
  final _JobInfoPromptType type;

  factory JobInfoPromptModal() {
    final profile = JobProfile.currentProfile;
    _JobInfoPromptType type;

    if (SKUser.current.avatarUrl == null)
      type = _JobInfoPromptType.avatar;
    else if (profile.regions == null)
      type = _JobInfoPromptType.regions;
    else if (profile.career_interests == null)
      type = _JobInfoPromptType.careerInterests;
    else if (profile.state_code == null)
      type = _JobInfoPromptType.stateCode;
    else if (profile.work_auth == null)
      type = _JobInfoPromptType.workAuth;
    else if (profile.sponsorship_required == null)
      type = _JobInfoPromptType.sponsorshipRequired;
    else if (profile.personality == null)
      type = _JobInfoPromptType.personality;
    else if (profile.gpa == null)
      type = _JobInfoPromptType.gpa;
    else if (profile.startup_interest == null)
      type = _JobInfoPromptType.startupInterest;

    return type == null ? null : JobInfoPromptModal._fromType(type);
  }

  JobInfoPromptModal._fromType(this.type);

  void tappedGPA(context) async {
    final gpaController = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) => _DataCollectorModal.textType(
        title: 'GPA',
        placeholderText: 'ex. 3.72',
        inputType:
            TextInputType.numberWithOptions(decimal: true, signed: false),
        onSubmit: (text) async {
          final loader = SKLoadingScreen.fadeIn(context);
          final gpa = double.parse(text);

          print(gpa);
          final response =
              await JobProfile.currentProfile.updateProfile(gpa: gpa);
          loader.fadeOut();

          if (response.wasSuccessful())
            DartNotificationCenter.post(
                channel: NotificationChannels.jobsChanged);
        },
      ),
    );

    gpaController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return nextPromptBuilder(context);
  }

  Widget nextPromptBuilder(BuildContext context) {
    String prompt;
    Function(dynamic) action;

    switch (type) {
      case _JobInfoPromptType.avatar:
        prompt = 'Add a profile picture';
        action = (_) {
          showDialog(context: context, builder: (context) => null);
        };
        break;
      case _JobInfoPromptType.regions:
        prompt = 'Where are you looking to work?';
        action = (_) {
          showDialog(context: context, builder: (context) => null);
        };
        break;
      case _JobInfoPromptType.careerInterests:
        prompt = 'What are your career interests?';
        action = (_) {
          showDialog(context: context, builder: (context) => null);
        };
        break;
      case _JobInfoPromptType.stateCode:
        prompt = 'What state are you from?';
        action = (_) {
          showDialog(context: context, builder: (context) => null);
        };
        break;
      case _JobInfoPromptType.workAuth:
        prompt = 'Are you authorized to work in the U.S?';
        action = (_) {
          showDialog(context: context, builder: (context) => null);
        };
        break;
      case _JobInfoPromptType.sponsorshipRequired:
        prompt = 'Do you require work sponsorship top work in the U.S?';
        action = (_) {
          showDialog(context: context, builder: (context) => null);
        };
        break;
      case _JobInfoPromptType.personality:
        prompt = 'Add some personality to your profile!';
        action = (_) {
          showDialog(context: context, builder: (context) => null);
        };
        break;
      case _JobInfoPromptType.gpa:
        prompt = 'What is your GPA?';
        action = tappedGPA;
        break;
      case _JobInfoPromptType.startupInterest:
        prompt = 'Are you interested to work for a startup?';
        action = (_) {
          // Navigator.push(context, Cupertin)
          print('show profile');
        };
        break;
    }
    prompt = 'What is your GPA?';
    action = tappedGPA;

    return GestureDetector(
      onTapUp: (_) => action(context),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 6, horizontal: 12),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5),
          color: SKColors.jobs_light_green,
          boxShadow: UIAssets.boxShadow,
        ),
        child: Text(
          prompt,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

enum _CollectionType { text, picker, toggle }

class _DataCollectorModal extends StatefulWidget {
  final String title;
  final _CollectionType type;
  final Future<void> Function(dynamic) onSubmit;

  // Text type
  final String placeholderText;
  final TextInputType inputType;

  _DataCollectorModal.textType({
    @required this.title,
    this.placeholderText,
    this.inputType,
    @required this.onSubmit,
  }) : type = _CollectionType.text;

  _DataCollectorModal.pickerType({
    @required this.title,
    @required this.onSubmit,
  })  : type = _CollectionType.picker,
        placeholderText = null,
        inputType = null;

  _DataCollectorModal.toggleType({
    @required this.title,
    @required this.onSubmit,
  })  : type = _CollectionType.toggle,
        placeholderText = null,
        inputType = null;

  @override
  State createState() => _DataCollectorModalState();
}

class _DataCollectorModalState extends State<_DataCollectorModal> {
  ValueNotifier controller;

  @override
  void initState() {
    controller = TextEditingController();

    super.initState();
  }

  @override
  void dispose() {
    controller?.dispose();

    super.dispose();
  }

  void tappedUpdate(_) async {
    dynamic result;

    if (widget.type == _CollectionType.text)
      result = (controller as TextEditingController).text;

    await widget.onSubmit(result);

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    Widget child;

    switch (widget.type) {
      case _CollectionType.text:
        child = buildTextType();
        break;
      case _CollectionType.picker:
        child = buildTextType();
        break;

      case _CollectionType.toggle:
        child = buildTextType();
        break;
    }

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      backgroundColor: SKColors.dark_gray,
      child: Padding(
        padding: EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(
              widget.title,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white),
            ),
            child,
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTapUp: tappedUpdate,
              child: Container(
                alignment: Alignment.center,
                padding: EdgeInsets.symmetric(vertical: 6),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5),
                  color: SKColors.jobs_light_green,
                ),
                child: Text(
                  'Update',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildTextType() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 16),
      child: CupertinoTextField(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(5),
        ),
        placeholder: widget.placeholderText,
        placeholderStyle: Theme.of(context)
            .textTheme
            .body1
            .copyWith(color: SKColors.text_light_gray),
        controller: controller,
        keyboardType: widget.inputType,
        autofocus: true,
      ),
    );
  }

  Widget buildPickerType() {}
  Widget buildToggleType() {}
}
