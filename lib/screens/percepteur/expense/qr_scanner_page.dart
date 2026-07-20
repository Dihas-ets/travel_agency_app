import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:code_initial/models/expense_model.dart';
import 'package:code_initial/models/store/expense_store.dart';
import 'manual_expense_page.dart';

class QRScannerPage extends StatefulWidget {
  final String? reservationReference;
  final String? assignmentReference;
  final String? tripRoute;
  final String? busMatricule;

  const QRScannerPage({
    super.key,
    this.reservationReference,
    this.assignmentReference,
    this.tripRoute,
    this.busMatricule,
  });

  @override
  State<QRScannerPage> createState() => _QRScannerPageState();
}

class _QRScannerPageState extends State<QRScannerPage> {
  late MobileScannerController controller;
  bool hasScanned = false;
  ExpenseModel? scannedExpense;
  String? scanMessage;

  static const _darkGreen = Color(0xFF0B4F2A);
  static const _green = Color(0xFF16A34A);
  static const _orange = Color(0xFFFF9500);

  @override
  void initState() {
    super.initState();
    controller = MobileScannerController(
      torchEnabled: false,
      detectionSpeed: DetectionSpeed.noDuplicates,
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void _processQRCode(String qrData) {
    if (hasScanned) return;
    hasScanned = true;
    final parts = qrData.split('|');

    if (parts.length >= 4) {
      setState(() {
        scanMessage = 'QR valide détecté. Ouverture du formulaire...';
      });
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => ManualExpensePage(
            initialLibelle: parts[0],
            initialDescription: parts.length > 1 ? parts[1] : '',
            initialCost: double.tryParse(parts[2]) ?? 0,
            initialQuantity: int.tryParse(parts[3]) ?? 1,
            initialQuantityUnit: parts.length > 4 ? parts[4] : '',
            initialCostInWords: parts.length > 5 ? parts[5] : '',
            initialNote: parts.length > 6 ? parts[6] : '',
            qrCode: qrData,
            reservationReference: widget.reservationReference,
            assignmentReference: widget.assignmentReference,
            tripRoute: widget.tripRoute,
            busMatricule: widget.busMatricule,
          ),
        ),
      );
    } else {
      _showScanError(
        'Format QR invalide. Utilisez libelle|description|cost|quantity|unite|cout en lettres|note',
      );
    }
  }

  void _showScanError(String message) {
    hasScanned = false;
    setState(() {
      scanMessage = message;
      scannedExpense = null;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red.shade700),
    );
  }

