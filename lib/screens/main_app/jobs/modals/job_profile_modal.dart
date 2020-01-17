import 'dart:collection';

import 'package:dropdown_banner/dropdown_banner.dart';
import 'package:flutter/material.dart';
import 'package:skoller/tools.dart';

class JobProfileModal extends StatefulWidget {
  @override
  State createState() => _JobProfileModalState();
}

class _JobProfileModalState extends State<JobProfileModal> {
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
            final loader = SKLoadingScreen.fadeIn(context);
            final response = await JobProfile.currentProfile
                .updateProfile(jobSearchType: items[index]);
            loader.fadeOut();

            if (response.wasSuccessful()) setState(() {});
          },
        ),
      );
    } else
      DropdownBanner.showBanner(
          text: 'Failed to get job types',
          color: SKColors.warning_red,
          textStyle: TextStyle(color: SKColors.warning_red));
  }

  void tappedUSWorkAuth(_) {
    showDialog(
      context: context,
      builder: (context) => SKPickerModal(
        items: ['Yes', 'No'],
        title: 'Work Authorization',
        subtitle: 'Are you authorized to work in the U.S?',
        onSelect: (index) async {
          final loader = SKLoadingScreen.fadeIn(context);
          final response = await JobProfile.currentProfile
              .updateProfile(workAuth: index == 0 ? true : false);
          loader.fadeOut();

          if (response.wasSuccessful()) setState(() {});
        },
      ),
    );
  }

  void tappedEmployerSponsorship(_) {
    showDialog(
      context: context,
      builder: (context) => SKPickerModal(
        items: ['Yes', 'No'],
        title: 'Employer Sponsorship',
        subtitle: 'Do you need to be sponsored to work in the U.S?',
        onSelect: (index) async {
          final loader = SKLoadingScreen.fadeIn(context);
          final response = await JobProfile.currentProfile
              .updateProfile(sponsorshipRequired: index == 0 ? true : false);
          loader.fadeOut();

          if (response.wasSuccessful()) setState(() {});
        },
      ),
    );
  }

  void tappedHomeState(_) {
    final keys = _states.keys.toList();
    showDialog(
      context: context,
      builder: (context) => SKPickerModal(
        items: keys,
        title: 'Home state',
        subtitle: 'Where are you from?',
        onSelect: (index) async {
          final loader = SKLoadingScreen.fadeIn(context);
          final response = await JobProfile.currentProfile
              .updateProfile(stateCode: _states[keys[index]]);
          loader.fadeOut();

          if (response.wasSuccessful()) setState(() {});
        },
      ),
    );
  }

  void tappedProfileStatus(_) async {
    final loader = SKLoadingScreen.fadeIn(context);
    final response = await TypeObject.getStatusTypes();
    loader.fadeOut();

    if (response.wasSuccessful()) {
      final items = response.obj as List<TypeObject>;
      showDialog(
        context: context,
        builder: (_) => SKPickerModal(
          title: 'Profile status',
          subtitle: 'Should we show your profile to employers?',
          items: items.map((t) => t.name).toList(),
          onSelect: (index) async {
            final loader = SKLoadingScreen.fadeIn(context);
            final response = await JobProfile.currentProfile
                .updateProfile(jobProfileStatus: items[index]);
            loader.fadeOut();

            if (response.wasSuccessful()) setState(() {});
          },
        ),
      );
    } else
      DropdownBanner.showBanner(
          text: 'Failed to get activity types',
          color: SKColors.warning_red,
          textStyle: TextStyle(color: SKColors.warning_red));
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          Flexible(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Material(
                color: SKColors.dark_gray,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    gradient: LinearGradient(
                        colors: [Colors.transparent, SKColors.jobs_dark_green],
                        stops: [0, 0.95],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              GestureDetector(
                                onTapUp: (_) => Navigator.pop(context),
                                child: SizedBox(
                                  width: 32,
                                  height: 32,
                                  child: Icon(
                                    Icons.keyboard_arrow_down,
                                    color: SKColors.jobs_light_green,
                                    size: 32,
                                  ),
                                ),
                              ),
                              Text(
                                'Basic Info',
                                style: TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 18,
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(width: 32),
                            ],
                          ),
                          SizedBox(height: 32),
                          ...buildInfoPrompt(
                            prompt: 'What type of job are you seeking?',
                            choice:
                                JobProfile.currentProfile.job_search_type.name,
                            callback: tappedJobType,
                          ),
                          ...buildInfoPrompt(
                            prompt:
                                'Are you authorized to work in the United States?',
                            choice: JobProfile.currentProfile.work_auth,
                            callback: tappedUSWorkAuth,
                          ),
                          ...buildInfoPrompt(
                            prompt:
                                'Will you need employer sponsorship to work in the United States?',
                            choice:
                                JobProfile.currentProfile.sponsorship_required,
                            callback: tappedEmployerSponsorship,
                          ),
                          ...buildInfoPrompt(
                            prompt: 'What is your home state?',
                            choice: JobProfile.currentProfile.state_code,
                            callback: tappedHomeState,
                          ),
                          ...buildInfoPrompt(
                            prompt: 'Profile status',
                            choice: JobProfile
                                .currentProfile.job_profile_status.name,
                            callback: tappedProfileStatus,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> buildInfoPrompt({
    String prompt,
    dynamic choice,
    Function(dynamic) callback,
  }) {
    String stringifiedChoice = choice != null
        ? (choice is bool ? (choice == true ? 'Yes' : 'No') : '$choice')
        : 'Select...';

    return [
      Padding(
        padding: EdgeInsets.symmetric(horizontal: 4),
        child: Text(
          prompt,
          style: TextStyle(
              color: Colors.white, fontWeight: FontWeight.w500, fontSize: 14),
        ),
      ),
      GestureDetector(
        onTapUp: callback,
        behavior: HitTestBehavior.opaque,
        child: Container(
          margin: EdgeInsets.only(top: 4, bottom: 24),
          padding: EdgeInsets.symmetric(vertical: 6, horizontal: 12),
          alignment: Alignment.centerLeft,
          decoration: BoxDecoration(
              color: SKColors.dark_gray,
              borderRadius: BorderRadius.circular(5),
              border: Border.all(color: SKColors.jobs_light_green),
              boxShadow: UIAssets.boxShadow),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                stringifiedChoice,
                style: TextStyle(color: SKColors.jobs_light_green),
              ),
              Image.asset(ImageNames.navArrowImages.dropdown_green)
            ],
          ),
        ),
      ),
    ];
  }
}

