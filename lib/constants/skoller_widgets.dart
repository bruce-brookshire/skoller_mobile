part of 'constants.dart';

// class SKTextField extends StatelessWidget {
//   final String fillText;
//   final EdgeInsets margin;
//   final double width;

//   SKTextField({this.fillText, this.margin, this.width, });

//   @override
//   Widget build(BuildContext context) => Container(
//         margin: margin,
//         width: width,
//         child: Material(
//           type: MaterialType.card,
//           elevation: 3,
//           borderRadius: BorderRadius.circular(5),
//           child: Container(
//             margin: EdgeInsets.all(4),
//             padding: EdgeInsets.symmetric(horizontal: 4, vertical: 6),
//             child: TextField(
//               obscureText: true,
//               decoration: InputDecoration.collapsed(hintText: fillText),
//               style: TextStyle(fontSize: 14),
//             ),
//           ),
//         ),
//       );
// }

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
  final bool leftIsPop;

  final String title;

  final Color titleColor;

  final Widget leftBtn;
  final Widget rightBtn;

  final VoidCallback callbackRight;
  final VoidCallback callbackLeft;
  final VoidCallback callbackTitle;

  SKNavBar(
    this.title, {
    this.leftIsPop = true,
    this.rightBtn,
    this.leftBtn,
    this.titleColor,
    this.callbackRight,
    this.callbackLeft,
    this.callbackTitle,
  });

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
                if (callbackLeft != null)
                  callbackLeft();
                else if (leftIsPop) Navigator.pop(context);
              },
              child: Container(
                padding: EdgeInsets.only(left: 4),
                child: leftBtn != null ? Center(child: leftBtn) : null,
                width: 44,
                height: 44,
              ),
            ),
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTapUp: (details) {
                if (callbackTitle != null) callbackTitle();
              },
              child: Text(
                title,
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: titleColor),
              ),
            ),
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTapUp: (details) {
                if (callbackRight != null) callbackRight();
              },
              child: Container(
                padding: EdgeInsets.only(right: 4),
                child: rightBtn != null ? Center(child: rightBtn) : null,
                width: 44,
                height: 44,
              ),
            ),
          ],
        ),
      );
}

class SKNavView extends StatelessWidget {
  final bool isPop;

  final String title;

  final Widget rightBtn;
  final Widget leftBtn;

  final VoidCallback callbackRight;
  final VoidCallback callbackLeft;
  final VoidCallback callbackTitle;

  final List<Widget> children;

  final Color titleColor;
  final Color backgroundColor;

  SKNavView({
    @required this.children,
    @required this.title,
    this.titleColor,
    this.rightBtn,
    this.isPop = true,
    this.leftBtn,
    this.callbackRight,
    this.callbackLeft,
    this.callbackTitle,
    this.backgroundColor,
  });

