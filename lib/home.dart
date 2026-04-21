import 'package:flutter/material.dart';
import 'package:receipt_pro/receipts/receipt_list_page.dart';
import 'package:receipt_pro/report/report_page.dart';
import 'package:receipt_pro/scan_page.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:receipt_pro/main.dart';
import 'package:receipt_pro/menu.dart';

class HomePage extends StatefulWidget {
  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  updateSelf() {
    print("HomePageState updateSelf called");
    setState(() {});
  }

  goScan() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ScanPage()),
    );
  }

  seeReceipts() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ReceiptListPage()),
    );
  }

  seeReports() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ReportPage()),
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
    var pageTitle = FlutterI18n.translate(context, "HOME");
    return WillPopScope(
      onWillPop: () async {
        FocusManager.instance.primaryFocus?.unfocus();
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => MyMain(title: appTitle)),
        );
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(pageTitle, style: TextStyle(fontSize: titleFontSize)),
          centerTitle: true,
          actions: [
            Menu(context: context, page: 'main', updateParent: updateSelf),
          ],
        ),
        body: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color.fromARGB(255, 241, 167, 254),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                        padding: EdgeInsets.zero,
                      ),
                      onPressed: () {
                        goScan();
                      },
                      icon: Icon(Icons.scanner),
                      label: Text(
                        FlutterI18n.translate(context, "SCAN"),
                        style: TextStyle(fontSize: buttonFontSize),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color.fromARGB(255, 241, 167, 254),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                        padding: EdgeInsets.zero,
                      ),
                      onPressed: () {
                        seeReceipts();
                      },
                      icon: Icon(Icons.receipt),
                      label: Text(
                        FlutterI18n.translate(context, "SEE_RECEIPTS"),
                        style: TextStyle(fontSize: buttonFontSize),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color.fromARGB(255, 241, 167, 254),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                        padding: EdgeInsets.zero,
                      ),
                      onPressed: () {
                        seeReports();
                      },
                      icon: Icon(Icons.report),
                      label: Text(
                        FlutterI18n.translate(context, "SEE_REPORTS"),
                        style: TextStyle(fontSize: buttonFontSize),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
