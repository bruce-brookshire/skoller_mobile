import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:skoller/constants/constants.dart';
import 'package:skoller/requests/subscription_manager.dart';

class SubscriptionsDataList extends StatelessWidget {
  const SubscriptionsDataList({
    Key? key,
    required this.onSubscriptionSelection,
    required this.selectedSubscriptionId,
    required this.isSubscriptionSelected,
    required this.buttonOnPress,
    required this.restoreOnPress,
  }) : super(key: key);

  final Function(ProductDetails) onSubscriptionSelection;
  final String? selectedSubscriptionId;
  final bool isSubscriptionSelected;
  final Function()? buttonOnPress;
  final Function() restoreOnPress;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ListView.separated(
          shrinkWrap: true,
          itemCount: SubscriptionManager.instance.subscriptions.length,
          physics: NeverScrollableScrollPhysics(),
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
        const SizedBox(height: 16),
        ElevatedButton(
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all(
              isSubscriptionSelected ? null : SKColors.dark_gray,
            ),
          ),
          child: Text(
            'Upgrade',
            style:
                TextStyle(color: isSubscriptionSelected ? null : Colors.white),
          ),
          onPressed: buttonOnPress,
        ),
        TextButton(
          child: Text(
            'Already subscribed? Restore!',
            style: Theme.of(context)
                .textTheme
                .caption
                ?.copyWith(color: SKColors.skoller_blue1),
          ),
          onPressed: restoreOnPress,
        ),
      ],
    );
  }
}
