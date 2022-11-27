import 'dart:convert';
import 'dart:developer';

import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:skoller/requests/requests_core.dart';
import 'package:skoller/screens/main_app/premium/stripe_bloc.dart';

class SubscriptionManager {
  SubscriptionManager._();
  static final instance = SubscriptionManager._();

  final _inAppPurchase = InAppPurchase.instance;

  late PurchaseDetails purchase;

  final purchaseStream = InAppPurchase.instance.purchaseStream;

  static const Set<String> productIds =
      isProd ? {'monthly', 'annual'} : {'monthlyStaging', 'annualStaging2'};

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

        final isPurchasing =
            await _inAppPurchase.buyNonConsumable(purchaseParam: purchaseParam);
        return isPurchasing;
      }
      return false;
    } catch (error) {
      log(error.toString());
      throw 'Failed to initialize subscription';
    }
  }

  Future<void> processPurchase(PurchaseDetails purchase) async {
    try {
      final isPurchased = purchase.status == PurchaseStatus.purchased;
      final isRestored = purchase.status == PurchaseStatus.restored;
      if (isPurchased || isRestored) {
        final bool valid = await _verifyPurchase(purchase);
        if (valid) {
          // deliverProduct(purchaseDetails);
        } else {
          // _handleInvalidPurchase(purchaseDetails);
          return;
        }

        log(purchase.toString());
        await _inAppPurchase.completePurchase(purchase);
        this.purchase = purchase;
      }
    } catch (error) {
      return;
    }
  }

  Future<bool> finalizePurchase() async {
    try {
      /// Send payment info to the backend
      final test = purchase;
      final purchaseData = purchase.toMap();
      // log(purchaseData.toString());
      log(jsonEncode(purchaseData));
      // print(jsonEncode(purchaseData));
      final didSucceed =
          await stripeBloc.sendInAppPurchaseToBackend(purchaseData);
      return didSucceed;
    } catch (error) {
      throw error;
    }
  }

  Future<bool> _verifyPurchase(PurchaseDetails purchaseDetails) {
    // IMPORTANT!! Always verify a purchase before delivering the product.
    // For the purpose of an example, we directly return true.
    return Future<bool>.value(true);
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
      if (response.notFoundIDs.isNotEmpty) throw 'Failed to load products';

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
      // 'verificationData': this.verificationData,
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
