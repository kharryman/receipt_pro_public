import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:receipt_pro/main.dart';
import 'package:receipt_pro/services/helpers.dart';

String subscribeProductId = "subscribe";
String priceSubscribe = "\$3.99";
StreamSubscription<List<PurchaseDetails>>? purchaseSubscription;
bool isSubscribed = false;

class BillingService {
  Future<void> initializeInAppPurchase(BuildContext context) async {
    final InAppPurchase iap = InAppPurchase.instance;
    final bool isAvailable = await iap.isAvailable();

    if (isAvailable) {
      if (purchaseSubscription != null) {
        await purchaseSubscription!.cancel();
      }

      purchaseSubscription = iap.purchaseStream.listen(
        (List<PurchaseDetails> purchases) async {
          PurchaseDetails? purchaseSubscription =
              purchases.isNotEmpty
                  ? purchases.firstWhere(
                    (purchase) => purchase.productID == subscribeProductId,
                  )
                  : null;

          if (purchaseSubscription != null) {
            if (purchaseSubscription.status == PurchaseStatus.purchased ||
                purchaseSubscription.status == PurchaseStatus.restored) {
              print(
                "main initializeInAppPurchase $subscribeProductId ${purchaseSubscription.status == PurchaseStatus.purchased ? "PURCHASED" : "RESTORED"}!",
              );
              isSubscribed = true;
              if (purchaseSubscription.pendingCompletePurchase) {
                print("Completing purchase...");
                //await MenuState().showSuccessThanksBuy();
                await InAppPurchase.instance.completePurchase(
                  purchaseSubscription,
                );
              }
            } else if (purchaseSubscription.status == PurchaseStatus.pending) {
              print(
                "IAP.listen purchaseRemoveAds.status == PurchaseStatus.pending ...",
              );
              //await InAppPurchase.instance.completePurchase(purchaseRemoveAds);
              //await MenuState().showSuccessThanksBuy();
            } else if (purchaseSubscription.status == PurchaseStatus.error) {
              // Handle failed purchase
              print(
                "main initializeInAppPurchase $subscribeProductId Purchase error: ${purchaseSubscription.error}.",
              );
              //if (mounted) {
              //  WidgetsBinding.instance.addPostFrameCallback((_) {
              await showPopup(
                context,
                "${FlutterI18n.translate(context, "PROMPT_PURCHASING_ERROR")}: ${purchaseSubscription.error}",
              );
              // });
              //}
            }
          }
        },
        onError: (error) {
          print("Purchase Error: $error");
        },
        onDone: () {
          purchaseSubscription?.cancel(); // Clean up after use
        },
        cancelOnError: true,
      );
      await restorePurchases();
    }
  }

  Future<void> restorePurchases() async {
    print("restorePurchases called");
    if (kIsWeb == true) {
      //MyHomeState().showPopup(context, "CAN'T RESTORE ADS ON WEB!");
      print("Cant restore purchases on web-app.");
    } else {
      //setState(() {
      //  isRestoring = true;
      //});
      final InAppPurchase iapInstance = InAppPurchase.instance;
      bool isAvailable = await iapInstance.isAvailable();
      if (isAvailable) {
        // Fetch past purchases
        try {
          await iapInstance.restorePurchases();
        } catch (e) {
          print("Failed to restore purchases");
          return;
        }
      }
    }
  }
}
