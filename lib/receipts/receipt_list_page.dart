import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:receipt_pro/receipts/receipt_detail_page.dart';
import 'package:receipt_pro/menu.dart';
import 'receipt_model.dart';

class ReceiptListPage extends StatefulWidget {
  @override
  ReceiptListPageState createState() => ReceiptListPageState();
}

class ReceiptListPageState extends State<ReceiptListPage> {
  final List<Receipt> receipts = []; // replace with real data

  updateSelf() {
    print("HomePageState updateSelf called");
    setState(() {});
  }

  seeReceiptDetails(BuildContext context, dynamic receipt) {
    print("seeReceiptDetails called");
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ReceiptDetailPage(receipt: receipt),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double titleFontSize =
        (screenWidth * 0.022 + 4) < 16 ? 16 : (screenWidth * 0.022 + 4);
    double buttonFontSize =
        (screenWidth * 0.018 + 4) < 12 ? 12 : (screenWidth * 0.018 + 4);
    String appTitle = FlutterI18n.translate(context, "APP_TITLE");
    var pageTitle = FlutterI18n.translate(context, "RECEIPTS_LIST_PAGE");
    return Scaffold(
      appBar: AppBar(
        title: Text(pageTitle, style: TextStyle(fontSize: titleFontSize)),
        centerTitle: true,
        actions: [
          Menu(
            context: context,
            page: 'receipts_list',
            updateParent: updateSelf,
          ),
        ],
      ),
      body: Column(
        children: [
          if (receipts.isEmpty)
            Align(
              alignment: Alignment.center,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  FlutterI18n.translate(context, "PROMPT_NO_RECEIPTS"),
                  style: TextStyle(
                    fontSize: titleFontSize,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          if (receipts.isNotEmpty)
            Expanded(
              child: Container(
                width: screenWidth,
                child: ListView.builder(
                  itemCount: receipts.length,
                  itemBuilder: (_, index) {
                    final receipt = receipts[index];
                    return ListTile(
                      title: Text(receipt.vendor),
                      subtitle: Text(receipt.date.toIso8601String()),
                      trailing: Text("\$${receipt.amount}"),
                      onTap: () {
                        // Handle the tap event here
                        print("Tapped on: ${receipt.vendor}");
                        seeReceiptDetails(context, receipt);
                      },
                    );
                  },
                ),
              ),
            ),
        ],
      ),
    );
  }
}
