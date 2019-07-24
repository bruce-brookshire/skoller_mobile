import 'dart:async';
import 'package:dropdown_banner/dropdown_banner.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:skoller/tools.dart';

class ProfessorSearchView extends StatefulWidget {
  final ProfessorCallback callback;

  ProfessorSearchView(this.callback);

  @override
  State<StatefulWidget> createState() => _ProfessorSearchState();
}

class _ProfessorSearchState extends State<ProfessorSearchView> {
  final searchController = TextEditingController();

  List<Professor> searchedProfessors = [];

  Timer _currentTimer;
  bool isSearching = false;
  School school;

  @override
  void initState() {
    school = SKUser.current.student.primarySchool;

    super.initState();
  }

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

      school.invalidateCurrentProfessorSearch();

      setState(() {
        searchedProfessors = [];
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
        school.searchProfessors(searchText).then((response) {
          _currentTimer = null;

          if (response.wasSuccessful()) {
            setState(() {
              searchedProfessors = response.obj;
              isSearching = false;
            });
          }
        });
      },
    );
  }

  void tappedCreateProfessor(TapUpDetails details) async {
    final searchText = searchController.text.trim().split(' ');
    final numSections = searchText.length;

    String firstName;
    String lastName;

    switch (numSections) {
      case 0:
        firstName = '';
        lastName = '';
        break;
      case 1:
        firstName = '';
        lastName = searchText[0];
        break;
      case 2:
        firstName = searchText[0];
        lastName = searchText[1];
        break;
      default:
        firstName = searchText.getRange(0, numSections - 1).toList().join(' ');
        lastName = searchText[numSections - 1];
        break;
    }

    final firstNameController = TextEditingController(text: firstName);
    final lastNameController = TextEditingController(text: lastName);

    final result = await showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
            side: BorderSide(color: SKColors.border_gray)),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Padding(
                padding: EdgeInsets.only(bottom: 12),
                child: Text(
                  'Create professor',
                  style: TextStyle(fontSize: 17),
                  textAlign: TextAlign.center,
                ),
              ),
              Row(
                children: <Widget>[
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: SKColors.selected_gray,
                        borderRadius: BorderRadius.circular(5),
                      ),
                      padding: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            'First name',
                            textAlign: TextAlign.left,
                            style: TextStyle(
                              color: SKColors.skoller_blue,
                              fontWeight: FontWeight.normal,
                              fontSize: 12,
                            ),
                          ),
                          CupertinoTextField(
                            autofocus: true,
                            decoration: BoxDecoration(border: null),
                            cursorColor: SKColors.skoller_blue,
                            padding: EdgeInsets.only(top: 5),
                            textCapitalization: TextCapitalization.words,
                            controller: firstNameController,
                            style: TextStyle(
                              fontWeight: FontWeight.normal,
                              fontSize: 14,
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 8,
                  ),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: SKColors.selected_gray,
                        borderRadius: BorderRadius.circular(5),
                      ),
                      padding: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            'Last name',
                            textAlign: TextAlign.left,
                            style: TextStyle(
                              color: SKColors.skoller_blue,
                              fontWeight: FontWeight.normal,
                              fontSize: 12,
                            ),
                          ),
                          CupertinoTextField(
                            autofocus: true,
                            controller: lastNameController,
                            decoration: BoxDecoration(border: null),
                            padding: EdgeInsets.only(top: 5),
                            style: TextStyle(
                              fontWeight: FontWeight.normal,
                              fontSize: 14,
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              GestureDetector(
                onTapUp: (details) => Navigator.pop(context, true),
                child: Container(
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5),
                      color: SKColors.skoller_blue),
                  padding: EdgeInsets.symmetric(vertical: 8),
                  margin: EdgeInsets.only(top: 12),
                  child: Text(
                    'Save',
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

      final loadingScreen = SKLoadingScreen.fadeIn(context);

      final result = await school.createProfessor(
        nameFirst: firstNameController.text.trim(),
        nameLast: lastNameController.text.trim(),
      );

      loadingScreen.dismiss();

      if (result.wasSuccessful()) {
        widget.callback(result.obj);
        Navigator.pop(context);
      } else {
        DropdownBanner.showBanner(
          text: 'Failed to create professor. Try searching and recreating if necessary.',
          color: SKColors.warning_red,
          textStyle: TextStyle(color: Colors.white),
        );
      }
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
                        placeholder: 'Professor name',
                        placeholderStyle: TextStyle(
                            fontSize: 15, color: SKColors.text_light_gray),
                        style:
                            TextStyle(color: SKColors.dark_gray, fontSize: 15),
                        padding: EdgeInsets.fromLTRB(6, 9, 4, 6),
                        onChanged: didTypeInSearch,
                        cursorColor: SKColors.skoller_blue,
                        textCapitalization: TextCapitalization.words,
                        decoration: BoxDecoration(border: null),
                        autofocus: true,
                        controller: searchController,
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
                  itemCount: searchController.text.trim().length > 0
                      ? searchedProfessors.length + (isSearching ? 0 : 1)
                      : 0,
                  itemBuilder: (context, index) {
                    if (index < searchedProfessors.length)
                      return GestureDetector(
                        onTapUp: (details) {
                          widget.callback(searchedProfessors[index]);
                          Navigator.pop(context);
                        },
                        child: Container(
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(5),
                              border: Border.all(color: SKColors.border_gray),
                              boxShadow: [UIAssets.boxShadow]),
                          margin: EdgeInsets.fromLTRB(12, 4, 12, 4),
                          padding:
                              EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Text(
                                searchedProfessors[index].fullName,
                                style: TextStyle(
                                    fontSize: 16, color: SKColors.dark_gray),
                              ),
                              Text(
                                '${searchedProfessors[index].email ?? ''}',
                                style: TextStyle(
                                    color: SKColors.light_gray,
                                    fontSize: 14,
                                    fontWeight: FontWeight.normal),
                              )
                            ],
                          ),
                        ),
                      );
                    else
                      return GestureDetector(
                        onTapUp: tappedCreateProfessor,
                        child: Container(
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(5),
                              border: Border.all(color: SKColors.border_gray),
                              boxShadow: [UIAssets.boxShadow]),
                          margin: EdgeInsets.fromLTRB(12, 4, 12, 4),
                          padding:
                              EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                          child: Row(
                            children: [
                              Container(
                                width: 36,
                                padding: EdgeInsets.only(
                                    right: 8, top: 2, bottom: 2),
                                child:
                                    Image.asset(ImageNames.sammiImages.shocked),
                              ),
                              Expanded(
                                child: Text.rich(
                                  TextSpan(
                                    text: 'Can\'t find your professor?',
                                    children: [
                                      TextSpan(
                                          text: 'Tap here to add a professor to Skoller',
                                          style: TextStyle(
                                              color: SKColors.skoller_blue)),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                  },
                ),
              ),
            ],
          ),
        ),
      );
}
