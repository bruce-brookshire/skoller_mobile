import 'package:dropdown_banner/dropdown_banner.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:skoller/tools.dart';

class MajorSelector extends StatefulWidget {
  final List<FieldsOfStudy> availableFields;

  MajorSelector(this.availableFields);

  @override
  State createState() => MajorSelectorState();
}

class MajorSelectorState extends State<MajorSelector> {
  Map<int, FieldsOfStudy> selectedFields = {};

  List<FieldsOfStudy> searchedFields = [];

  @override
  void initState() {
    super.initState();
    (SKUser.current.student.fieldsOfStudy ?? [])
        .forEach((f) => selectedFields[f.id] = f);
  }

  void processSearch(String search) {
    final searchText = search.trim().toLowerCase();

    if (searchText == '')
      searchedFields = SKUser.current.student.fieldsOfStudy ?? [];
    else {
      final searcher = (String key) => widget.availableFields
          .toList()
          .where(
            (field) => field.field.toLowerCase().contains(key),
          )
          .toList();

      // Get the fields that match the phrase
      final searched = (searchText.split(" ")
            ..removeWhere(
              (s) => s == '',
            ))
          .expand(searcher);

      Map<FieldsOfStudy, int> ranker = {};

      for (final field in searched) {
        if (ranker.containsKey(field))
          ranker[field] += 1;
        else
          ranker[field] = 1;
      }

      searchedFields = (ranker.entries.toList(growable: false)
            ..sort(
              (e1, e2) => e2.value.compareTo(e1.value),
            ))
          .map((e) => e.key)
          .toList();
    }
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
        text: 'Saved your new fields of study!',
        color: SKColors.success,
        textStyle: TextStyle(color: Colors.white),
      );
      Navigator.pop(context);
    } else
      DropdownBanner.showBanner(
        text: 'Unable to save your updated information. Tap to try again.',
        color: SKColors.warning_red,
        textStyle: TextStyle(color: Colors.white),
        tapCallback: () => tappedSave(null),
      );
  }

  void tappedDismiss(TapUpDetails details) async {
    final fos = SKUser.current.student.fieldsOfStudy ?? [];
    if (fos.length == selectedFields.length &&
        !fos.any((f) => selectedFields[f.id] == null)) {
      Navigator.pop(context);
    } else {
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black.withOpacity(0),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
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
                  GestureDetector(
                    onTapUp: (details) => setState(
                        () => searchedFields = selectedFields.values.toList()),
                    child: Text(
                      '${selectedFields.length} selected',
                      style: TextStyle(
                          fontWeight: FontWeight.normal,
                          fontSize: 13,
                          color: SKColors.skoller_blue),
                    ),
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
                      padding:
                          EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
      ),
    );
  }
}
