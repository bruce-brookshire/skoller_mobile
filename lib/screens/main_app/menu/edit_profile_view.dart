import 'package:dart_notification_center/dart_notification_center.dart';
import 'package:dropdown_banner/dropdown_banner.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:skoller/tools.dart';

class EditProfileView extends StatefulWidget {
  @override
  State createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfileView> {
  final firstNameController =
      TextEditingController(text: SKUser.current.student.nameFirst);
  final lastNameController =
      TextEditingController(text: SKUser.current.student.nameLast);
  final bioController = TextEditingController(text: SKUser.current.student.bio);
  final organizationsController =
      TextEditingController(text: SKUser.current.student.organizations);

  @override
  void dispose() {
    super.dispose();
    firstNameController.dispose();
    lastNameController.dispose();
    bioController.dispose();
    organizationsController.dispose();
  }

  void tappedSave() async {
    final firstName = firstNameController.text.trim();
    final lastName = lastNameController.text.trim();
    final bio = bioController.text.trim();
    final organizations = organizationsController.text.trim();

    if (firstName.length > 0 && lastName.length > 0) {
      SKUser.current
          .update(
        firstName: firstName,
        lastName: lastName,
        bio: bio,
        organizations: organizations,
      )
          .then((success) {
        if (success) {
          Navigator.pop(context);
        }
      });
    } else {
      DropdownBanner.showBanner(
        text: 'You must have a first and last name',
        color: SKColors.warning_red,
        textStyle: TextStyle(color: Colors.white),
      );
    }
  }

  void tappedSelectMajors(TapUpDetails details) async {
    final loader = SKLoadingScreen.fadeIn(context);
    final result = await FieldsOfStudy.getFieldsOfStudy();
    loader.dismiss();

    if (result.wasSuccessful()) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => _MajorSelector(result.obj),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SKNavView(
      title: 'Edit Profile',
      rightBtn: Text(
        'Save',
        style: TextStyle(color: SKColors.skoller_blue),
      ),
      callbackRight: tappedSave,
      children: <Widget>[
        Padding(
          padding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
          child: Row(children: [
            Container(
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: SKColors.light_gray,
                shape: BoxShape.circle,
                image: SKUser.current?.avatarUrl == null
                    ? null
                    : DecorationImage(
                        fit: BoxFit.fill,
                        image: NetworkImage(SKUser.current.avatarUrl),
                      ),
              ),
              margin: EdgeInsets.only(bottom: 12),
              height: 64,
              width: 64,
              child: SKUser.current.avatarUrl == null
                  ? Text(
                      SKUser.current.student.nameFirst[0] +
                          SKUser.current.student.nameLast[0],
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        letterSpacing: 1,
                      ),
                    )
                  : null,
            ),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Container(
                    margin: EdgeInsets.fromLTRB(16, 4, 0, 8),
                    padding: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(5),
                      border: Border.all(color: SKColors.border_gray),
                      boxShadow: [UIAssets.boxShadow],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Text(
                          'First name',
                          style: TextStyle(
                              color: SKColors.skoller_blue,
                              fontSize: 14,
                              fontWeight: FontWeight.normal),
                        ),
                        CupertinoTextField(
                          padding: EdgeInsets.all(0),
                          placeholder: 'Alex',
                          style: TextStyle(fontSize: 15),
                          decoration: BoxDecoration(border: null),
                          controller: firstNameController,
                        ),
                      ],
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.fromLTRB(16, 4, 0, 4),
                    padding: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(5),
                      border: Border.all(color: SKColors.border_gray),
                      boxShadow: [UIAssets.boxShadow],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Text(
                          'Last name',
                          style: TextStyle(
                              color: SKColors.skoller_blue,
                              fontSize: 14,
                              fontWeight: FontWeight.normal),
                        ),
                        CupertinoTextField(
                          padding: EdgeInsets.all(0),
                          placeholder: 'Smith',
                          style: TextStyle(fontSize: 15),
                          decoration: BoxDecoration(border: null),
                          controller: lastNameController,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ]),
        ),
        Container(
          margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          padding: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(5),
            border: Border.all(color: SKColors.border_gray),
            boxShadow: [UIAssets.boxShadow],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                'Bio',
                style: TextStyle(
                    color: SKColors.skoller_blue,
                    fontSize: 14,
                    fontWeight: FontWeight.normal),
              ),
              CupertinoTextField(
                padding: EdgeInsets.all(0),
                minLines: 4,
                maxLines: 4,
                placeholder: 'Tell your classmates a bit about yourself!',
                style: TextStyle(fontSize: 15),
                decoration: BoxDecoration(border: null),
                controller: bioController,
              ),
            ],
          ),
        ),
        Container(
          margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          padding: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(5),
            border: Border.all(color: SKColors.border_gray),
            boxShadow: [UIAssets.boxShadow],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                'Organizations',
                style: TextStyle(
                    color: SKColors.skoller_blue,
                    fontSize: 14,
                    fontWeight: FontWeight.normal),
              ),
              CupertinoTextField(
                padding: EdgeInsets.all(0),
                minLines: 4,
                maxLines: 4,
                placeholder: 'What organizations are you involved with?',
                style: TextStyle(fontSize: 15),
                decoration: BoxDecoration(border: null),
                controller: organizationsController,
              ),
            ],
          ),
        ),
        GestureDetector(
          onTapUp: tappedSelectMajors,
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Text(
              'Select majors and minors',
              style: TextStyle(color: SKColors.skoller_blue),
            ),
          ),
        ),
        Spacer(),
        SafeArea(
          top: false,
          child: GestureDetector(
            onTapUp: (details) {
              showCupertinoDialog(
                context: context,
                builder: (context) => CupertinoActionSheet(
                  title: Text(
                    'Delete Account',
                    style: TextStyle(
                        color: SKColors.dark_gray,
                        fontSize: 15,
                        fontWeight: FontWeight.bold),
                  ),
                  message: Text(
                    'DANGER ZONE: This action is irreversible. IF YOU DELETE YOUR ACCOUNT, YOUR DATA IS GONE FOREVER. WE CAN\'T HELP. Are you sure you want to proceed?',
                    style: TextStyle(color: SKColors.dark_gray),
                  ),
                  actions: <Widget>[
                    CupertinoActionSheetAction(
                      isDestructiveAction: true,
                      child: Text(
                        'I\m sure. Delete me.',
                        style: TextStyle(fontSize: 16),
                      ),
                      onPressed: () async {
                        bool success = await SKUser.current.delete();
                        if (success) success = await Auth.logOut();

                        if (success)
                          DartNotificationCenter.post(
                              channel: NotificationChannels.appStateChanged,
                              options: AppState.auth);
                      },
                    ),
                    CupertinoActionSheetAction(
                      child: Text(
                        'Take me to safety!',
                        style: TextStyle(fontSize: 16, color: SKColors.success),
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    )
                  ],
                ),
              );
            },
            child: Text(
              'Delete account',
              style: TextStyle(
                color: SKColors.warning_red,
                fontSize: 12,
                fontWeight: FontWeight.normal,
              ),
            ),
          ),
        )
      ],
    );
  }
}

