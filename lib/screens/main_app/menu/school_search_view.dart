import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:skoller/tools.dart';
import 'package:dart_notification_center/dart_notification_center.dart';

class SchoolSearchView extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _SchoolSearchViewState();
}

class _SchoolSearchViewState extends State<SchoolSearchView> {
  final searchController = TextEditingController();

  List<School> searchedSchools = [];

  Timer _currentTimer;
  bool isSearching = false;

  void didTypeInSearch(String text) {
    if (_currentTimer != null) {
      _currentTimer.cancel();
      _currentTimer = null;
    }

    final searchText = text.trim();

    if (searchText == '') {
      if (isSearching) {
        setState(() {
          isSearching = false;
        });
      }

      SchoolClass.invalidateCurrentClassSearch();

      setState(() {
        searchedSchools = [];
      });
      return;
    }

    if (!isSearching) {
      setState(() {
        isSearching = true;
      });
    }

    _currentTimer = Timer(
      Duration(milliseconds: searchText.length < 3 ? 800 : 300),
      () {
        School.searchSchools(searchText).then((response) {
          _currentTimer = null;

          if (response.wasSuccessful()) {
            setState(() {
              searchedSchools = response.obj;
              isSearching = false;
            });
          }
        });
      },
    );
  }

  void tappedSchool(int index) async {
    final school = searchedSchools[index];

    final result = await showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: BorderSide(color: SKColors.border_gray),
        ),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Text(school.name,
                  style: TextStyle(
                    fontSize: 18,
                    color: school.color ?? SKColors.dark_gray,
                  )),
              Padding(
                padding: EdgeInsets.symmetric(vertical: 2),
                child: Text(
                  '${school.adrLocality ?? ''} ${school.adrRegion ?? ''}',
                  style: TextStyle(
                    fontWeight: FontWeight.normal,
                  ),
                ),
              ),
              GestureDetector(
                onTapUp: (details) => Navigator.pop(context, true),
                child: Container(
                  alignment: Alignment.center,
                  padding: EdgeInsets.symmetric(vertical: 8),
                  margin: EdgeInsets.only(top: 12),
                  decoration: BoxDecoration(
                    color: SKColors.skoller_blue,
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Text(
                    'Select this school',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );

    if (result is bool && result) {
      await SKUser.current.update(primarySchool: school);
      Navigator.pop(context);
      DartNotificationCenter.post(channel: NotificationChannels.userChanged, options: school);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Column(
            children: <Widget>[
              Container(
                padding: EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: SKColors.border_gray),
                    boxShadow: [UIAssets.boxShadow]),
                // color: Colors.white,
                child: Row(
                  children: <Widget>[
                    GestureDetector(
                      onTapUp: (details) => Navigator.pop(context),
                      child: Container(
                        width: 36,
                        height: 36,
                        child: Image.asset(
                            ImageNames.signUpImages.search_back_arrow),
                      ),
                    ),
                    Expanded(
                      child: CupertinoTextField(
                        placeholder: 'School name',
                        placeholderStyle: TextStyle(
                            fontSize: 15, color: SKColors.text_light_gray),
                        style:
                            TextStyle(color: SKColors.dark_gray, fontSize: 15),
                        padding: EdgeInsets.fromLTRB(6, 9, 4, 6),
                        onChanged: didTypeInSearch,
                        cursorColor: SKColors.skoller_blue,
                        textCapitalization: TextCapitalization.words,
                        decoration: BoxDecoration(border: null),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: 8, right: 8),
                      child: isSearching
                          ? SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                              ))
                          : Image.asset(
                              ImageNames.rightNavImages.magnifying_glass),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  padding: EdgeInsets.only(top: 4),
                  itemCount: searchedSchools.length,
                  itemBuilder: (context, index) => GestureDetector(
                    onTapUp: (details) => tappedSchool(index),
                    child: Container(
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(5),
                          border: Border.all(color: SKColors.border_gray),
                          boxShadow: [UIAssets.boxShadow]),
                      margin: EdgeInsets.fromLTRB(12, 4, 12, 4),
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            searchedSchools[index].name,
                            style: TextStyle(
                                fontSize: 16,
                                color: searchedSchools[index].color ??
                                    SKColors.dark_gray),
                          ),
                          Text(
                            '${searchedSchools[index].adrLocality ?? ''} ${searchedSchools[index].adrRegion ?? ''}',
                            style: TextStyle(
                                color: SKColors.light_gray,
                                fontSize: 14,
                                fontWeight: FontWeight.normal),
                          )
                        ],
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
