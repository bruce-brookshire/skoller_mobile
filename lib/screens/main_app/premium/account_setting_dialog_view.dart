import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:intl/intl.dart';
import 'package:skoller/constants/BaseUtilities.dart';
import 'package:skoller/requests/subscription_manager.dart';
import 'package:skoller/screens/main_app/main_view.dart';
import 'package:skoller/tools.dart';

class AccountSettingsDialogView extends StatefulWidget {
  AccountSettingsDialogView({Key? key}) : super(key: key);

  @override
  State<AccountSettingsDialogView> createState() =>
      _AccountSettingsDialogViewState();
}

class _AccountSettingsDialogViewState extends State<AccountSettingsDialogView> {
  ProductDetails? selectedSubscription;

  bool showPurchaseStatus = false;

  /// User has an active trial if true.
  final isTrial = Subscriptions.mySubscriptions?.user?.trial ?? false;

  /// User has no active subscription if subscriptionList is empty.
  /// This could mean that the user still has an active trial.
  final subscriptions =
      Subscriptions.mySubscriptions?.user?.subscriptions ?? [];

  Future<void> initializePurchase() async {
    SubscriptionManager.instance
        .initializePurchase(selectedSubscription!)
        .then((isPurchasing) {
      if (isPurchasing) {
        setState(() {
          showPurchaseStatus = isPurchasing;
        });
      }
    }).catchError((error) {
      Utilities.showErrorMessage(error.toString());
    });
  }

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
                                  subtitle: 'Upgrade to premium',
                                )
                              : _SubscriptionWidget(
                                  title: 'You have a premium account.',
                                  subtitle:
                                      'Go to skoller.co to manage your account.',
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
                            showPurchaseStatus ? 'Purchasing' : 'Select a Plan',
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
                        child: showPurchaseStatus
                            ? _SubscriptionPurchaseStatusStream(
                                isSubscriptionSelected:
                                    selectedSubscription == null,
                              )
                            : _SubscriptionsList(
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

class _SubscriptionsList extends StatelessWidget {
  const _SubscriptionsList({
    Key? key,
    required this.onSubscriptionSelection,
    required this.selectedSubscriptionId,
    required this.isSubscriptionSelected,
    required this.buttonOnPress,
  }) : super(key: key);

  final Function(ProductDetails) onSubscriptionSelection;
  final String? selectedSubscriptionId;
  final bool isSubscriptionSelected;
  final Function()? buttonOnPress;

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ListView.separated(
            shrinkWrap: true,
            itemCount: SubscriptionManager.instance.subscriptions.length,
            separatorBuilder: (context, index) => Divider(height: 0),
            itemBuilder: (context, index) {
              final subscription =
                  SubscriptionManager.instance.subscriptions[index];
              return GestureDetector(
                onTap: () => onSubscriptionSelection(subscription),
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: selectedSubscriptionId == subscription.id
                        ? SKColors.menu_blue
                        : null,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${subscription.price} ${subscription.title.toLowerCase()}',
                        style:
                            TextStyle(fontSize: 14, color: SKColors.light_gray),
                      ),
                      Text(
                        subscription.description == 'null'
                            ? ''
                            : subscription.description,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w400,
                          color: SKColors.light_gray,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          SizedBox(height: 16),
          ElevatedButton(
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all(
                isSubscriptionSelected ? null : SKColors.dark_gray,
              ),
            ),
            child: Text(
              'Upgrade',
              style: TextStyle(
                  color: isSubscriptionSelected ? null : Colors.white),
            ),
            onPressed: buttonOnPress,
          ),
        ],
      ),
    );
  }
}

class _SubscriptionPurchaseStatusStream extends StatelessWidget {
  const _SubscriptionPurchaseStatusStream({
    Key? key,
    required this.isSubscriptionSelected,
  }) : super(key: key);
  final bool isSubscriptionSelected;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(height: 16),
        StreamBuilder<List<PurchaseDetails>>(
          stream: SubscriptionManager.instance.purchaseStream,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              final data = snapshot.data!;

              return ListView.builder(
                shrinkWrap: true,
                itemCount: data.length,
                itemBuilder: (context, index) {
                  final purchase = data[index];
                  SubscriptionManager.instance.processPurchase(purchase);

                  return ListTile(
                    title: Text(purchase.productID),
                    subtitle: Text(purchase.status.toString()),
                  );
                },
              );
            }

            return Text('Something went wrong');
          },
        ),
        SizedBox(height: 16),
        ElevatedButton(
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all(
              isSubscriptionSelected ? null : SKColors.dark_gray,
            ),
          ),
          child: Text(
            'Complete',
            style:
                TextStyle(color: isSubscriptionSelected ? null : Colors.white),
          ),
          onPressed: () async {
            await SubscriptionManager.instance
                .finalizePurchase()
                .then((didSucceed) {
              if (didSucceed) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => MainView()),
                  (route) => false,
                );
              }
            }).catchError((error) {
              Utilities.showErrorMessage(error.toString());
            });
          },
        ),
      ],
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
