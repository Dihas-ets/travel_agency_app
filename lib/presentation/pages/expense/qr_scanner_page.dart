import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:code_initial/models/expense_model.dart';
import 'expense_store.dart';
import 'manual_expense_page.dart';

class QRScannerPage extends StatefulWidget {
  const QRScannerPage({super.key});

  @override
  State<QRScannerPage> createState() => _QRScannerPageState();
}

class _QRScannerPageState extends State<QRScannerPage> {
  late MobileScannerController controller;
  bool hasScanned = false;

  @override
  void initState() {
    super.initState();
    controller = MobileScannerController();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  // Parse QR code and create expense
  void _processQRCode(String qrData) {
    if (hasScanned) return;
    hasScanned = true;

    try {
      // Expected QR format: "libelle|description|cost|quantity|note"
      final parts = qrData.split('|');

      if (parts.length >= 4) {
        final expense = ExpenseModel(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          libelle: parts[0],
          description: parts.length > 1 ? parts[1] : '',
          cost: double.tryParse(parts[2]) ?? 0,
          quantity: int.tryParse(parts[3]) ?? 1,
          note: parts.length > 4 ? parts[4] : '',
          createdAt: DateTime.now(),
          status: "En cours",
          qrCode: qrData,
        );

        ExpenseStore().addExpense(expense);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Dépense ajoutée: ${expense.libelle}',
              style: const TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );

        Future.delayed(const Duration(seconds: 2), () {
          if (!mounted) return;
          Navigator.of(context).pop();
        });
      } else {
        _showErrorDialog('Format QR invalide');
      }
    } catch (e) {
      _showErrorDialog('Erreur: ${e.toString()}');
    }
  }

  void _showErrorDialog(String message) {
    hasScanned = false;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Erreur'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scanner Code QR'),
        backgroundColor: const Color(0xFF16A34A),
        elevation: 0,
      ),
      body: Stack(
        children: [
          // Camera
          MobileScanner(
            controller: controller,
            onDetect: (capture) {
              final List<Barcode> barcodes = capture.barcodes;
              for (final barcode in barcodes) {
                if (barcode.rawValue != null && !hasScanned) {
                  _processQRCode(barcode.rawValue!);
                }
              }
            },
          ),
          // Overlay avec guide
          Center(
            child: Container(
              width: 280,
              height: 280,
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.white,
                  width: 3,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
          // Instructions
          Positioned(
            top: 40,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'Positionnez le code QR dans le cadre',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ),
          // Bottom buttons
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(16),
              color: Colors.black87,
              child: Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                const ManualExpensePage(),
                          ),
                        );
                      },
                      icon: const Icon(Icons.edit),
                      label: const Text('Enregistrement Manuel'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF9500),
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: OutlinedButton.icon(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                      label: const Text('Annuler'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: const BorderSide(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
