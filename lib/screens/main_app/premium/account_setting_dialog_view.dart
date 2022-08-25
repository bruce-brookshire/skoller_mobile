import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:skoller/tools.dart';

class AccountSettingsDialogView extends StatelessWidget {
  AccountSettingsDialogView({Key? key}) : super(key: key);

  /// User has an active trial if true.
  final isTrial = Subscriptions.mySubscriptions?.user?.trial ?? false;

  /// User has no active subscription if subscriptionList is empty.
  /// This could mean that the user still has an active trial.
  final subscriptions =
      Subscriptions.mySubscriptions?.user?.subscriptions ?? [];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Center(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Material(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: SKColors.border_gray),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTapUp: (_) => Navigator.pop(context),
                            child: SizedBox(
                              width: 32,
                              height: 24,
                              child:
                                  Image.asset(ImageNames.navArrowImages.down),
                            ),
                          ),
                        ],
                      ),
                      isTrial && subscriptions.isEmpty
                          ? _SubscriptionWidget(
                              title:
                                  'Your free trial expires in ${(Subscriptions.mySubscriptions?.user?.trial ?? false) == false ? '' : Subscriptions.mySubscriptions?.user?.trialDaysLeft?.toStringAsFixed(0)} days',
                              subtitle:
                                  'Trial ends ${DateFormat('MMMM dd, yyyy').format(DateTime.now().add(Duration(days: int.parse(Subscriptions.mySubscriptions?.user?.trialDaysLeft?.toStringAsFixed(0) ?? '0'))))}',
                            )
                          : subscriptions.isEmpty
                              ? _SubscriptionWidget(
                                  title: 'Your free trial has expired!',
                                  subtitle:
                                      'Go to skoller.co on desktop to continue using skoller.',
                                )
                              : _SubscriptionWidget(
                                  title: 'You have a premium account.',
                                  subtitle:
                                      'Go to skoller.co to manage your account.',
                                ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SubscriptionWidget extends StatelessWidget {
  const _SubscriptionWidget({
    Key? key,
    required this.title,
    required this.subtitle,
  }) : super(key: key);

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(5),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Row(
            children: [
              Image.asset(ImageNames.sammiImages.big_smile),
              Flexible(
                child: Container(
                  margin: EdgeInsets.only(left: 10.0),
                  child: Column(
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      Container(
                        alignment: Alignment.center,
                        margin: EdgeInsets.only(
                          left: 10.0,
                          top: 5,
                        ),
                        child: Text(
                          subtitle,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.normal,
                            color: Colors.black,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
