import 'dart:async';
import 'package:flutter/material.dart';
import 'package:feexpay_flutter_v2/feexpay_flutter.dart';
import 'package:feexpay_flutter_v2/models/payment_result.dart';
import 'package:random_string/random_string.dart';

class FeexPayService {
  static Future<void> openPayment({
    required BuildContext context,
    required num amount,
    required String token,
    required String shopId,
    required String reference,
    required FutureOr<void> Function(PaymentResult result) onResult,
  }) async {
    if (token.isEmpty || shopId.isEmpty || reference.isEmpty) {
      throw ArgumentError(
        'Les paramètres FeexPay retournés par le backend sont incomplets.',
      );
    }

    final transKey = randomAlphaNumeric(15);

    final amountString = amount.toInt().toString();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChoicePage(
          token: token,
          id: shopId,
          amount: amountString,
          reference: reference,
          // L'identité est déjà collectée dans la réservation et envoyée
          // au backend. Le formulaire du SDK ne peut pas être prérempli.
          hide_identity_form: true,
          redirecturl: '/payment-success',
          errorredirecturl: '/payment-error',
          trans_key: transKey,
          onPaymentResult: (PaymentResult result) {
            final callbackResult = onResult(result);
            if (callbackResult is Future<void>) {
              unawaited(callbackResult);
            }
          },
        ),
      ),
    );
  }
}
