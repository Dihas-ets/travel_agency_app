import 'package:flutter/material.dart';
import 'package:kkiapay_flutter_sdk/kkiapay_flutter_sdk.dart';

class KkiapayService {
  static Future<String?> openPayment({
    required BuildContext context,
    required int amount,
    required String publicKey,
    required bool sandbox,
    required String reference,
    String? phone,
    String? name,
    String? email,
  }) async {
    if (publicKey.isEmpty || amount <= 0) {
      throw ArgumentError(
        'Les paramètres Kkiapay retournés par le backend sont incomplets.',
      );
    }

    String? transactionId;
    var callbackHandled = false;

    void handleCallback(Map<String, dynamic> response, BuildContext callbackContext) {
      if (callbackHandled) return;

      final status = response['status']?.toString();
      if (status == PAYMENT_SUCCESS) {
        transactionId = response['transactionId']?.toString();
        callbackHandled = true;
        if (callbackContext.mounted && Navigator.of(callbackContext).canPop()) {
          Navigator.of(callbackContext).pop();
        }
      } else if (status == PAYMENT_CANCELLED || status == 'PAYMENT_FAILED') {
        callbackHandled = true;
        if (callbackContext.mounted && Navigator.of(callbackContext).canPop()) {
          Navigator.of(callbackContext).pop();
        }
      }
    }

    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => KKiaPay(
          amount: amount,
          apikey: publicKey,
          sandbox: sandbox,
          phone: phone ?? '',
          name: name ?? '',
          email: email ?? '',
          reason: 'Paiement $reference',
          data: reference,
          partnerId: reference,
          countries: const ['BJ', 'CI', 'SN', 'TG'],
          paymentMethods: const ['momo', 'card'],
          callback: handleCallback,
        ),
      ),
    );

    return transactionId;
  }
}
