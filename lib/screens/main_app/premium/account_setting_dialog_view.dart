import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:intl/intl.dart';
import 'package:ios_open_subscriptions_settings/ios_open_subscriptions_settings.dart';
import 'package:skoller/constants/BaseUtilities.dart';
import 'package:skoller/model/my_subscriptions.dart';
import 'package:skoller/requests/subscription_manager.dart';
import 'package:skoller/screens/main_app/main_view.dart';
import 'package:skoller/screens/main_app/premium/components/subscription_data_widget.dart';
import 'package:skoller/screens/main_app/premium/components/subscription_purchase_status_stream.dart';
import 'package:skoller/screens/main_app/premium/components/subscriptions_data_list.dart';
import 'package:skoller/screens/main_app/premium/stripe_bloc.dart';
import 'package:skoller/tools.dart';

class AccountSettingsDialogView extends StatefulWidget {
  AccountSettingsDialogView({Key? key}) : super(key: key);

  @override
  State<AccountSettingsDialogView> createState() =>
      _AccountSettingsDialogViewState();
}

class _AccountSettingsDialogViewState extends State<AccountSettingsDialogView> {
  ProductDetails? selectedSubscription;

  bool showCloseIcon = true;
  bool showPurchaseStatus = false;
  bool isRestoring = false;

  Future<void> initializePurchase() async {
    await SubscriptionManager.instance
        .initializePurchase(selectedSubscription!)
        .then((isPurchasing) async {
      if (isPurchasing) {
        setState(() {
          showPurchaseStatus = isPurchasing;
          showCloseIcon = false;
        });
      }
    }).catchError((error) {
      Utilities.showErrorMessage(error.toString());
    });
  }

  Future<void> finalizePurchase() async {
    await SubscriptionManager.instance.finalizePurchase().then((didSucceed) {
      if (didSucceed) {
        stripeBloc.mySubscriptionsList();
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => MainView()),
          (route) => false,
        );
      }
    }).catchError((error) {
      Utilities.showErrorMessage(error.toString());
    });
  }

  Future<void> restoreSubscription() async {
    setState(() {
      selectedSubscription == null;
      showCloseIcon = false;
      isRestoring = true;
    });

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
        setState(() {
          showCloseIcon = true;
          isRestoring = false;
        });
      }
    }).catchError((error) {
      Utilities.showErrorMessage(
        'Failed to restore subscription.',
      );

      setState(() {
        showCloseIcon = true;
        isRestoring = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    if (Subscriptions.isSubscriptionActive &&
        (Subscriptions.subscriptionPlatform == SubscriptionPlatform.ios ||
            Subscriptions.subscriptionPlatform == SubscriptionPlatform.play)) {
      return Center(
        child: Container(
          padding: EdgeInsets.all(10),
          margin: EdgeInsets.all(20),
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: SKColors.border_gray),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
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
                      child: Image.asset(ImageNames.navArrowImages.down),
                    ),
                  ),
                ],
              ),
              Text(
                'You are a Premium user',
                style: Theme.of(context)
                    .textTheme
                    .headline6
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Text(
                'Current subscription: ${Subscriptions.mySubscriptions?.user?.subscription?.interval}',
                style: Theme.of(context)
                    .textTheme
                    .bodyText1
                    ?.copyWith(fontWeight: FontWeight.normal),
              ),
              SizedBox(height: 20),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 40),
                child: OutlinedButton(
                  child: Text('Manage subscription'),
                  style: OutlinedButton.styleFrom(
                    primary: SKColors.skoller_blue1,
                    minimumSize: Size(double.infinity, 36),
                    side: BorderSide(color: SKColors.skoller_blue1),
                    textStyle: Theme.of(context)
                        .textTheme
                        .button
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  onPressed:
                      IosOpenSubscriptionsSettings.openSubscriptionsSettings,
                ),
              ),
              SizedBox(height: 10),
            ],
          ),
        ),
      );
    }

    if (Subscriptions.isSubscriptionActive &&
        Subscriptions.subscriptionPlatform == SubscriptionPlatform.stripe) {
      return Center(
        child: Container(
          padding: EdgeInsets.all(10),
          margin: EdgeInsets.all(20),
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: SKColors.border_gray),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
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
                      child: Image.asset(ImageNames.navArrowImages.down),
                    ),
                  ),
                ],
              ),
              Text(
                'You are a Premium user',
                style: Theme.of(context)
                    .textTheme
                    .headline6
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Text(
                'Login on desktop at Skoller.co to\nmanage your account setting.',
                textAlign: TextAlign.center,
                style: Theme.of(context)
                    .textTheme
                    .bodyText1
                    ?.copyWith(fontWeight: FontWeight.normal),
              ),
              SizedBox(height: 10),
            ],
          ),
        ),
      );
    }

    /// If user has no subscription or is on trial
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
                      if (showCloseIcon)
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
                      SubscriptionDataWidget(
                        title:
                            'Your free trial expires in ${Subscriptions.isTrial == false ? '' : Subscriptions.trialDaysLeft.toStringAsFixed(0)} days',
                        subtitle:
                            'Trial ends ${DateFormat('MMMM dd, yyyy').format(DateTime.now().add(Duration(days: int.parse(Subscriptions.trialDaysLeft.toStringAsFixed(0)))))}',
                      ),
                      SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: Divider(
                              height: 0,
                              thickness: 1,
                              color: Colors.black,
                            ),
                          ),
                          SizedBox(width: 8),
                          Text(
                            isRestoring
                                ? 'Restoring'
                                : showPurchaseStatus
                                    ? 'Purchasing'
                                    : 'Select a Plan',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          SizedBox(width: 8),
                          Expanded(
                            child: Divider(
                              height: 0,
                              thickness: 1,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 16),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: SKColors.border_gray),
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: UIAssets.boxShadow,
                        ),
                        child: isRestoring
                            ? Padding(
                                padding: EdgeInsets.all(20),
                                child: CircularProgressIndicator.adaptive())
                            : showPurchaseStatus
                                ? SubscriptionPurchaseStatusStream(
                                    isSubscriptionSelected:
                                        selectedSubscription == null,
                                    completePurchase: () async =>
                                        await finalizePurchase(),
                                    restartPurchase: () {
                                      setState(() {
                                        showPurchaseStatus = false;
                                        showCloseIcon = true;
                                      });
                                    },
                                  )
                                : SubscriptionsDataList(
                                    isSubscriptionSelected:
                                        selectedSubscription == null,
                                    selectedSubscriptionId:
                                        selectedSubscription?.id,
                                    onSubscriptionSelection: (subscription) {
                                      setState(() {
                                        selectedSubscription = subscription;
                                      });
                                    },
                                    buttonOnPress: selectedSubscription == null
                                        ? null
                                        : () => initializePurchase(),
                                    restoreOnPress: () async {
                                      await restoreSubscription();
                                    },
                                  ),
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