class _MajorSelector extends StatefulWidget {
  final List<FieldsOfStudy> availableFields;

  _MajorSelector(this.availableFields);

  @override
  State createState() => _MajorSelectorState();
}

class _MajorSelectorState extends State<_MajorSelector> {
  Map<int, FieldsOfStudy> selectedFields = {};

  List<FieldsOfStudy> searchedFields = [];

  @override
  void initState() {
    super.initState();
    (SKUser.current.student.fieldsOfStudy ?? [])
        .forEach((f) => selectedFields[f.id] = f);
  }

  void processSearch(String search) {
    final searchText = search.trim();
    if (searchText == '')
      searchedFields = [];
    else
      searchedFields = widget.availableFields.toList()
        ..removeWhere((field) =>
            !field.field.toLowerCase().contains(search.toLowerCase()));
    setState(() {});
  }

  void tappedSave(TapUpDetails details) async {
    final loader = SKLoadingScreen.fadeIn(context);

    final success = await SKUser.current.update(
      fieldsOfStudy: selectedFields.keys.toList(),
    );

    loader.dismiss();

    if (success) {
      DropdownBanner.showBanner(
          text: 'Saved your new fields of study!', color: SKColors.success);
      Navigator.pop(context);
    } else
      DropdownBanner.showBanner(
          text: 'Unable to save your updated information. Tap to try again.',
          color: SKColors.warning_red,
          tapCallback: () => tappedSave(null));
  }

  void tappedDismiss(TapUpDetails details) async {
    final shouldDismiss = await showDialog(
      context: context,
      builder: (newContext) => SKAlertDialog(
        title: 'Are your sure?',
        subTitle: 'Your changes have not been saved yet and will be lost.',
        confirmText: 'Dismiss',
      ),
    );

    if (shouldDismiss is bool && shouldDismiss) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24),
        child: Material(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
            side: BorderSide(color: SKColors.border_gray),
          ),
          child: Padding(
            padding: EdgeInsets.fromLTRB(12, 12, 12, 0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: <Widget>[
                    GestureDetector(
                      onTapUp: tappedDismiss,
                      child: Container(
                        alignment: Alignment.centerLeft,
                        padding: EdgeInsets.only(left: 4),
                        width: 44,
                        height: 28,
                        child: Image.asset(ImageNames.navArrowImages.down),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        'Search Majors and Minors',
                        textAlign: TextAlign.center,
                      ),
                    ),
                    GestureDetector(
                      onTapUp: tappedSave,
                      child: Container(
                        alignment: Alignment.centerRight,
                        width: 44,
                        height: 28,
                        child: Text(
                          'Save',
                          style: TextStyle(color: SKColors.skoller_blue),
                        ),
                      ),
                    ),
                  ],
                ),
                Text(
                  '${selectedFields.length} selected',
                  style: TextStyle(fontWeight: FontWeight.normal, fontSize: 13),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: CupertinoTextField(
                    autofocus: true,
                    onChanged: processSearch,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5),
                      border: Border.all(color: SKColors.border_gray),
                    ),
                    placeholder: 'Search...',
                    placeholderStyle: TextStyle(
                      color: SKColors.text_light_gray,
                      fontSize: 15,
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    style: TextStyle(
                      color: SKColors.dark_gray,
                      fontSize: 15,
                    ),
                    cursorColor: SKColors.skoller_blue,
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                      itemCount: searchedFields.length,
                      itemBuilder: (context, index) {
                        final field = searchedFields[index];
                        return GestureDetector(
                          onTapUp: (details) => setState(
                            () => selectedFields.containsKey(field.id)
                                ? selectedFields.remove(field.id)
                                : (selectedFields[field.id] = field),
                          ),
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 4),
                            child: Text(
                              field.field,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: selectedFields[field.id] == null
                                    ? SKColors.dark_gray
                                    : SKColors.skoller_blue,
                              ),
                            ),
                          ),
                        );
                      }),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