  void _saveScannedExpense() {
    if (scannedExpense == null) return;
    ExpenseStore().addExpense(scannedExpense!);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Dépense ajoutée: ${scannedExpense!.libelle}'),
        backgroundColor: _green,
        duration: const Duration(seconds: 2),
      ),
    );

    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;
      Navigator.of(context).pop();
    });
  }

  void _resetScanner() {
    setState(() {
      hasScanned = false;
      scanMessage = null;
      scannedExpense = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Positioned.fill(
            child: MobileScanner(
              controller: controller,
              onDetect: (capture) {
                if (hasScanned) return;
                for (final barcode in capture.barcodes) {
                  final value = barcode.rawValue;
                  if (value != null) {
                    _processQRCode(value);
                    break;
                  }
                }
              },
            ),
          ),
          Positioned.fill(
            child: CustomPaint(painter: _ScannerOverlayPainter()),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(18, 10, 18, 18),
              child: Column(
                children: [
                  _buildTopBar(),
                  const Spacer(),
                  if (scannedExpense != null)
                    _buildScannedCard()
                  else
                    _buildIdleActions(),
                ],
              ),
            ),
          ),
          Center(
            child: SizedBox(
              width: 266,
              height: 266,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.88),
                    width: 1.4,
                  ),
                ),
                child: Stack(
                  children: const [
                    _ScannerCorner(alignment: Alignment.topLeft),
                    _ScannerCorner(alignment: Alignment.topRight),
                    _ScannerCorner(alignment: Alignment.bottomLeft),
                    _ScannerCorner(alignment: Alignment.bottomRight),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopBar() {
    return Row(
      children: [
        _CircleButton(
          icon: Icons.arrow_back_rounded,
          onTap: () => Navigator.pop(context),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.56),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: Colors.white.withValues(alpha: 0.14)),
            ),
            child: Row(
              children: [
                const Icon(Icons.qr_code_scanner_rounded, color: Colors.white),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    scanMessage ?? 'Placez le QR dans le cadre',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13.2,
                      fontWeight: FontWeight.w800,
                      height: 1.25,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        _CircleButton(icon: Icons.refresh_rounded, onTap: _resetScanner),
      ],
    );
  }

  Widget _buildIdleActions() {
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.18),
                blurRadius: 22,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Row(
            children: [
              _SoftIcon(icon: Icons.center_focus_strong_rounded, color: _green),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'La caméra reste visible. Alignez simplement le code dans le cadre.',
                  style: TextStyle(
                    color: Color(0xFF334155),
                    fontWeight: FontWeight.w700,
                    height: 1.35,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ManualExpensePage(
                        reservationReference: widget.reservationReference,
                        assignmentReference: widget.assignmentReference,
                        tripRoute: widget.tripRoute,
                        busMatricule: widget.busMatricule,
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.edit_note_rounded),
                label: const Text('Manuel'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _orange,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  textStyle: const TextStyle(fontWeight: FontWeight.w900),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close_rounded),
                label: const Text('Annuler'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: BorderSide(color: Colors.white.withValues(alpha: 0.8)),
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  textStyle: const TextStyle(fontWeight: FontWeight.w900),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildScannedCard() {
    final expense = scannedExpense!;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.20),
            blurRadius: 28,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              const _SoftIcon(icon: Icons.verified_rounded, color: _green),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Dépense détectée',
                  style: TextStyle(
                    color: _darkGreen,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              Text(
                '${(expense.cost * expense.quantity).toStringAsFixed(0)} FCFA',
                style: const TextStyle(
                  color: _green,
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildInfoRow('Libellé', expense.libelle, Icons.label_rounded),
          _buildInfoRow(
            'Montant unitaire',
            '${expense.cost.toStringAsFixed(0)} FCFA',
            Icons.payments_rounded,
          ),
          _buildInfoRow(
            'Quantité',
            _quantityLabel(expense),
            Icons.numbers_rounded,
          ),
          if (expense.description.isNotEmpty)
            _buildInfoRow(
              'Description',
              expense.description,
              Icons.description_rounded,
            ),
          if (expense.note.isNotEmpty)
            _buildInfoRow('Note', expense.note, Icons.sticky_note_2_rounded),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _saveScannedExpense,
                  icon: const Icon(Icons.check_circle_rounded),
                  label: const Text('Enregistrer'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _green,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    textStyle: const TextStyle(fontWeight: FontWeight.w900),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _resetScanner,
                  icon: const Icon(Icons.replay_rounded),
                  label: const Text('Reprendre'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: _darkGreen,
                    side: const BorderSide(color: _darkGreen),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    textStyle: const TextStyle(fontWeight: FontWeight.w900),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String title, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          _SoftIcon(icon: icon, color: _darkGreen, size: 36, iconSize: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Color(0xFF64748B),
                    fontSize: 11.5,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF0F172A),
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _quantityLabel(ExpenseModel expense) {
    final unit = expense.quantityUnit.trim();
    if (unit.isEmpty) return '${expense.quantity}';
    return '${expense.quantity} $unit';
  }
}

class _ScannerOverlayPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final scanRect = Rect.fromCenter(
      center: Offset(size.width / 2, size.height / 2),
      width: 266,
      height: 266,
    );
    final background = Path()..addRect(Offset.zero & size);
    final cutout = Path()
      ..addRRect(RRect.fromRectAndRadius(scanRect, const Radius.circular(28)));
    final overlay = Path.combine(PathOperation.difference, background, cutout);

    canvas.drawPath(
      overlay,
      Paint()..color = Colors.black.withValues(alpha: 0.52),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _ScannerCorner extends StatelessWidget {
  final Alignment alignment;

  const _ScannerCorner({required this.alignment});

  @override
  Widget build(BuildContext context) {
    final isLeft = alignment.x < 0;
    final isTop = alignment.y < 0;

    return Align(
      alignment: alignment,
      child: Container(
        width: 56,
        height: 56,
        margin: const EdgeInsets.all(1),
        decoration: BoxDecoration(
          border: Border(
            left: isLeft
                ? const BorderSide(color: Color(0xFF4ADE80), width: 5)
                : BorderSide.none,
            right: !isLeft
                ? const BorderSide(color: Color(0xFF4ADE80), width: 5)
                : BorderSide.none,
            top: isTop
                ? const BorderSide(color: Color(0xFF4ADE80), width: 5)
                : BorderSide.none,
            bottom: !isTop
                ? const BorderSide(color: Color(0xFF4ADE80), width: 5)
                : BorderSide.none,
          ),
          borderRadius: BorderRadius.only(
            topLeft: isLeft && isTop ? const Radius.circular(28) : Radius.zero,
            topRight: !isLeft && isTop
                ? const Radius.circular(28)
                : Radius.zero,
            bottomLeft: isLeft && !isTop
                ? const Radius.circular(28)
                : Radius.zero,
            bottomRight: !isLeft && !isTop
                ? const Radius.circular(28)
                : Radius.zero,
          ),
        ),
      ),
    );
  }
}

class _CircleButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _CircleButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black.withValues(alpha: 0.56),
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(
          width: 48,
          height: 48,
          child: Icon(icon, color: Colors.white),
        ),
      ),
    );
  }
}

class _SoftIcon extends StatelessWidget {
  final IconData icon;
  final Color color;
  final double size;
  final double iconSize;

  const _SoftIcon({
    required this.icon,
    required this.color,
    this.size = 42,
    this.iconSize = 21,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Icon(icon, color: color, size: iconSize),
    );
  }
}