  Widget build(BuildContext context) {
    final navBar = SKNavBar(
      title,
      rightBtn: rightBtn,
      leftBtn: leftBtn ??
          (isPop ? Image.asset(ImageNames.navArrowImages.left) : null),
      leftIsPop: isPop,
      titleColor: titleColor,
      callbackRight: callbackRight,
      callbackLeft: callbackLeft,
      callbackTitle: callbackTitle,
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
                color: backgroundColor ?? SKColors.background_gray,
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
      print(date);
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
                          margin: EdgeInsets.only(bottom: 4),
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
  final controller = PageController(initialPage: 1);

  List<DateTime> children = [];
  int curIndex = 1;

  DateTime selectedDate;

  @override
  void initState() {
    super.initState();

    selectedDate = widget.startDate;

    children = [
      DateTime(widget.startDate.year, widget.startDate.month - 1, 1),
      DateTime(widget.startDate.year, widget.startDate.month, 1),
      DateTime(widget.startDate.year, widget.startDate.month + 1, 1),
    ];
  }

  void tappedNextMonth(dynamic details) {
    controller.animateToPage(curIndex + 1,
        duration: Duration(milliseconds: 300), curve: Curves.decelerate);
  }

  void tappedPreviousMonth(dynamic details) {
    controller.animateToPage(curIndex - 1,
        duration: Duration(milliseconds: 300), curve: Curves.decelerate);
  }

  void pageChanged(int index) {
    setState(() {
      curIndex = index;

      if (curIndex == (children.length - 1)) {
        final curMonth = children.last;
        children.add(DateTime(curMonth.year, curMonth.month + 1, 1));
      } else if (curIndex == 0) {
        final curMonth = children.first;
        children.insert(0, DateTime(curMonth.year, curMonth.month - 1, 1));
        curIndex = 1;
        controller.jumpToPage(curIndex);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1,
      child: Container(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Container(
              margin: EdgeInsets.symmetric(vertical: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTapUp: tappedPreviousMonth,
                    child: Container(
                      width: 36,
                      height: 36,
                      alignment: Alignment.center,
                      child: Image.asset(ImageNames.navArrowImages.left),
                    ),
                  ),
                  Text(DateFormat('MMMM, yyyy').format(children[curIndex])),
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTapUp: tappedNextMonth,
                    child: Container(
                      width: 36,
                      height: 36,
                      alignment: Alignment.center,
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
              ),
            ),
            Expanded(
              child: PageView.builder(
                itemCount: children.length,
                controller: controller,
                itemBuilder: (context, index) => _SKCalendarBody(
                  month: children[index],
                  onDateSelected: (date) {
                    setState(() {
                      selectedDate = date;
                    });

                    widget._completionHandler(date);
                  },
                  getSelected: () => selectedDate,
                ),
                onPageChanged: pageChanged,
              ),
            )
          ],
        ),
      ),
    );
  }
}

class _SKCalendarBody extends StatefulWidget {
  final DateTime firstOfMonth;
  final DateTime startDate;
  final DateCallback onDateSelected;
  final DateFetch getSelected;

  _SKCalendarBody({DateTime month, this.onDateSelected, this.getSelected})
      : firstOfMonth = month,
        startDate = month.weekday == 7
            ? month
            : DateTime(month.year, month.month, 1 - month.weekday);

  @override
  State createState() => _SKCalendarBodyState();
}

class _SKCalendarBodyState extends State<_SKCalendarBody> {
  DateTime selectedDay;

  Widget build(BuildContext context) {
    final startDate = widget.startDate;
    selectedDay = widget.getSelected();

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        week(startDate),
        week(DateTime(startDate.year, startDate.month, startDate.day + 7)),
        week(DateTime(startDate.year, startDate.month, startDate.day + 14)),
        week(DateTime(startDate.year, startDate.month, startDate.day + 21)),
        week(DateTime(startDate.year, startDate.month, startDate.day + 28)),
        week(DateTime(startDate.year, startDate.month, startDate.day + 35)),
      ],
    );
  }

