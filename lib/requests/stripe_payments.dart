import 'dart:async';

import 'package:flutter/material.dart';
import 'package:stripe_payment/stripe_payment.dart';

class StripePayments {
  final String stripeSecreteKey =
      "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";

  Future addSource(CreditCard testCard, BuildContext context) async {
    Completer completer = new Completer();
    StripePayment.setOptions(StripeOptions(
      publishableKey:
          "pk_live_51JHvLoGtOURsTxunmypyAUNfbRF4jOahklknp1RTBHhxpy3qEveFU7lCWdrBt4YggE5ytlblCgYYHPPzsLC0Gf8K00NC7FWyoh",
      merchantId: "merchant.com.erchant.co.skoller.skoller-staging",
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
