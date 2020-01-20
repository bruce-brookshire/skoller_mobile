import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:skoller/screens/main_app/jobs/modals/job_data_collector_modal.dart';
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
  Map<String, double> choices = {
    _enneagram: 3,
    _competitive: 3,
    _myersBriggs: 3,
    _clientFacing: 3,
    _teamVsIndividual: 3,
    _challengeStatusQuo: 3,
    _createiveVsAnalytical: 3,
    _extrovertedVsIntroverted: 3
  };

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
                          Text(
                            'Personality',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.white, fontSize: 18),
                          ),
                          ...createSlider(_extrovertedVsIntroverted),
                          ...createSlider(_clientFacing),
                          ...createSlider(_teamVsIndividual),
                          ...createSlider(_competitive),
                          ...createSlider(_createiveVsAnalytical),
                          ...createSlider(_challengeStatusQuo),
                          ...createSlider(_extrovertedVsIntroverted),
                          ...createSlider(_extrovertedVsIntroverted),
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
          descriptions[key],
          style: TextStyle(
              color: Colors.white, fontWeight: FontWeight.w300, fontSize: 14),
        ),
      ),
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
      SizedBox(height: 16)
    ];
  }
}
