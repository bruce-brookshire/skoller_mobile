import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:skoller/constants/constants.dart';
import 'package:skoller/requests/requests_core.dart';

class PhoneVerificationView extends StatefulWidget {
  final String phoneNumber;

  PhoneVerificationView(this.phoneNumber);
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
  String errorMsg;
  bool loading = false;

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

    setState(() {
      loading = true;
    });

    final trimStr = widget.phoneNumber.replaceAll(RegExp(r'[\(\) \-]+'), '');

    Auth.logIn(trimStr, code).then((success) {
      return StudentClass.getStudentClasses();
    }).then((response) {
      setState(() => loading = false);
      Navigator.pop(context, response.wasSuccessful());
    }).catchError(
      (onError) => setState(() {
        if (errorMsg != null && errorMsg is String) errorMsg = onError;
        loading = false;
      }),
    );

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
            padding: EdgeInsets.symmetric(vertical: 4, horizontal: 16),
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
          loading
              ? Container(
                  padding: EdgeInsets.symmetric(vertical: 28),
                  alignment: Alignment.center,
                  child: SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator()))
              : Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                  child: Row(children: List.generate(5, createPinField)),
                ),
          ...errorMsg != null
              ? [
                  Padding(
                    padding: EdgeInsets.only(bottom: 8),
                    child: Text(
                      errorMsg,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: SKColors.warning_red,
                        fontSize: 13,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                  ),
                ]
              : []
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
