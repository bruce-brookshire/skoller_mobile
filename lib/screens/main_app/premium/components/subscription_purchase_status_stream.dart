import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:skoller/constants/constants.dart';
import 'package:skoller/requests/subscription_manager.dart';

class SubscriptionPurchaseStatusStream extends StatefulWidget {
  const SubscriptionPurchaseStatusStream({
    Key? key,
    required this.isSubscriptionSelected,
    required this.completePurchase,
    required this.restartPurchase,
  }) : super(key: key);
  final bool isSubscriptionSelected;
  final Function() completePurchase;
  final Function() restartPurchase;

  @override
  State<SubscriptionPurchaseStatusStream> createState() =>
      _SubscriptionPurchaseStatusStreamState();
}

class _SubscriptionPurchaseStatusStreamState
    extends State<SubscriptionPurchaseStatusStream> {
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
