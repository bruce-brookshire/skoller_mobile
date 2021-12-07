import 'package:dart_notification_center/dart_notification_center.dart';
import 'package:dropdown_banner/dropdown_banner.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:skoller/tools.dart';

class ProfessorChangeRequestView extends StatefulWidget {
  final int classId;

  ProfessorChangeRequestView(this.classId);

  @override
  State createState() => _ProfessorChangeRequestViewState();
}

class _ProfessorChangeRequestViewState
    extends State<ProfessorChangeRequestView> {
  bool isValidState = false;

  TextEditingController firstNameController;
  TextEditingController lastNameController;
  TextEditingController emailController;
  TextEditingController phoneNumberController;
  TextEditingController officeLocationController;
  TextEditingController availabilityController;
  @override
  void initState() {
    super.initState();

    final professor = StudentClass.currentClasses[widget.classId].professor;

    firstNameController = TextEditingController(text: professor.firstName);
    lastNameController = TextEditingController(text: professor.lastName);
    emailController = TextEditingController(text: professor.email);
    phoneNumberController = TextEditingController(text: professor.phoneNumber);
    officeLocationController =
        TextEditingController(text: professor.officeLocation);
    availabilityController =
        TextEditingController(text: professor.availability);
  }

  @override
  void dispose() {
    super.dispose();

    firstNameController.dispose();
    lastNameController.dispose();
    emailController.dispose();
    phoneNumberController.dispose();
    officeLocationController.dispose();
    availabilityController.dispose();
  }

  void tappedSave(_) async {
    if (isValidState) {
      final loader = SKLoadingScreen.fadeIn(context);

      // Form info
      final firstName = firstNameController.text.trim();
      final lastName = lastNameController.text.trim();
      final email = emailController.text.trim();
      final phoneNumber = phoneNumberController.text
          .trim()
          .replaceAll(RegExp(r'[\(\)]+'), '')
          .replaceAll(RegExp(r'[ ]'), '-');
      final officeLocation = officeLocationController.text.trim();
      final availability = availabilityController.text.trim();

      // Objects
      final studentClass = StudentClass.currentClasses[widget.classId];
      final professor = studentClass.professor;

      final origEmail = (professor.email ?? '') == '';
      final origPhone = (professor.phoneNumber ?? '') == '';
      final origLocation = (professor.officeLocation ?? '') == '';
      final origAvailability = (professor.availability ?? '') == '';

      // Save directly or submit change request
      final emailDirect = email != '' && origEmail;
      final phoneDirect = phoneNumber != '' && origPhone;
      final officeDirect = officeLocation != '' && origLocation;
      final availabilityDirect = availability != '' && origAvailability;

      // Update direct
      final direct_response = await professor.updateInfo(
        emailDirect ? email : null,
        phoneDirect ? phoneNumber : null,
        availabilityDirect ? availability : null,
        officeDirect ? officeLocation : null,
      );

      // Submit change request
      final change_response = await studentClass.submitProfessorChangeRequest(
        firstName: firstName == professor.firstName ? null : firstName,
        lastName: lastName == professor.lastName ? null : lastName,
        email: !origEmail && email != '' ? email : null,
        phoneNumber: !origPhone && phoneNumber != '' ? phoneNumber : null,
        officeLocation:
            !origLocation && officeLocation != '' ? officeLocation : null,
        availability:
            !origAvailability && availability != '' ? availability : null,
      );

      if (direct_response && change_response) {
        await studentClass.refetchSelf();

        DartNotificationCenter.post(channel: NotificationChannels.classChanged);

        loader.fadeOut();

        DropdownBanner.showBanner(
          text: 'Successfully submitted professor information for review!',
          color: SKColors.success,
          textStyle: TextStyle(color: Colors.white),
        );

        Navigator.pop(context);
      } else {
        loader.fadeOut();
        DropdownBanner.showBanner(
          text: 'Failed to save updated professor information.',
          color: SKColors.warning_red,
          textStyle: TextStyle(color: Colors.white),
        );
      }
    } else {
      final firstName = firstNameController.text.trim();
      final lastName = lastNameController.text.trim();

      if (firstName == '' || lastName == '') {
        DropdownBanner.showBanner(
          text: 'Professor first and last name cannot be blank',
          color: SKColors.warning_red,
          textStyle: TextStyle(color: Colors.white),
        );
      } else {
        DropdownBanner.showBanner(
          text: 'You must change a field to request a change',
          color: SKColors.warning_red,
          textStyle: TextStyle(color: Colors.white),
        );
      }
    }
  }

  void didEdit(_) {
    final professor = StudentClass.currentClasses[widget.classId].professor;

    final firstName = firstNameController.text.trim();
    final lastName = lastNameController.text.trim();
    final email = emailController.text.trim();
    final phoneNumber = phoneNumberController.text.trim();
    final officeLocation = officeLocationController.text.trim();
    final availability = availabilityController.text.trim();

    isValidState = (firstName != (professor.firstName ?? '') ||
            lastName != (professor.lastName ?? '') ||
            email != (professor.email ?? '') ||
            phoneNumber != (professor.phoneNumber ?? '') ||
            officeLocation != (professor.officeLocation ?? '') ||
            availability != (professor.availability ?? '')) &&
        firstName != '' &&
        lastName != '';

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final studentClass = StudentClass.currentClasses[widget.classId];

    return SKNavView(
      leftBtn: Image.asset(ImageNames.navArrowImages.down),
      title: studentClass.name,
      titleColor: studentClass.getColor(),
      children: <Widget>[
        Expanded(
          child: ListView(
            children: [
              SKHeaderCard(
                leftHeaderItem: Text(
                  'Edit professor info',
                  style: TextStyle(fontSize: 17),
                ),
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: Container(
                          margin: EdgeInsets.fromLTRB(0, 4, 4, 4),
                          padding:
                              EdgeInsets.symmetric(vertical: 4, horizontal: 4),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(5),
                            border: Border.all(color: SKColors.border_gray),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              Text(
                                'First name',
                                style: TextStyle(
                                    color: firstNameController.text.trim() == ''
                                        ? SKColors.warning_red
                                        : SKColors.skoller_blue,
                                    fontSize: 13,
                                    fontWeight: FontWeight.normal),
                              ),
                              CupertinoTextField(
                                cursorColor: SKColors.skoller_blue,
                                padding: EdgeInsets.only(top: 1),
                                placeholder: 'Joe',
                                style: TextStyle(
                                    fontSize: 15, color: SKColors.dark_gray),
                                placeholderStyle: TextStyle(
                                    color: SKColors.light_gray,
                                    fontSize: 15,
                                    fontWeight: FontWeight.normal),
                                decoration: BoxDecoration(border: null),
                                textCapitalization:
                                    TextCapitalization.characters,
                                controller: firstNameController,
                                onChanged: didEdit,
                              ),
                            ],
                          ),
                        ),
                      ),
                      Expanded(
                        child: Container(
                          margin: EdgeInsets.fromLTRB(4, 4, 0, 4),
                          padding:
                              EdgeInsets.symmetric(vertical: 4, horizontal: 4),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(5),
                            border: Border.all(color: SKColors.border_gray),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              Text(
                                'Last name',
                                style: TextStyle(
                                    color: lastNameController.text.trim() == ''
                                        ? SKColors.warning_red
                                        : SKColors.skoller_blue,
                                    fontSize: 13,
                                    fontWeight: FontWeight.normal),
                              ),
                              CupertinoTextField(
                                cursorColor: SKColors.skoller_blue,
                                padding: EdgeInsets.only(top: 1),
                                placeholder: 'Schmo',
                                style: TextStyle(
                                    fontSize: 15, color: SKColors.dark_gray),
                                decoration: BoxDecoration(border: null),
                                placeholderStyle: TextStyle(
                                    color: SKColors.light_gray,
                                    fontSize: 15,
                                    fontWeight: FontWeight.normal),
                                controller: lastNameController,
                                onChanged: didEdit,
                                keyboardType: TextInputType.text,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  Container(
                    margin: EdgeInsets.symmetric(vertical: 4),
                    padding: EdgeInsets.symmetric(vertical: 4, horizontal: 4),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(5),
                      border: Border.all(color: SKColors.border_gray),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Text(
                          'Email address',
                          style: TextStyle(
                              color: emailController.text.trim() == ''
                                  ? SKColors.alert_orange
                                  : SKColors.skoller_blue,
                              fontSize: 13,
                              fontWeight: FontWeight.normal),
                        ),
                        CupertinoTextField(
                          cursorColor: SKColors.skoller_blue,
                          padding: EdgeInsets.only(top: 1),
                          placeholder: 'joe-schmo@example.com',
                          style: TextStyle(
                              fontSize: 15, color: SKColors.dark_gray),
                          placeholderStyle: TextStyle(
                              color: SKColors.light_gray,
                              fontSize: 15,
                              fontWeight: FontWeight.normal),
                          decoration: BoxDecoration(border: null),
                          controller: emailController,
                          onChanged: didEdit,
                          keyboardType: TextInputType.emailAddress,
                        ),
                      ],
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.symmetric(vertical: 4),
                    padding: EdgeInsets.symmetric(vertical: 4, horizontal: 4),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(5),
                      border: Border.all(color: SKColors.border_gray),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Text(
                          'Phone number',
                          style: TextStyle(
                              color: phoneNumberController.text.trim() == ''
                                  ? SKColors.alert_orange
                                  : SKColors.skoller_blue,
                              fontSize: 13,
                              fontWeight: FontWeight.normal),
                        ),
                        CupertinoTextField(
                          cursorColor: SKColors.skoller_blue,
                          padding: EdgeInsets.only(top: 1),
                          placeholder: '(555) 555-5555',
                          style: TextStyle(
                              fontSize: 15, color: SKColors.dark_gray),
                          placeholderStyle: TextStyle(
                              color: SKColors.light_gray,
                              fontSize: 15,
                              fontWeight: FontWeight.normal),
                          decoration: BoxDecoration(border: null),
                          controller: phoneNumberController,
                          inputFormatters: [USNumberTextInputFormatter()],
                          onChanged: didEdit,
                          keyboardType: TextInputType.phone,
                        ),
                      ],
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.symmetric(vertical: 4),
                    padding: EdgeInsets.symmetric(vertical: 4, horizontal: 4),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(5),
                      border: Border.all(color: SKColors.border_gray),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Text(
                          'Office location',
                          style: TextStyle(
                              color: officeLocationController.text.trim() == ''
                                  ? SKColors.alert_orange
                                  : SKColors.skoller_blue,
                              fontSize: 13,
                              fontWeight: FontWeight.normal),
                        ),
                        CupertinoTextField(
                          cursorColor: SKColors.skoller_blue,
                          padding: EdgeInsets.only(top: 1),
                          placeholder: 'SCIE 305',
                          style: TextStyle(
                              fontSize: 15, color: SKColors.dark_gray),
                          placeholderStyle: TextStyle(
                              color: SKColors.light_gray,
                              fontSize: 15,
                              fontWeight: FontWeight.normal),
                          decoration: BoxDecoration(border: null),
                          controller: officeLocationController,
                          onChanged: didEdit,
                          keyboardType: TextInputType.text,
                        ),
                      ],
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.symmetric(vertical: 4),
                    padding: EdgeInsets.symmetric(vertical: 4, horizontal: 4),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(5),
                      border: Border.all(color: SKColors.border_gray),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Text(
                          'Availability',
                          style: TextStyle(
                              color: availabilityController.text.trim() == ''
                                  ? SKColors.alert_orange
                                  : SKColors.skoller_blue,
                              fontSize: 13,
                              fontWeight: FontWeight.normal),
                        ),
                        CupertinoTextField(
                          cursorColor: SKColors.skoller_blue,
                          padding: EdgeInsets.only(top: 1),
                          placeholder: 'MTW from 3-5pm...',
                          style: TextStyle(
                              fontSize: 15, color: SKColors.dark_gray),
                          placeholderStyle: TextStyle(
                              color: SKColors.light_gray,
                              fontSize: 15,
                              fontWeight: FontWeight.normal),
                          decoration: BoxDecoration(border: null),
                          controller: availabilityController,
                          onChanged: didEdit,
                          keyboardType: TextInputType.text,
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTapUp: tappedSave,
                    child: Container(
                      alignment: Alignment.center,
                      padding: EdgeInsets.symmetric(vertical: 8),
                      margin: EdgeInsets.only(top: 12),
                      decoration: BoxDecoration(
                        color: isValidState
                            ? SKColors.success
                            : SKColors.inactive_gray,
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Text(
                        'Submit',
                        style: TextStyle(
                            color: isValidState
                                ? Colors.white
                                : SKColors.dark_gray),
                      ),
                    ),
                  )
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
