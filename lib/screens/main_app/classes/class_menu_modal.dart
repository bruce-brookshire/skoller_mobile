import 'package:auto_size_text/auto_size_text.dart';
import 'package:dart_notification_center/dart_notification_center.dart';
import 'package:dropdown_banner/dropdown_banner.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:skoller/screens/main_app/classes/class_document_view.dart';
import 'package:skoller/screens/main_app/classes/class_info_view.dart';
import 'package:skoller/screens/main_app/classes/classmates_view.dart';
import 'package:skoller/screens/main_app/classes/grade_scale_view.dart';
import 'package:skoller/screens/main_app/classes/modals/add_grade_scale_modal.dart';
import 'package:skoller/screens/main_app/classes/weights_info_view.dart';
import 'package:skoller/screens/main_app/menu/profile_link_sharing_view.dart';
import 'package:skoller/tools.dart';
import 'package:url_launcher/url_launcher.dart';

class ClassMenuModal extends StatefulWidget {
  final int classId;

  ClassMenuModal(this.classId);

  @override
  State createState() => _ClassMenuState();
}

class _ClassMenuState extends State<ClassMenuModal> {
  StudentClass studentClass;

  @override
  void initState() {
    super.initState();

    studentClass = StudentClass.currentClasses[widget.classId];
  }

  void tappedLink(BuildContext context) {
    Navigator.push(
      context,
      SKNavOverlayRoute(
        builder: (_) => ProfileLinkSharingView(studentClass.id),
      ),
    );
  }

  void tappedSpeculate(BuildContext context) async {
    bool shouldProceed = true;

    if (studentClass.gradeScale == null) {
      final result = await showGradeScalePicker(context);
      if (result == null || !result) {
        shouldProceed = false;
      }
    }

    if (shouldProceed) {
      showSpeculate(context);
    }
  }

  Future showGradeScalePicker(BuildContext context) {
    return Navigator.push(
      context,
      SKNavOverlayRoute(
        isBarrierDismissible: false,
        builder: (context) => AddGradeScaleModal(
          classId: studentClass.id,
          onCompletionShowGradeScale: false,
        ),
      ),
    );
  }

