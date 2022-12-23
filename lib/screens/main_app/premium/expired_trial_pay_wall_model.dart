import 'package:flutter/material.dart';
import 'package:skoller/constants/BaseUtilities.dart';
import 'package:skoller/constants/constants.dart';
import 'package:skoller/requests/subscription_manager.dart';
import 'package:skoller/screens/main_app/main_view.dart';
import 'package:skoller/screens/main_app/premium/stripe_bloc.dart';

class ExpiredTrialPayWallModal extends StatelessWidget {
  const ExpiredTrialPayWallModal({Key? key}) : super(key: key);

  Future<void> restoreSubscription(BuildContext context) async {
    await SubscriptionManager.instance.restorePurchase().then((didRestore) {
      if (didRestore) {
        stripeBloc.mySubscriptionsList();
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) => MainView(),
          ),
          (route) => false,
        );
      } else {
        Utilities.showErrorMessage(
          'Failed to restore subscription.',
        );
      }
    }).catchError((error) {
      Utilities.showErrorMessage(
        'Failed to restore subscription.',
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Stack(
        children: <Widget>[
          Positioned.fill(
            child: Container(
              color: Colors.black.withOpacity(0.65),
            ),
          ),
          Container(
            alignment: Alignment.center,
            padding: EdgeInsets.fromLTRB(24, 0, 24, 64),
            child: Material(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
                side: BorderSide(color: SKColors.border_gray),
              ),
              color: SKColors.background_gray,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 48),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Your 7-day free trial has expired.',
                      style: TextStyle(fontSize: 16),
                    ),
                    SizedBox(height: 20),
                    Text(
                      'Go to skoller.co on desktop and\nlogin to continue using Skoller.',
                      style: TextStyle(
                        fontWeight: FontWeight.normal,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    TextButton(
                      child: Text(
                        'Already subscribed? Restore!',
                        style: Theme.of(context)
                            .textTheme
                            .caption
                            ?.copyWith(color: SKColors.skoller_blue1),
                      ),
                      onPressed: () async => await restoreSubscription(context),
                    ),
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
