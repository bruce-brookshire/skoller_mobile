part of 'constants.dart';

typedef ContextCallback(BuildContext context);
typedef void DateCallback(DateTime date);

class SKTextField extends StatelessWidget {
  final String fillText;
  final EdgeInsets margins;

  SKTextField({Key key, String labelText, EdgeInsets margin})
      : fillText = labelText,
        margins = margin,
        super(key: key);

  @override
  Widget build(BuildContext context) => Container(
        margin: margins,
        child: Material(
          type: MaterialType.card,
          elevation: 3,
          borderRadius: BorderRadius.circular(5),
          child: Container(
            margin: EdgeInsets.all(4),
            padding: EdgeInsets.symmetric(horizontal: 4, vertical: 6),
            child: TextField(
              obscureText: true,
              decoration: InputDecoration.collapsed(hintText: fillText),
              style: TextStyle(fontSize: 14),
            ),
          ),
        ),
      );
}

class SKButton extends StatelessWidget {
  final String buttonText;
  final EdgeInsets margins;
  final double width;
  final ContextCallback callback;

  SKButton(
      {Key key,
      String buttonText,
      EdgeInsets margin,
      double width,
      ContextCallback callback})
      : buttonText = buttonText,
        margins = margin,
        width = width,
        callback = callback,
        super(key: key);

  Widget build(BuildContext context) => Container(
        margin: margins,
        height: 36,
        width: width,
        child: SizedBox.expand(
          child: RaisedButton(
            color: Colors.white,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
            child: Text(
              buttonText,
              style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: SKColors.skoller_blue),
            ),
            onPressed: () {
              callback(context);
            },
          ),
        ),
      );
}

class SKNavBar extends StatelessWidget {
  final String _title;
  final Color _titleColor;
  final bool _isBack;
  final bool _isDown;
  final String _rightBtnImage;
  final VoidCallback _callback_right;
  final VoidCallback _callback_back;

  SKNavBar(
    String title, {
    Key key,
    bool backBtnEnabled,
    bool downBtnEnabled,
    String rightBtnImage,
    Color titleColor,
    VoidCallback right_btn_callback,
    VoidCallback back_btn_callback,
  })  : _title = title,
        _isBack = backBtnEnabled ?? false,
        _isDown = downBtnEnabled ?? false,
        _rightBtnImage = rightBtnImage,
        _titleColor = titleColor ?? SKColors.dark_gray,
        _callback_right = right_btn_callback,
        _callback_back = back_btn_callback,
        super(key: key) {
    assert(_isBack != _isDown || !_isBack);
  }

  Widget build(BuildContext context) => Container(
        height: 44,
        decoration: BoxDecoration(boxShadow: [
          BoxShadow(
            color: Color(0x1C000000),
            offset: Offset(0, 3.5),
            blurRadius: 2,
          )
        ], color: Colors.white),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTapUp: (details) {
                if (_isBack) Navigator.pop(context);
                // if (_isDown) Navigator.
              },
              child: Container(
                padding: EdgeInsets.only(left: 4),
                child: (_isBack || _isDown)
                    ? Center(
                        child: _isBack
                            ? Image(
                                image:
                                    AssetImage(ImageNames.navArrowImages.left),
                              )
                            : null)
                    : null,
                width: 44,
                height: 44,
              ),
            ),
            Text(
              _title,
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: _titleColor),
            ),
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTapUp: (details) {
                if (_rightBtnImage != null && _callback_right != null) {
                  _callback_right();
                }
              },
              child: Container(
                padding: EdgeInsets.only(right: 4),
                child: (_rightBtnImage == null)
                    ? null
                    : Center(
                        child: Image(
                          image: AssetImage(_rightBtnImage),
                        ),
                      ),
                width: 44,
                height: 44,
              ),
            ),
          ],
        ),
      );
}

class SKNavView extends StatelessWidget {
  final String title;
  final Color titleColor;
  final bool isBack;
  final bool isDown;
  final String rightBtnImage;
  final VoidCallback callbackRight;
  final VoidCallback callbackBack;
  final List<Widget> children;

  SKNavView({
    Key key,
    @required this.children,
    @required this.title,
    this.titleColor,
    this.isBack = true,
    this.isDown = false,
    this.rightBtnImage,
    this.callbackRight,
    this.callbackBack,
    bool downBtnEnabled,
  }) : super(key: key);

  Widget build(BuildContext context) {
    final navBar = SKNavBar(
      title,
      backBtnEnabled: isBack,
      downBtnEnabled: isDown,
      rightBtnImage: rightBtnImage,
      titleColor: titleColor,
      right_btn_callback: callbackRight,
    );
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        bottom: false,
        child: Stack(
          children: <Widget>[
            Align(
              alignment: Alignment.center,
              child: Container(
                margin: EdgeInsets.only(top: 44),
                color: SKColors.background_gray,
                child: Center(
                  child: Column(
                    children: children,
                  ),
                ),
              ),
            ),
            Align(
              child: navBar,
              alignment: Alignment.topCenter,
            ),
          ],
        ),
      ),
    );
  }
}

