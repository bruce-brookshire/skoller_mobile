import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:skoller/screens/main_app/classes/assignment_weight_view.dart';
import 'package:skoller/screens/main_app/classes/modals/syllabus_instructions_modal.dart';
import 'package:skoller/screens/main_app/classes/weight_extraction_view.dart';
import 'package:skoller/tools.dart';

class ClassStatusModal extends StatelessWidget {
  final int classId;

  ClassStatusModal(this.classId);

  @override
  Widget build(BuildContext context) {
    final studentClass = StudentClass.currentClasses[classId];
    final statusId = studentClass.status.id;

    List<Widget> Function(BuildContext context) bodyFactory;

    if ([ClassStatuses.class_setup, ClassStatuses.class_issue]
        .contains(statusId))
      bodyFactory = createClassSetup;
    else if (statusId == ClassStatuses.syllabus_submitted)
      bodyFactory = createSyllabusSubmittedCard;
    else if ((studentClass.weights ?? []).length > 0)
      bodyFactory = createAddAssignmentCard;
    else
      bodyFactory = createSetUpClassCard;

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(color: SKColors.border_gray),
      ),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: bodyFactory(context),
        ),
      ),
    );
  }

  List<Widget> createClassSetup(BuildContext context) => [
        Text.rich(
          TextSpan(
            text: 'Welcome to:\n',
            style: TextStyle(fontWeight: FontWeight.normal, fontSize: 18),
            children: [
              TextSpan(
                  text: StudentClass.currentClasses[classId].name + '!',
                  style: TextStyle(fontWeight: FontWeight.bold))
            ],
          ),
          textAlign: TextAlign.center,
        ),
        Flexible(
          child: GifWrapper('todolist_gif_assets', 188),
        ),
        Text.rich(
          TextSpan(
            text: 'The syllabus for this class is\n',
            children: [
              TextSpan(
                text: 'ALREADY ORGANIZED',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              TextSpan(text: ' on Skoller 🙌')
            ],
            style: TextStyle(fontWeight: FontWeight.normal),
          ),
          textAlign: TextAlign.center,
        ),
        GestureDetector(
          onTapUp: (details) => Navigator.pop(context, true),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            margin: EdgeInsets.only(top: 20, bottom: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5),
              color: SKColors.skoller_blue,
              boxShadow: UIAssets.boxShadow,
            ),
            child: Text(
              'Add another class',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white),
            ),
          ),
        ),
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapUp: (details) => Navigator.pop(context, false),
          child: Container(
            alignment: Alignment.center,
            padding: EdgeInsets.symmetric(vertical: 4),
            child: Text(
              'Enter Skoller',
              style: TextStyle(fontSize: 14, color: SKColors.skoller_blue),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ];

  List<Widget> createSyllabusSubmittedCard(BuildContext context) => [
        Text(
          'You\'re in!',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 18),
        ),
        Text(
          'The syllabus is currently in review 🕙',
          textAlign: TextAlign.center,
          style: TextStyle(fontWeight: FontWeight.normal),
        ),
        SizedBox(
          height: 180,
          child: Image.asset(ImageNames.statusImages.in_review),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            'Check back in a few hours to find the class setup',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 15),
          ),
        ),
        GestureDetector(
          onTapUp: (details) => Navigator.pop(context, true),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            margin: EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5),
              color: SKColors.skoller_blue,
              boxShadow: UIAssets.boxShadow,
            ),
            child: Text(
              'Enter Skoller',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white),
            ),
          ),
        ),
        GestureDetector(
          onTapUp: (details) => Navigator.pop(context, false),
          child: Container(
            alignment: Alignment.center,
            padding: EdgeInsets.symmetric(vertical: 4),
            child: Text(
              'Join another class',
              style: TextStyle(fontSize: 14, color: SKColors.skoller_blue),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ];

  List<Widget> createAddAssignmentCard(BuildContext context) => [
        Padding(
          padding: EdgeInsets.only(bottom: 8),
          child: Text(
            'You\'ve joined the class! 👌',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 18),
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 12),
          child: Image.asset(ImageNames.classesImages.syllabus_in_review),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            'Now lets finish getting it set up...',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 15),
          ),
        ),
        GestureDetector(
          onTapUp: (details) => Navigator.pushReplacement(
            context,
            CupertinoPageRoute(
              builder: (context) => AssignmentWeightView(classId),
              settings: RouteSettings(name: 'AssignmentWeightView'),
            ),
          ),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            margin: EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5),
              color: SKColors.skoller_blue,
              boxShadow: UIAssets.boxShadow,
            ),
            child: Text(
              'Create assignments',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white),
            ),
          ),
        ),
        GestureDetector(
          onTapUp: (details) => Navigator.pop(context, false),
          child: Container(
            alignment: Alignment.center,
            padding: EdgeInsets.symmetric(vertical: 4),
            child: Text(
              'Do this later',
              style: TextStyle(fontSize: 14, color: SKColors.skoller_blue),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ];

  List<Widget> createSetUpClassCard(BuildContext context) => [
        Padding(
          padding: EdgeInsets.only(bottom: 8),
          child: Text(
            'You\'ve joined the class! 👌',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 18),
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 12),
          child: Image.asset(ImageNames.classesImages.syllabus_upload),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            'Now lets get it set up...',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 15),
          ),
        ),
        GestureDetector(
          onTapUp: (details) => Navigator.pushReplacement(
            context,
            SKNavOverlayRoute(
              builder: (context) => SyllabusInstructionsModal(
                SammiExplanationType.needsSetup,
                () => Navigator.pushReplacement(
                  context,
                  CupertinoPageRoute(
                    builder: (context) => WeightExtractionView(classId),
                    settings: RouteSettings(name: 'WeightExtractionView'),
                  ),
                ),
              ),
            ),
          ),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            margin: EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5),
              color: SKColors.skoller_blue,
              boxShadow: UIAssets.boxShadow,
            ),
            child: Text(
              'Send us your Syllabus!',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white),
            ),
          ),
        ),
        GestureDetector(
          onTapUp: (details) => Navigator.pop(context, true),
          child: Container(
            alignment: Alignment.center,
            padding: EdgeInsets.symmetric(vertical: 4),
            child: Text(
              'Do this later',
              style: TextStyle(fontSize: 14, color: SKColors.skoller_blue),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ];
}
