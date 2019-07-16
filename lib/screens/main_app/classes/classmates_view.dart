import 'package:flutter/material.dart';
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
      builder: (context) => Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: Container(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Row(
                children: <Widget>[
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTapUp: (details) {
                      Navigator.pop(context);
                    },
                    child: Container(
                      alignment: Alignment.centerLeft,
                      child: Container(
                        width: 44,
                        height: 40,
                        child: Image.asset(ImageNames.navArrowImages.down),
                      ),
                    ),
                  ),
                ],
              ),
              Container(
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: SKColors.light_gray,
                  shape: BoxShape.circle,
                  image: student.user.avatar == null
                      ? null
                      : DecorationImage(
                          fit: BoxFit.fill,
                          image: NetworkImage(student.user.avatar),
                        ),
                ),
                margin: EdgeInsets.only(bottom: 12),
                height: 44,
                width: 44,
                child: student.user.avatar == null
                    ? Text(
                        student.name_first[0] + student.name_last[0],
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          letterSpacing: 1,
                        ),
                      )
                    : null,
              ),
              Text(
                '${student.name_first} ${student.name_last}',
                style: TextStyle(fontSize: 17),
              ),
              Padding(
                padding: EdgeInsets.only(top: 16),
                child: Stack(
                  children: <Widget>[
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Row(
                        children: <Widget>[
                          Expanded(
                            child: Container(
                              margin:
                                  EdgeInsets.only(top: 9, left: 12, right: 12),
                              padding: EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                border: Border.all(color: SKColors.dark_gray),
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: Text(
                                student.bio ?? 'no bio here...',
                                style: TextStyle(
                                    fontWeight: FontWeight.normal,
                                    fontSize: 14),
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Container(
                        color: Colors.white,
                        margin: EdgeInsets.only(left: 20),
                        padding: EdgeInsets.symmetric(horizontal: 6),
                        child: Text(
                          'Bio',
                          style: TextStyle(fontSize: 14),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.only(top: 16),
                child: Stack(
                  children: <Widget>[
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Row(
                        children: <Widget>[
                          Expanded(
                            child: Container(
                              margin: EdgeInsets.only(
                                  top: 9, left: 12, right: 12, bottom: 16),
                              padding: EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                border: Border.all(color: SKColors.dark_gray),
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: Text(
                                student.org ?? 'no orgs here...',
                                style: TextStyle(
                                    fontWeight: FontWeight.normal,
                                    fontSize: 14),
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Container(
                        color: Colors.white,
                        margin: EdgeInsets.only(left: 20),
                        padding: EdgeInsets.symmetric(horizontal: 6),
                        child: Text(
                          'Organizations',
                          style: TextStyle(fontSize: 14),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
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
            itemCount: classmates < 5 ? classmates + 1 : classmates,
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
                      Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(
                                text: 'You\'re ',
                                style: TextStyle(
                                    fontWeight: FontWeight.normal,
                                    fontSize: 17)),
                            TextSpan(
                                text:
                                    '${5 - studentClass.enrollment} classmate${(5 - studentClass.enrollment) == 1 ? '' : 's'}',
                                style: TextStyle(
                                    color: studentClass.getColor(),
                                    fontSize: 17)),
                            TextSpan(
                                text: ' away from ',
                                style: TextStyle(
                                    fontWeight: FontWeight.normal,
                                    fontSize: 17)),
                            TextSpan(
                              text: 'a PARTY 🎉',
                              style: TextStyle(fontSize: 17),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(vertical: 8),
                        child: Text.rich(
                          TextSpan(
                            children: [
                              TextSpan(
                                  text: 'It\'s a party when ',
                                  style:
                                      TextStyle(fontWeight: FontWeight.normal)),
                              TextSpan(
                                text: '5 or more classmates',
                              ),
                              TextSpan(
                                  text: ' are conquering school... ',
                                  style:
                                      TextStyle(fontWeight: FontWeight.normal)),
                              TextSpan(text: 'TOGETHER!'),
                            ],
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTapUp: (details) {
                          Share.share(
                              'School is hard. But this new app called Skoller makes it easy! Our class \(studentClass.name ?? "") is already in the app. Download so we can keep up together!\n\n${studentClass.enrollmentLink}');
                        },
                        child: Container(
                          // alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: SKColors.skoller_blue,
                            borderRadius: BorderRadius.circular(5),
                          ),
                          padding: EdgeInsets.symmetric(vertical: 10),
                          margin: EdgeInsets.only(left: 16, right: 16, top: 4),
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
