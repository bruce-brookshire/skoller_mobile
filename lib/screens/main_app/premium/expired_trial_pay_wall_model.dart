import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:skoller/constants/BaseUtilities.dart';
import 'package:skoller/constants/constants.dart';
import 'package:skoller/requests/subscription_manager.dart';
import 'package:skoller/screens/main_app/main_view.dart';
import 'package:skoller/screens/main_app/premium/components/subscription_data_widget.dart';
import 'package:skoller/screens/main_app/premium/components/subscription_purchase_status_stream.dart';
import 'package:skoller/screens/main_app/premium/components/subscriptions_data_list.dart';
import 'package:skoller/screens/main_app/premium/stripe_bloc.dart';

class ExpiredTrialPayWallModal extends StatefulWidget {
  const ExpiredTrialPayWallModal({Key? key}) : super(key: key);

  @override
  State<ExpiredTrialPayWallModal> createState() =>
      _ExpiredTrialPayWallModalState();
}

class _ExpiredTrialPayWallModalState extends State<ExpiredTrialPayWallModal> {
  ProductDetails? selectedSubscription;

  bool showPurchaseStatus = false;
  bool isRestoring = false;

  Future<void> initializePurchase() async {
    await SubscriptionManager.instance
        .initializePurchase(selectedSubscription!)
        .then((isPurchasing) async {
      if (isPurchasing) {
        setState(() {
          showPurchaseStatus = isPurchasing;
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
      isRestoring = true;
    });

    await SubscriptionManager.instance
        .restorePurchase()
        .then((didRestore) async {
      if (didRestore) {
        await stripeBloc.mySubscriptionsList();
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
          isRestoring = false;
        });
      }
    }).catchError((error) {
      Utilities.showErrorMessage(
        'Failed to restore subscription.',
      );

      setState(() {
        isRestoring = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: <Widget>[
        Positioned.fill(
          child: Container(
            color: Colors.black.withOpacity(0.65),
          ),
        ),
        SafeArea(
          child: Container(
            margin: const EdgeInsets.all(20),
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: SKColors.border_gray),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Material(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SubscriptionDataWidget(
                    title: 'Your free trial has expired!',
                    subtitle:
                        'Upgrade to premium for Skoller’s syllabus setup service and unlimited access to the platform.',
                  ),
                  const SizedBox(height: 30),
                  Row(
                    children: [
                      Expanded(
                        child: Divider(
                          height: 0,
                          thickness: 1,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(width: 8),
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
                      const SizedBox(width: 8),
                      Expanded(
                        child: Divider(
                          height: 0,
                          thickness: 1,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: SKColors.border_gray),
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: UIAssets.boxShadow,
                    ),
                    child: isRestoring
                        ? Center(
                            child: const Padding(
                                padding: EdgeInsets.all(20),
                                child: CircularProgressIndicator.adaptive()),
                          )
                        : showPurchaseStatus
                            ? SubscriptionPurchaseStatusStream(
                                isSubscriptionSelected:
                                    selectedSubscription == null,
                                completePurchase: () async =>
                                    await finalizePurchase(),
                                restartPurchase: () {
                                  setState(() {
                                    showPurchaseStatus = false;
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
      ],
    );
  }
}
