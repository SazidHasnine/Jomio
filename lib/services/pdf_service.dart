import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:universal_html/html.dart' as html;
import '../models/customer.dart';

class PdfService {
  static Future<void> generateAndDownloadLedger(List<Customer> customers) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('Business Logbook Ledger', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 20),
              pw.Table.fromTextArray(
                context: context,
                headers: ['Name', 'Type', 'Balance'],
                data: customers.map((c) => [
                  c.name,
                  c.userType.name.toUpperCase(),
                  '${c.balance > 0 ? "Advance" : (c.balance < 0 ? "Due" : "Settled")} BDT ${c.balance.abs()}'
                ]).toList(),
              ),
            ],
          );
        },
      ),
    );

    final Uint8List bytes = await pdf.save();
    
    // Trigger download in browser
    final blob = html.Blob([bytes], 'application/pdf');
    final url = html.Url.createObjectUrlFromBlob(blob);
    final anchor = html.AnchorElement(href: url)
      ..setAttribute('download', 'ledger_report.pdf')
      ..click();
    html.Url.revokeObjectUrl(url);
  }
}
