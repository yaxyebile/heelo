import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class WaafiPayResult {
  final bool success;
  final String message;
  final String? transactionId;
  final String? referenceId;

  WaafiPayResult({
    required this.success,
    required this.message,
    this.transactionId,
    this.referenceId,
  });
}

class WaafiPayService {
  static const String _endpoint = 'https://api.waafipay.net/asm';

  /// Format Somali phone number to standard 25261XXXXXXX format expected by WaafiPay
  static String formatPhone(String rawPhone) {
    String clean = rawPhone.replaceAll(RegExp(r'\D'), '');
    if (clean.startsWith('252')) {
      return clean;
    }
    if (clean.startsWith('061') || clean.startsWith('062') || clean.startsWith('077')) {
      clean = clean.substring(1);
    }
    if (clean.startsWith('61') || clean.startsWith('62') || clean.startsWith('77')) {
      return '252$clean';
    }
    return '252$clean';
  }

  /// Process EVC Plus payment via WAAFI Pay API Purchase Prompt
  static Future<WaafiPayResult> processEvcPayment({
    required String phone,
    required double amount,
    required String orderId,
    required String merchantUid,
    required String apiUserId,
    required String apiKey,
  }) async {
    final formattedPhone = formatPhone(phone);
    final timestamp = DateTime.now().toIso8601String().replaceAll('T', ' ').substring(0, 19);
    final requestId = 'REQ_${DateTime.now().millisecondsSinceEpoch}';

    final parsedApiUserId = int.tryParse(apiUserId) ?? apiUserId;
    final cleanRefId = orderId.replaceAll('-', '');
    final shortRef = cleanRefId.substring(0, cleanRefId.length > 20 ? 20 : cleanRefId.length);

    // Build WAAFI Pay JSON Payload
    final body = {
      "schemaVersion": "1.0",
      "requestId": requestId,
      "timestamp": timestamp,
      "channelName": "WEB",
      "serviceName": "API_PURCHASE",
      "serviceParams": {
        "merchantUid": merchantUid,
        "apiUserId": parsedApiUserId,
        "apiKey": apiKey,
        "paymentMethod": "MWALLET_ACCOUNT",
        "payerInfo": {
          "accountNo": formattedPhone,
        },
        "transactionInfo": {
          "referenceId": shortRef,
          "invoiceId": "INV-${shortRef.substring(0, shortRef.length > 8 ? 8 : shortRef.length)}",
          "amount": amount.toStringAsFixed(2),
          "currency": "USD",
          "description": "Payment for order #$shortRef"
        }
      }
    };

    debugPrint('WAAFI Pay Request Payload: ${jsonEncode(body)}');

    try {
      final response = await http.post(
        Uri.parse(_endpoint),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      ).timeout(const Duration(seconds: 45));

      debugPrint('WAAFI Pay Response Status: ${response.statusCode}');
      debugPrint('WAAFI Pay Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final responseCode = data['responseCode']?.toString().toUpperCase() ?? '';
        final responseMsg = data['responseMsg']?.toString().toUpperCase() ?? '';
        final errorCode = data['errorCode']?.toString().toUpperCase() ?? '';
        final params = data['params'] as Map<String, dynamic>?;
        final state = params?['state']?.toString().toUpperCase();
        final txId = params?['txId']?.toString() ??
            params?['issuerTransactionId']?.toString() ??
            data['txId']?.toString() ??
            data['transactionId']?.toString();

        final isCodeSuccess = responseCode == '2001' ||
            responseCode == '0000' ||
            responseCode == '2000' ||
            responseCode == '200' ||
            responseCode == '0' ||
            responseCode == 'SUCCESS' ||
            responseCode == 'APPROVED';

        final isMsgSuccess = responseMsg.contains('RRA_SUCCESS') ||
            responseMsg.contains('SUCCESS') ||
            responseMsg.contains('APPROVED') ||
            responseMsg.contains('COMPLETED') ||
            responseMsg.contains('PAID');

        final isStateSuccess = state == 'APPROVED' ||
            state == 'COMPLETED' ||
            state == 'SUCCESS' ||
            state == 'SUCCESSFUL' ||
            state == 'PAID' ||
            state == 'OK';

        final isExplicitFailure = responseMsg.contains('CANCEL') ||
            responseMsg.contains('REJECT') ||
            responseMsg.contains('INSUFFICIENT') ||
            responseMsg.contains('INVALID') ||
            responseMsg.contains('FAIL') ||
            responseMsg.contains('DECLINE') ||
            responseMsg.contains('DENIED') ||
            responseMsg.contains('EXPIRED') ||
            responseMsg.contains('NOT_FOUND') ||
            state == 'FAILED' ||
            state == 'CANCELLED' ||
            state == 'REJECTED';

        final isSuccess = (isCodeSuccess || isMsgSuccess || isStateSuccess) && !isExplicitFailure;

        if (isSuccess) {
          return WaafiPayResult(
            success: true,
            message: 'Lacag bixinta waa la xaqiijiyay! (Paid successfully)',
            transactionId: txId ?? requestId,
            referenceId: orderId,
          );
        } else {
          String userMsg = 'Lacag bixintu waa fashilantay.';
          if (responseMsg.contains('CANCEL') || responseMsg.contains('REJECT')) {
            userMsg = 'Waad kansashay ama ma gelinin PIN-ka EVC Plus.';
          } else if (responseMsg.contains('INSUFFICIENT')) {
            userMsg = 'Haragaaga EVC Plus kuguma filna.';
          } else if (responseMsg.contains('PIN')) {
            userMsg = 'PIN-ka EVC Plus oo aad gelisay waa magal.';
          } else if (responseMsg.isNotEmpty) {
            userMsg = responseMsg;
          }

          return WaafiPayResult(
            success: false,
            message: '$userMsg (Code: $responseCode)',
          );
        }
      } else {
        return WaafiPayResult(
          success: false,
          message: 'Error ka yimid server-ka WaafiPay: HTTP ${response.statusCode}',
        );
      }
    } catch (e) {
      debugPrint('WaafiPay Exception: $e');
      return WaafiPayResult(
        success: false,
        message: 'Cillad internet/waqti dhamaaday: $e',
      );
    }
  }
}