class ClassCompletionChart extends StatefulWidget {
  final double completion;
  final Color color;

  ClassCompletionChart(this.completion, this.color) : super();

  @override
  State createState() => _ClassCompletionChartState();
}

class _ClassCompletionChartState extends State<ClassCompletionChart> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: CustomPaint(
        painter: _ChartPainter(widget.color, widget.completion),
        child: Container(
          height: 12,
          width: 12,
        ),
      ),
    );
  }
}

class _ChartPainter extends CustomPainter {
  final Color color;
  final double completion;

  _ChartPainter(this.color, this.completion) : super();

  @override
  void paint(Canvas canvas, Size size) {
    final paint1 = Paint();
    final paint2 = Paint();
    // set the color property of the paint
    paint1.color = color;
    paint2.color = Colors.white;

    final radius = size.width / 2;
    final center = Offset(radius, radius);
    final rect = Rect.fromCircle(center: center, radius: radius);

    // draw the circle on centre of canvas having radius 75.0
    canvas.drawCircle(center, radius, paint1);
    canvas.drawCircle(center, radius - 0.75, paint2);
    canvas.drawArc(rect, -1.5708, 6.2831 * completion, true, paint1);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class SKCalendarPicker extends StatefulWidget {
  final DateTime startDate;
  final DateCallback _completionHandler;

  SKCalendarPicker._(this.startDate, this._completionHandler) : super();

  @override
  State createState() => _SKCalendarPickerState();

  static Future<DateTime> presentDateSelector({
    @required String title,
    @required String subtitle,
    @required BuildContext context,
    @required DateTime startDate,
  }) async {
    DateTime selectedDate = startDate;

    final calendar = SKCalendarPicker._(startDate, (date) {
      selectedDate = date;
    });

    return showDialog(
        context: context,
        builder: (context) {
          return Dialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(10))),
            child: Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: SKColors.border_gray),
                  borderRadius: BorderRadius.circular(10)),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    alignment: Alignment.center,
                    child: Text(
                      title,
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: SKColors.dark_gray,
                          fontSize: 15),
                    ),
                  ),
                  Container(
                    alignment: Alignment.center,
                    padding: EdgeInsets.only(bottom: 6, top: 4),
                    child: Text(
                      subtitle,
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.normal,
                          color: SKColors.dark_gray),
                    ),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.max,
                    children: <Widget>[
                      Expanded(
                        child: Container(
                          child: null,
                          margin: EdgeInsets.only(bottom: 8),
                          height: 1.25,
                          color: SKColors.border_gray,
                        ),
                      ),
                    ],
                  ),
                  calendar,
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTapUp: (details) {
                            Navigator.pop(context);
                          },
                          child: Container(
                            alignment: Alignment.center,
                            padding: EdgeInsets.only(top: 12, bottom: 8),
                            child: Text(
                              'Dismiss',
                              style: TextStyle(
                                  color: SKColors.skoller_blue,
                                  fontWeight: FontWeight.normal),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTapUp: (details) {
                            Navigator.pop(context, selectedDate);
                          },
                          child: Container(
                            alignment: Alignment.center,
                            padding: EdgeInsets.only(top: 12, bottom: 8),
                            child: Text(
                              'Select',
                              style: TextStyle(color: SKColors.skoller_blue),
                            ),
                          ),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          );
        });
  }
}

class _SKCalendarPickerState extends State<SKCalendarPicker> {
  final weekDayStyle = TextStyle(fontSize: 14, color: SKColors.text_light_gray);

  DateTime firstOfMonth;
  DateTime startDate;

  DateTime selectedDay;

  @override
  void initState() {
    super.initState();

    selectedDay = widget.startDate;
    firstOfMonth = DateTime(selectedDay.year, selectedDay.month, 1);
    startDate = firstOfMonth.weekday == 7
        ? firstOfMonth
        : DateTime(
            selectedDay.year, selectedDay.month, 1 - firstOfMonth.weekday);
  }

  void tappedNextMonth(dynamic details) {
    setState(() {
      firstOfMonth = DateTime(firstOfMonth.year, firstOfMonth.month + 1, 1);
      startDate = firstOfMonth.weekday == 7
          ? firstOfMonth
          : DateTime(
              firstOfMonth.year, firstOfMonth.month, 1 - firstOfMonth.weekday);
    });
  }

