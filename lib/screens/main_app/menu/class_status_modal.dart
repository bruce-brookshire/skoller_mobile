import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:share/share.dart';
import 'package:skoller/screens/main_app/classes/assignment_weight_view.dart';
import 'package:skoller/screens/main_app/classes/weight_extraction_view.dart';
import 'package:skoller/tools.dart';

class _SyllabusAction {
  final String header;
  final String subHeader;
  final String prompt;
  final String imageName;
  final String primaryActionStr;
  final String secondaryActionStr;
  final VoidCallback primaryAction;
  final VoidCallback secondaryAction;

  _SyllabusAction({
    @required this.header,
    this.subHeader,
    this.prompt,
    @required this.imageName,
    @required this.primaryActionStr,
    this.secondaryActionStr,
    @required this.primaryAction,
    this.secondaryAction,
  });
}

class ClassStatusModal extends StatelessWidget {
  final int classId;

  ClassStatusModal(this.classId);

  @override
  Widget build(BuildContext context) {
    final studentClass = StudentClass.currentClasses[classId];
    final statusId = studentClass.status.id;

    _SyllabusAction status;

    if (statusId == ClassStatuses.syllabus_submitted) {
      status = _SyllabusAction(
        header: 'You\'re in!',
        subHeader: 'The syllabus is currently in review 🕙',
        prompt: 'Check back in a few hours to find the class setup',
        imageName: ImageNames.statusImages.in_review,
        primaryActionStr: 'Enter Skoller',
        primaryAction: () => Navigator.pop(context),
      );
    } else if ([ClassStatuses.class_setup, ClassStatuses.class_issue]
            .contains(statusId) &&
        studentClass.enrollment < 4) {
      status = _SyllabusAction(
        header: 'You\'re in!',
        subHeader: 'And this class is already set up 🙌',
        prompt: 'Invite classmates using your class link 👇',
        imageName: ImageNames.statusImages.setup_community,
        primaryActionStr: studentClass.enrollmentLink,
        secondaryActionStr: 'Enter Skoller',
        primaryAction: () {
          Share.share(
              'School is hard. But this new app called Skoller makes it easy! Our class ${studentClass.name ?? ''} is already in the app. Download so we can keep up together!\n\n${studentClass.enrollmentLink}');
        },
        secondaryAction: () => Navigator.pop(context),
      );
    } else if ([ClassStatuses.class_setup, ClassStatuses.class_issue]
            .contains(statusId) &&
        studentClass.enrollment >= 4) {
      status = _SyllabusAction(
        header: 'You\'re in!',
        subHeader: 'And this class is already LIVE 🎉',
        imageName: ImageNames.statusImages.setup_live,
        primaryActionStr: 'Enter Skoller',
        primaryAction: () => Navigator.pop(context, true),
      );
    } else if ((studentClass.weights ?? []).length > 0) {
      status = _SyllabusAction(
        header: 'You\'ve joined the class! 👌',
        prompt: 'Now lets finish getting it set up...',
        imageName: ImageNames.statusImages.needs_syllabus,
        primaryActionStr: 'Create assignments',
        secondaryActionStr: 'Do this later',
        primaryAction: () => Navigator.pushReplacement(
          context,
          CupertinoPageRoute(
            builder: (context) => AssignmentWeightView(classId),
            settings: RouteSettings(name: 'AssignmentWeightView'),
          ),
        ),
        secondaryAction: () => Navigator.pop(context),
      );
    } else {
      status = _SyllabusAction(
        header: 'You\'ve joined the class! 👌',
        prompt: 'Now lets get it set up...',
        imageName: ImageNames.statusImages.needs_syllabus,
        primaryActionStr: 'Send us your Syllabus!',
        secondaryActionStr: 'Do this later',
        primaryAction: () => Navigator.pushReplacement(
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
        secondaryAction: () => Navigator.pop(context),
      );
    }

    return Dialog(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: BorderSide(color: SKColors.border_gray)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text(
              status.header,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18),
            ),
            if (status.subHeader != null)
              Text(
                status.subHeader,
                textAlign: TextAlign.center,
                style: TextStyle(fontWeight: FontWeight.normal),
              ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 24),
              child: Image.asset(
                status.imageName,
                fit: BoxFit.fitHeight,
              ),
            ),
            if (status.prompt != null)
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 12),
                child: Text(
                  status.prompt,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 15),
                ),
              ),
            GestureDetector(
              onTapUp: (details) => status.primaryAction(),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                margin: EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5),
                  color: SKColors.skoller_blue,
                  boxShadow: [UIAssets.boxShadow],
                ),
                child: Text(
                  status.primaryActionStr,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
            if (status.secondaryActionStr != null)
              GestureDetector(
                onTapUp: (details) => status.secondaryAction(),
                child: Container(
                  alignment: Alignment.center,
                  padding: EdgeInsets.symmetric(vertical: 4),
                  child: Text(
                    status.secondaryActionStr,
                    style:
                        TextStyle(fontSize: 14, color: SKColors.skoller_blue),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
