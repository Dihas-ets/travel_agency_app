import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:code_initial/presentation/pages/parcel/envois_effectues_page.dart';

class BilletPage extends StatelessWidget {
  final String code;
  final String departureCity;
  final String destinationCity;
  final String recipientLastName;
  final String recipientFirstName;
  final String recipientPhone;
  final String parcelNature;
  final int parcelCount;

  const BilletPage({
    super.key,
    required this.code,
    required this.departureCity,
    required this.destinationCity,
    required this.recipientLastName,
    required this.recipientFirstName,
    required this.recipientPhone,
    required this.parcelNature,
    required this.parcelCount,
  });

  Future<void> _downloadTicketPdf(
    BuildContext context, {
    required String date,
    required String time,
  }) async {
    try {
      final bytes = await _buildTicketPdf(date: date, time: time);
      final safeCode = code.replaceAll(RegExp(r'[^A-Za-z0-9_-]'), '_');

      await Printing.sharePdf(
        bytes: bytes,
        filename: 'billet_ticbus_$safeCode.pdf',
      );
    } catch (_) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Impossible de générer le PDF du billet."),
          backgroundColor: Color(0xFFF80C0D),
        ),
      );
    }
  }

  Future<Uint8List> _buildTicketPdf({
    required String date,
    required String time,
  }) async {
    final pdf = pw.Document();
    final deepBlue = PdfColor.fromHex('#060663');
    final logoRed = PdfColor.fromHex('#F80C0D');
    final lightRed = PdfColor.fromHex('#FFF1F1');
    final border = PdfColor.fromHex('#E6EAF2');
    final muted = PdfColor.fromHex('#687089');

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (context) {
          return pw.Container(
            padding: const pw.EdgeInsets.all(22),
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: border, width: 1.2),
              borderRadius: pw.BorderRadius.circular(18),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          'TicBus',
                          style: pw.TextStyle(
                            color: deepBlue,
                            fontSize: 28,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                        pw.SizedBox(height: 4),
                        pw.Text(
                          'Billet colis',
                          style: pw.TextStyle(
                            color: muted,
                            fontSize: 13,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    pw.Container(
                      padding: const pw.EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                      decoration: pw.BoxDecoration(
                        color: lightRed,
                        borderRadius: pw.BorderRadius.circular(12),
                      ),
                      child: pw.Text(
                        'A presenter en agence',
                        style: pw.TextStyle(
                          color: logoRed,
                          fontSize: 12,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                pw.SizedBox(height: 28),
                pw.Center(
                  child: pw.Column(
                    children: [
                      pw.Text(
                        'Code de validation',
                        style: pw.TextStyle(
                          color: muted,
                          fontSize: 13,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                      pw.SizedBox(height: 8),
                      pw.Text(
                        code,
                        textAlign: pw.TextAlign.center,
                        style: pw.TextStyle(
                          color: deepBlue,
                          fontSize: 25,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                      pw.SizedBox(height: 18),
                      pw.BarcodeWidget(
                        barcode: pw.Barcode.qrCode(),
                        data: code,
                        width: 130,
                        height: 130,
                      ),
                    ],
                  ),
                ),
                pw.SizedBox(height: 26),
                pw.Container(height: 1, color: border),
                pw.SizedBox(height: 18),
                pw.Row(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Expanded(
                      child: _pdfInfoBlock('Numero du package', code, deepBlue, muted),
                    ),
                    pw.SizedBox(width: 18),
                    pw.Expanded(
                      child: _pdfInfoBlock(
                        'Date d envoi',
                        '$date a $time',
                        deepBlue,
                        muted,
                      ),
                    ),
                  ],
                ),
                pw.SizedBox(height: 16),
                pw.Row(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Expanded(
                      child: _pdfInfoBlock(
                        'Expediteur',
                        '$recipientLastName $recipientFirstName'.trim(),
                        deepBlue,
                        muted,
                      ),
                    ),
                    pw.SizedBox(width: 18),
                    pw.Expanded(
                      child: _pdfInfoBlock(
                        'Telephone destinataire',
                        recipientPhone,
                        deepBlue,
                        muted,
                      ),
                    ),
                  ],
                ),
                pw.SizedBox(height: 16),
                pw.Row(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Expanded(
                      child: _pdfInfoBlock(
                        'Nature du colis',
                        parcelNature,
                        deepBlue,
                        muted,
                      ),
                    ),
                    pw.SizedBox(width: 18),
                    pw.Expanded(
                      child: _pdfInfoBlock(
                        'Quantite',
                        'x$parcelCount',
                        deepBlue,
                        muted,
                      ),
                    ),
                  ],
                ),
                pw.SizedBox(height: 16),
                _pdfInfoBlock(
                  'Trajet',
                  '$departureCity -> $destinationCity',
                  deepBlue,
                  muted,
                ),
                pw.Spacer(),
                pw.Container(
                  width: double.infinity,
                  padding: const pw.EdgeInsets.all(12),
                  decoration: pw.BoxDecoration(
                    color: lightRed,
                    borderRadius: pw.BorderRadius.circular(12),
                  ),
                  child: pw.Text(
                    "Les frais d'envoi seront determines par l'equipe TicBus en agence.",
                    textAlign: pw.TextAlign.center,
                    style: pw.TextStyle(
                      color: deepBlue,
                      fontSize: 12,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );

    return pdf.save();
  }

  pw.Widget _pdfInfoBlock(
    String title,
    String value,
    PdfColor deepBlue,
    PdfColor muted,
  ) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          title,
          style: pw.TextStyle(
            color: muted,
            fontSize: 12,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
        pw.SizedBox(height: 6),
        pw.Text(
          value.isEmpty ? '--' : value,
          style: pw.TextStyle(
            color: deepBlue,
            fontSize: 15,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    const Color deepBlue = Color(0xFF060663);
    const Color logoRed = Color(0xFFF80C0D);
    const Color pageBg = Color(0xFFE8F0FF);

    final now = DateTime.now();
    final date =
        '${now.day.toString().padLeft(2, '0')}-${now.month.toString().padLeft(2, '0')}-${now.year}';
    final time =
        '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';

    return Scaffold(
      backgroundColor: pageBg,
      appBar: AppBar(
        backgroundColor: deepBlue,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Votre billet',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(18, 18, 18, 24),
          child: Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: deepBlue.withValues(alpha: 0.12)),
                  boxShadow: [
                    BoxShadow(
                      color: deepBlue.withValues(alpha: 0.06),
                      blurRadius: 16,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: logoRed.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Icon(
                          Icons.local_shipping_rounded,
                          color: logoRed,
                          size: 30,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Center(
                      child: Text(
                        'Code de validation',
                        style: TextStyle(
                          color: deepBlue.withValues(alpha: 0.9),
                          fontWeight: FontWeight.w900,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Center(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          code,
                          maxLines: 1,
                          style: const TextStyle(
                            color: deepBlue,
                            fontWeight: FontWeight.w900,
                            fontSize: 34,
                            letterSpacing: 1,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Center(
                      child: QrImageView(
                        data: code,
                        version: QrVersions.auto,
                        size: 180,
                        padding: const EdgeInsets.all(0),
                        backgroundColor: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: logoRed.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Text(
                        "Les frais d'envoi seront déterminés par l'équipe TicBus en agence",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: deepBlue.withValues(alpha: 0.85),
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    const Divider(height: 1),
                    const SizedBox(height: 10),
                    _InfoRow(
                      leftTitle: 'N° du package',
                      leftValue: code,
                      rightTitle: 'Date d’envoi',
                      rightValue: '$date\n$time',
                    ),
                    const SizedBox(height: 10),
                    _InfoRow(
                      leftTitle: 'Expéditeur',
                      leftValue:
                          '$recipientLastName $recipientFirstName'.trim(),
                      rightTitle: 'Destinataire',
                      rightValue: recipientPhone,
                      isPhone: true,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Nature du colis',
                      style: TextStyle(
                        color: deepBlue.withValues(alpha: 0.75),
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      parcelNature,
                      style: const TextStyle(
                        color: deepBlue,
                        fontWeight: FontWeight.w800,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Quantité',
                      style: TextStyle(
                        color: deepBlue.withValues(alpha: 0.75),
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'x$parcelCount',
                      style: TextStyle(
                        color: deepBlue,
                        fontWeight: FontWeight.w900,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      'Trajet',
                      style: TextStyle(
                        color: deepBlue.withValues(alpha: 0.75),
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '$departureCity → $destinationCity',
                      style: const TextStyle(
                        color: deepBlue,
                        fontWeight: FontWeight.w800,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                height: 58,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: logoRed,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    textStyle: const TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 15.5,
                    ),
                  ),
                  onPressed: () =>
                      _downloadTicketPdf(context, date: date, time: time),
                  icon: const Icon(Icons.picture_as_pdf_rounded, size: 22),
                  label: const Text('Télécharger en PDF'),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 58,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: deepBlue,
                    side: BorderSide(color: deepBlue.withValues(alpha: 0.55)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    textStyle: const TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 15.5,
                    ),
                  ),
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => EnvoisEffectuesPage(
                          code: code,
                          departureCity: departureCity,
                          destinationCity: destinationCity,
                          recipientLastName: recipientLastName,
                          recipientFirstName: recipientFirstName,
                          recipientPhone: recipientPhone,
                          parcelNature: parcelNature,
                          parcelCount: parcelCount,
                        ),
                      ),
                    );
                  },
                  child: const Text('Liste des envois effectués'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String leftTitle;
  final String leftValue;
  final String rightTitle;
  final String rightValue;
  final bool isPhone;

  const _InfoRow({
    required this.leftTitle,
    required this.leftValue,
    required this.rightTitle,
    required this.rightValue,
    this.isPhone = false,
  });

  @override
  Widget build(BuildContext context) {
    const deepBlue = Color(0xFF060663);

    TextStyle valueStyle() {
      return TextStyle(
        color: deepBlue,
        fontWeight: FontWeight.w900,
        fontSize: isPhone ? 15.5 : 16,
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: _Block(
            title: leftTitle,
            value: leftValue,
            valueStyle: valueStyle(),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: _Block(
            title: rightTitle,
            value: rightValue,
            valueStyle: valueStyle(),
          ),
        ),
      ],
    );
  }
}

class _Block extends StatelessWidget {
  final String title;
  final String value;
  final TextStyle valueStyle;

  const _Block({
    required this.title,
    required this.value,
    required this.valueStyle,
  });

  @override
  Widget build(BuildContext context) {
    const deepBlue = Color(0xFF060663);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            color: deepBlue.withValues(alpha: 0.55),
            fontWeight: FontWeight.w900,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          value,
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
          style: valueStyle,
        ),
      ],
    );
  }
}
