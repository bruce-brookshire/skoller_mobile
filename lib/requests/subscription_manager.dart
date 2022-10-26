import 'dart:developer';

import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:skoller/requests/requests_core.dart';

class SubscriptionManager {
  SubscriptionManager._();
  static final instance = SubscriptionManager._();

  final _inAppPurchase = InAppPurchase.instance;

  final purchaseStream = InAppPurchase.instance.purchaseStream;

  static const Set<String> productIds = isProd
      ? {'monthly', 'annual', 'lifetime'}
      : {'monthlyStaging', 'annualStaging2', 'lifetimeStaging'};

  List<ProductDetails> _subscriptions = [];
  List<ProductDetails> get subscriptions => _subscriptions;

  Future<void> init() async {
    try {
      _subscriptions = await fetchStoreSubscriptions();
    } catch (error) {
      return;
    }
  }

  Future<bool> initializePurchase(ProductDetails product) async {
    try {
      final isAvailable = await isStoreAvailable();

      if (isAvailable) {
        final selectedProduct = _subscriptions
            .firstWhere((element) => product.title == element.title);
        final purchaseParam = PurchaseParam(productDetails: selectedProduct);

        final didPurchase =
            await _inAppPurchase.buyNonConsumable(purchaseParam: purchaseParam);
        return didPurchase;
      }
      return false;
    } catch (error) {
      log(error.toString());
      throw 'Failed to load subscription';
    }
  }

  Future<void> completePurchase(PurchaseDetails purchaseDetails) async {
    try {
      await _inAppPurchase.completePurchase(purchaseDetails);
    } catch (error) {
      return;
    }
  }

  Future<bool> isStoreAvailable() async {
    try {
      return await _inAppPurchase.isAvailable();
    } catch (error) {
      return false;
    }
  }

  Future<List<ProductDetails>> fetchStoreSubscriptions() async {
    try {
      final response = await _inAppPurchase.queryProductDetails(productIds);
      final customList = <ProductDetails>[];

      if (response.notFoundIDs.isEmpty) {
        final subscriptions = response.productDetails;
        final monthly = subscriptions.firstWhere((item) =>
            item.title == 'monthly' || item.title == 'monthlyStaging');
        customList.add(monthly);
        final annual = subscriptions.firstWhere(
            (item) => item.title == 'annual' || item.title == 'annualStaging2');
        customList.add(annual);
        final lifetime = subscriptions.firstWhere((item) =>
            item.title == 'lifetime' || item.title == 'lifetimeStaging');
        customList.add(lifetime);
      } else {
        throw 'Failed to load products';
      }
      return customList;
    } catch (error) {
      rethrow;
    }
  }
}
