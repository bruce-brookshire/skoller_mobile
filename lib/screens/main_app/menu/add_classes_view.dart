import 'dart:async';

import 'package:dart_notification_center/dart_notification_center.dart';
import 'package:dropdown_banner/dropdown_banner.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:skoller/screens/main_app/menu/class_search_settings_modal.dart';
import 'package:skoller/screens/main_app/menu/class_status_modal.dart';
import 'package:skoller/screens/main_app/menu/create_class_modal.dart';
import 'package:skoller/tools.dart';

class AddClassesView extends StatefulWidget {
  @override
  State createState() => _AddClassesState();
}

class _AddClassesState extends State<AddClassesView> {
  List<SchoolClass> searchedClasses = [];

  Timer? _currentTimer;

  Period? activePeriod;

  final searchController = TextEditingController();
  final searchFocusNode = FocusNode();

  bool isSearching = false;

  @override
  void initState() {
    super.initState();

    activePeriod = SKUser.current?.student.primaryPeriod ??
        SKUser.current?.student.primarySchool?.getBestCurrentPeriod();

    DartNotificationCenter.subscribe(
      observer: this,
      channel: NotificationChannels.classChanged,
      onNotification: (options) => SchoolClass.searchSchoolClasses(
        searchController.text.trim(),
        activePeriod!,
      ).then(
        (response) {
          _currentTimer = null;

          if (response.wasSuccessful() && mounted) {
            setState(() {
              searchedClasses = (response.obj as List<SchoolClass>)
                ..sort((s1, s2) =>
                    (s2.enrollment ?? 0).compareTo(s1.enrollment ?? 0));
            });
          }
        },
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    DartNotificationCenter.unsubscribe(observer: this);
    searchController.dispose();
    searchFocusNode.dispose();
  }

  void didTypeInSearch(String searchText) {
    if (_currentTimer != null) {
      _currentTimer!.cancel();
      _currentTimer = null;
    }

    searchText = searchText.trim();

    if (searchText == '') {
      if (isSearching) {
        setState(() {
          isSearching = false;
        });
      }

      SchoolClass.invalidateCurrentClassSearch();

      setState(() {
        searchedClasses = [];
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
        SchoolClass.searchSchoolClasses(
          searchText,
          activePeriod!,
        ).then((response) {
          _currentTimer = null;

          if (response.wasSuccessful() && mounted) {
            setState(() {
              searchedClasses = (response.obj as List<SchoolClass>)
                ..sort((s1, s2) =>
                    (s2.enrollment ?? 0).compareTo(s1.enrollment ?? 0));
              isSearching = false;
            });
          }
        });
      },
    );
  }

  void didTapClassCard(int index) async {
    final SchoolClass schoolClass = searchedClasses[index];

    final bool isEnrolled =
        StudentClass.currentClasses.containsKey(schoolClass.id);

    await showDialog(
      context: context,
      builder: (newContext) => Dialog(
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
                      '${schoolClass.subject ?? '-'} ${schoolClass.code ?? '-'}.${schoolClass.section ?? '-'}',
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
                    '${schoolClass.professor?.firstName ?? '-'} ${schoolClass.professor?.lastName ?? '-'}',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                ],
              ),
              GestureDetector(
                onTapUp: (details) {
                  final requestFunc = isEnrolled
                      ? StudentClass.currentClasses[schoolClass.id]!.dropClass
                      : schoolClass.enrollInClass;

                  final loader = SKLoadingScreen.fadeIn(newContext);

                  requestFunc().then((response) {
                    if (response is bool) {
                      return response;
                    } else if (response is RequestResponse) {
                      return response.wasSuccessful();
                    } else {
                      return false;
                    }
                  }).then((success) async {
                    if (success) {
                      await StudentClass.getStudentClasses();

                      loader.fadeOut();

                      if (isEnrolled)
                        Navigator.pop(newContext);
                      else
                        Navigator.pushReplacement(
                          newContext,
                          SKNavOverlayRoute(
                            builder: (context) =>
                                ClassStatusModal(schoolClass.id),
                          ),
                        ).then((val) {
                          //Should we propogate pop?
                          if (val is bool && !val) {
                            Navigator.pop(context, val);
                          } else {
                            searchController.text = '';
                            if (val is bool && val)
                              searchFocusNode.requestFocus();
                          }
                        });
                      DartNotificationCenter.post(
                          channel: NotificationChannels.classChanged);
                    } else {
                      Navigator.pop(newContext);
                      DropdownBanner.showBanner(
                        text:
                            'Failed to ${isEnrolled ? 'enroll in' : 'drop'} class',
                        color: SKColors.warning_red,
                        textStyle: TextStyle(color: Colors.white),
                      );
                    }
                  });
                },
                child: Container(
                  margin: EdgeInsets.only(top: 16),
                  alignment: Alignment.center,
                  padding: EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: isEnrolled
                        ? SKColors.warning_red
                        : SKColors.skoller_blue1,
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Text(
                    isEnrolled ? 'Drop this class' : 'Join this class',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void tappedSettings([_]) async {
    final results = await showDialog(
      context: context,
      builder: (context) => ClassSearchSettingsModal(activePeriod!.id),
    );

    if (results is Map && results['period'] is Period) {
      activePeriod = results['period'];
      if (mounted) setState(() {});
    }
  }

  void tappedCreateClass() {
    Navigator.push(
      context,
      SKNavOverlayRoute(
        builder: (context) => CreateClassModal(
          activePeriod!,
          searchController.text.trim(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final showSammiInstructions =
        StudentClass.currentClasses.length == 0 && searchController.text == '';

    int listViewItemCount;

    if (showSammiInstructions)
      listViewItemCount = 1;
    else if (searchedClasses.isEmpty && searchController.text.trim() == '')
      listViewItemCount = 1;
    else
      listViewItemCount = searchedClasses.length + (isSearching ? 0 : 1);

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
                          itemCount: listViewItemCount,
                          itemBuilder: (context, index) {
                            // If there are no classes, we need to guide the user
                            if (showSammiInstructions)
                              return Padding(
                                padding: EdgeInsets.only(top: 8),
                                child: SammiSpeechBubble(
                                  sammiPersonality: SammiPersonality.smile,
                                  speechBubbleContents:
                                      Text('👆Now, add your first class!'),
                                ),
                              );

                            // Otherwise, show the user their classes
                            Widget contents;

                            if (index < searchedClasses.length) {
                              final schoolClass = searchedClasses[index];

                              contents = createClassCard(schoolClass);
                            } else {
                              contents = Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Padding(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 2),
                                    child: Image.asset(
                                        ImageNames.sammiImages.shocked),
                                  ),
                                  Expanded(
                                    child: Padding(
                                      padding:
                                          EdgeInsets.only(top: 4, right: 8),
                                      child: Text.rich(
                                        TextSpan(
                                          text: 'Can\'t find your class?',
                                          children: [
                                            TextSpan(
                                              text:
                                                  ' Tap here to add it to Skoller.',
                                              style: TextStyle(
                                                color: SKColors.skoller_blue1,
                                              ),
                                            )
                                          ],
                                        ),
                                        style: TextStyle(fontSize: 16),
                                        textAlign: TextAlign.left,
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            }

                            /// If search field is empty and there's no results to display ,
                            /// show background image and text
                            if (searchedClasses.isEmpty &&
                                searchController.text.trim() == '') {
                              return const _EmptySearchClassBackground();
                            }

                            return GestureDetector(
                                onTapUp: (details) {
                                  index == searchedClasses.length
                                      ? tappedCreateClass()
                                      : didTapClassCard(index);
                                },
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 4, vertical: 2),
                                  margin: EdgeInsets.symmetric(vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    border:
                                        Border.all(color: SKColors.border_gray),
                                    borderRadius: BorderRadius.circular(5),
                                    boxShadow: UIAssets.boxShadow,
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
    final classCount = StudentClass.currentClasses.values.fold(
        0,
        (a, s) =>
            int.parse(a.toString()) +
            (s.classPeriod == SKUser.current?.student.primaryPeriod ? 1 : 0));

    return Container(
      height: 136,
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
                      SKUser.current?.student.primarySchool?.name ?? '',
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          fontSize: 18,
                          color: SKUser.current?.student.primarySchool?.color ??
                              SKColors.dark_gray),
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: 1, bottom: 4),
                      child: Text(
                        activePeriod?.name ?? 'Something went wrong',
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
                onTapUp: tappedSettings,
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
                    controller: searchController,
                    focusNode: searchFocusNode,
                    clearButtonMode: OverlayVisibilityMode.editing,
                    cursorColor: SKColors.skoller_blue,
                    decoration: BoxDecoration(border: null),
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                    placeholder: 'Search a class name',
                    placeholderStyle:
                        TextStyle(color: SKColors.text_light_gray),
                    style: TextStyle(fontSize: 15, color: SKColors.dark_gray),
                    textCapitalization: TextCapitalization.words,
                    autofocus: true,
                    autocorrect: false,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(right: 8),
                  child: isSearching
                      ? Container(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Image.asset(ImageNames.rightNavImages.magnifying_glass),
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
                  '${schoolClass.professor?.firstName ?? '-'} ${schoolClass.professor?.lastName ?? '-'}',
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
                '${schoolClass.subject ?? '-'} ${schoolClass.code ?? '-'}.${schoolClass.section ?? '-'}',
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

class _EmptySearchClassBackground extends StatelessWidget {
  const _EmptySearchClassBackground({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: 0.5,
      child: Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.only(top: 50),
        child: Column(
          children: [
            Image.asset(
              ImageNames.sammiImages.smile,
              height: 100,
              fit: BoxFit.fill,
            ),
            const SizedBox(height: 10),
            Text(
              'Search your class',
              style: Theme.of(context)
                  .textTheme
                  .headline6
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 5),
            Text(
              "to see if it's already on Skoller!",
              style: Theme.of(context)
                  .textTheme
                  .bodyText2
                  ?.copyWith(fontWeight: FontWeight.normal),
            ),
          ],
        ),
      ),
    );
  }
}
