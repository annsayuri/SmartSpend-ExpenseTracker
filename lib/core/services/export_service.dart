import 'package:csv/csv.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class ExportService {
  // 📄 1. Export Transactions as PDF Report
  static Future<void> exportToPDF(List<Map<String, dynamic>> transactions) async {
    final pdf = pw.Document();

    double totalIncome = 0.0;
    double totalExpense = 0.0;

    for (var tx in transactions) {
      double amt = (tx['amount'] as num).toDouble();
      if (tx['type'] == 'Expense') {
        totalExpense += amt;
      } else {
        totalIncome += amt;
      }
    }

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return [
            // Title Header
            pw.Header(
              level: 0,
              child: pw.Row(
                mainpw: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('SmartSpend Financial Report',
                      style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold)),
                  pw.Text(DateTime.now().toString().split(' ')[0],
                      style: const pw.TextStyle(fontSize: 12, color: PdfColors.grey700)),
                ],
              ),
            ),
            pw.SizedBox(height: 10),

            // Summary Cards
            pw.Row(
              mainpw: pw.MainAxisAlignment.spaceAround,
              children: [
                pw.Container(
                  padding: const pw.EdgeInsets.all(10),
                  decoration: pw.BoxDecoration(border: pw.Border.all(color: PdfColors.green)),
                  child: pw.Column(
                    children: [
                      pw.Text('Total Income', style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey600)),
                      pw.Text('Rs. ${totalIncome.toStringAsFixed(2)}',
                          style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold, color: PdfColors.green)),
                    ],
                  ),
                ),
                pw.Container(
                  padding: const pw.EdgeInsets.all(10),
                  decoration: pw.BoxDecoration(border: pw.Border.all(color: PdfColors.red)),
                  child: pw.Column(
                    children: [
                      pw.Text('Total Expense', style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey600)),
                      pw.Text('Rs. ${totalExpense.toStringAsFixed(2)}',
                          style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold, color: PdfColors.red)),
                    ],
                  ),
                ),
                pw.Container(
                  padding: const pw.EdgeInsets.all(10),
                  decoration: pw.BoxDecoration(border: pw.Border.all(color: PdfColors.blue)),
                  child: pw.Column(
                    children: [
                      pw.Text('Net Balance', style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey600)),
                      pw.Text('Rs. ${(totalIncome - totalExpense).toStringAsFixed(2)}',
                          style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold, color: PdfColors.blue)),
                    ],
                  ),
                ),
              ],
            ),
            pw.SizedBox(height: 20),

            // Transactions Table
            pw.Table.fromTextArray(
              headers: ['ID', 'Title', 'Type', 'Amount (Rs.)', 'Date'],
              data: transactions.map((tx) {
                return [
                  tx['id'].toString(),
                  tx['title'].toString(),
                  tx['type'].toString(),
                  (tx['amount'] as num).toDouble().toStringAsFixed(2),
                  tx['date'].toString(),
                ];
              }).toList(),
              headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white),
              headerDecoration: const pw.BoxDecoration(color: PdfColors.deepPurple),
              cellAlignment: pw.Alignment.centerLeft,
              rowDecoration: const pw.BoxDecoration(border: pw.Border(bottom: pw.BorderSide(color: PdfColors.grey300, width: 0.5))),
            ),
          ];
        },
      ),
    );

    // BROWSER / DEVICE PRINT PREVIEW OR SAVE
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: 'SmartSpend_Report_${DateTime.now().millisecondsSinceEpoch}.pdf',
    );
  }

  // 📊 2. Export Transactions as CSV File
  static String generateCSV(List<Map<String, dynamic>> transactions) {
    List<List<dynamic>> rows = [];

    // Header Row
    rows.add(["ID", "Title", "Type", "Amount", "Date"]);

    // Data Rows
    for (var tx in transactions) {
      rows.add([
        tx['id'],
        tx['title'],
        tx['type'],
        tx['amount'],
        tx['date'],
      ]);
    }

    return const ListToCsvConverter().convert(rows);
  }
}