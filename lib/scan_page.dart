import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:receipt_pro/services/ocr_service.dart';

class ScanPage extends StatefulWidget {
  @override
  ScanPageState createState() => ScanPageState();
}

class ScanPageState extends State<ScanPage> {
  String _recognizedText = "";
  updateSelf() {
    print("ScanPageState updateSelf called");
    setState(() {});
  }

  doScan() async {
    _recognizedText = await OCRService.scanImage();
    print("ScapPage.doScan scanController.startScan returned!");
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double titleFontSize =
        (screenWidth * 0.022 + 4) < 16 ? 16 : (screenWidth * 0.022 + 4);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          FlutterI18n.translate(context, "SCAN_RECEIPT"),
          style: TextStyle(fontSize: titleFontSize),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          ElevatedButton(
            onPressed: () => {doScan()},
            child: Text(
              FlutterI18n.translate(context, "START_SCAN"),
              style: TextStyle(fontSize: titleFontSize),
            ),
          ),
          SizedBox(height: 20),
          Expanded(child: SingleChildScrollView(child: Text(_recognizedText))),
        ],
      ),
    );
  }
}
