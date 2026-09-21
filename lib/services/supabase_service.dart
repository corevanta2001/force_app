import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';
class SupabaseService {
  final _client = Supabase.instance.client;
  Future<String> uploadReceipt(String userId, String orderNumber, Uint8List bytes) async {
    final path = "$userId/$orderNumber.pdf";
    await _client.storage.from('receipts').uploadBinary(path, bytes, fileOptions: const FileOptions(upsert: true, contentType: 'application/pdf'));
    return await _client.storage.from('receipts').createSignedUrl(path, 31536000);
  }
}
