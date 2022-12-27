import 'package:flutter/material.dart';
import 'package:skoller/tools.dart';

enum SammiExplanationType { needsSetup, diy, inReview, syllabusOverload }

class SyllabusInstructionsModal extends StatelessWidget {
  final SammiExplanationType type;
  final VoidCallback startExtractionCallback;

  SyllabusInstructionsModal(this.type, this.startExtractionCallback);

  @override
  Widget build(BuildContext context) {
    Widget body;

    switch (type) {
      case SammiExplanationType.diy:
        body = Padding(
          padding: EdgeInsets.symmetric(vertical: 16, horizontal: 4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              SammiSpeechBubble(
                sammiPersonality: SammiPersonality.wow,
                speechBubbleContents: Text(
                  'Oops... we have a problem!',
                  textAlign: TextAlign.left,
                  style: TextStyle(fontSize: 17),
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Image.asset(ImageNames.classesImages.syllabus_diy),
              ),
              Padding(
                padding: EdgeInsets.only(bottom: 12),
                child: Text(
                  'The document(s) you submitted do not\nhave the info we need for setup!',
                  style: TextStyle(fontWeight: FontWeight.w300, fontSize: 16),
                  textAlign: TextAlign.center,
                ),
              ),
              Text('Try this 👇'),
              GestureDetector(
                onTapUp: (details) => startExtractionCallback(),
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 6, horizontal: 36),
                  margin: EdgeInsets.only(top: 4, bottom: 8),
                  decoration: BoxDecoration(
                    color: SKColors.skoller_blue,
                    borderRadius: BorderRadius.circular(5),
                    boxShadow: UIAssets.boxShadow,
                  ),
                  child: Text(
                    'Instant Setup',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Text.rich(
                  TextSpan(
                    text: 'Or go to ',
                    children: [
                      TextSpan(
                          text: 'skoller.co on your computer\n',
                          style: TextStyle(
                              color: SKColors.alert_orange,
                              fontWeight: FontWeight.w700)),
                      TextSpan(text: 'to submit the correct documents'),
                    ],
                    style: TextStyle(fontSize: 16),
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        );
        break;
      case SammiExplanationType.inReview:
        body = Padding(
          padding: EdgeInsets.symmetric(vertical: 16, horizontal: 4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              SammiSpeechBubble(
                sammiPersonality: SammiPersonality.cool,
                speechBubbleContents: Text(
                  'Your syllabus is IN REVIEW',
                  textAlign: TextAlign.left,
                  style: TextStyle(fontSize: 17),
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Image.asset(ImageNames.classesImages.syllabus_in_review),
              ),
              Padding(
                padding: EdgeInsets.only(bottom: 12),
                child: Text(
                  'You will get a notification when\nthis class is ready-to-go!',
                  style: TextStyle(fontWeight: FontWeight.w300, fontSize: 16),
                  textAlign: TextAlign.center,
                ),
              ),
              Text(
                'Don\'t want to wait?',
                style: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: SKColors.text_light_gray),
              ),
              GestureDetector(
                onTapUp: (details) => startExtractionCallback(),
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 6, horizontal: 36),
                  margin: EdgeInsets.only(top: 4),
                  decoration: BoxDecoration(
                    color: SKColors.skoller_blue,
                    borderRadius: BorderRadius.circular(5),
                    boxShadow: UIAssets.boxShadow,
                  ),
                  child: Text(
                    'Instant Setup',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              )
            ],
          ),
        );
        break;
      case SammiExplanationType.needsSetup:
        body = Padding(
          padding: EdgeInsets.symmetric(vertical: 16, horizontal: 4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              SammiSpeechBubble(
                sammiPersonality: SammiPersonality.ooo,
                speechBubbleContents: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(bottom: 2),
                      child: Text(
                        'Send us your syllabus',
                        textAlign: TextAlign.left,
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
                    Text(
                      'And WE will set up the class!',
                      style: TextStyle(
                        fontWeight: FontWeight.w400,
                        fontSize: 16,
                      ),
                      textAlign: TextAlign.left,
                    )
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Image.asset(ImageNames.classesImages.syllabus_upload),
              ),
              Padding(
                padding: EdgeInsets.only(bottom: 12),
                child: Text.rich(
                  TextSpan(
                    text: 'Hop on your computer and log in at\nskoller.co to',
                    children: [
                      TextSpan(
                          text: ' drag-n-drop ',
                          style: TextStyle(
                              color: SKColors.warning_red,
                              fontWeight: FontWeight.w600)),
                      TextSpan(text: 'the syllabus'),
                    ],
                    style: TextStyle(fontWeight: FontWeight.w300, fontSize: 16),
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              Text(
                'Set it up yourself?',
                style: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: SKColors.text_light_gray),
              ),
              GestureDetector(
                onTapUp: (details) => startExtractionCallback(),
                behavior: HitTestBehavior.opaque,
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 6, horizontal: 36),
                  margin: EdgeInsets.only(top: 4),
                  decoration: BoxDecoration(
                    border: Border.all(color: SKColors.skoller_blue1),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Text(
                    'Instant Setup',
                    style: TextStyle(color: SKColors.skoller_blue1),
                  ),
                ),
              )
            ],
          ),
        );
        break;
      case SammiExplanationType.syllabusOverload:
        body = Padding(
          padding: EdgeInsets.symmetric(vertical: 16, horizontal: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              SammiSpeechBubble(
                sammiPersonality: SammiPersonality.wow,
                speechBubbleContents: Text(
                  'SYLLABUS OVERLOAD...',
                  textAlign: TextAlign.left,
                  style: TextStyle(fontSize: 17),
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Image.asset(ImageNames.classesImages.syllabus_overload),
              ),
              Text.rich(
                TextSpan(
                  text: 'Due to high volumes, it could take\nour team ',
                  children: [
                    TextSpan(
                      text: 'a few days',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    TextSpan(text: ' to set up this class'),
                  ],
                ),
                style: TextStyle(fontWeight: FontWeight.normal, fontSize: 16),
                textAlign: TextAlign.center,
              ),
              Text('Try this 👇'),
              GestureDetector(
                onTapUp: (details) => startExtractionCallback(),
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 6, horizontal: 36),
                  margin: EdgeInsets.only(top: 4, bottom: 8),
                  decoration: BoxDecoration(
                    color: SKColors.skoller_blue,
                    borderRadius: BorderRadius.circular(5),
                    boxShadow: UIAssets.boxShadow,
                  ),
                  child: Text(
                    'Instant Setup',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Text.rich(
                  TextSpan(
                    text:
                        'You can also go to skoller.co on your computer\n and ',
                    children: [
                      TextSpan(
                        text: 'use the diy tool',
                        style: TextStyle(color: SKColors.alert_orange),
                      ),
                      TextSpan(text: '(10 min or less)'),
                    ],
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w300),
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              Padding(
                padding: EdgeInsets.only(bottom: 12),
                child: Text(
                  'Thanks for bearing with us! ❤️',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        );
        break;
    }
    return Padding(
      padding: EdgeInsets.all(24),
      child: Column(
        children: [
          Material(
            color: Colors.transparent,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: SKColors.border_gray),
                color: Colors.white,
                boxShadow: UIAssets.boxShadow,
              ),
              child: body,
            ),
          ),
        ],
      ),
    );
  }
}
