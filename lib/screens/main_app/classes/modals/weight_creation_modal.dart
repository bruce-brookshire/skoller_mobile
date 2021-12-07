import 'package:skoller/tools.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class WeightCreationModal extends StatefulWidget {
  final bool isPoints;
  final bool isCreate;

  final String startNameVal;
  final String startValueVal;

  final DoubleStringCallback resultsCallback;

  WeightCreationModal(this.isPoints, this.isCreate, this.startNameVal,
      this.startValueVal, this.resultsCallback);

  @override
  State createState() => _WeightExtractionFormModalState();
}

class _WeightExtractionFormModalState extends State<WeightCreationModal> {
  final nameFocusNode = FocusNode();
  final valueFocusNode = FocusNode();

  TextEditingController nameController;
  TextEditingController valueController;

  @override
  void initState() {
    nameController = TextEditingController(text: widget.startNameVal);
    valueController = TextEditingController(text: widget.startValueVal);
    super.initState();
  }

  @override
  void dispose() {
    unfocusNodes();

    nameFocusNode.dispose();
    valueFocusNode.dispose();

    nameController.dispose();
    valueController.dispose();

    super.dispose();
  }

  void unfocusNodes() {
    nameFocusNode.unfocus();
    valueFocusNode.unfocus();
  }

  @override
  Widget build(BuildContext context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: BorderSide(color: SKColors.border_gray),
        ),
        child: Padding(
          padding: EdgeInsets.fromLTRB(12, 12, 12, 0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Text(
                widget.isCreate ? 'Create weight' : 'Update weight',
                style: TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
              Padding(
                padding: EdgeInsets.only(top: 16),
                child: Text('Name'),
              ),
              CupertinoTextField(
                placeholder: 'Exams',
                controller: nameController,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5),
                  border: Border.all(color: SKColors.border_gray),
                ),
                padding: EdgeInsets.fromLTRB(6, 8, 6, 4),
                textCapitalization: TextCapitalization.words,
                cursorColor: SKColors.skoller_blue,
                autofocus: true,
                focusNode: nameFocusNode,
                textInputAction: TextInputAction.next,
                placeholderStyle:
                    TextStyle(fontSize: 14, color: SKColors.text_light_gray),
                onSubmitted: (_) => nameFocusNode.nextFocus(),
                style: TextStyle(color: SKColors.dark_gray, fontSize: 15),
              ),
              Padding(
                padding: EdgeInsets.only(top: 12),
                child: Text('Value'),
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  SizedBox(
                      width: 60,
                      child: CupertinoTextField(
                        controller: valueController,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5),
                          border: Border.all(color: SKColors.border_gray),
                        ),
                        padding: EdgeInsets.fromLTRB(6, 8, 6, 4),
                        cursorColor: SKColors.skoller_blue,
                        placeholder: '25',
                        focusNode: valueFocusNode,
                        keyboardType: TextInputType.number,
                        placeholderStyle: TextStyle(
                            fontSize: 14, color: SKColors.text_light_gray),
                        style:
                            TextStyle(color: SKColors.dark_gray, fontSize: 15),
                      )),
                  Padding(
                    padding: EdgeInsets.only(left: 8),
                    child: Text('${widget.isPoints ? 'pts.' : '%'}'),
                  ),
                  Spacer(),
                ],
              ),
              GestureDetector(
                onTapUp: (details) {
                  widget.resultsCallback(
                      nameController.text, valueController.text);
                  unfocusNodes();
                  Navigator.pop(context);
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: SKColors.skoller_blue,
                    borderRadius: BorderRadius.circular(5),
                  ),
                  padding: EdgeInsets.symmetric(vertical: 8),
                  margin: EdgeInsets.symmetric(vertical: 12),
                  child: Text(
                    widget.isCreate ? 'Add' : 'Update',
                    style: TextStyle(color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
}
