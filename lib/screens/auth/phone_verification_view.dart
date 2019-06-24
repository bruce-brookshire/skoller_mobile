import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:skoller/constants/constants.dart';
import 'package:skoller/requests/requests_core.dart';

class PhoneVerificationView extends StatefulWidget {
  @override
  State createState() => _PhoneVerificationViewState();
}

class _PhoneVerificationViewState extends State<PhoneVerificationView> {
  final List<TextEditingController> pinControllers = [
    TextEditingController(),
    TextEditingController(),
    TextEditingController(),
    TextEditingController(),
    TextEditingController(),
  ];

  final List<FocusNode> pinFocusNodes = [
    FocusNode(),
    FocusNode(),
    FocusNode(),
    FocusNode(),
    FocusNode(),
  ];

  int currentIndex = 0;

  @override
  void dispose() {
    pinControllers.forEach((controller) => controller.dispose());
    pinFocusNodes.forEach((controller) => controller.dispose());

    super.dispose();
  }

  void pinFieldChanged(int index) {
    final text = pinControllers[index].text.trim();

    if (text.length == 1) {
      if (index == 4) {
        checkPinValidity();
      } else {
        pinFocusNodes[currentIndex + 1].requestFocus();
      }
    } else if (index > 0 && text.length == 0) {
      pinFocusNodes[currentIndex - 1].requestFocus();
    } else if (text.length == 2 && index < 4) {
      pinControllers[index].text = text[0];
      pinControllers[index + 1].text = text[1];
      if (index == 3) {
        checkPinValidity();
      } else {
        pinFocusNodes[currentIndex + 2].requestFocus();
      }
    } else if (text.length > 0) {
      pinControllers[index].text = text[0];
    }
  }

  void checkPinValidity() {
    String code = '';
    for (final controller in pinControllers) {
      String digit = controller.text.trim();
      if (digit.length != 1) {
        resetPinFields();
        return;
      } else {
        code += digit;
      }
    }
    Auth.logIn("9032452355", code).then((success) {
      if (!success) {
        throw 'Invalid code';
      }
      return StudentClass.getStudentClasses();
    }).then((response) {
      Navigator.pop(context, response.wasSuccessful());
    }).catchError((onError) => Navigator.pop(context, false));

    resetPinFields();
  }

  void resetPinFields() {
    pinControllers.forEach((controller) => controller.text = '');
    pinFocusNodes[0].requestFocus();
    currentIndex = 0;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(color: SKColors.border_gray),
      ),
      backgroundColor: Colors.white,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(top: 24),
            child: Text(
              'Sign in',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 4),
            child: Text(
              'Check your texts for a verification code',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.normal),
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(48, 8, 48, 8),
            child: Image.asset(ImageNames.signUpImages.text_verify),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 24),
            child: Row(children: List.generate(5, createPinField)),
          ),
          // Container(
          //   margin: EdgeInsets.all(16),
          //   alignment: Alignment.center,
          //   padding: EdgeInsets.symmetric(vertical: 8),
          //   decoration: BoxDecoration(
          //     color: Colors.white,
          //     border: Border.all(color: SKColors.border_gray),
          //     borderRadius: BorderRadius.circular(5),
          //     boxShadow: [UIAssets.boxShadow],
          //   ),
          //   child: Text('Submit'),
          // ),
        ],
      ),
    );
  }

  Widget createPinField(int index) {
    final focusNode = pinFocusNodes[index];
    focusNode.addListener(() {
      if (focusNode.hasFocus) {
        currentIndex = index;
      }
    });
    return Expanded(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 8),
        child: CupertinoTextField(
          autofocus: true,
          onChanged: (String newContent) => pinFieldChanged(index),
          controller: pinControllers[index],
          focusNode: pinFocusNodes[index],
          textAlign: TextAlign.center,
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(color: SKColors.skoller_blue),
            ),
          ),
        ),
      ),
    );
  }
}
