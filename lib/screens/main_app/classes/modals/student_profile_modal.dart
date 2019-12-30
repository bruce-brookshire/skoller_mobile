import 'package:flutter/material.dart';
import 'package:skoller/tools.dart';

class StudentProfileModal extends StatelessWidget {
  final PublicStudent student;

  StudentProfileModal(this.student);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Container(
        padding: EdgeInsets.only(top: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTapUp: (details) {
                    Navigator.pop(context);
                  },
                  child: Container(
                    alignment: Alignment.centerLeft,
                    padding: EdgeInsets.only(left: 8),
                    child: Container(
                      width: 44,
                      height: 40,
                      child: Image.asset(ImageNames.navArrowImages.down),
                    ),
                  ),
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
                  height: 60,
                  width: 60,
                  child: student.user.avatar == null
                      ? Text(
                          student.name_first[0] + student.name_last[0],
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                          ),
                        )
                      : null,
                ),
                Padding(
                  padding: EdgeInsets.only(right: 8),
                  child: SizedBox(width: 44),
                )
              ],
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
                                  fontWeight: FontWeight.normal, fontSize: 14),
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
                                  fontWeight: FontWeight.normal, fontSize: 14),
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
    );
  }
}
