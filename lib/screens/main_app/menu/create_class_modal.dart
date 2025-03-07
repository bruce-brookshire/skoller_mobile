import 'dart:collection';

import 'package:dart_notification_center/dart_notification_center.dart';
import 'package:dropdown_banner/dropdown_banner.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:skoller/screens/main_app/menu/class_status_modal.dart';
import 'package:skoller/screens/main_app/menu/professor_search_view.dart';
import 'package:skoller/tools.dart';

class CreateClassModal extends StatefulWidget {
  final Period period;
  final String initName;

  CreateClassModal(this.period, this.initName);

  @override
  State createState() => _CreateClassModalState();
}

class _CreateClassModalState extends State<CreateClassModal> {
  late TextEditingController classNameController;
  final subjectController = TextEditingController();
  final codeController = TextEditingController();
  final sectionController = TextEditingController();

  Map<String, bool> selectedDays = LinkedHashMap.fromIterables(
    ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'],
    List.generate(7, (index) => false),
  );

  bool isOnline = false;

  Professor? professor;

  DateTime? time;

  @override
  void initState() {
    classNameController = TextEditingController(text: widget.initName);

    super.initState();
  }

  @override
  void dispose() {
    super.dispose();

    subjectController.dispose();
    codeController.dispose();
    sectionController.dispose();
    classNameController.dispose();
  }

