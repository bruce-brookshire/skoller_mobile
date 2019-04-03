part of 'constants.dart';

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

typedef ContextCallback(BuildContext context);

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
  final bool _isBack;
  final bool _isDown;
  final String _rightBtnImage;

  SKNavBar(String title,
      {Key key, bool backBtnEnabled, bool downBtnEnabled, String rightBtnImage})
      : _title = title,
        _isBack = backBtnEnabled ?? false,
        _isDown = downBtnEnabled ?? false,
        _rightBtnImage = rightBtnImage,
        super(key: key) {
    assert(_isBack != _isDown || !_isBack);
  }

  Widget build(BuildContext context) => Container(
        height: 44,
        decoration: BoxDecoration(boxShadow: [
          BoxShadow(
            color: Color(0x1C000000),
            offset: Offset(0, 3.5),
            blurRadius: 3.5,
          )
        ], color: Colors.white),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Container(
              padding: EdgeInsets.only(left: 4),
              child: (_isBack || _isDown)
                  ? Center(
                      child: Text('b'),
                    )
                  : null,
              width: 44,
              height: 44,
            ),
            Text(
              _title,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Container(
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
          ],
        ),
      );
}
