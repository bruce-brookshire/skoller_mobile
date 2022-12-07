import 'dart:convert';
import 'dart:developer';

import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:in_app_purchase_storekit/store_kit_wrappers.dart';
import 'package:skoller/requests/requests_core.dart';
import 'package:skoller/screens/main_app/premium/stripe_bloc.dart';

class SubscriptionManager {
  SubscriptionManager._() {
    _init();
    stripeBloc.mySubscriptionsList();
  }

  static final instance = SubscriptionManager._();

  final _inAppPurchase = InAppPurchase.instance;

  late PurchaseDetails purchase;

  final purchaseStream = InAppPurchase.instance.purchaseStream;

  static const Set<String> productIds =
      isProd ? {'monthly', 'annual'} : {'monthlyStaging', 'annualStaging2'};

  List<ProductDetails> _subscriptions = [];
  List<ProductDetails> get subscriptions => _subscriptions;

  Future<void> _init() async {
    try {
      final paymentWrapper = SKPaymentQueueWrapper();
      final transactions = await paymentWrapper.transactions();
      transactions.forEach((transaction) async {
        await paymentWrapper.finishTransaction(transaction);
      });

      _subscriptions = await _fetchStoreSubscriptions();
    } catch (error) {
      return;
    }
  }

  Future<bool> initializePurchase(ProductDetails product) async {
    try {
      final isStoreAvailable = await _isStoreAvailable();

      if (isStoreAvailable) {
        final selectedProduct = _subscriptions
            .firstWhere((element) => product.title == element.title);
        final purchaseParam = PurchaseParam(productDetails: selectedProduct);

        final isPurchasing =
            await _inAppPurchase.buyNonConsumable(purchaseParam: purchaseParam);
        return isPurchasing;
      }

      return false;
    } catch (error) {
      log(error.toString());
      throw 'Failed to initialize subscription. Please try again!';
    }
  }

  Future<void> setSelectedSubscription(PurchaseDetails purchase) async {
    try {
      this.purchase = purchase;

      if (purchase.pendingCompletePurchase) {
        await _inAppPurchase.completePurchase(purchase);
      }
    } catch (error) {
      return;
    }
  }

  Future<bool> finalizePurchase() async {
    try {
      /// Send payment info to the backend
      final purchaseData = purchase.toMap();
      log(jsonEncode(purchaseData));
      final didSucceed =
          await stripeBloc.sendInAppPurchaseToBackend(purchaseData);
      return didSucceed;
    } catch (error) {
      throw error;
    }
  }

  Future<bool> _isStoreAvailable() async {
    try {
      return await _inAppPurchase.isAvailable();
    } catch (error) {
      return false;
    }
  }

  Future<List<ProductDetails>> _fetchStoreSubscriptions() async {
    try {
      final response = await _inAppPurchase.queryProductDetails(productIds);

      if (response.notFoundIDs.isNotEmpty) {
        throw 'Failed to load subscriptions.';
      }

      final customList = <ProductDetails>[];

      final subscriptions = response.productDetails;
      final monthly = subscriptions.firstWhere(
          (item) => item.title == 'monthly' || item.title == 'monthlyStaging');
      final annual = subscriptions.firstWhere(
          (item) => item.title == 'annual' || item.title == 'annualStaging2');

      customList.addAll([monthly, annual]);

      return customList;
    } catch (error) {
      rethrow;
    }
  }
}

extension PurchaseDetailsEncoder on PurchaseDetails {
  Map<String, dynamic> toMap() {
    return {
      'skollerUserId': SKUser.current?.id,
      'purchaseID': this.purchaseID,
      'productID': this.productID,
      'verificationData': this.verificationData.toMap(),
      'transactionDate': this.transactionDate,
      'status': this.status.name,
      'error': this.error,
      'pendingCompletePurchase': this.pendingCompletePurchase,
    };
  }
}

extension PurchaseVerificationDataEncoder on PurchaseVerificationData {
  Map<String, dynamic> toMap() {
    return {
      'localVerificationData': this.localVerificationData,
      'serverVerificationData': this.serverVerificationData,
      'source': this.source,
    };
  }
}
