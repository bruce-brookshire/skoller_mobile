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
