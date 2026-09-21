import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../models/order_model.dart';
class PdfService {
  static Future<Uint8List> generateReceipt(OrderModel order) async {
    final pdf = pw.Document();
    pdf.addPage(pw.Page(pageFormat: PdfPageFormat.a4, build: (c) {
      return pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
        pw.Text('FORCEapp - Receipt', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 20),
        pw.Text('Order: ${order.orderNumber}'),
        pw.Text('Customer: ${order.customerName}'),
        pw.Text('Phone: ${order.customerPhone}'),
        pw.Text('Address: ${order.address}'),
        pw.Text('Total: ${{order.totalAmount}'),
        pw.Text('Status: ${order.status}'),
        pw.Text('Date: ${order.createdAt.toString()}'),
        pw.SizedBox(height: 20),
        pw.Text('Thank you!'),
      ]);
    }));
    return pdf.save();
  }
}
