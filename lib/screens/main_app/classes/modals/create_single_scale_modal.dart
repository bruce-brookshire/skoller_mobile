import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:skoller/tools.dart';

class CreateSingleScaleModal extends StatefulWidget {
  @override
  State createState() => _CreateSingleScaleModalState();
}

class _CreateSingleScaleModalState extends State<CreateSingleScaleModal> {
  final letterController = TextEditingController(text: '');
  final numberController = TextEditingController(text: '');

  final focusNodes = [FocusNode(), FocusNode()];

  bool isValid = false;

  @override
  void dispose() {
    super.dispose();

    [letterController, numberController, ...focusNodes].forEach(
      (f) => (f as dynamic).dispose(),
    );
  }

  void stateChanged(_) {
    final numberText = numberController.text.trim();
    final newVal = letterController.text.trim() != '' &&
        numberText != '' &&
        int.tryParse(numberText) != null;

    if (newVal != isValid) setState(() => isValid = newVal);
  }

  void tappedAction([_]) {
    for (final node in focusNodes) if (node.hasFocus) node.unfocus();

    if (isValid) {
      final letterText = letterController.text.trim();
      final numberText = numberController.text.trim();
      final obj = {'letter': letterText, 'number': numberText};

      Navigator.pop(context, obj);
    } else
      Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(color: SKColors.border_gray),
      ),
      backgroundColor: Colors.white,
      child: Padding(
        padding: EdgeInsets.all(12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text(
              'Add scale',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 17),
            ),
            Padding(
              padding: EdgeInsets.only(top: 4, left: 2),
              child: Text(
                'Letter grade',
                style: TextStyle(fontWeight: FontWeight.normal, fontSize: 13),
              ),
            ),
            CupertinoTextField(
              placeholder: 'e.g. A+',
              placeholderStyle:
                  TextStyle(color: SKColors.light_gray, fontSize: 15, fontWeight: FontWeight.normal),
              controller: letterController,
              onChanged: stateChanged,
              style: TextStyle(color: SKColors.dark_gray, fontSize: 15, fontWeight: FontWeight.bold),
              textCapitalization: TextCapitalization.characters,
              textInputAction: TextInputAction.next,
              onSubmitted: (_) => focusNodes[0].nextFocus(),
              focusNode: focusNodes[0],
              decoration: BoxDecoration(
                  border: Border.all(color: SKColors.border_gray),
                  borderRadius: BorderRadius.circular(5)),
            ),
            Padding(
              padding: EdgeInsets.only(top: 12, left: 2),
              child: Text(
                'Starts at',
                style: TextStyle(fontWeight: FontWeight.normal, fontSize: 13),
              ),
            ),
            CupertinoTextField(
              placeholder: 'e.g. 93',
              placeholderStyle:
                  TextStyle(color: SKColors.light_gray, fontSize: 15, fontWeight: FontWeight.normal),
              onChanged: stateChanged,
              style: TextStyle(color: SKColors.dark_gray, fontSize: 15, fontWeight: FontWeight.bold),
              controller: numberController,
              keyboardType: TextInputType.number,
              focusNode: focusNodes[1],
              decoration: BoxDecoration(
                  border: Border.all(color: SKColors.border_gray),
                  borderRadius: BorderRadius.circular(5)),
            ),
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTapUp: tappedAction,
              child: isValid
                  ? Container(
                      decoration: BoxDecoration(
                        color: SKColors.skoller_blue,
                        borderRadius: BorderRadius.circular(5),
                      ),
                      alignment: Alignment.center,
                      margin: EdgeInsets.only(top: 12),
                      padding: EdgeInsets.symmetric(vertical: 6),
                      child: Text(
                        'Add',
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                    )
                  : Container(
                      decoration: BoxDecoration(
                        // border: Border.all(color: SKColors.skoller_blue),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      alignment: Alignment.center,
                      margin: EdgeInsets.only(top: 12),
                      padding: EdgeInsets.symmetric(vertical: 6),
                      child: Text(
                        'Dismiss',
                        style: TextStyle(
                          color: SKColors.skoller_blue,
                        ),
                      ),
                    ),
            )
          ],
        ),
      ),
    );
  }
}
