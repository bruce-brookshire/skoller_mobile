import 'dart:async';

import 'package:flutter/material.dart';
import 'package:stripe_payment/stripe_payment.dart';

class StripePayments {
  final String stripeSecreteKey =
      "sk_test_51JHvLoGtOURsTxun9zAvF8xXT9LBVHtV58UggeaE3HwoKVy4UCEEw9g8rI41LH0EKH3EizCLJwjP6rMjUicVXhlW00WnQo5cAq";

  Future addSource(CreditCard testCard, BuildContext context) async {
    Completer completer = new Completer();
    StripePayment.setOptions(StripeOptions(
      publishableKey:
          "pk_test_51JHvLoGtOURsTxunH2YZl8bG4pvpTQUKRoTVXjqEtZUFR8SsgUIMps4qGBl9OrPYiAGEy8dlAiRATkrRnRUiHMMa00xYgr7qtu",
      merchantId: "merchant.erchant.co.skoller.skoller-staging",
      androidPayMode: 'test',
    ));
    StripePayment.createTokenWithCard(
      testCard,
    ).then((token) async {
      debugPrint("token for stripe account >>>> ${token.tokenId}");
      completer.complete(token.tokenId);
    }).catchError((error) => completer.completeError(error));
    return completer.future;
  }
}
