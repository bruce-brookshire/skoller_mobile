import 'package:flutter/material.dart';
import 'package:skoller/tools.dart';

class ClassMenuModal extends StatelessWidget {
  final StudentClass studentClass;

  ClassMenuModal(this.studentClass);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 32),
      child: Material(
        color: Colors.transparent,
        child: Container(
          padding: EdgeInsets.only(top: 12),
          decoration: BoxDecoration(color: SKColors.background_gray),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Expanded(
                child: SafeArea(
                  child: GridView.count(
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 4),
                    childAspectRatio: 1.4,
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    children: <Widget>[
                      buildLink(),
                      buildSpeculate(),
                      buildClassmates(),
                      buildInfo(),
                      buildGradeScale(),
                      buildWeights(),
                      buildClassDocuments(),
                      buildClassColor(),
                    ].map(containerCard).toList(),
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Need help?',
                    style: TextStyle(fontWeight: FontWeight.w300, fontSize: 13),
                  ),
                  Text(
                    ' Let us know',
                    style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                        color: SKColors.skoller_blue),
                  )
                ],
              ),
              Container(
                alignment: Alignment.center,
                margin: EdgeInsets.only(top: 8),
                decoration: BoxDecoration(
                    gradient: LinearGradient(
                        colors: [
                          Colors.white,
                          SKColors.text_light_gray,
                          SKColors.light_gray
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        stops: [0.0, 0.35, 0.65]),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(10),
                      bottomRight: Radius.circular(10),
                    ),
                    color: SKColors.light_gray),
                child: Icon(
                  Icons.keyboard_arrow_up,
                  color: Colors.white,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget buildLink() => Column(
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
      );

  Widget buildSpeculate() => Column(
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
      );

  Widget buildClassmates() => Column(
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
      );

  Widget buildInfo() => Column(
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
      );

  Widget buildGradeScale() => Column(
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
      );

  Widget buildWeights() => Column(
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
      );
  Widget buildClassDocuments() => Column(
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
      );
  Widget buildClassColor() => SKColorPicker(
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
