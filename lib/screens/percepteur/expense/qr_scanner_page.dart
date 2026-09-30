import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'manual_expense_page.dart';

class QRScannerPage extends StatefulWidget {
  const QRScannerPage({
    super.key,
    String? reservationReference,
    String? assignmentReference,
    String? tripRoute,
    String? busMatricule,
  });

  @override
  State<QRScannerPage> createState() => _QRScannerPageState();
}

class _QRScannerPageState extends State<QRScannerPage> {
  late final MobileScannerController _controller;
  bool _hasScanned = false;
  String? _scanError;

  @override
  void initState() {
    super.initState();
    _controller = MobileScannerController(
      torchEnabled: false,
      detectionSpeed: DetectionSpeed.noDuplicates,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String _formatMecefCode(String code) {
    final compact = code.replaceAll(RegExp(r'[\s-]'), '');
    final chunks = <String>[];
    for (var start = 0; start < compact.length; start += 4) {
      final end = start + 4 < compact.length ? start + 4 : compact.length;
      chunks.add(compact.substring(start, end));
    }
    return chunks.join('-');
  }

  ({String code, String nim})? _parseMecefQr(String content) {
    final parts = content.trim().split(';');
    if (parts.length < 3 || parts.first.trim().toUpperCase() != 'F') {
      return null;
    }
    final nim = parts[1].trim();
    final code = _formatMecefCode(parts[2].trim());
    if (nim.isEmpty || code.isEmpty) return null;
    return (code: code, nim: nim);
  }

  Future<void> _processQr(String content) async {
    if (_hasScanned) return;
    final parsed = _parseMecefQr(content);
    if (parsed == null) {
      setState(() {
        _scanError =
            'QR non reconnu. Scannez le QR MECeF au format F;NIM;CODE;IFU;DATE.';
        _hasScanned = true;
      });
      return;
    }

    setState(() => _hasScanned = true);
    await _controller.stop();
    if (!mounted) return;
    final created = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (context) => ManualExpensePage(
          initialMecefCode: parsed.code,
          initialMecefNim: parsed.nim,
        ),
      ),
    );
    if (!mounted) return;
    if (created == true) {
      Navigator.pop(context, true);
      return;
    }
    await _controller.start();
    if (!mounted) return;
    setState(() {
      _hasScanned = false;
      _scanError = null;
    });
  }

  void _resumeScanning() {
    setState(() {
      _hasScanned = false;
      _scanError = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: const Color(0xFF0B4F2A),
        foregroundColor: Colors.white,
        title: const Text(
          'Scanner une facture MECeF',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: MobileScanner(
              controller: _controller,
              onDetect: (capture) {
                if (_hasScanned || capture.barcodes.isEmpty) return;
                final value = capture.barcodes.first.rawValue;
                if (value != null && value.trim().isNotEmpty) {
                  unawaited(_processQr(value));
                }
              },
            ),
          ),
          Positioned.fill(
            child: IgnorePointer(
              child: Container(color: Colors.black.withValues(alpha: 0.2)),
            ),
          ),
          Center(
            child: Container(
              width: 270,
              height: 270,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white, width: 2),
                borderRadius: BorderRadius.circular(24),
              ),
            ),
          ),
          SafeArea(
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.all(22),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.7),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _scanError ??
                            'Placez le QR MECeF de la facture dans le cadre.',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      if (_scanError != null) ...[
                        const SizedBox(height: 12),
                        OutlinedButton.icon(
                          onPressed: _resumeScanning,
                          icon: const Icon(Icons.refresh_rounded),
                          label: const Text('Réessayer'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
