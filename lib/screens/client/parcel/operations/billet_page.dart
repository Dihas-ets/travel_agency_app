import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:code_initial/data/local/session_store.dart';
import 'package:code_initial/screens/client/parcel/operations/colis_attente_page.dart';
import 'package:code_initial/models/store/parcel_store.dart';

class BilletPage extends StatelessWidget {
  final String code;
  final String departureCity;
  final String destinationCity;
  final String recipientLastName;
  final String recipientFirstName;
  final String recipientPhone;
  final String parcelNature;
  final int parcelCount;
  final String? attachmentPath;
  final String? attachmentName;
  final String deliveryFee;
  final bool showValidation;

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
    required this.deliveryFee,
    this.attachmentPath,
    this.attachmentName,
    this.showValidation = true,
  });

  ParcelRecord _toParcelRecord() {
    return ParcelRecord(
      code: code,
      departureCity: departureCity,
      destinationCity: destinationCity,
      recipientLastName: recipientLastName,
      recipientFirstName: recipientFirstName,
      recipientPhone: recipientPhone,
      parcelNature: parcelNature,
      parcelCount: parcelCount,
      senderPhone: SessionStore.currentClientPhone ?? 'Inconnu',
      attachmentPath: attachmentPath,
      attachmentName: attachmentName,
      deliveryFee: deliveryFee,
      createdAt: DateTime.now(),
      status: showValidation ? 'Enregistré' : 'En attente',
    );
  }

  void _openParcelList(BuildContext context) {
    if (!showValidation) {
      ParcelStore.upsertPending(_toParcelRecord());
    }

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) =>
            ColisAttentePage(initialTabIndex: showValidation ? 0 : 1),
      ),
    );
  }

  Future<void> _showAgencyPaymentMessage(BuildContext context) async {
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Paiement en agence',
          style: TextStyle(
            color: Color(0xFF0B4F2A),
            fontWeight: FontWeight.w900,
          ),
        ),
        content: const Text(
          'Veuillez passer à l\'agence pour payer les frais de ce colis.',
          style: TextStyle(
            color: Color(0xFF0B4F2A),
            fontWeight: FontWeight.w700,
            height: 1.4,
          ),
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF16A34A),
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Compris'),
          ),
        ],
      ),
    );
    if (!context.mounted) return;
    _openParcelList(context);
  }

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
        filename: 'billet_fofana_$safeCode.pdf',
      );
    } catch (_) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Impossible de générer le PDF du billet."),
          backgroundColor: Color(0xFF16A34A),
        ),
      );
    }
  }

  Future<Uint8List> _buildTicketPdf({
    required String date,
    required String time,
  }) async {
    final pdf = pw.Document();
    final deepBlue = PdfColor.fromHex('#0B4F2A');
    final logoRed = PdfColor.fromHex('#16A34A');
    final lightRed = PdfColor.fromHex('#EAF7EF');
    final border = PdfColor.fromHex('#E6EAF2');
    final muted = PdfColor.fromHex('#687089');
    pw.MemoryImage? attachmentImage;

    if (attachmentPath != null && File(attachmentPath!).existsSync()) {
      try {
        attachmentImage = pw.MemoryImage(
          await File(attachmentPath!).readAsBytes(),
        );
      } catch (_) {
        attachmentImage = null;
      }
    }

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
                          'Fofana',
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
                if (showValidation) ...[
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
                ],
                pw.Container(height: 1, color: border),
                pw.SizedBox(height: 18),
                if (showValidation)
                  pw.Row(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Expanded(
                        child: _pdfInfoBlock(
                          'Numero du package',
                          code,
                          deepBlue,
                          muted,
                        ),
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
                  )
                else
                  _pdfInfoBlock(
                    'Date d envoi',
                    '$date a $time',
                    deepBlue,
                    muted,
                  ),
                pw.SizedBox(height: 16),
                pw.Row(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Expanded(
                      child: _pdfInfoBlock(
                        'Destinataire',
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
                if (attachmentImage != null) ...[
                  _pdfInfoBlock(
                    'Fichier importe',
                    attachmentName ?? 'Image du colis',
                    deepBlue,
                    muted,
                  ),
                  pw.SizedBox(height: 8),
                  pw.Container(
                    height: 180,
                    width: double.infinity,
                    decoration: pw.BoxDecoration(
                      border: pw.Border.all(color: border),
                      borderRadius: pw.BorderRadius.circular(12),
                    ),
                    child: pw.ClipRRect(
                      horizontalRadius: 12,
                      verticalRadius: 12,
                      child: pw.Image(attachmentImage, fit: pw.BoxFit.cover),
                    ),
                  ),
                  pw.SizedBox(height: 16),
                ],
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
                  'Frais de livraison',
                  deliveryFee.isEmpty ? '--' : '$deliveryFee CFA',
                  deepBlue,
                  muted,
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
                    "Les frais d'envoi seront determines par l'equipe Fofana en agence.",
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
    const Color deepBlue = Color(0xFF0B4F2A);
    const Color logoRed = Color(0xFF16A34A);
    const Color pageBg = Color(0xFFEAF7EF);
    final hasAttachment =
        attachmentPath != null && attachmentPath!.trim().isNotEmpty;

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
                    if (showValidation) ...[
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
                    ] else
                      Center(
                        child: Text(
                          'Aperçu du billet colis',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: deepBlue.withValues(alpha: 0.9),
                            fontWeight: FontWeight.w900,
                            fontSize: 20,
                          ),
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
                        "Les frais d'envoi seront déterminés par l'équipe Fofana en agence",
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
                    if (showValidation)
                      _InfoRow(
                        leftTitle: 'Expéditeur',
                        leftValue: SessionStore.currentClientPhone ?? '--',
                        rightTitle: 'Statut',
                        rightValue: 'Enregistré',
                      )
                    else
                      _InfoRow(
                        leftTitle: 'Expéditeur',
                        leftValue: SessionStore.currentClientPhone ?? '--',
                        rightTitle: 'Statut',
                        rightValue: 'Aperçu',
                      ),
                    const SizedBox(height: 10),
                    _InfoRow(
                      leftTitle: 'Destinataire',
                      leftValue: '$recipientLastName $recipientFirstName'
                          .trim(),
                      rightTitle: 'Téléphone',
                      rightValue: recipientPhone,
                      isPhone: true,
                    ),
                    const SizedBox(height: 12),
                    _InfoRow(
                      leftTitle: 'Départ',
                      leftValue: departureCity,
                      rightTitle: 'Destination',
                      rightValue: destinationCity,
                    ),
                    const SizedBox(height: 12),
                    _SingleInfoBlock(
                      title: 'Détails colis',
                      value: parcelNature,
                    ),
                    const SizedBox(height: 12),
                    _SingleInfoBlock(
                      title: 'Frais de livraison',
                      value: deliveryFee.isEmpty ? '--' : '$deliveryFee CFA',
                    ),
                    if (hasAttachment) ...[
                      const SizedBox(height: 12),
                      _SingleInfoBlock(
                        title: 'Pièce jointe',
                        value: attachmentName ?? 'Image du colis',
                      ),
                      const SizedBox(height: 14),
                      Text(
                        'Fichier importé',
                        style: TextStyle(
                          color: deepBlue.withValues(alpha: 0.75),
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.file(
                          File(attachmentPath!),
                          width: double.infinity,
                          height: 190,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            height: 74,
                            width: double.infinity,
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF8F9FE),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.insert_drive_file_rounded,
                                  color: logoRed,
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    attachmentName ?? 'Fichier importé',
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      color: deepBlue,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 10),
                    _InfoRow(
                      leftTitle: 'Nature du colis',
                      leftValue: parcelNature,
                      rightTitle: 'Quantité',
                      rightValue: 'x$parcelCount',
                    ),
                    const SizedBox(height: 14),
                    Center(
                      child: Column(
                        children: [
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
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: deepBlue,
                              fontWeight: FontWeight.w800,
                              fontSize: 15,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                height: 58,
                child: ElevatedButton(
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
                  onPressed: showValidation
                      ? null
                      : () => _showAgencyPaymentMessage(context),
                  child: const Text('Suivant'),
                ),
              ),
              if (showValidation) ...[
                const SizedBox(height: 12),
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
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _SingleInfoBlock extends StatelessWidget {
  final String title;
  final String value;

  const _SingleInfoBlock({required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    const deepBlue = Color(0xFF0B4F2A);

    return _Block(
      title: title,
      value: value,
      valueStyle: const TextStyle(
        color: deepBlue,
        fontWeight: FontWeight.w900,
        fontSize: 16,
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
    const deepBlue = Color(0xFF0B4F2A);

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
    const deepBlue = Color(0xFF0B4F2A);

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
