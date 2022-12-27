import 'package:dart_notification_center/dart_notification_center.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:skoller/screens/main_app/jobs/modals/job_data_collector_modal.dart';
import 'package:skoller/screens/main_app/jobs/modals/personality_form_modal.dart';
import 'package:skoller/screens/main_app/menu/profile_photo_view.dart';
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
    _JobInfoPromptType? type=null;

    if (SKUser.current?.avatarUrl == null)
      type = _JobInfoPromptType.avatar;
    else if (profile!.regions == null)
      type = _JobInfoPromptType.regions;
    else if (profile.career_interests == null)
      type = _JobInfoPromptType.careerInterests;
    else if (profile.startup_interest == null)
      type = _JobInfoPromptType.startupInterest;
    else if (profile.gpa == null)
      type = _JobInfoPromptType.gpa;
    else if (profile.state_code == null)
      type = _JobInfoPromptType.stateCode;
    else if (profile.work_auth == null)
      type = _JobInfoPromptType.workAuth;
    else if (profile.sponsorship_required == null)
      type = _JobInfoPromptType.sponsorshipRequired;
    else if (profile.personality == null) type = _JobInfoPromptType.personality;

    return JobInfoPromptModal._fromType(type!);
  }

  JobInfoPromptModal._fromType(this.type);

  void showTextModal({
    required String title,
    required String placeholderText,
    required TextInputType inputType,
    required String parameterName,
    required BuildContext context,
    dynamic Function(dynamic)? resultConverter,
  }) {
    showDialog(
      context: context,
      builder: (context) => DataCollectorModal.textType(
        title: title,
        placeholderText: placeholderText,
        inputType: inputType,
        onSubmit: (text) async {
          final value = resultConverter != null ? resultConverter(text) : text;
          await updateProfile(
            parameterName: parameterName,
            value: value,
            context: context,
          );
        },
      ),
    );
  }

  void showPickerModal({
    required String title,
    required List<String> items,
    required String parameterName,
    required BuildContext context,
    dynamic Function(dynamic)? resultConverter,
  }) =>
      showDialog(
        context: context,
        builder: (context) => DataCollectorModal.pickerType(
          title: title,
          items: items,
          onSubmit: (indexes) async {
            final value =
                resultConverter != null ? resultConverter(indexes) : indexes;
            await updateProfile(
              parameterName: parameterName,
              value: value,
              context: context,
            );
          },
        ),
      );

  void showMultipleSelectModal({
    required String title,
    required List<String> items,
    required String parameterName,
    required BuildContext context,
    String? subtitle,
    dynamic Function(dynamic)? resultConverter,
  }) =>
      showDialog(
        context: context,
        builder: (context) => DataCollectorModal.multipleSelectType(
          title: title,
          items: items,
          subtitle: subtitle,
          onSubmit: (indexes) async {
            final value =
                resultConverter != null ? resultConverter(indexes) : indexes;
            await updateProfile(
              parameterName: parameterName,
              value: value,
              context: context,
            );
          },
        ),
      );

  void showToggleModal({
    required String title,
    required String parameterName,
    required BuildContext context,
    String? subtitle,
  }) =>
      showDialog(
        context: context,
        builder: (context) => DataCollectorModal.toggleType(
          title: title,
          subtitle: subtitle,
          onSubmit: (value) async {
            await updateProfile(
              parameterName: parameterName,
              value: value,
              context: context,
            );
          },
        ),
      );

  void showScaleModal({
    required String title,
    required String parameterName,
    required BuildContext context,
  }) =>
      showDialog(
        context: context,
        builder: (context) => DataCollectorModal.scaleType(
          title: title,
          numSegments: 3,
          onSubmit: (value) async {
            await updateProfile(
              parameterName: parameterName,
              value: value,
              context: context,
            );
          },
        ),
      );

 Future<void> updateProfile({
    String? parameterName,
    dynamic value,
    BuildContext? context,
  }) async {
    final loader = SKLoadingScreen.fadeIn(context!);
    final response = await JobProfile.currentProfile!
        .updateProfileWithParameters({parameterName!: value});

    loader.fadeOut();

    if (response.wasSuccessful())
      DartNotificationCenter.post(channel: NotificationChannels.jobsChanged);
  }

  void tappedAvatar(context) {
    showDialog(
      context: context,
      builder: (modalContext) => ProfilePhotoSourceModal(isJobs: true));
  }

  void tappedGPA(context) => showTextModal(
        title: 'What is your GPA?',
        placeholderText: 'ex. 3.72',
        inputType:
            TextInputType.numberWithOptions(decimal: true, signed: false),
        parameterName: 'gpa',
        context: context,
        resultConverter: (text) => double.tryParse(text),
      );

  void tappedRegions(context) {
    final regions = ['Northwest', 'Northeast', 'Southwest', 'Southeast'];

    showMultipleSelectModal(
      title: 'Work Location',
      items: regions,
      parameterName: 'regions',
      context: context,
      resultConverter: (indexes) =>
          (indexes as List<int>).map((i) => regions[i]).join("|"),
    );
  }

  void tappedState(context) {
    final states = statesMap.keys.toList();

    showPickerModal(
      title: 'Work Location',
      items: states,
      parameterName: 'state_code',
      context: context,
      resultConverter: (index) => statesMap[states[index]],
    );
  }

  void tappedWorkAuth(context) => showToggleModal(
      context: context,
      parameterName: 'work_auth',
      title: 'Work Authorization',
      subtitle: 'Are you authorized to work in the United States?');

  void tappedSponsorship(context) => showToggleModal(
      context: context,
      parameterName: 'sponsorship_required',
      title: 'Employer Sponsorship',
      subtitle:
          'Will you need employer sponsorship to work in the United States?');

  void tappedStartupInterest(context) => showScaleModal(
      title: 'How interested are you in working at a startup?',
      context: context,
      parameterName: 'startup_interest');

  void tappedCareerInterest(context) {
    final careerInterests = [
      'Account Manager',
      'Accounting',
      'Biotechnology',
      'Business Analyst',
      'Consulting',
      'Data Science',
      'Design/Creative',
      'Engineering',
      'Finance',
      'Government and Politics',
      'Human Resources/Recruiting',
      'Information Technology',
      'Legal',
      'Marketing/Advertising',
      'Nonprofit',
      'Office Management',
      'Operations/Logistics',
      'Product Management',
      'Quantitative Trading',
      'Real Estate',
      'Research',
      'Sales/Business Development',
      'Social Media/Communications',
      'Software Development',
      'Startups',
      'Teaching'
    ];

    showMultipleSelectModal(
      context: context,
      title: 'Career Interests',
      subtitle: 'Select up to 5',
      parameterName: 'career_interests',
      items: careerInterests,
      resultConverter: (indexes) {
        if (indexes.length > 5) {
          throw 'You cannnot select more than 5 items';
        } else {
          return (indexes as List<int>)
              .map((i) => careerInterests[i])
              .join("|");
        }
      },
    );
  }

  void tappedPersonality(context) => Navigator.push(
        context,
        SKNavOverlayRoute(
          isBarrierDismissible: false,
          builder: (context) => PersonalityFormModal(),
        ),
      );

  @override
  Widget build(BuildContext context) {
    return nextPromptBuilder(context);
  }

  Widget nextPromptBuilder(BuildContext context) {
    String prompt;
    Function(BuildContext context) action;

    switch (type) {
      case _JobInfoPromptType.avatar:
        prompt = 'Add a profile picture';
        action = tappedAvatar;
        break;
      case _JobInfoPromptType.regions:
        prompt = 'Where are you looking to work?';
        action = tappedRegions;
        break;
      case _JobInfoPromptType.careerInterests:
        prompt = 'What are your career interests?';
        action = tappedCareerInterest;
        break;
      case _JobInfoPromptType.stateCode:
        prompt = 'What state are you from?';
        action = tappedState;
        break;
      case _JobInfoPromptType.workAuth:
        prompt = 'Are you authorized to work in the U.S?';
        action = tappedWorkAuth;
        break;
      case _JobInfoPromptType.sponsorshipRequired:
        prompt = 'Do you require work sponsorship to work in the U.S?';
        action = tappedSponsorship;
        break;
      case _JobInfoPromptType.personality:
        prompt = 'Add some personality to your profile!';
        action = tappedPersonality;
        break;
      case _JobInfoPromptType.gpa:
        prompt = 'What is your GPA?';
        action = tappedGPA;
        break;
      case _JobInfoPromptType.startupInterest:
        prompt = 'Are you interested in working for a startup?';
        action = tappedStartupInterest;
        break;
    }

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
