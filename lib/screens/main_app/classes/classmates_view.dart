import 'package:flutter/material.dart';
import './modals/student_profile_modal.dart';
import 'package:skoller/tools.dart';
import 'package:share/share.dart';

class ClassmatesView extends StatefulWidget {
  final int class_id;

  ClassmatesView(this.class_id) : super();

  @override
  State createState() => _ClassmatesState();
}

class _ClassmatesState extends State<ClassmatesView> {
  StudentClass studentClass;

  @override
  void initState() {
    super.initState();

    studentClass = StudentClass.currentClasses[widget.class_id];
  }

  void tappedStudent(PublicStudent student) {
    showDialog(
      context: context,
      builder: (context) => StudentProfileModal(student),
    );
  }

  @override
  Widget build(BuildContext context) {
    List<PublicStudent> students = studentClass.students ?? [];
    final classmates = students.length;

    return SKNavView(
      title: studentClass.name,
      titleColor: studentClass.getColor(),
      backgroundColor: Colors.white,
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(12, 16, 32, 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(
                'Classmates',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.normal,
                ),
              ),
              Text(
                'Points',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: classmates < 4 ? classmates + 1 : classmates,
            itemBuilder: (context, index) {
              if (index < classmates) {
                final student = students[index];
                final bool isOwnStudent =
                    student.id == SKUser.current.student.id;

                return GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTapUp: (details) {
                    tappedStudent(student);
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            '${student.name_first} ${student.name_last}${isOwnStudent ? ' (You)' : ''}',
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(right: 12),
                          child: Text(
                            '${student.points ?? 0}',
                            style: TextStyle(
                                fontWeight: FontWeight.normal, fontSize: 16),
                          ),
                        ),
                        Image.asset(ImageNames.navArrowImages.right),
                      ],
                    ),
                  ),
                );
              } else {
                return SammiSpeechBubble(
                  sammiPersonality: SammiPersonality.cool,
                  speechBubbleContents: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.only(bottom: 8),
                        child: Text.rich(
                          TextSpan(
                            children: [
                              TextSpan(
                                text: 'Share Skoller and\n',
                                style: TextStyle(
                                    fontWeight: FontWeight.normal,
                                    fontSize: 17),
                              ),
                              TextSpan(
                                text: 'grow your community!',
                                style: TextStyle(
                                    color: studentClass.getColor(),
                                    fontSize: 17),
                              ),
                            ],
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      GestureDetector(
                        onTapUp: (details) {
                          Share.share(studentClass.shareMessage);
                        },
                        child: Container(
                          // alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: SKColors.skoller_blue,
                            borderRadius: BorderRadius.circular(5),
                          ),
                          padding: EdgeInsets.symmetric(vertical: 10),
                          margin: EdgeInsets.only(left: 12, right: 12, top: 4, bottom: 4),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Padding(
                                padding: EdgeInsets.only(right: 4),
                                child: Image.asset(
                                    ImageNames.peopleImages.people_white),
                              ),
                              Text(
                                'Share with classmates',
                                style: TextStyle(color: Colors.white),
                              )
                            ],
                          ),
                        ),
                      )
                    ],
                  ),
                );
              }
            },
          ),
        )
      ],
    );
  }
}