final _states = LinkedHashMap.fromIterables([
  "Alabama",
  "Alaska",
  "Arizona",
  "Arkansas",
  "California",
  "Colorado",
  "Connecticut",
  "Delaware",
  "District Of Columbia",
  "Florida",
  "Georgia",
  "Hawaii",
  "Idaho",
  "Illinois",
  "Indiana",
  "Iowa",
  "Kansas",
  "Kentucky",
  "Louisiana",
  "Maine",
  "Maryland",
  "Massachusetts",
  "Michigan",
  "Minnesota",
  "Mississippi",
  "Missouri",
  "Montana",
  "Nebraska",
  "Nevada",
  "New Hampshire",
  "New Jersey",
  "New Mexico",
  "New York",
  "North Carolina",
  "North Dakota",
  "Ohio",
  "Oklahoma",
  "Oregon",
  "Pennsylvania",
  "Rhode Island",
  "South Carolina",
  "South Dakota",
  "Tennessee",
  "Texas",
  "Utah",
  "Vermont",
  "Virginia",
  "Washington",
  "West Virginia",
  "Wisconsin",
  "Wyoming"
], [
  "AL",
  "AK",
  "AZ",
  "AR",
  "CA",
  "CO",
  "CT",
  "DE",
  "DC",
  "FL",
  "GA",
  "HI",
  "ID",
  "IL",
  "IN",
  "IA",
  "KS",
  "KY",
  "LA",
  "ME",
  "MD",
  "MA",
  "MI",
  "MN",
  "MS",
  "MO",
  "MT",
  "NE",
  "NV",
  "NH",
  "NJ",
  "NM",
  "NY",
  "NC",
  "ND",
  "OH",
  "OK",
  "OR",
  "PA",
  "RI",
  "SC",
  "SD",
  "TN",
  "TX",
  "UT",
  "VT",
  "VA",
  "WA",
  "WV",
  "WI",
  "WY"
]);
