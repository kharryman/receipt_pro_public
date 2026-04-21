import 'package:flutter/material.dart';
import 'billing_service.dart';

class PurchasePage extends StatelessWidget {
  final billing = BillingService();

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () async {
        final success = true;
        //final success = await billing.purchasePremium();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(success ? "Purchased!" : "Failed")),
        );
      },
      child: Text("Buy Premium"),
    );
  }
}