  void showSpeculate(BuildContext context) async {
    final speculate = await studentClass.speculateClass().then(
      (response) {
        if (response.wasSuccessful())
          return response.obj;
        else
          throw 'Unable to get speculation';
      },
    ).catchError((onError) {
      DropdownBanner.showBanner(
        text: onError is String ? onError : 'Failed to get speculation',
        color: SKColors.warning_red,
        textStyle: TextStyle(color: Colors.white),
      );
    });

    if (!(speculate is List)) {
      return;
    }

    (speculate as List).sort(
      (elem1, elem2) =>
          (elem2['speculation'] as num).compareTo(elem1['speculation'] as num),
    );

    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(10)),
        ),
        child: _SpeculateModalView(
          speculate,
        ),
      ),
    );
  }

  void tappedClassmates(BuildContext context) {
    Navigator.push(
      context,
      CupertinoPageRoute(
        builder: (context) => ClassmatesView(widget.classId),
        settings: RouteSettings(name: 'ClassmatesView'),
      ),
    );
  }

  void tappedClassInfo(BuildContext context) async {
    final shouldPop = await Navigator.push(
      context,
      CupertinoPageRoute(
        builder: (_) => ClassInfoView(widget.classId),
      ),
    );

    if (shouldPop is bool && shouldPop) Navigator.pop(context, true);
  }

  void tappedGradeScale(BuildContext context) async {
    StudentClass studentClass = StudentClass.currentClasses[widget.classId];

    if (studentClass.gradeScale == null) {
      await Navigator.push(
        context,
        SKNavOverlayRoute(
          builder: (context) => AddGradeScaleModal(
            classId: widget.classId,
            onCompletionShowGradeScale: true,
          ),
        ),
      );
    } else {
      Navigator.push(
        context,
        CupertinoPageRoute(
          builder: (context) => GradeScaleView(widget.classId),
        ),
      );
    }
  }

  void tappedWeights(BuildContext context) {
    Navigator.push(
      context,
      CupertinoPageRoute(
        builder: (_) => WeightsInfoView(widget.classId),
      ),
    );
  }

  void tappedClassDocuments(BuildContext context) {
    final docs = StudentClass.currentClasses[widget.classId].documents;

    showDialog(
      context: context,
      builder: (context) => SKPickerModal(
        title: 'Class documents',
        subtitle: 'Which would you like to view?',
        onSelect: (index) => Navigator.push(
          context,
          CupertinoPageRoute(
            builder: (context) => ClassDocumentView(docs[index]),
          ),
        ),
        items: docs.map((d) => d.name).toList(),
      ),
    );
  }

  void tappedContactUs(_) async {
    final url = 'mailto:support@skoller.co';

    if (await canLaunch(url))
      launch(url);
    else
      Navigator.push(
        context,
        SKNavOverlayRoute(
          builder: (context) => SKAlertDialog(
            title: 'Contact us',
            subTitle:
                'Email support@skoller.co with your question and we will get back to you asap!',
            confirmText: 'Copy email',
            cancelText: 'Dismiss',
            getResults: () => Clipboard.setData(
              ClipboardData(text: 'support@skoller.co'),
            ),
          ),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    if (StudentClass.currentClasses[widget.classId] == null)
      return Container(
        color: Colors.white,
      );
    return Padding(
      padding: EdgeInsets.only(bottom: 32),
      child: Material(
        color: Colors.transparent,
        child: Container(
          padding: EdgeInsets.only(top: 24),
          decoration: BoxDecoration(
            color: SKColors.background_gray,
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(15),
              bottomRight: Radius.circular(15),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Padding(
                padding: EdgeInsets.only(top: 4, bottom: 8),
                child: AutoSizeText(
                  studentClass.name,
                  textAlign: TextAlign.left,
                  maxLines: 1,
                  minFontSize: 10,
                  style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: studentClass.getColor()),
                ),
              ),
              Expanded(
                child: GridView.count(
                  padding: EdgeInsets.fromLTRB(24, 4, 24, 0),
                  childAspectRatio: 1.4,
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  children: <Widget Function(BuildContext)>[
                    buildLink,
                    buildSpeculate,
                    buildClassmates,
                    buildInfo,
                    buildGradeScale,
                    buildWeights,
                    if ((StudentClass
                                    .currentClasses[widget.classId].documents ??
                                [])
                            .length >
                        0)
                      buildClassDocuments,
                    buildClassColor,
                  ].map((f) => f(context)).map(containerCard).toList(),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Need help?',
                    style: TextStyle(fontWeight: FontWeight.w300, fontSize: 13),
                  ),
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTapUp: tappedContactUs,
                    child: Text(
                      ' Let us know',
                      style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                          color: SKColors.skoller_blue),
                    ),
                  ),
                ],
              ),
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTapUp: (_) => Navigator.pop(context),
                onVerticalDragEnd: (details) {
                  if (details.primaryVelocity < 0) Navigator.pop(context);
                },
                child: Container(
                  alignment: Alignment.center,
                  padding: EdgeInsets.only(top: 8, bottom: 8),
                  child: RotatedBox(
                    quarterTurns: 2,
                    child: Image.asset(
                      ImageNames.navArrowImages.pulldown_gray,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildLink(BuildContext context) => GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapUp: (_) => tappedLink(context),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            Text('Share YOUR Link'),
            Icon(
              Icons.insert_link,
              size: 32,
              color: studentClass.getColor(),
            ),
            Text.rich(
              TextSpan(
                text: 'It\'s a ',
                children: [
                  TextSpan(
                    text: 'fast pass',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextSpan(
                    text: ' for your classmates to join Skoller!',
                  )
                ],
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.normal,
                ),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );

  Widget buildSpeculate(BuildContext context) => GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapUp: (_) => tappedSpeculate(context),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            Text('Speculate Grade'),
            Icon(
              Icons.assistant_photo,
              size: 32,
              color: studentClass.getColor(),
            ),
            Text.rich(
              TextSpan(
                text: 'Always ',
                children: [
                  TextSpan(
                    text: 'know where you stand',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextSpan(text: ' during the semester.')
                ],
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.normal,
                ),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );

  Widget buildClassmates(BuildContext context) => GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapUp: (_) => tappedClassmates(context),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            Text('Classmates'),
            Icon(
              Icons.people,
              size: 32,
              color: studentClass.getColor(),
            ),
            Text.rich(
              TextSpan(
                text:
                    '${studentClass.enrollment - 1} classmate${studentClass.enrollment == 2 ? '' : 's'}',
                children: [
                  TextSpan(
                    text: ' are helping you manage schedule changes.',
                    style: TextStyle(fontWeight: FontWeight.normal),
                  ),
                ],
                style: TextStyle(
                  fontSize: 11,
                ),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );

  Widget buildInfo(BuildContext context) => GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapUp: (_) => tappedClassInfo(context),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            Text('Class info'),
            Icon(
              Icons.info,
              size: 32,
              color: studentClass.getColor(),
            ),
            Text.rich(
              TextSpan(
                text: 'See ',
                children: [
                  TextSpan(
                    text: 'class and professor',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextSpan(text: ' details here.')
                ],
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.normal,
                ),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );

  Widget buildGradeScale(BuildContext context) => GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapUp: (_) => tappedGradeScale(context),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            Text('Grade Scale'),
            Icon(
              Icons.assessment,
              size: 32,
              color: studentClass.getColor(),
            ),
            Text.rich(
              TextSpan(
                text: 'Speculate with the ',
                children: [
                  TextSpan(
                    text: 'correct calculations',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.normal,
                ),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );

  Widget buildWeights(BuildContext context) => GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapUp: (_) => tappedWeights(context),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            Text('Weights'),
            Icon(
              Icons.category,
              size: 32,
              color: studentClass.getColor(),
            ),
            Text.rich(
              TextSpan(
                text: 'It\'s ',
                children: [
                  TextSpan(
                    text: 'the foundation',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextSpan(text: ' for your grade calculator.'),
                ],
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.normal,
                ),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );

  Widget buildClassDocuments(BuildContext context) => GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapUp: (_) => tappedClassDocuments(context),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            Text('Class Documents'),
            Icon(
              Icons.find_in_page,
              size: 32,
              color: studentClass.getColor(),
            ),
            Text.rich(
              TextSpan(
                text:
                    '${studentClass.documents.length} document${studentClass.documents.length == 1 ? '' : 's'}',
                children: [
                  TextSpan(
                    text: ' were used to set up this class.',
                    style: TextStyle(fontWeight: FontWeight.normal),
                  )
                ],
                style: TextStyle(fontSize: 11),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );

  Widget buildClassColor(_) => SKColorPicker(
        callback: (newColor) {
          studentClass.setColor(newColor).then((response) =>
              DartNotificationCenter.post(
                  channel: NotificationChannels.classChanged));
          setState(() {});
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            Text('Class Color'),
            Icon(
              Icons.color_lens,
              size: 32,
              color: studentClass.getColor(),
            ),
            Text.rich(
              TextSpan(
                text: 'Select your',
                children: [
                  TextSpan(
                    text: ' class color.',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.normal,
                ),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );

  Widget containerCard(Widget child) {
    return Container(
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5),
        border: Border.all(color: SKColors.border_gray),
        boxShadow: UIAssets.boxShadow,
        color: Colors.white,
      ),
      child: child,
    );
  }
}

class _SpeculateModalView extends StatefulWidget {
  final List speculate;

  _SpeculateModalView(this.speculate);

  @override
  State createState() => _SpeculateModalState();
}

class _SpeculateModalState extends State<_SpeculateModalView> {
  int selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(top: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: SKColors.border_gray,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Speculate',
            style: TextStyle(fontSize: 17),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(24, 8, 24, 0),
            child: Text(
              'What grade do you want to make in this class?',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.normal,
              ),
            ),
          ),
          Container(
            height: 140,
            child: CupertinoPicker.builder(
              backgroundColor: Colors.white,
              childCount: widget.speculate.length,
              itemBuilder: (context, index) => Container(
                alignment: Alignment.center,
                child: Text(
                  '${widget.speculate[index]['grade']}',
                  style: TextStyle(
                    color: SKColors.dark_gray,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              itemExtent: 32,
              onSelectedItemChanged: (index) {
                setState(() {
                  selectedIndex = index;
                });
              },
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: 'You need to average at least a ',
                    style: TextStyle(fontWeight: FontWeight.normal),
                  ),
                  TextSpan(
                      text:
                          '${widget.speculate[selectedIndex]['speculation']}%'),
                  TextSpan(
                    text:
                        ' on your remaining assignments to achieve the grade ',
                    style: TextStyle(fontWeight: FontWeight.normal),
                  ),
                  TextSpan(
                      text: '${widget.speculate[selectedIndex]['grade']}.'),
                ],
              ),
              textAlign: TextAlign.center,
            ),
          ),
          GestureDetector(
            onTapUp: (details) => Navigator.pop(context),
            child: Container(
              margin: EdgeInsets.only(top: 24, left: 16, right: 16),
              padding: EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                  border: Border(top: BorderSide(color: SKColors.border_gray))),
              alignment: Alignment.center,
              child: Text(
                'Dismiss',
                style: TextStyle(
                  color: SKColors.skoller_blue,
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
