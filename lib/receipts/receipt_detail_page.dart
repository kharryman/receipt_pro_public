import 'package:flutter/material.dart';
import 'receipt_model.dart';

class ReceiptDetailPage extends StatelessWidget {
  final Receipt receipt;

  const ReceiptDetailPage({required this.receipt});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(receipt.vendor)),
      body: Column(
        children: [
          Text("Date: ${receipt.date}"),
          Text("Amount: \$${receipt.amount}"),
        ],
      ),
    );
  }
}
