import 'package:flutter/material.dart';
import 'package:receipt_pro/report/report_service.dart';

class ReportPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final report = ReportService.generateMonthlyReport();

    return Scaffold(
      appBar: AppBar(title: Text("Monthly Report")),
      body: Center(child: Text("Total Spent: \$${report.totalAmount}")),
    );
  }
}
