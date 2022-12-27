import 'package:dart_notification_center/dart_notification_center.dart';
import 'package:dropdown_banner/dropdown_banner.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:skoller/tools.dart';

class PersonalityFormModal extends StatefulWidget {
  @override
  State createState() => _PersonalityFormState();
}

const _enneagram = 'enneagram';
const _competitive = 'competitive';
const _myersBriggs = 'myers_briggs';
const _clientFacing = 'client_facing';
const _teamVsIndividual = 'team_vs_individual';
const _challengeStatusQuo = 'challenge_status_quo';
const _createiveVsAnalytical = 'creative_vs_analytical';
const _extrovertedVsIntroverted = 'extroverted_vs_introverted';

class _PersonalityFormState extends State<PersonalityFormModal> {
  Map<String, double?> choices = {};

  Map<String, String> descriptions = {
    _enneagram: 'My Enneagram type is...',
    _competitive: 'I am very competitive.',
    _myersBriggs: 'My Myers-Briggs type is...',
    _clientFacing: 'I prefer working in more client facing roles.',
    _teamVsIndividual: 'I prefer team over individual work.',
    _challengeStatusQuo: 'I like to challenge the status quo.',
    _createiveVsAnalytical:
        'I more often think creatively rather than analytically.',
    _extrovertedVsIntroverted: 'I am more extroverted than introverted.',
  };

  final numSegments = 5;
  final interestLevels = [
    'Strongly disagree',
    'Disagree',
    'Neutral',
    'Agree',
    'Strongly agree',
  ];

  @override
  void initState() {
    super.initState();

    final profilePersonality = JobProfile.currentProfile!.personality;

    if (profilePersonality != null) {
      final values = profilePersonality
          .map((key, value) => MapEntry(key, double.tryParse(value)));
      choices.addAll(values);
    }
  }

  void tappedSave(_) async {
    final personalityEntries =
        choices.map((key, value) => MapEntry(key, value!.round().toString()));
    final loader = SKLoadingScreen.fadeIn(context);
    final response = await JobProfile.currentProfile!
        .updateProfileWithParameters({'personality': personalityEntries});
    loader.fadeOut();
    if (response.wasSuccessful()) {
      DartNotificationCenter.post(channel: NotificationChannels.jobsChanged);
      Navigator.pop(context);
    } else
      DropdownBanner.showBanner(
          text: 'Unable to save new profile information. Please try again!');
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Flexible(
              child: Scrollbar(
                child: Material(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  color: SKColors.dark_gray,
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          Row(
                            children: <Widget>[
                              GestureDetector(
                                behavior: HitTestBehavior.opaque,
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
                              Expanded(
                                child: Text(
                                  'Personality',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 18),
                                ),
                              ),
                              SizedBox(width: 32),
                            ],
                          ),
                          ...createSlider(_extrovertedVsIntroverted),
                          ...createSlider(_clientFacing),
                          ...createSlider(_teamVsIndividual),
                          ...createSlider(_competitive),
                          ...createSlider(_createiveVsAnalytical),
                          ...createSlider(_challengeStatusQuo),
                          if (choices.length > 0)
                            GestureDetector(
                              behavior: HitTestBehavior.opaque,
                              onTapUp: tappedSave,
                              child: Container(
                                alignment: Alignment.center,
                                padding: EdgeInsets.symmetric(vertical: 6),
                                margin: EdgeInsets.only(bottom: 16),
                                decoration: BoxDecoration(
                                    color: SKColors.jobs_light_green,
                                    borderRadius: BorderRadius.circular(5),
                                    boxShadow: UIAssets.boxShadow),
                                child: Text('Save'),
                              ),
                            )
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> createSlider(String key) {
    final value = choices[key];

    return [
      Padding(
        padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        child: Text(
          descriptions[key]!,
          style: TextStyle(
              color: Colors.white, fontWeight: FontWeight.w300, fontSize: 14),
        ),
      ),
      ...(value != null
          ? [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 18),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List<Widget>.generate(
                    numSegments,
                    (i) => Text(
                      (i + 1).toString(),
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w300,
                          fontSize: 14),
                    ),
                  ),
                ),
              ),
              CupertinoSlider(
                divisions: numSegments - 1,
                min: 1,
                max: 5,
                value: value,
                activeColor: SKColors.jobs_light_green,
                onChanged: (newVal) => setState(() {
                  choices[key] = newVal;
                }),
              ),
              Text(
                interestLevels[value.round() - 1],
                style: TextStyle(color: Colors.white, fontSize: 13),
                textAlign: TextAlign.center,
              ),
            ]
          : [
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTapUp: (_) => setState(() => choices[key] = 3),
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 4),
                  margin: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    border: Border.all(
                      color: SKColors.jobs_light_green,
                    ),
                  ),
                  child: Text(
                    'Select...',
                    style: TextStyle(color: SKColors.jobs_light_green),
                  ),
                ),
              ),
            ]),
      SizedBox(height: 16)
    ];
  }
}
