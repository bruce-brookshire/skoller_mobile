import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:skoller/requests/requests_core.dart';
import 'package:skoller/constants/constants.dart';

class AddClassesView extends StatefulWidget {
  @override
  State createState() => _AddClassesViewState();
}

class _AddClassesViewState extends State<AddClassesView> {
  List<SchoolClass> searchedClasses = [];
  Timer _currentTimer;

  void didTypeInSearch(String searchText) {
    if (_currentTimer != null) {
      _currentTimer.cancel();
      _currentTimer = null;
    }

    searchText = searchText.trim();

    if (searchText == '') {
      SchoolClass.invalidateCurrentClassSearch();

      setState(() {
        searchedClasses = [];
      });
      return;
    }

    _currentTimer = Timer(
      Duration(milliseconds: searchText.length < 3 ? 800 : 300),
      () {
        SchoolClass.searchSchoolClasses(
          searchText,
          Period.currentPeriods.values.first,
        ).then((response) {
          _currentTimer = null;

          if (response.wasSuccessful()) {
            setState(() {
              searchedClasses = response.obj;
            });
          }
        });
      },
    );
  }

  void didTapClassCard(int index) async {
    SchoolClass schoolClass = searchedClasses[index];

    final bool isEnrolled =
        StudentClass.currentClasses.containsKey(schoolClass.id);

    await showDialog(
      context: context,
      builder: (context) => Dialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
              side: BorderSide(color: SKColors.border_gray),
            ),
            child: Padding(
              padding: EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: EdgeInsets.only(bottom: 2),
                    child: Text(
                      schoolClass.name,
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Expanded(
                        child: Text(
                          '${schoolClass.subject} ${schoolClass.code}.${schoolClass.section}',
                          style: TextStyle(
                              fontWeight: FontWeight.normal, fontSize: 14),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 2),
                        child: Text(
                          '${schoolClass.enrollment ?? 0}',
                          style: TextStyle(
                              fontSize: 14, fontWeight: FontWeight.normal),
                        ),
                      ),
                      Image.asset(ImageNames.peopleImages.person_dark_gray),
                    ],
                  ),
                  Container(
                    color: SKColors.dark_gray,
                    height: 2,
                    margin: EdgeInsets.only(top: 4, bottom: 12),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Meeting times',
                        style: TextStyle(
                          color: SKColors.light_gray,
                          fontSize: 14,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                      Text(
                        'Professor',
                        style: TextStyle(
                          color: SKColors.light_gray,
                          fontSize: 14,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${schoolClass.meetDays ?? ''} ${schoolClass.meetTime?.format(context) ?? ''}',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                      Text(
                        '${schoolClass.professor?.first_name ?? ''} ${schoolClass.professor?.last_name ?? ''}',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    margin: EdgeInsets.only(top: 16),
                    alignment: Alignment.center,
                    padding: EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: isEnrolled
                          ? SKColors.warning_red
                          : SKColors.skoller_blue,
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Text(
                      isEnrolled ? 'Drop this class' : 'Join this class',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ),
    );
  }

  void didTapAddClassCard() async {
    print('add');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        bottom: false,
        child: Stack(
          children: <Widget>[
            Align(
              alignment: Alignment.center,
              child: Container(
                margin: EdgeInsets.only(top: 128),
                color: SKColors.background_gray,
                child: Center(
                  child: Column(
                    children: [
                      Expanded(
                        child: ListView.builder(
                          padding: EdgeInsets.fromLTRB(8, 6, 8, 12),
                          itemCount: searchedClasses.length == 0 ? 0 : searchedClasses.length + 1,
                          itemBuilder: (context, index) {
                            Widget contents;

                            if (index < searchedClasses.length) {
                              final schoolClass = searchedClasses[index];

                              contents = createClassCard(schoolClass);
                            } else {
                              contents = Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Padding(
                                    padding: EdgeInsets.only(right: 8),
                                    child: Image.asset(
                                        ImageNames.sammiImages.shocked),
                                  ),
                                  Text.rich(
                                    TextSpan(
                                      text: 'Can\'t find your class?',
                                      children: [
                                        TextSpan(
                                          text: ' Tap to add it!',
                                          style: TextStyle(
                                            color: SKColors.skoller_blue,
                                          ),
                                        )
                                      ],
                                    ),
                                    style: TextStyle(fontSize: 16),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              );
                            }

                            return GestureDetector(
                                onTapUp: (details) {
                                  index == searchedClasses.length
                                      ? didTapAddClassCard()
                                      : didTapClassCard(index);
                                },
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 4, vertical: 3),
                                  margin: EdgeInsets.symmetric(vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    border:
                                        Border.all(color: SKColors.border_gray),
                                    borderRadius: BorderRadius.circular(5),
                                    boxShadow: [UIAssets.boxShadow],
                                  ),
                                  child: contents,
                                ));
                          },
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
            Align(
              child: createHeader(),
              alignment: Alignment.topCenter,
            ),
          ],
        ),
      ),
    );
  }

  Widget createHeader() {
    final classCount = StudentClass.currentClasses.length;

    return Container(
      height: 128,
      padding: EdgeInsets.only(top: 12),
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Color(0x1C000000),
            offset: Offset(0, 3.5),
            blurRadius: 2,
          )
        ],
        borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(10), bottomRight: Radius.circular(10)),
        color: Colors.white,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTapUp: (details) {
                  Navigator.pop(context);
                },
                child: Container(
                  padding: EdgeInsets.only(left: 4),
                  child: Center(
                      child: Image.asset(ImageNames.navArrowImages.down)),
                  width: 44,
                  height: 44,
                ),
              ),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text(
                      'Vanderbilt University',
                      style: TextStyle(fontSize: 18),
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: 1, bottom: 4),
                      child: Text(
                        'Summer 2019',
                        style: TextStyle(
                            fontWeight: FontWeight.normal, fontSize: 15),
                      ),
                    ),
                    Text(
                      'You have joined ${classCount} class${classCount == 1 ? '' : 'es'}',
                      style: TextStyle(
                          fontWeight: FontWeight.normal, fontSize: 11),
                    )
                  ],
                ),
              ),
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTapUp: (details) {
                  // if (callbackRight != null) {
                  //   callbackRight();
                  // }
                },
                child: Container(
                  padding: EdgeInsets.only(right: 4),
                  child: Image.asset(ImageNames.rightNavImages.filter_bars),
                  width: 44,
                  height: 44,
                ),
              ),
            ],
          ),
          Container(
            margin: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: SKColors.background_gray,
              borderRadius: BorderRadius.circular(5),
            ),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: CupertinoTextField(
                    onChanged: didTypeInSearch,
                    clearButtonMode: OverlayVisibilityMode.editing,
                    cursorColor: SKColors.skoller_blue,
                    decoration: BoxDecoration(border: null),
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                    placeholder: 'Search a class name',
                    style: TextStyle(fontSize: 15),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(right: 8),
                  child:
                      Image.asset(ImageNames.rightNavImages.magnifying_glass),
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget createClassCard(SchoolClass schoolClass) => Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  '${StudentClass.currentClasses.containsKey(schoolClass.id) ? '✅ ' : ''}${schoolClass.name}',
                  style: TextStyle(fontSize: 17),
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 2),
                child: Text(
                  '${schoolClass.enrollment ?? 0}',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.normal),
                ),
              ),
              Image.asset(ImageNames.peopleImages.person_dark_gray),
            ],
          ),
          Row(
            children: <Widget>[
              Padding(
                padding: EdgeInsets.symmetric(vertical: 2),
                child: Text(
                  '${schoolClass.professor?.first_name ?? ''} ${schoolClass.professor?.last_name ?? ''}',
                  style: TextStyle(
                    fontWeight: FontWeight.normal,
                  ),
                ),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(
                '${schoolClass.subject} ${schoolClass.code}.${schoolClass.section}',
                style: TextStyle(
                    fontWeight: FontWeight.normal,
                    fontSize: 14,
                    color: SKColors.light_gray),
              ),
              Text(
                '${schoolClass.meetDays ?? ''} ${schoolClass.meetTime?.format(context) ?? ''}',
                style: TextStyle(
                    fontWeight: FontWeight.normal,
                    fontSize: 14,
                    color: SKColors.light_gray),
              )
            ],
          ),
        ],
      );
}