  void manageClassCreation() async {
    final interpreter = (String day) {
      if (day == 'Sun')
        return 'U';
      else if (day == 'Thu')
        return 'R';
      else
        return day[0];
    };

    final days = selectedDays.keys.fold(
        '', (r, k) => selectedDays[k]! ? r.toString() + interpreter(k) : r);

    final loadingScreen = SKLoadingScreen.fadeIn(context);

    widget.period
        .createClass(
      className: classNameController.text.trim(),
      subject: subjectController.text.trim(),
      code: codeController.text.trim(),
      section: sectionController.text.trim(),
      professorId: professor?.id,
      isOnline: isOnline,
      meetDays: days as String,
      meetTime: time == null ? null : TimeOfDay.fromDateTime(time!),
    )
        .then((response) {
      if (response.wasSuccessful() && response.obj is SchoolClass) {
        return (response.obj as SchoolClass).enrollInClass();
      } else {
        throw 'Failed to create this class. Try again';
      }
    }).then((response) async {
      if (response.wasSuccessful()) {
        loadingScreen.fadeOut();

        StudentClass.getStudentClasses().then(
          (response) => DartNotificationCenter.post(
              channel: NotificationChannels.classChanged),
        );

        Navigator.pushReplacement(
          context,
          SKNavOverlayRoute(
            builder: (context) => ClassStatusModal(response.obj.id),
          ),
        );

        DropdownBanner.showBanner(
          text: 'Successfully created and enrolled this class!',
          color: SKColors.success,
          textStyle: TextStyle(color: Colors.white),
        );
      } else {
        Navigator.pop(context);
        throw 'Failed automatically enrolling in the class. Try adding it from the search.';
      }
    }).catchError((onError) {
      loadingScreen.fadeOut();

      if (onError is String) {
        DropdownBanner.showBanner(
          text: onError,
          color: SKColors.warning_red,
          textStyle: TextStyle(color: Colors.white),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white.withOpacity(0),
      body: GestureDetector(
        onTapUp: (details) => Navigator.pop(context),
        behavior: HitTestBehavior.opaque,
        child: Center(
          child: Padding(
            padding: EdgeInsets.fromLTRB(24, 0, 24, 0),
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTapUp: (_) {},
              child: _CreateClassScreenOne(this),
            ),
          ),
        ),
      ),
    );
  }
}

class _CreateClassScreenOne extends StatefulWidget {
  final _CreateClassModalState subviewParent;

  _CreateClassScreenOne(this.subviewParent);

  @override
  State<StatefulWidget> createState() => _CreateClassScreenOneState();
}

class _CreateClassScreenOneState extends State<_CreateClassScreenOne> {
  bool isValid = false;

  final nodes = [FocusNode(), FocusNode(), FocusNode(), FocusNode()];

  @override
  void initState() {
    checkValid();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();

    nodes.forEach((node) => node.dispose());
  }

  void checkValid([String? _str]) {
    final parent = widget.subviewParent;

    final className = parent.classNameController.text.trim();

    final newIsValid = className != '';
    if (newIsValid != isValid) {
      setState(() {
        isValid = newIsValid;
      });
    }
  }

  void tappedStartTime(TapUpDetails details) {
    final parent = widget.subviewParent;

    if (parent.isOnline) return;

    final now = DateTime.now();

    /// Minutes should be divisible [minuteInterval] which is 5.
    DateTime tempTime = parent.time ??
        DateTime(
          now.year,
          now.month,
          now.day,
          now.hour,
          (now.minute % 5 * 5).toInt(),
        );

    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(top: 12),
              child: Text(
                'Start time',
                textAlign: TextAlign.center,
              ),
            ),
            Padding(
              padding: EdgeInsets.only(bottom: 8),
              child: Text(
                'What time does your class start?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.normal,
                ),
              ),
            ),
            Container(
              height: 160,
              child: CupertinoDatePicker(
                mode: CupertinoDatePickerMode.time,
                initialDateTime: tempTime,
                minuteInterval: 5,
                onDateTimeChanged: (dateTime) => tempTime = dateTime,
              ),
            ),
            Row(
              children: <Widget>[
                Expanded(
                  child: GestureDetector(
                    onTapUp: (details) => Navigator.pop(context),
                    behavior: HitTestBehavior.opaque,
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      alignment: Alignment.center,
                      child: Text(
                        'Cancel',
                        style: TextStyle(
                            color: SKColors.skoller_blue1,
                            fontWeight: FontWeight.normal),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTapUp: (details) {
                      setState(() {
                        parent.time = tempTime;
                      });
                      Navigator.pop(context);
                    },
                    behavior: HitTestBehavior.opaque,
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      alignment: Alignment.center,
                      child: Text(
                        'Select',
                        style: TextStyle(color: SKColors.skoller_blue1),
                      ),
                    ),
                  ),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final parent = widget.subviewParent;

    return SingleChildScrollView(
      child: Column(
        children: [
          Material(
            color: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
              side: BorderSide(color: SKColors.border_gray),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: EdgeInsets.only(bottom: 16, top: 12),
                  child: SammiSpeechBubble(
                    sammiPersonality: SammiPersonality.cool,
                    speechBubbleContents: Text.rich(
                      TextSpan(text: 'Create your class ', children: [
                        TextSpan(
                            text: 'in seconds!',
                            style: TextStyle(fontWeight: FontWeight.normal)),
                      ]),
                    ),
                  ),
                ),
                GestureDetector(
                  onTapUp: (details) => nodes[0].requestFocus(),
                  child: Container(
                    margin: EdgeInsets.symmetric(vertical: 6, horizontal: 12),
                    padding: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(5),
                      border: Border.all(color: SKColors.border_gray),
                      boxShadow: UIAssets.boxShadow,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Text(
                          'Class name',
                          style: TextStyle(
                              color: SKColors.skoller_blue,
                              fontSize: 14,
                              fontWeight: FontWeight.normal),
                        ),
                        CupertinoTextField(
                          cursorColor: SKColors.skoller_blue,
                          padding: EdgeInsets.only(top: 1),
                          placeholder: 'Intro to Calculus',
                          style: TextStyle(
                              fontSize: 15, color: SKColors.dark_gray),
                          placeholderStyle: TextStyle(
                              color: SKColors.light_gray,
                              fontSize: 15,
                              fontWeight: FontWeight.normal),
                          decoration: BoxDecoration(border: null),
                          controller: parent.classNameController,
                          textCapitalization: TextCapitalization.words,
                          focusNode: nodes[0],
                          onChanged: checkValid,
                          onEditingComplete: () => nodes[0].nextFocus(),
                          textInputAction: TextInputAction.next,
                        ),
                      ],
                    ),
                  ),
                ),
                _AnimatedExpansionTile(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(5),
                        border: Border.all(color: SKColors.border_gray),
                        boxShadow: UIAssets.boxShadow,
                      ),
                      margin: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                      padding: EdgeInsets.all(8),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Text(
                                'This is an online class',
                                style: TextStyle(fontWeight: FontWeight.normal),
                              ),
                              Switch(
                                activeColor: SKColors.skoller_blue,
                                value: parent.isOnline,
                                onChanged: (newVal) {
                                  setState(() => parent.isOnline = newVal);
                                  checkValid();
                                },
                              )
                            ],
                          ),
                          Padding(
                            padding: EdgeInsets.only(top: 8, bottom: 2),
                            child: Text('Meet days'),
                          ),
                          Container(
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(5),
                                border: Border.all(
                                  color: parent.isOnline
                                      ? SKColors.light_gray
                                      : SKColors.skoller_blue,
                                )),
                            child: Row(
                              children: <Widget>[
                                createDay('Sun'),
                                createDay('Mon'),
                                createDay('Tue'),
                                createDay('Wed'),
                                createDay('Thu'),
                                createDay('Fri'),
                                createDay('Sat'),
                              ],
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(top: 12, bottom: 2),
                            child: Text('Meet Time'),
                          ),
                          GestureDetector(
                            onTapUp: tappedStartTime,
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(5),
                                border: Border.all(
                                    color: parent.isOnline
                                        ? SKColors.light_gray
                                        : SKColors.skoller_blue),
                              ),
                              child: Text(
                                '${parent.time == null ? '                ' : TimeOfDay.fromDateTime(parent.time!).format(context)}',
                                style: TextStyle(
                                    color: parent.isOnline
                                        ? SKColors.light_gray
                                        : SKColors.skoller_blue,
                                    fontWeight: FontWeight.normal),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTapUp: (details) => Navigator.push(
                        context,
                        SKNavFadeUpRoute(
                          builder: (context) =>
                              ProfessorSearchView((professor) {
                            setState(() {
                              parent.professor = professor;
                            });
                            checkValid();
                          }),
                        ),
                      ),
                      child: Container(
                        margin: EdgeInsets.fromLTRB(8, 0, 8, 4),
                        padding:
                            EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(5),
                          border: Border.all(color: SKColors.border_gray),
                          boxShadow: UIAssets.boxShadow,
                        ),
                        child: Row(
                          children: <Widget>[
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
                                  Text(
                                    'Professor',
                                    style: TextStyle(
                                        color: SKColors.skoller_blue,
                                        fontSize: 12,
                                        fontWeight: FontWeight.normal),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.only(top: 1),
                                    child: Text(
                                      parent.professor?.fullName ??
                                          'Search your professor...',
                                      style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.normal,
                                          color: parent.professor == null
                                              ? SKColors.light_gray
                                              : SKColors.dark_gray),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 4),
                              child: Image.asset(
                                  ImageNames.rightNavImages.magnifying_glass),
                            )
                          ],
                        ),
                      ),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Expanded(
                          child: GestureDetector(
                            onTapUp: (details) => nodes[1].requestFocus(),
                            child: Container(
                              margin: EdgeInsets.fromLTRB(12, 4, 4, 4),
                              padding: EdgeInsets.symmetric(
                                  vertical: 4, horizontal: 4),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(5),
                                border: Border.all(color: SKColors.border_gray),
                                boxShadow: UIAssets.boxShadow,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
                                  Text(
                                    'Subject',
                                    style: TextStyle(
                                        color: SKColors.skoller_blue,
                                        fontSize: 13,
                                        fontWeight: FontWeight.normal),
                                  ),
                                  CupertinoTextField(
                                    cursorColor: SKColors.skoller_blue,
                                    padding: EdgeInsets.only(top: 1),
                                    placeholder: 'MATH',
                                    style: TextStyle(
                                        fontSize: 15,
                                        color: SKColors.dark_gray),
                                    placeholderStyle: TextStyle(
                                        color: SKColors.light_gray,
                                        fontSize: 15,
                                        fontWeight: FontWeight.normal),
                                    decoration: BoxDecoration(border: null),
                                    textCapitalization:
                                        TextCapitalization.characters,
                                    controller: parent.subjectController,
                                    focusNode: nodes[1],
                                    onEditingComplete: () =>
                                        nodes[1].nextFocus(),
                                    textInputAction: TextInputAction.next,
                                    onChanged: checkValid,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: GestureDetector(
                            onTapUp: (details) => nodes[2].requestFocus(),
                            child: Container(
                              margin: EdgeInsets.fromLTRB(4, 4, 4, 4),
                              padding: EdgeInsets.symmetric(
                                  vertical: 4, horizontal: 4),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(5),
                                border: Border.all(color: SKColors.border_gray),
                                boxShadow: UIAssets.boxShadow,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
                                  Text(
                                    'Code',
                                    style: TextStyle(
                                        color: SKColors.skoller_blue,
                                        fontSize: 13,
                                        fontWeight: FontWeight.normal),
                                  ),
                                  CupertinoTextField(
                                    cursorColor: SKColors.skoller_blue,
                                    padding: EdgeInsets.only(top: 1),
                                    placeholder: '1300',
                                    style: TextStyle(
                                        fontSize: 15,
                                        color: SKColors.dark_gray),
                                    placeholderStyle: TextStyle(
                                        color: SKColors.light_gray,
                                        fontSize: 15,
                                        fontWeight: FontWeight.normal),
                                    decoration: BoxDecoration(border: null),
                                    controller: parent.codeController,
                                    onChanged: checkValid,
                                    focusNode: nodes[2],
                                    keyboardType: TextInputType.number,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: GestureDetector(
                            onTapUp: (details) => nodes[3].requestFocus(),
                            child: Container(
                              margin: EdgeInsets.fromLTRB(4, 4, 12, 4),
                              padding: EdgeInsets.symmetric(
                                  vertical: 4, horizontal: 4),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(5),
                                border: Border.all(color: SKColors.border_gray),
                                boxShadow: UIAssets.boxShadow,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
                                  Text(
                                    'Section',
                                    style: TextStyle(
                                        color: SKColors.skoller_blue,
                                        fontSize: 13,
                                        fontWeight: FontWeight.normal),
                                  ),
                                  CupertinoTextField(
                                    cursorColor: SKColors.skoller_blue,
                                    padding: EdgeInsets.only(top: 1),
                                    placeholder: '2',
                                    style: TextStyle(
                                        fontSize: 15,
                                        color: SKColors.dark_gray),
                                    placeholderStyle: TextStyle(
                                        color: SKColors.light_gray,
                                        fontSize: 15,
                                        fontWeight: FontWeight.normal),
                                    decoration: BoxDecoration(border: null),
                                    controller: parent.sectionController,
                                    keyboardType: TextInputType.text,
                                    focusNode: nodes[3],
                                    onChanged: checkValid,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                  child: GestureDetector(
                    onTapUp: (details) {
                      if (isValid) {
                        widget.subviewParent.manageClassCreation();
                        nodes.forEach((n) {
                          if (n.hasPrimaryFocus) n.unfocus();
                        });
                      }
                    },
                    behavior: HitTestBehavior.opaque,
                    child: Container(
                      decoration: BoxDecoration(
                        color:
                            isValid ? SKColors.success : SKColors.inactive_gray,
                        borderRadius: BorderRadius.circular(5),
                        border: Border.all(color: SKColors.border_gray),
                        boxShadow: UIAssets.boxShadow,
                      ),
                      padding: EdgeInsets.symmetric(vertical: 6),
                      alignment: Alignment.center,
                      child: Text(
                        'Create Class! 🎉',
                        style: TextStyle(
                            color: isValid ? Colors.white : SKColors.dark_gray),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget createDay(String day) {
    final parent = widget.subviewParent;

    return Expanded(
      child: GestureDetector(
        onTapUp: (details) {
          if (parent.isOnline) return;
          setState(() => parent.selectedDays[day] = !parent.selectedDays[day]!);
          checkValid();
        },
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 7),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: parent.selectedDays[day]!
                ? (parent.isOnline
                    ? SKColors.light_gray
                    : SKColors.skoller_blue1)
                : null,
            border: day == 'Sat'
                ? null
                : Border(
                    right: BorderSide(
                        color: parent.isOnline
                            ? SKColors.light_gray
                            : SKColors.skoller_blue)),
          ),
          child: Text(
            day,
            style: TextStyle(
                fontWeight: FontWeight.normal,
                fontSize: 14,
                color: parent.selectedDays[day]!
                    ? Colors.white
                    : (parent.isOnline
                        ? SKColors.light_gray
                        : SKColors.skoller_blue)),
          ),
        ),
      ),
    );
  }
}

class _AnimatedExpansionTile extends StatefulWidget {
  const _AnimatedExpansionTile({
    Key? key,
    required this.children,
  }) : super(key: key);

  final List<Widget> children;

  @override
  State<_AnimatedExpansionTile> createState() => _AnimatedExpansionTileState();
}

class _AnimatedExpansionTileState extends State<_AnimatedExpansionTile> {
  bool showChildren = false;

  void _toggleChildren() {
    setState(() {
      showChildren = !showChildren;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTap: _toggleChildren,
          child: Container(
            padding: const EdgeInsets.all(8),
            margin: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5),
              border: Border.all(color: SKColors.skoller_blue1, width: 1),
            ),
            child: Row(
              children: [
                Text(
                  showChildren
                      ? 'Hide class details'
                      : 'Add class details (optional)',
                  style: Theme.of(context)
                      .textTheme
                      .bodyText1
                      ?.copyWith(color: SKColors.skoller_blue1),
                ),
                const Spacer(),
                Icon(
                  showChildren
                      ? Icons.keyboard_arrow_up_outlined
                      : Icons.keyboard_arrow_down_outlined,
                  color: SKColors.skoller_blue1,
                ),
              ],
            ),
          ),
        ),
        AnimatedCrossFade(
          duration: const Duration(milliseconds: 200),
          firstChild: Column(children: widget.children),
          secondChild: Container(),
          crossFadeState: showChildren
              ? CrossFadeState.showFirst
              : CrossFadeState.showSecond,
        ),
      ],
    );
  }
}
