import 'package:dropdown_banner/dropdown_banner.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:skoller/tools.dart';
import 'dart:collection';

class CreateSchoolModal extends StatefulWidget {
  final String initName;

  CreateSchoolModal(this.initName);

  @override
  State<StatefulWidget> createState() => _CreateSchoolModalState();
}

class _CreateSchoolModalState extends State<CreateSchoolModal> {
  final states = LinkedHashMap.fromIterables([
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

  int selectedSegment = 0;

  TextEditingController nameController;
  final cityController = TextEditingController();
  String selectedState;

  bool isValid = false;

  @override
  void initState() {
    nameController = TextEditingController(text: widget.initName);

    super.initState();
  }

  void checkValid([String str]) {
    final newIsValid = nameController.text.trim() != '' &&
        cityController.text.trim() != '' &&
        selectedState != null;

    if (isValid != newIsValid) {
      setState(() {
        isValid = newIsValid;
      });
    }
  }

  void tappedSelectState(TapUpDetails details) async {
    final keys = states.keys.toList();
    String selectedState = keys[0];

    final result = await showDialog(
      context: context,
      builder: (context) => SKPickerModal(
        title: 'Select state',
        subtitle: 'What state is your school in?',
        items: keys,
        onSelect: (index) => selectedState = keys[index],
      ),
    );

    if (result is bool && result) {
      setState(() {
        this.selectedState = selectedState;
      });
      checkValid();
    }
  }

  void tappedSaveSchool(TapUpDetails details) {
    if (!isValid) return;

    final loadingScreen = SKLoadingScreen.fadeIn(context);

    School.createSchool(
      isUniversity: selectedSegment == 0,
      schoolName: nameController.text.trim(),
      cityName: cityController.text.trim(),
      stateAbv: states[selectedState],
    ).then((response) {
      if (response.wasSuccessful() && response.obj is School) {
        return SKUser.current
            .update(primarySchool: response.obj)
            .then((response2) {
          if (response2) {
            Navigator.pop(context, response.obj);
          } else {
            throw 'Failed to set preferences. Please search school and add.';
          }
        });
      } else {
        throw 'Failed to create school. Try searching and recreating';
      }
    }).catchError((error) {
      if (error is String) {
        DropdownBanner.showBanner(
          text: error,
          color: SKColors.warning_red,
          textStyle: TextStyle(color: Colors.white),
        );
      }
    }).then((response) => loadingScreen.dismiss());
  }

  @override
  Widget build(BuildContext context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: BorderSide(color: SKColors.border_gray),
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Padding(
                padding: EdgeInsets.only(bottom: 4),
                child: Text(
                  'Create a new school',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 17),
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(13, 0, 13, 12),
                child: Text(
                  'We will use this information for all classes at this school',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      // color: SKColors.light_gray,
                      fontWeight: FontWeight.normal,
                      fontSize: 13),
                ),
              ),
              CupertinoSegmentedControl(
                padding: null,
                onValueChanged: (newVal) =>
                    setState(() => selectedSegment = newVal),
                selectedColor: SKColors.skoller_blue,
                borderColor: SKColors.skoller_blue,
                groupValue: selectedSegment,
                children: LinkedHashMap.fromIterables(
                  [0, 1],
                  [
                    Text(
                      'College',
                      style: TextStyle(
                        color: selectedSegment == 0
                            ? Colors.white
                            : SKColors.skoller_blue,
                        fontWeight: FontWeight.normal,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      'High school',
                      style: TextStyle(
                        color: selectedSegment == 1
                            ? Colors.white
                            : SKColors.skoller_blue,
                        fontWeight: FontWeight.normal,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                margin: EdgeInsets.fromLTRB(15, 8, 15, 4),
                padding: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                decoration: BoxDecoration(
                  color: SKColors.background_gray,
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text(
                      'School name',
                      style: TextStyle(
                          color: SKColors.skoller_blue,
                          fontSize: 14,
                          fontWeight: FontWeight.normal),
                    ),
                    CupertinoTextField(
                      cursorColor: SKColors.skoller_blue,
                      padding: EdgeInsets.only(top: 1),
                      placeholder: 'Harvard University',
                      style: TextStyle(fontSize: 15, color: SKColors.dark_gray),
                      decoration: BoxDecoration(border: null),
                      controller: nameController,
                      onChanged: checkValid,
                      autofocus: true,
                    ),
                  ],
                ),
              ),
              Container(
                margin: EdgeInsets.symmetric(vertical: 4, horizontal: 15),
                padding: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                decoration: BoxDecoration(
                  color: SKColors.background_gray,
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text(
                      'School city',
                      style: TextStyle(
                          color: SKColors.skoller_blue,
                          fontSize: 14,
                          fontWeight: FontWeight.normal),
                    ),
                    CupertinoTextField(
                      cursorColor: SKColors.skoller_blue,
                      padding: EdgeInsets.only(top: 1),
                      placeholder: 'Boston',
                      style: TextStyle(fontSize: 15, color: SKColors.dark_gray),
                      decoration: BoxDecoration(border: null),
                      controller: cityController,
                      onChanged: checkValid,
                      autofocus: true,
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTapUp: tappedSelectState,
                child: Container(
                  margin: EdgeInsets.symmetric(vertical: 4, horizontal: 15),
                  padding: EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                  decoration: BoxDecoration(
                    color: SKColors.background_gray,
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        child: Text(
                            selectedState == null
                                ? 'School state'
                                : selectedState,
                            style: TextStyle(
                                color: selectedState == null
                                    ? SKColors.text_light_gray
                                    : SKColors.dark_gray,
                                fontWeight: FontWeight.normal,
                                fontSize: 15)),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 4),
                        child: Image.asset(
                            ImageNames.navArrowImages.dropdown_blue),
                      ),
                    ],
                  ),
                ),
              ),
              GestureDetector(
                onTapUp: tappedSaveSchool,
                child: Container(
                  alignment: Alignment.center,
                  padding: EdgeInsets.symmetric(vertical: 10),
                  margin: EdgeInsets.fromLTRB(15, 12, 15, 0),
                  decoration: BoxDecoration(
                      color: isValid
                          ? SKColors.skoller_blue
                          : SKColors.inactive_gray,
                      borderRadius: BorderRadius.circular(5),
                      boxShadow: [UIAssets.boxShadow]),
                  child: Text(
                    'Save school',
                    style: TextStyle(
                        color: isValid ? Colors.white : SKColors.dark_gray),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
}
