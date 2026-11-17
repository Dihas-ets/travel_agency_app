import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:feexpay_flutter_v2/models/payment_result.dart';
import 'package:webview_flutter/webview_flutter.dart';

class FeexPayService {
  static Future<void> openPayment({
    required BuildContext context,
    required num amount,
    required String token,
    required String shopId,
    required String reference,
    required String environment,
    Map<String, dynamic>? customer,
    String callbackUrl = '',
    required FutureOr<void> Function(PaymentResult result) onResult,
  }) async {
    if (token.isEmpty || shopId.isEmpty || reference.isEmpty || amount <= 0) {
      throw ArgumentError(
        'Les paramètres FeexPay retournés par le backend sont incomplets.',
      );
    }

    final result = await Navigator.of(context).push<PaymentResult>(
      MaterialPageRoute(
        builder: (_) => _FeexPayWebPaymentPage(
          html: _checkoutHtml(
            amount: amount,
            token: token,
            shopId: shopId,
            reference: reference,
            environment: environment,
            customer: customer,
            callbackUrl: callbackUrl,
          ),
        ),
      ),
    );
    await onResult(
      result ??
          const PaymentResult(
            status: 'FAILED',
            reference: '',
            message: 'Paiement annulé.',
          ),
    );
  }

  static String _checkoutHtml({
    required num amount,
    required String token,
    required String shopId,
    required String reference,
    required String environment,
    Map<String, dynamic>? customer,
    required String callbackUrl,
  }) {
    final phone = (customer?['phone'] ?? '').toString().replaceAll(
      RegExp(r'\D'),
      '',
    );
    final firstName = (customer?['firstname'] ?? '').toString();
    final lastName = (customer?['lastname'] ?? '').toString();
    final name = '$firstName $lastName'
        .replaceAll(RegExp(r'[^a-zA-Z0-9\s]'), '')
        .trim();
    final email = (customer?['email'] ?? '').toString();
    final mode =
        [
          'live',
          'production',
          'prod',
        ].contains(environment.trim().toLowerCase())
        ? 'LIVE'
        : 'SANDBOX';
    final config = jsonEncode({
      'id': shopId,
      'amount': amount.toInt(),
      'token': token,
      'first_name': name.isEmpty ? 'Client' : name,
      'full_name': name.isEmpty ? 'Client' : name,
      'name': name.isEmpty ? 'Client' : name,
      'email': email,
      'fields_to_hide': ['name', 'email'],
      'phone': phone,
      'phonenumber': phone,
      'phone_number': phone,
      'reference': reference,
      'custom_id': reference,
      'description': 'Paiement $reference',
      'mode': mode,
      'callback_url': callbackUrl,
      'defaultValueField': {
        'phonenumber': phone,
        'phone': phone,
        'phone_number': phone,
        'country_iban': 'BJ',
        'country': 'BJ',
        'first_name': name.isEmpty ? 'Client' : name,
        'name': name.isEmpty ? 'Client' : name,
        'email': email,
      },
    });

    return '''
  <!doctype html>
  <html lang="fr">
  <head>
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <meta charset="utf-8">
    <style>
      body { font-family: sans-serif; margin: 0; padding: 20px; color: #0b4f2a; }
      #feexpay-render { min-height: 60px; }
      button.feexpay-button { display: none !important; }
      #error { color: #b42318; text-align: center; }
    </style>
  </head>
  <body>
    <div id="feexpay-render"></div>
    <p id="error"></p>
    <script>
      function report(status, reference, message) {
        FeexPayNative.postMessage(JSON.stringify({
          status: status,
          reference: reference || '',
          message: message || ''
        }));
      }

      const config = $config;
      config.callback = function(response) {
        const rawStatus = String(
          response?.status ?? response?.state ?? response?.statut ??
          response?.code ?? response?.response?.status ??
          response?.response?.statut ?? ''
        ).toUpperCase();
        const reference = String(
          response?.reference ?? response?.transactionId ??
          response?.transaction_id ?? response?.id ?? ''
        );
        const approved = [
          'SUCCESSFUL', 'SUCCESS', 'APPROVED', 'PAID',
          'TRANSFERRED', 'COMPLETED', '200'
        ].includes(rawStatus) || response?.status === 200 || response?.code === 200;
        const failed = ['FAILED', 'CANCELLED', 'CANCELED'].includes(rawStatus);
        report(
          failed ? 'FAILED' : 'SUCCESSFUL',
          reference,
          approved && !reference
            ? 'FeexPay n’a pas retourné de référence de transaction.'
            : response?.message ?? ''
        );
      };

      const script = document.createElement('script');
      script.src = 'https://api-v2.feexpay.me/feexpay-javascript-sdk/index.js';
      script.onload = function() {
        if (!window.FeexPayButton) {
          document.getElementById('error').textContent =
            'Le service de paiement FeexPay est indisponible.';
          report('FAILED', '', 'Le SDK FeexPay n’est pas disponible.');
          return;
        }
        document.addEventListener('click', function(event) {
          const target = event.target instanceof Element ? event.target : null;
          if (!target) return;
          const dismissButton = target.closest('#feexpay-close-btn, #feexpay-back-btn');
          const backdrop = target.matches('.feexpay-modal-overlay');
          if (dismissButton || backdrop) {
            event.preventDefault();
            event.stopImmediatePropagation();
            report('FAILED', '', 'Paiement annulé.');
          }
        }, true);
        const container = document.getElementById('feexpay-render');
        let buttonOpened = false;
        const buttonObserver = new MutationObserver(function() {
          const paymentButton = container.querySelector('button.feexpay-button');
          if (paymentButton && !buttonOpened) {
            buttonOpened = true;
            buttonObserver.disconnect();
            paymentButton.click();
          }
        });
        buttonObserver.observe(container, { childList: true, subtree: true });
        window.FeexPayButton.init('feexpay-render', config);
        setTimeout(function() {
          buttonObserver.disconnect();
          if (!buttonOpened) {
            document.getElementById('error').textContent =
              'Impossible d’ouvrir le guichet FeexPay. Vérifiez la connexion et les paramètres de paiement.';
            report('FAILED', '', 'Le bouton FeexPay ne s’est pas chargé.');
          }
        }, 20000);
      };
      script.onerror = function() {
        document.getElementById('error').textContent =
          'Impossible de charger FeexPay. Vérifiez votre connexion.';
        report('FAILED', '', 'Impossible de charger le SDK FeexPay.');
      };
      document.head.appendChild(script);
    </script>
  </body>
  </html>
  ''';
  }
}

class _FeexPayWebPaymentPage extends StatefulWidget {
  final String html;

  const _FeexPayWebPaymentPage({required this.html});

  @override
  State<_FeexPayWebPaymentPage> createState() => _FeexPayWebPaymentPageState();
}

class _FeexPayWebPaymentPageState extends State<_FeexPayWebPaymentPage> {
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..addJavaScriptChannel(
        'FeexPayNative',
        onMessageReceived: _handlePaymentResult,
      )
      ..setBackgroundColor(Colors.white)
      ..loadHtmlString(widget.html, baseUrl: 'https://api-v2.feexpay.me');
  }

  void _handlePaymentResult(JavaScriptMessage message) {
    final decoded = jsonDecode(message.message);
    if (decoded is! Map) {
      throw const FormatException('Réponse FeexPay invalide.');
    }
    final data = Map<String, dynamic>.from(decoded);
    final result = PaymentResult(
      status: data['status']?.toString() ?? 'FAILED',
      reference: data['reference']?.toString() ?? '',
      message: data['message']?.toString(),
    );
    if (mounted && Navigator.of(context).canPop()) {
      Navigator.of(context).pop(result);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Paiement FeexPay')),
    body: WebViewWidget(controller: _controller),
  );
}
