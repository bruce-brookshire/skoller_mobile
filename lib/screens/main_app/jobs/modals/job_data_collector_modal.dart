import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:skoller/tools.dart';

enum _CollectionType { text, picker, toggle, multipleSelect, scale }

class DataCollectorModal extends StatefulWidget {
  final String title;
  final String subtitle;
  final _CollectionType type;
  final Future<void> Function(dynamic) onSubmit;

  // Text type
  final String placeholderText;
  final TextInputType inputType;

  // Picker type
  final List<String> items;

  // Scale type
  final int numSegments;

  DataCollectorModal.textType({
    @required this.title,
    this.subtitle,
    this.placeholderText,
    this.inputType,
    @required this.onSubmit,
  })  : type = _CollectionType.text,
        items = null,
        numSegments = null;

  DataCollectorModal.pickerType({
    @required this.title,
    this.subtitle,
    @required this.onSubmit,
    @required this.items,
  })  : type = _CollectionType.picker,
        placeholderText = null,
        inputType = null,
        numSegments = null;

  DataCollectorModal.toggleType({
    @required this.title,
    this.subtitle,
    @required this.onSubmit,
  })  : type = _CollectionType.toggle,
        placeholderText = null,
        inputType = null,
        items = null,
        numSegments = null;

  DataCollectorModal.multipleSelectType({
    @required this.title,
    this.subtitle,
    @required this.onSubmit,
    @required this.items,
  })  : type = _CollectionType.multipleSelect,
        placeholderText = null,
        inputType = null,
        numSegments = null;

  DataCollectorModal.scaleType({
    @required this.title,
    this.subtitle,
    @required this.onSubmit,
    @required this.numSegments,
  })  : type = _CollectionType.scale,
        items = null,
        placeholderText = null,
        inputType = null;

  @override
  State createState() => _DataCollectorModalState();
}

class _DataCollectorModalState extends State<DataCollectorModal> {
  ChangeNotifier controller;
  List<int> selectedIndexes;
  bool toggleOn;
  double value;
  String errorMessage;

  @override
  void initState() {
    if (widget.type == _CollectionType.text)
      controller = TextEditingController();
    else if (widget.type == _CollectionType.picker)
      controller = FixedExtentScrollController();
    else if (widget.type == _CollectionType.multipleSelect)
      selectedIndexes = [];
    else if (widget.type == _CollectionType.toggle)
      toggleOn = false;
    else if (widget.type == _CollectionType.scale) value = 1;

    super.initState();
  }

  @override
  void dispose() {
    controller?.dispose();

    super.dispose();
  }

  void tappedUpdate(_) async {
    dynamic result;

    if (widget.type == _CollectionType.text)
      result = (controller as TextEditingController).text;
    else if (widget.type == _CollectionType.picker)
      result = (controller as FixedExtentScrollController).selectedItem;
    else if (widget.type == _CollectionType.multipleSelect)
      result = selectedIndexes..sort((i1, i2) => i1.compareTo(i2));
    else if (widget.type == _CollectionType.toggle)
      result = toggleOn;
    else if (widget.type == _CollectionType.scale) result = value.round();

    try {
      await widget.onSubmit(result);
      Navigator.pop(context);
    } catch (result) {
      if (result is String) setState(() => errorMessage = result);
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget child;

    switch (widget.type) {
      case _CollectionType.text:
        child = buildTextType();
        break;

      case _CollectionType.picker:
        child = buildPickerType();
        break;

      case _CollectionType.toggle:
        child = buildToggleType();
        break;

      case _CollectionType.multipleSelect:
        child = buildMultipleSelectionType();
        break;

      case _CollectionType.scale:
        child = buildScaleType();
        break;
    }

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      backgroundColor: SKColors.dark_gray,
      child: Padding(
        padding: EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(
              widget.title,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white),
            ),
            if (widget.subtitle != null)
              Text(
                widget.subtitle,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.w300,
                  fontSize: 13,
                  color: Colors.white,
                ),
              ),
            if (errorMessage != null)
              Text(
                errorMessage,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: SKColors.warning_red,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            Flexible(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: child,
              ),
            ),
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTapUp: tappedUpdate,
              child: Container(
                alignment: Alignment.center,
                padding: EdgeInsets.symmetric(vertical: 6),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    color: SKColors.jobs_light_green,
                    boxShadow: UIAssets.boxShadow),
                child: Text(
                  'Update',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildTextType() {
    return CupertinoTextField(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(5),
      ),
      placeholder: widget.placeholderText,
      placeholderStyle: Theme.of(context)
          .textTheme
          .body1
          .copyWith(color: SKColors.text_light_gray),
      controller: controller,
      keyboardType: widget.inputType,
      autofocus: true,
    );
  }

  Widget buildPickerType() {
    return SizedBox(
      height: 144,
      child: CupertinoPicker(
        itemExtent: 32,
        backgroundColor: null,
        scrollController: controller,
        children: widget.items
            .map(
              (s) => Container(
                alignment: Alignment.center,
                child: Text(
                  s,
                  style: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 15,
                      color: Colors.white),
                ),
              ),
            )
            .toList(),
        onSelectedItemChanged: (_) {},
      ),
    );
  }

