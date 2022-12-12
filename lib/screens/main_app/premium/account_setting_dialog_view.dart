import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:intl/intl.dart';
import 'package:skoller/constants/BaseUtilities.dart';
import 'package:skoller/model/my_subscriptions.dart';
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

  bool showCloseIcon = true;
  bool showPurchaseStatus = false;

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
                  onPressed: () {},
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
                      _SubscriptionWidget(
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
                                completePurchase: () async =>
                                    await finalizePurchase(),
                                restartPurchase: () {
                                  setState(() {
                                    showPurchaseStatus = false;
                                    showCloseIcon = true;
                                  });
                                },
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

class _SubscriptionPurchaseStatusStream extends StatefulWidget {
  const _SubscriptionPurchaseStatusStream({
    Key? key,
    required this.isSubscriptionSelected,
    required this.completePurchase,
    required this.restartPurchase,
  }) : super(key: key);
  final bool isSubscriptionSelected;
  final Function() completePurchase;
  final Function() restartPurchase;

  @override
  State<_SubscriptionPurchaseStatusStream> createState() =>
      _SubscriptionPurchaseStatusStreamState();
}

class _SubscriptionPurchaseStatusStreamState
    extends State<_SubscriptionPurchaseStatusStream> {
  PurchaseStatus purchaseStatus = PurchaseStatus.pending;

  Widget trailingIcon(PurchaseStatus status) {
    switch (status) {
      case PurchaseStatus.pending:
        return CircularProgressIndicator.adaptive();
      case PurchaseStatus.purchased:
        return Icon(Icons.check_circle_outline_outlined);
      case PurchaseStatus.error:
        return Icon(Icons.close_outlined);
      case PurchaseStatus.restored:
        return Icon(Icons.check_circle_outline_outlined);
      case PurchaseStatus.canceled:
        return Icon(Icons.close_outlined);
    }
  }

  Widget button(PurchaseStatus status) {
    String buttonTitle() {
      switch (status) {
        case PurchaseStatus.purchased:
          return 'Complete';
        case PurchaseStatus.restored:
          return 'Complete';
        case PurchaseStatus.canceled:
          return 'Restart purchase';
        case PurchaseStatus.pending:
          return 'Processing...';
        default:
          return 'Done';
      }
    }

    Function()? buttonOnPress() {
      switch (status) {
        case PurchaseStatus.purchased:
          return () async => await widget.completePurchase();
        case PurchaseStatus.restored:
          return () {};
        case PurchaseStatus.canceled:
          return () async => await widget.restartPurchase();
        case PurchaseStatus.pending:
          return null;
        default:
          return null;
      }
    }

    return ElevatedButton(
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.all(
          widget.isSubscriptionSelected ? null : SKColors.dark_gray,
        ),
      ),
      child: Text(
        buttonTitle(),
        style: TextStyle(
          color: widget.isSubscriptionSelected ? null : Colors.white,
        ),
      ),
      onPressed: buttonOnPress(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<PurchaseDetails>>(
      stream: SubscriptionManager.instance.purchaseStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (snapshot.hasData) {
          final data = snapshot.data!;
          final purchase = data[0];
          SubscriptionManager.instance.setSelectedSubscription(purchase);

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ListTile(
                title: Text(
                  purchase.productID.replaceFirst(
                    purchase.productID[0],
                    purchase.productID[0].toUpperCase(),
                  ),
                ),
                subtitle: Text(
                  purchase.status.name.replaceFirst(
                    purchase.status.name[0],
                    purchase.status.name[0].toUpperCase(),
                  ),
                ),
                trailing: trailingIcon(purchase.status),
              ),
              button(purchase.status),
            ],
          );
        }

        return Text('Something went wrong');
      },
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
