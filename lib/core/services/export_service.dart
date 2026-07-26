import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:csv/csv.dart';

class ExportService {
  // 📄 Export Data to PDF
  static Future<void> exportToPDF(List<Map<String, dynamic>> transactions) async {
    final pdf = pw.Document();

    // Calculate Summary Data
    double totalIncome = 0.0;
    double totalExpense = 0.0;

    for (var tx in transactions) {
      double amount = (tx['amount'] as num).toDouble();
      if (tx['type'] == 'Income') {
        totalIncome += amount;
      } else {
        totalExpense += amount;
      }
    }

    double netBalance = totalIncome - totalExpense;

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return [
            // Header Section
            pw.Header(
              level: 0,
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    'SmartSpend Financial Report',
                    style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold),
                  ),
                  pw.Text(
                    DateTime.now().toString().split(' ')[0],
                    style: const pw.TextStyle(fontSize: 12, color: PdfColors.grey700),
                  ),
                ],
              ),
            ),
            pw.SizedBox(height: 10),

            // Summary Cards
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
              children: [
                pw.Container(
                  padding: const pw.EdgeInsets.all(10),
                  decoration: pw.BoxDecoration(border: pw.Border.all(color: PdfColors.green)),
                  child: pw.Column(
                    children: [
                      pw.Text('Total Income', style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey600)),
                      pw.Text(
                        'Rs. ${totalIncome.toStringAsFixed(2)}',
                        style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold, color: PdfColors.green),
                      ),
                    ],
                  ),
                ),
                pw.Container(
                  padding: const pw.EdgeInsets.all(10),
                  decoration: pw.BoxDecoration(border: pw.Border.all(color: PdfColors.red)),
                  child: pw.Column(
                    children: [
                      pw.Text('Total Expense', style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey600)),
                      pw.Text(
                        'Rs. ${totalExpense.toStringAsFixed(2)}',
                        style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold, color: PdfColors.red),
                      ),
                    ],
                  ),
                ),
                pw.Container(
                  padding: const pw.EdgeInsets.all(10),
                  decoration: pw.BoxDecoration(border: pw.Border.all(color: PdfColors.blue)),
                  child: pw.Column(
                    children: [
                      pw.Text('Net Balance', style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey600)),
                      pw.Text(
                        'Rs. ${netBalance.toStringAsFixed(2)}',
                        style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold, color: PdfColors.blue),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            pw.SizedBox(height: 20),

            // Transactions Table Title
            pw.Text('Transaction Details', style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 10),

            // Table Data
            pw.TableHelper.fromTextArray(
              headers: ['Title', 'Type', 'Amount (Rs.)', 'Date'],
              data: transactions.map((tx) {
                return [
                  tx['title'].toString(),
                  tx['type'].toString(),
                  (tx['amount'] as num).toStringAsFixed(2),
                  tx['date'].toString(),
                ];
              }).toList(),
              headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white),
              headerDecoration: const pw.BoxDecoration(color: PdfColors.deepPurple),
              cellAlignment: pw.Alignment.centerLeft,
              cellPadding: const pw.EdgeInsets.all(6),
            ),
          ];
        },
      ),
    );

    // Layout and share / print PDF
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
    );
  }

  // 📊 Generate CSV Format Data
  static String generateCSV(List<Map<String, dynamic>> transactions) {
    List<List<dynamic>> rows = [];

    // Add CSV Headers
    rows.add(["ID", "Title", "Amount", "Type", "Date"]);

    // Add Data Rows
    for (var tx in transactions) {
      rows.add([
        tx['id'],
        tx['title'],
        tx['amount'],
        tx['type'],
        tx['date'],
      ]);
    }

    return const ListToCsvConverter().convert(rows);
  }
}