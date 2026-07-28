import 'dart:io';
import 'package:csv/csv.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';

class ExportService {
  
  // 1. Export as PDF Method
  static Future<void> exportToPDF(List<Map<String, dynamic>> transactions) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return [
            pw.Header(
              level: 0,
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('SmartSpend - Transaction Report',
                      style: pw.TextStyle(
                          fontSize: 20, fontWeight: pw.FontWeight.bold)),
                  pw.Text(DateTime.now().toString().split(' ')[0]),
                ],
              ),
            ),
            pw.SizedBox(height: 20),
            pw.Table.fromTextArray(
              headers: ['ID', 'Title', 'Amount', 'Type', 'Date'],
              data: transactions.map((tx) {
                return [
                  tx['id'].toString(),
                  tx['title'].toString(),
                  'Rs. ${tx['amount']}',
                  tx['type'].toString(),
                  tx['date'].toString(),
                ];
              }).toList(),
              headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              headerDecoration: const pw.BoxDecoration(color: PdfColors.grey300),
              rowDecoration: const pw.BoxDecoration(
                border: pw.Border(
                  bottom: pw.BorderSide(color: PdfColors.grey200, width: 0.5),
                ),
              ),
            ),
          ];
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
    );
  }

  // 2. Export as CSV Method
  static Future<void> exportAndShareCSV(List<Map<String, dynamic>> transactions) async {
    try {
      List<List<dynamic>> csvData = [
        ['ID', 'Title', 'Amount', 'Type', 'Category', 'Date'],
      ];

      for (var tx in transactions) {
        csvData.add([
          tx['id'],
          tx['title'],
          tx['amount'],
          tx['type'],
          tx['category'] ?? 'N/A',
          tx['date'],
        ]);
      }

      String csv = const ListToCsvConverter().convert(csvData);

      final directory = await getTemporaryDirectory();
      final path = '${directory.path}/smartspend_transactions.csv';
      final file = File(path);

      await file.writeAsString(csv);

      await Share.shareXFiles(
        [XFile(path)],
        text: 'SmartSpend Expense Report (CSV)',
      );
    } catch (e) {
      print("CSV Export Error: $e");
    }
  }
}