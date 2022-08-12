import 'dart:async';

import 'package:flutter_stripe/flutter_stripe.dart';

class StripePayments {
  final publishableKey =
      "pk_live_51JHvLoGtOURsTxunmypyAUNfbRF4jOahklknp1RTBHhxpy3qEveFU7lCWdrBt4YggE5ytlblCgYYHPPzsLC0Gf8K00NC7FWyoh";
  // "pk_test_51JHvLoGtOURsTxunH2YZl8bG4pvpTQUKRoTVXjqEtZUFR8SsgUIMps4qGBl9OrPYiAGEy8dlAiRATkrRnRUiHMMa00xYgr7qtu";
  final merchantId = "merchant.erchant.co.skoller.skoller-staging";

  Future payWithCard(CardDetails cardDetails) async {
    try {
      Stripe.publishableKey = publishableKey;
      Stripe.merchantIdentifier = merchantId;
      await Stripe.instance.dangerouslyUpdateCardDetails(cardDetails);

      final cardTokenParams = CardTokenParams();
      final tokenParams = CreateTokenParams.card(params: cardTokenParams);
      final token = await Stripe.instance.createToken(tokenParams);
      return token.id;
    } on StripeException catch (error) {
      throw error.error.message ?? 'Couldn\'t process payment';
    } catch (error) {
      throw 'Something went wrong';
    }
  }
}
