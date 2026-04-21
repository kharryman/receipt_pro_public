class Report {
  final double totalAmount;
  Report(this.totalAmount);
}

class ReportService {
  static Report generateMonthlyReport() {
    // Aggregate receipt data
    return Report(123.45);
  }
}
