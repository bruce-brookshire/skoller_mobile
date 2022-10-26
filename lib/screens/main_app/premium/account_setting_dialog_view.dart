import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:intl/intl.dart';
import 'package:skoller/requests/subscription_manager.dart';
import 'package:skoller/tools.dart';

class AccountSettingsDialogView extends StatefulWidget {
  AccountSettingsDialogView({Key? key}) : super(key: key);

  @override
  State<AccountSettingsDialogView> createState() =>
      _AccountSettingsDialogViewState();
}

class _AccountSettingsDialogViewState extends State<AccountSettingsDialogView> {
  ProductDetails? selectedSubscription;

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
                            'Select a Plan',
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
                        child: ListView.separated(
                          shrinkWrap: true,
                          itemCount:
                              SubscriptionManager.instance.subscriptions.length,
                          separatorBuilder: (context, index) =>
                              Divider(height: 0),
                          itemBuilder: (context, index) {
                            final product = SubscriptionManager
                                .instance.subscriptions[index];
                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  selectedSubscription = product;
                                });
                              },
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 8),
                                decoration: BoxDecoration(
                                  color: selectedSubscription?.id == product.id
                                      ? SKColors.menu_blue
                                      : null,
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      '${product.price} ${product.title.toLowerCase()}',
                                      style: TextStyle(
                                          fontSize: 14,
                                          color: SKColors.light_gray),
                                    ),
                                    Text(
                                      product.description == 'null'
                                          ? ''
                                          : product.description,
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
                      ),
                      SizedBox(height: 16),
                      ElevatedButton(
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all(
                            selectedSubscription == null
                                ? null
                                : SKColors.dark_gray,
                          ),
                        ),
                        child: Text('Upgrade'),
                        onPressed: () {},
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
