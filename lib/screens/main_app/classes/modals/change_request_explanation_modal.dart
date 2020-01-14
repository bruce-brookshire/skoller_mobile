import 'package:flutter/material.dart';
import 'package:skoller/tools.dart';

class ChangeRequestExplanationModal extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(5),
          side: BorderSide(color: SKColors.border_gray),
        ),
        child: Padding(
          padding: EdgeInsets.fromLTRB(16, 16, 16, 0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Text(
                'Change Requests',
                style: TextStyle(fontSize: 17),
                textAlign: TextAlign.center,
              ),
              Padding(
                padding: EdgeInsets.symmetric(vertical: 4),
                child: Text(
                  'Skoller HQ is currently reviewing these changes. Keeping the Skoller community accurate and safe is a priority for us!',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontWeight: FontWeight.normal, fontSize: 14),
                ),
              ),
              GestureDetector(
                onTapUp: (_) => Navigator.pop(context),
                behavior: HitTestBehavior.opaque,
                child: Container(
                  alignment: Alignment.center,
                  padding: EdgeInsets.only(top: 6, bottom: 12),
                  child: Text(
                    'Dismiss',
                    style: TextStyle(color: SKColors.skoller_blue),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
}
