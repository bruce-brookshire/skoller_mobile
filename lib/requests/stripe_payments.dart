import 'dart:async';

import 'package:flutter/material.dart';
import 'package:stripe_payment/stripe_payment.dart';

class StripePayments {
  final String stripeSecreteKey = "sk_test_51JV9OSSGLvMTa3qVQGL5oc6UusqzdXaERjWnAOTmcNjK44emrv8dS6WZomBR96RQxzBQQeqoXIIdzbsoNsD0jVs500EG7uso1T";

  Future addSource(CreditCard testCard,BuildContext context) async {
    Completer completer = new Completer();
    StripePayment.setOptions(
        StripeOptions(publishableKey:
        "pk_test_51JV9OSSGLvMTa3qVnwhFxc03IiK5JOGO94YQufQumo21gTgUAdpvMtEGYH9dgH1BPFrrirHuNbiVbE49gPNHHxIU00WpzV3KLP",
          merchantId: "Test", androidPayMode: 'test',));
    StripePayment.createTokenWithCard(
      testCard,
    ).then((token) async {
      debugPrint("token for stripe account >>>> ${token.tokenId}");
      completer.complete(token.tokenId);
    }).catchError((error) => completer.completeError(error));
    return completer.future;
  }

}