  Widget buildToggleType() {
    final radius = Radius.circular(5);

    return Row(
      children: <Widget>[
        Expanded(
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTapUp: (_) => setState(() => toggleOn = false),
            child: Container(
              height: 24,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: toggleOn ? null : SKColors.jobs_light_green,
                border: Border.all(color: SKColors.jobs_light_green),
                borderRadius: BorderRadius.only(
                  bottomLeft: radius,
                  topLeft: radius,
                ),
              ),
              child: Text(
                'No',
                style: TextStyle(
                  color:
                      toggleOn ? SKColors.jobs_light_green : SKColors.dark_gray,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
        Expanded(
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTapUp: (_) => setState(() => toggleOn = true),
            child: Container(
              height: 24,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: toggleOn ? SKColors.jobs_light_green : null,
                border: Border.all(color: SKColors.jobs_light_green),
                borderRadius: BorderRadius.only(
                  bottomRight: radius,
                  topRight: radius,
                ),
              ),
              child: Text(
                'Yes',
                style: TextStyle(
                  color:
                      toggleOn ? SKColors.dark_gray : SKColors.jobs_light_green,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget buildMultipleSelectionType() {
    final items = widget.items;
    final children = List<Widget>.generate(items.length, (i) {
      final isSelected = selectedIndexes.indexOf(i) != -1;

      return GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapUp: (_) {
          if (isSelected)
            setState(() => selectedIndexes.remove(i));
          else
            setState(() => selectedIndexes.add(i));
        },
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: <Widget>[
              Container(
                margin: EdgeInsets.only(right: 8),
                child: Icon(
                  isSelected
                      ? Icons.check_circle
                      : Icons.radio_button_unchecked,
                  color: isSelected
                      ? SKColors.jobs_light_green
                      : SKColors.light_gray,
                  size: 20,
                ),
              ),
              Expanded(
                  child: Text(
                items[i],
                style:
                    TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
              )),
            ],
          ),
        ),
      );
    });

    return Scrollbar(
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: children,
        ),
      ),
    );
  }

  Widget buildScaleType() {
    final interestLevels = [
      'Never',
      'Somewhat',
      'Absolutely',
    ];

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 18),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List<Widget>.generate(
              widget.numSegments,
              (i) => Text(
                (i + 1).toString(),
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w300,
                    fontSize: 14),
              ),
            ),
          ),
        ),
        CupertinoSlider(
          divisions: widget.numSegments - 1,
          min: 1,
          max: widget.numSegments.toDouble(),
          value: value,
          activeColor: SKColors.jobs_light_green,
          onChanged: (newVal) => setState(() {
            value = newVal;
          }),
        ),
        Text(
          interestLevels[value.round() - 1],
          style: TextStyle(color: Colors.white),
          textAlign: TextAlign.center,
        )
      ],
    );
  }
}
