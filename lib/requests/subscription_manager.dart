import 'dart:convert';
import 'dart:developer';

import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:in_app_purchase_storekit/store_kit_wrappers.dart';
import 'package:skoller/requests/requests_core.dart';
import 'package:skoller/screens/main_app/premium/stripe_bloc.dart';

class SubscriptionManager {
  SubscriptionManager._() {
    _setSubscriptions();
    _completePendingTransaction();
    stripeBloc.mySubscriptionsList();
  }

  static final instance = SubscriptionManager._();

  final _inAppPurchase = InAppPurchase.instance;

  Stream<List<PurchaseDetails>> get purchaseStream =>
      InAppPurchase.instance.purchaseStream;

  late PurchaseDetails purchase;

  List<ProductDetails> _subscriptions = [];
  List<ProductDetails> get subscriptions => _subscriptions;

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

  Future<void> _setSubscriptions() async {
    try {
      _subscriptions = await _fetchStoreSubscriptions();
    } catch (error) {
      return;
    }
  }

  Future<void> _completePendingTransaction() async {
    try {
      final paymentWrapper = SKPaymentQueueWrapper();
      final transactions = await paymentWrapper.transactions();
      transactions.forEach((transaction) async {
        await paymentWrapper.finishTransaction(transaction);
      });
    } catch (_) {
      return;
    }
  }

  Future<List<ProductDetails>> _fetchStoreSubscriptions() async {
    try {
      final Set<String> productIds =
          isProd ? {'monthly', 'annual'} : {'monthlyStaging', 'annualStaging2'};

      final response = await _inAppPurchase.queryProductDetails(productIds);

      if (response.notFoundIDs.isNotEmpty) {
        throw 'Failed to load subscriptions.';
      }

      final customList = <ProductDetails>[];

      final subscriptions = response.productDetails;
      final monthly = subscriptions.firstWhere(
          (item) => item.id == 'monthly' || item.id == 'monthlyStaging');
      final annual = subscriptions.firstWhere(
          (item) => item.id == 'annual' || item.id == 'annualStaging2');

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