  Widget week(DateTime date) {
    final isEmptyBottomRow = date.weekday == 7 &&
        date.day != widget.startDate.day &&
        date.month != widget.firstOfMonth.month;

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

    return date.month != widget.firstOfMonth.month
        ? Expanded(child: Container(child: null))
        : Expanded(
            child: AspectRatio(
              aspectRatio: 1,
              child: GestureDetector(
                onTapUp: (details) {
                  widget.onDateSelected(date);
                  // selectedDay = date;
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

class SKNavFadeUpRoute extends ModalRoute<void> {
  final WidgetBuilder builder;

  SKNavFadeUpRoute({@required this.builder});

  @override
  Duration get transitionDuration => Duration(milliseconds: 500);

  @override
  bool get opaque => true;

  @override
  bool get barrierDismissible => false;

  @override
  Color get barrierColor => Colors.white;

  @override
  String get barrierLabel => null;

  @override
  bool get maintainState => true;

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) {
    // This makes sure that text and other content follows the material style
    return builder(context);
  }

  @override
  Widget buildTransitions(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation, Widget child) {
    // You can add your own animations for the overlay content

    return FadeTransition(
      opacity: animation,
      child: CupertinoFullscreenDialogTransition(
        animation: animation,
        child: child,
      ),
    );
  }
}

class SKNavOverlayRoute extends ModalRoute<void> {
  final WidgetBuilder builder;

  SKNavOverlayRoute({@required this.builder});

  @override
  Duration get transitionDuration => Duration(milliseconds: 500);

  @override
  bool get opaque => false;

  @override
  bool get barrierDismissible => true;

  @override
  Color get barrierColor => Colors.black.withOpacity(0.3);

  @override
  String get barrierLabel => null;

  @override
  bool get maintainState => true;

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) {
    // This makes sure that text and other content follows the material style
    return builder(context);
  }

  @override
  Widget buildTransitions(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation, Widget child) {
    // You can add your own animations for the overlay content

    return FadeTransition(
      opacity: animation,
      child: CupertinoFullscreenDialogTransition(
        animation: animation,
        child: child,
      ),
    );
  }
}

class SKLoadingScreen extends ModalRoute<void> {
  static SKLoadingScreen fadeIn(BuildContext context) {
    final loadingScreen = SKLoadingScreen();

    Navigator.of(context).push(loadingScreen);

    return loadingScreen;
  }

  @override
  Duration get transitionDuration => Duration(milliseconds: 300);

  @override
  bool get opaque => false;

  @override
  bool get barrierDismissible => false;

  @override
  Color get barrierColor => SKColors.text_light_gray.withOpacity(0.2);

  @override
  String get barrierLabel => null;

  @override
  bool get maintainState => true;

  void dismiss() {
    navigator.pop();
  }

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) =>
      BackdropFilter(
        filter: dartUI.ImageFilter.blur(sigmaX: 3.0, sigmaY: 3.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            SizedBox(width: 44, height: 44, child: CircularProgressIndicator())
          ],
        ),
      );

  @override
  Widget buildTransitions(BuildContext context, Animation<double> animation,
          Animation<double> secondaryAnimation, Widget child) =>
      FadeTransition(
        opacity: animation,
        child: child,
      );
}

class SKAlertDialog extends StatelessWidget {
  final String title;
  final String subTitle;

  final String confirmText;
  final String cancelText;

  final Widget child;

  final DynamicCallback getResults;

  SKAlertDialog({
    @required this.title,
    this.subTitle,
    this.child,
    this.confirmText,
    this.cancelText,
    this.getResults,
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
          style: TextStyle(fontSize: 16),
        ),
      ),
    );

    if (subTitle != null) {
      children.add(
        Padding(
          padding: EdgeInsets.symmetric(vertical: 4, horizontal: 12),
          child: Text(
            subTitle,
            textAlign: TextAlign.center,
            style: TextStyle(
                fontWeight: FontWeight.normal,
                fontSize: 12,
                color: SKColors.light_gray),
          ),
        ),
      );
    }

    if (child != null) {
      children.add(
        Container(
          child: null,
          margin: EdgeInsets.only(top: 4, bottom: 12),
          height: 1,
          color: SKColors.border_gray,
        ),
      );

      children.add(child);
    }

    children.add(
      Row(
        children: <Widget>[
          Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTapUp: (details) => Navigator.pop(context, false),
              child: Container(
                decoration: BoxDecoration(
                  // borderRadius: BorderRadius.only(
                  //   bottomLeft: Radius.circular(0),
                  //   bottomRight: Radius.circular(0),
                  //   topLeft: Radius.circular(0),
                  //   topRight: Radius.circular(0),
                  // ),
                  border: Border(
                    right: BorderSide(color: SKColors.border_gray, width: 0.5),
                    top: BorderSide(color: SKColors.border_gray, width: 1),
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
              onTapUp: (details) => Navigator.pop(
                context,
                getResults == null ? true : getResults(),
              ),
              child: Container(
                decoration: BoxDecoration(
                  // borderRadius: BorderRadius.only(
                  //   bottomRight: Radius.circular(10),
                  // ),
                  border: Border(
                    left: BorderSide(color: SKColors.border_gray, width: 0.5),
                    top: BorderSide(color: SKColors.border_gray, width: 1),
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

class GradeScaleModalView extends StatefulWidget {
  final StudentClass studentClass;

  GradeScaleModalView(this.studentClass);

  @override
  State createState() => _GradeScaleModalState();
}

class _GradeScaleModalState extends State<GradeScaleModalView> {
  int selectedIndex = 0;

  final scaleMapper = (List<String> scale, bool isSelected) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: scale
            .map((elem) => Text(
                  elem,
                  style: TextStyle(
                      color: isSelected ? Colors.white : SKColors.dark_gray),
                ))
            .toList(),
      );

  @override
  Widget build(BuildContext context) {
    final scales = [
      [
        ['A', 'B', 'C', 'D'],
        ['90', '80', '70', '60']
      ],
      [
        ['A+', 'A', 'B+', 'B', 'B-', 'C+', 'C', 'C-', 'D'],
        ['93', '90', '87', '83', '80', '77', '73', '70', '60'],
      ],
      [
        ['A+', 'A', 'B+', 'B', 'B-', 'C+', 'C', 'C-', 'D+', 'D', 'D-'],
        ['93', '90', '87', '83', '80', '77', '73', '70', '67', '63', '60'],
      ],
    ];

    int curIndex = 0;
    List<Widget> containers = [];

    for (final scale in scales) {
      int curTemp = curIndex.toInt();

      containers.add(
        Expanded(
          child: GestureDetector(
            onTapUp: (details) {
              if (selectedIndex != curTemp) {
                setState(() {
                  selectedIndex = curTemp;
                });
              }
            },
            child: Container(
              height: 220,
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              margin: EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(
                border: Border.all(color: SKColors.border_gray),
                borderRadius: BorderRadius.circular(5),
                boxShadow: [UIAssets.boxShadow],
                color: selectedIndex == curTemp
                    ? SKColors.skoller_blue
                    : Colors.white,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: scale
                    .map((elem) => scaleMapper(elem, selectedIndex == curTemp))
                    .toList(),
              ),
            ),
          ),
        ),
      );

      curIndex += 1;
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: EdgeInsets.fromLTRB(8, 12, 8, 8),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: SKColors.skoller_blue,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(10),
                topRight: Radius.circular(10),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: <Widget>[
                Text(
                  'Select grade scale',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
                Text(
                  'for entire class',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.normal),
                ),
              ],
            ),
          ),
          Container(
            margin: EdgeInsets.symmetric(vertical: 8),
            child: Text(
              'Select the grade scale for this class',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14),
            ),
          ),
          Container(
            margin: EdgeInsets.fromLTRB(8, 8, 8, 16),
            child: Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: containers,
            ),
          ),
          GestureDetector(
            onTapUp: (details) {
              if (selectedIndex == -1) {
                return;
              }
              final scale = Map.fromIterables(
                  scales[selectedIndex][0], scales[selectedIndex][1]);
              widget.studentClass.addGradeScale(scale).then((response) {
                if (response.wasSuccessful()) {
                  Navigator.pop<bool>(context, true);
                } else {
                  DropdownBanner.showBanner(
                    text: 'Failed to add grade scale',
                    color: SKColors.warning_red,
                    textStyle: TextStyle(color: Colors.white),
                  );
                }
              });
            },
            child: Container(
              alignment: Alignment.center,
              padding: EdgeInsets.symmetric(vertical: 8),
              margin: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5),
                color: selectedIndex == -1
                    ? SKColors.inactive_gray
                    : SKColors.skoller_blue,
                boxShadow: [UIAssets.boxShadow],
              ),
              child: Text(
                'Select',
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class SKColorPicker extends StatefulWidget {
  final ColorCallback callback;
  final Widget child;
  final List<Color> colors = [
    Color(0xFF9B55E5),
    Color(0xFFFF71A8),
    Color(0xFF57B9E4),
    Color(0xFF4CD8BD),
    Color(0xFF4CCC58),
    Color(0xFFF7D300),
    Color(0xFFFFAE42),
    Color(0xFFDD4A63),
  ];

  SKColorPicker({this.callback, this.child});

  @override
  State createState() => _SKColorPickerState();
}

class _SKColorPickerState extends State<SKColorPicker> {
  OverlayEntry _overlayEntry;

  void _tappedColorPicker(TapUpDetails details) async {
    if (this._overlayEntry == null) {
      this._overlayEntry = _createOverlayEntry();
      Overlay.of(context).insert(this._overlayEntry);
    }
  }

  OverlayEntry _createOverlayEntry() {
    RenderBox renderBox = context.findRenderObject();
    var size = renderBox.size;
    var offset = renderBox.localToGlobal(Offset.zero);

    return OverlayEntry(
      builder: (context) => GestureDetector(
        onTapUp: (details) {
          this._overlayEntry.remove();
          this._overlayEntry = null;
        },
        child: Stack(
          children: <Widget>[
            Align(
              alignment: Alignment.center,
              child: Scaffold(
                backgroundColor: Colors.black.withOpacity(0.3),
              ),
            ),
            Positioned(
              top: offset.dy + size.height + 13,
              left: (offset.dx + (size.width / 2)) - 148,
              child: Container(
                padding: EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: SKColors.dark_gray,
                  borderRadius: BorderRadius.circular(5),
                  boxShadow: [UIAssets.boxShadow],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: widget.colors.map(_createColorCard).toList(),
                ),
              ),
            ),
            Positioned(
              top: offset.dy + size.height - 0.5,
              left: (offset.dx + (size.width / 2)) - 9,
              child: CustomPaint(
                painter: _CustomArrowPainter(SKColors.dark_gray),
                child: Container(
                  width: 18,
                  height: 14,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _createColorCard(Color color) => GestureDetector(
        onTapUp: (details) {
          widget.callback(color);
          this._overlayEntry.remove();
          this._overlayEntry = null;
        },
        child: Container(
          width: 36,
          height: 36,
          child: null,
          color: color,
        ),
      );

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapUp: _tappedColorPicker,
      child: Container(
        child: widget.child,
      ),
    );
  }
}

class _CustomArrowPainter extends CustomPainter {
  final Color color;

  _CustomArrowPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    final x_vals = [0.0, size.width / 2, size.width];
    final y_vals = [size.height, 0.0, size.height];

    final point_radius = 4.0;

    var path = Path();
    path.moveTo(x_vals[0], y_vals[0]);
    path.lineTo(x_vals[1] - point_radius, y_vals[1] + point_radius);
    path.arcToPoint(
      Offset(x_vals[1] + point_radius, y_vals[1] + point_radius),
      radius: Radius.circular(point_radius + 0.5),
    );
    path.lineTo(x_vals[2], y_vals[2]);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class SKPickerModal extends StatefulWidget {
  final String title;
  final String subtitle;
  final List<String> items;
  final IntCallback onSelect;

  SKPickerModal({
    @required this.title,
    this.subtitle,
    @required this.items,
    @required this.onSelect,
  });

  @override
  State createState() => _SKPickerModalState();
}

class _SKPickerModalState extends State<SKPickerModal> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    List<Widget> children = [Text(widget.title)];

    if (widget.subtitle != null) {
      children.add(
        Padding(
          padding: EdgeInsets.fromLTRB(24, 4, 24, 0),
          child: Text(
            widget.subtitle,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.normal,
            ),
          ),
        ),
      );
    }

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Container(
        padding: EdgeInsets.only(top: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: SKColors.border_gray),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ...children,
            Container(
              height: 180,
              margin: EdgeInsets.symmetric(horizontal: 24),
              child: CupertinoPicker.builder(
                backgroundColor: Colors.white,
                childCount: widget.items.length,
                itemBuilder: (context, index) => Container(
                  alignment: Alignment.center,
                  child: Text(
                    widget.items[index],
                    style: TextStyle(fontSize: 15, color: SKColors.dark_gray),
                  ),
                ),
                itemExtent: 32,
                onSelectedItemChanged: (index) => this._selectedIndex = index,
              ),
            ),
            Row(
              children: <Widget>[
                Expanded(
                  child: GestureDetector(
                    onTapUp: (details) => Navigator.pop(context, false),
                    child: Container(
                      alignment: Alignment.center,
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: Text(
                        'Cancel',
                        style: TextStyle(
                            color: SKColors.skoller_blue,
                            fontWeight: FontWeight.normal),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTapUp: (details) {
                      Navigator.pop(context, true);
                      widget.onSelect(_selectedIndex);
                    },
                    child: Container(
                      alignment: Alignment.center,
                      padding: EdgeInsets.symmetric(vertical: 12),
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
  }
}

class SKHeaderProfilePhoto extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          image: DecorationImage(
            fit: BoxFit.fill,
            image: SKUser.current.avatarUrl == null
                ? AssetImage(ImageNames.peopleImages.static_profile)
                : NetworkImage(SKUser.current.avatarUrl),
          ),
        ),
        height: 30,
        width: 30,
      );
}

enum SammiPersonality { cool, smile, wow, ooo }
enum SammiSide { left, right }

class SammiSpeechBubble extends StatelessWidget {
  final SammiPersonality sammiPersonality;
  final Widget speechBubbleContents;
  final SammiSide sammiSide;

  SammiSpeechBubble({
    @required this.sammiPersonality,
    @required this.speechBubbleContents,
    this.sammiSide = SammiSide.left,
  });

  @override
  Widget build(BuildContext context) {
    final leftArrow = sammiSide == SammiSide.left;
    final image = _sammiImageBuilder();

    final contents = Align(
      alignment: leftArrow ? Alignment.centerLeft : Alignment.centerRight,
      child: Container(
          margin: leftArrow
              ? EdgeInsets.only(left: 13)
              : EdgeInsets.only(right: 13),
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: SKColors.border_gray),
            boxShadow: [UIAssets.boxShadow],
          ),
          child: speechBubbleContents),
    );

    final arrow = Align(
      alignment: leftArrow ? Alignment.centerLeft : Alignment.centerRight,
      child: CustomPaint(
        painter: _SammiArrowPainter(this.sammiSide),
        child: Container(
          width: 14,
          height: 16,
        ),
      ),
    );

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment:
            leftArrow ? MainAxisAlignment.start : MainAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: leftArrow
            ? [
                image,
                Flexible(
                  flex: 1,
                  fit: FlexFit.tight,
                  child: Padding(
                    padding: EdgeInsets.only(left: 2, top: 6),
                    child: Stack(
                      alignment: Alignment.centerLeft,
                      children: <Widget>[
                        contents,
                        arrow,
                      ],
                    ),
                  ),
                ),
              ]
            : [
                Flexible(
                  flex: 1,
                  fit: FlexFit.tight,
                  child: Padding(
                    padding: EdgeInsets.only(left: 2, top: 6),
                    child: Stack(
                      alignment: Alignment.centerRight,
                      children: <Widget>[
                        contents,
                        arrow,
                      ],
                    ),
                  ),
                ),
                image,
              ],
      ),
    );
  }

  Image _sammiImageBuilder() {
    switch (sammiPersonality) {
      case SammiPersonality.cool:
        return Image.asset(ImageNames.sammiImages.cool);
      case SammiPersonality.smile:
        return Image.asset(ImageNames.sammiImages.smile);
      case SammiPersonality.wow:
        return Image.asset(ImageNames.sammiImages.wow);
      case SammiPersonality.ooo:
        return Image.asset(ImageNames.sammiImages.shocked);
    }
    return null;
  }
}

class _SammiArrowPainter extends CustomPainter {
  final SammiSide side;
  final point_radius = 2.0;

  _SammiArrowPainter(this.side);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    final paint2 = Paint()
      ..color = SKColors.border_gray
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..isAntiAlias = true;

    final x_vals = createXPath(size);
    final y_vals = [
      0.0,
      size.height / 2 - point_radius,
      size.height / 2 + point_radius,
      size.height,
    ];

    var path = Path();
    path.moveTo(x_vals[0], y_vals[0]);
    path.lineTo(x_vals[1], y_vals[1]);
    path.arcToPoint(
      Offset(x_vals[2], y_vals[2]),
      radius: Radius.circular(point_radius + 0.5),
      clockwise: side != SammiSide.left,
    );
    path.lineTo(x_vals[3], y_vals[3]);
    path.close();

    var outline = Path();
    outline.moveTo(x_vals[0], y_vals[0]);
    outline.lineTo(x_vals[1], y_vals[1]);
    outline.arcToPoint(
      Offset(x_vals[2], y_vals[2]),
      radius: Radius.circular(point_radius + 0.5),
      clockwise: side != SammiSide.left,
    );
    outline.lineTo(x_vals[3], y_vals[3]);

    canvas.drawPath(path, paint);
    canvas.drawPath(outline, paint2);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;

  List<double> createXPath(Size size) {
    return side == SammiSide.left
        ? [
            size.width,
            0.0 + point_radius,
            0.0 + point_radius,
            size.width,
          ]
        : [
            0,
            size.width - point_radius,
            size.width - point_radius,
            0,
          ];
  }
}