  void tappedPreviousMonth(dynamic details) {
    setState(() {
      firstOfMonth = DateTime(firstOfMonth.year, firstOfMonth.month - 1, 1);
      startDate = firstOfMonth.weekday == 7
          ? firstOfMonth
          : DateTime(
              firstOfMonth.year, firstOfMonth.month, 1 - firstOfMonth.weekday);
    });
  }

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1,
      child: Container(
        child: Column(
          children: <Widget>[
            Container(
              padding: EdgeInsets.symmetric(horizontal: 4),
              margin: EdgeInsets.symmetric(vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  GestureDetector(
                    onTapUp: tappedPreviousMonth,
                    child: Container(
                      padding: EdgeInsets.all(4),
                      child: Image.asset(ImageNames.navArrowImages.left),
                    ),
                  ),
                  Text(DateFormat('MMMM, yyyy').format(firstOfMonth)),
                  GestureDetector(
                    onTapUp: tappedNextMonth,
                    child: Container(
                      padding: EdgeInsets.all(4),
                      child: Image.asset(ImageNames.navArrowImages.right),
                    ),
                  ),
                ],
              ),
            ),
            Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  // border: Border(
                  //     bottom: BorderSide(color: SKColors.text_light_gray)),
                ),
                alignment: Alignment.centerLeft,
                padding: EdgeInsets.symmetric(horizontal: 2, vertical: 4),
                margin: EdgeInsets.only(bottom: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[
                    Text('U', style: weekDayStyle),
                    Text('M', style: weekDayStyle),
                    Text('T', style: weekDayStyle),
                    Text('W', style: weekDayStyle),
                    Text('R', style: weekDayStyle),
                    Text('F', style: weekDayStyle),
                    Text('S', style: weekDayStyle),
                  ],
                )),
            ...calendarBody(),
          ],
        ),
      ),
    );
  }

  List<Widget> calendarBody() {
    return <Widget>[
      week(startDate),
      week(DateTime(startDate.year, startDate.month, startDate.day + 7)),
      week(DateTime(startDate.year, startDate.month, startDate.day + 14)),
      week(DateTime(startDate.year, startDate.month, startDate.day + 21)),
      week(DateTime(startDate.year, startDate.month, startDate.day + 28)),
      week(DateTime(startDate.year, startDate.month, startDate.day + 35)),
    ];
  }

  Widget week(DateTime date) {
    final isEmptyBottomRow = date.weekday == 7 &&
        date.day != startDate.day &&
        date.month != firstOfMonth.month;

    return isEmptyBottomRow
        ? Container(child: null)
        : Expanded(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 2),
              child: Row(
                children: <Widget>[
                  createDay(date),
                  createDay(DateTime(date.year, date.month, date.day + 1)),
                  createDay(DateTime(date.year, date.month, date.day + 2)),
                  createDay(DateTime(date.year, date.month, date.day + 3)),
                  createDay(DateTime(date.year, date.month, date.day + 4)),
                  createDay(DateTime(date.year, date.month, date.day + 5)),
                  createDay(DateTime(date.year, date.month, date.day + 6)),
                ],
              ),
            ),
          );
  }

  Widget createDay(DateTime date) {
    final isSelected = date.day == selectedDay.day &&
        date.month == selectedDay.month &&
        selectedDay.year == date.year;

    return date.month != firstOfMonth.month
        ? Expanded(child: Container(child: null))
        : Expanded(
            child: AspectRatio(
              aspectRatio: 1,
              child: GestureDetector(
                onTapUp: (details) {
                  setState(() {
                    selectedDay = date;
                    widget._completionHandler(date);
                  });
                },
                child: Container(
                  margin: EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isSelected ? SKColors.skoller_blue : Colors.white,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    "${date.day}",
                    style: TextStyle(
                      color: isSelected ? Colors.white : SKColors.dark_gray,
                      fontWeight: FontWeight.normal,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ),
          );
  }
}

class SKAlertDialog extends StatelessWidget {
  final String title;
  final String subTitle;

  final String confirmText;
  final String cancelText;

  final Widget child;

  SKAlertDialog({
    @required this.title,
    this.subTitle,
    @required this.child,
    this.confirmText,
    this.cancelText,
  });

  @override
  Widget build(BuildContext context) {
    List<Widget> children = [];

    children.add(
      Padding(
        padding: EdgeInsets.only(top: 12, left: 4, right: 4),
        child: Text(
          title,
          textAlign: TextAlign.center,
        ),
      ),
    );

    if (subTitle != null) {
      children.add(
        Padding(
          padding: EdgeInsets.all(4),
          child: Text(
            subTitle,
            textAlign: TextAlign.center,
            style: TextStyle(fontWeight: FontWeight.normal, fontSize: 14),
          ),
        ),
      );
    }
    children.add(
      Container(
        child: null,
        margin: EdgeInsets.fromLTRB(16, 4, 16, 12,),
        height: 1.25,
        color: SKColors.border_gray,
      ),
    );

    children.add(child);

    children.add(
      Row(
        children: <Widget>[
          Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTapUp: (details) => Navigator.pop(context, false),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(10),
                  ),
                ),
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Text(
                  cancelText ?? 'Cancel',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: SKColors.skoller_blue,
                      fontWeight: FontWeight.normal),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTapUp: (details) => Navigator.pop(context, true),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                    bottomRight: Radius.circular(10),
                  ),
                ),
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Text(
                  confirmText ?? 'Select',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: SKColors.skoller_blue, fontSize: 15),
                ),
              ),
            ),
          ),
        ],
      ),
    );

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(10)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: children,
      ),
    );
  }
}
