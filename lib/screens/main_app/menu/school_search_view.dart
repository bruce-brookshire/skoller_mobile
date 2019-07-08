import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:skoller/tools.dart';

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

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Column(
            children: <Widget>[
              Container(
                padding: EdgeInsets.symmetric(horizontal: 4, vertical: 6),
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
                        padding: EdgeInsets.fromLTRB(6, 9, 4, 6),
                        onChanged: didTypeInSearch,
                        cursorColor: SKColors.skoller_blue,
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
                  itemBuilder: (context, index) => Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(5),
                      border: Border.all(color: SKColors.border_gray),
                      boxShadow: [UIAssets.boxShadow]
                    ),
                    margin: EdgeInsets.fromLTRB(12, 4, 12, 4),
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(searchedSchools[index].name),
                        Text(searchedSchools[index].timezone ?? 'N/A', style: TextStyle(color: SKColors.light_gray, fontWeight: FontWeight.normal),)
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
}
