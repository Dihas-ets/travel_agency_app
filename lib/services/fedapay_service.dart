import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class FedaPayPaymentResult {
  final String status;
  final String reference;
  final String? message;

  const FedaPayPaymentResult({
    required this.status,
    required this.reference,
    this.message,
  });

  bool get isSuccess {
    final normalized = status.toUpperCase();
    return const {
      'SUCCESS',
      'SUCCESSFUL',
      'APPROVED',
      'PAID',
      'TRANSFERRED',
      'COMPLETED',
      'CONFIRMED',
    }.contains(normalized);
  }
}

class FedaPayService {
  static Future<void> openPayment({
    required BuildContext context,
    required num amount,
    required String transactionId,
    required String token,
    required String publicKey,
    required String environment,
    required String description,
    Map<String, dynamic>? customer,
    required FutureOr<void> Function(FedaPayPaymentResult result) onResult,
  }) async {
    if (transactionId.isEmpty ||
        token.isEmpty ||
        publicKey.isEmpty ||
        amount <= 0) {
      throw ArgumentError(
        'Les paramètres FedaPay retournés par le backend sont incomplets.',
      );
    }

    final result = await Navigator.of(context).push<FedaPayPaymentResult>(
      MaterialPageRoute(
        builder: (_) => _FedaPayWebPaymentPage(
          html: _checkoutHtml(
            amount: amount,
            transactionId: transactionId,
            token: token,
            publicKey: publicKey,
            environment: environment,
            description: description,
            customer: customer,
          ),
        ),
      ),
    );

    await onResult(
      result ??
          const FedaPayPaymentResult(
            status: 'FAILED',
            reference: '',
            message: 'Paiement annulé.',
          ),
    );
  }

  static String _checkoutHtml({
    required num amount,
    required String transactionId,
    required String token,
    required String publicKey,
    required String environment,
    required String description,
    Map<String, dynamic>? customer,
  }) {
    final normalizedEnvironment =
        const {
          'live',
          'production',
          'prod',
        }.contains(environment.trim().toLowerCase())
        ? 'live'
        : 'sandbox';
    final safeCustomer = customer == null
        ? '{}'
        : jsonEncode({
            'firstname': customer['firstname']?.toString() ?? 'Client',
            'lastname': customer['lastname']?.toString() ?? 'Fofana',
            'email': customer['email']?.toString() ?? 'contact@fofana.com',
            'phone_number': {
              'number':
                  customer['phone']?.toString().replaceAll(RegExp(r'\D'), '') ??
                  '',
              'country': 'BJ',
            },
          });

    final config = jsonEncode({
      'public_key': publicKey,
      'environment': normalizedEnvironment,
      'transaction': {
        'id': int.tryParse(transactionId) ?? transactionId,
        'token': token,
        'amount': amount.toInt(),
        'description': description,
      },
      'customer': jsonDecode(safeCustomer),
    });

    return '''
<!doctype html>
<html lang="fr">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <style>
    body {
      margin: 0;
      min-height: 100vh;
      display: flex;
      align-items: center;
      justify-content: center;
      font-family: sans-serif;
      background: #f8fafc;
    }
    #error {
      color: #b42318;
      text-align: center;
      padding: 24px;
    }
  </style>
</head>
<body>
  <p id="error"></p>
  <script src="https://cdn.fedapay.com/checkout.js?v=1.1.7"></script>
  <script>
    function report(status, reference, message) {
      FedaPayNative.postMessage(JSON.stringify({
        status: status,
        reference: reference || '',
        message: message || ''
      }));
    }

    window.addEventListener('load', function () {
      if (!window.FedaPay) {
        document.getElementById('error').textContent =
          'Le service FedaPay est indisponible.';
        report('FAILED', '', 'Le SDK FedaPay est indisponible.');
        return;
      }

      const config = $config;
      config.onSuccess = function(transaction) {
        const reference = String(
          transaction?.id ??
          transaction?.transaction_id ??
          transaction?.reference ??
          ''
        );
        report('SUCCESSFUL', reference, 'Paiement confirmé.');
      };
      config.onComplete = function(response) {
        const status = String(
          response?.transaction?.status ??
          response?.status ??
          ''
        ).toUpperCase();
        if (['APPROVED', 'TRANSFERRED', 'PAID', 'SUCCESSFUL', 'COMPLETED']
          .includes(status)) {
          const transaction = response?.transaction || {};
          report(
            'SUCCESSFUL',
            String(transaction.id ?? transaction.transaction_id ?? ''),
            'Paiement confirmé.'
          );
        }
      };
      config.onFailed = function(transaction) {
        report(
          'FAILED',
          String(transaction?.id ?? ''),
          'Le paiement a échoué.'
        );
      };
      config.onClosed = function() {
        report('FAILED', '', 'Paiement annulé.');
      };

      const widget = window.FedaPay.init(config);
      widget.open();
    });
  </script>
</body>
</html>
''';
  }
}

class _FedaPayWebPaymentPage extends StatefulWidget {
  final String html;

  const _FedaPayWebPaymentPage({required this.html});

  @override
  State<_FedaPayWebPaymentPage> createState() => _FedaPayWebPaymentPageState();
}

class _FedaPayWebPaymentPageState extends State<_FedaPayWebPaymentPage> {
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..addJavaScriptChannel(
        'FedaPayNative',
        onMessageReceived: _handlePaymentResult,
      )
      ..setBackgroundColor(Colors.white)
      ..loadHtmlString(
        widget.html,
        baseUrl: 'https://sandbox-process.fedapay.com',
      );
  }

  void _handlePaymentResult(JavaScriptMessage message) {
    final decoded = jsonDecode(message.message);
    if (decoded is! Map) {
      throw const FormatException('Réponse FedaPay invalide.');
    }
    final data = Map<String, dynamic>.from(decoded);
    final result = FedaPayPaymentResult(
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
    appBar: AppBar(title: const Text('Paiement FedaPay')),
    body: WebViewWidget(controller: _controller),
  );
}
