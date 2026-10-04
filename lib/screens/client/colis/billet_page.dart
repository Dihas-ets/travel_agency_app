import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:http/http.dart' as http;
import 'package:qr_flutter/qr_flutter.dart';
import 'package:code_initial/data/local/session_store.dart';
import 'package:code_initial/models/colis_print_settings.dart';
import 'package:code_initial/screens/client/colis/colis_attente_page.dart';
import 'package:code_initial/models/store/colis_store.dart';
import 'package:code_initial/services/colis_print_settings_service.dart';

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
  final String senderName;
  final String senderPhone;
  final double montantBase;
  final double montantTaxe;
  final double taxeTaux;
  final Map<String, dynamic>? mecefResponse;
  final double poidsTotal;
  final String description;
  final String issuerName;
  final String taxGroupLabel;

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
    this.senderName = '',
    this.senderPhone = '',
    this.montantBase = 0,
    this.montantTaxe = 0,
    this.taxeTaux = 0,
    this.mecefResponse,
    this.poidsTotal = 0,
    this.description = '',
    this.issuerName = '',
    this.taxGroupLabel = '',
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
      senderPhone: senderPhone.isNotEmpty
          ? senderPhone
          : SessionStore.currentClientPhone ?? 'Inconnu',
      senderName: senderName.isEmpty ? null : senderName,
      attachmentPath: attachmentPath,
      attachmentName: attachmentName,
      deliveryFee: deliveryFee,
      createdAt: DateTime.now(),
      status: showValidation ? 'Enregistré' : 'En attente',
      amountBase: montantBase,
      taxAmount: montantTaxe,
      taxRate: taxeTaux,
      taxGroupLabel: taxGroupLabel,
      parcelItems: [
        ParcelLine(
          nature: parcelNature,
          quantity: parcelCount,
          weight: parcelCount > 0 ? poidsTotal / parcelCount : 0,
          description: description,
          attachmentPath: attachmentPath,
        ),
      ],
      mecefInfo: mecefResponse == null
          ? null
          : ParcelMecefInfo.fromJson(mecefResponse!),
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
      final settings = await ColisPrintSettingsService().getSettings();
      if (!settings.enabled) {
        throw Exception('L’impression des bordereaux est désactivée.');
      }
      final bytes = await _buildTicketPdf(
        date: date,
        time: time,
        settings: settings,
      );
      final safeCode = code.replaceAll(RegExp(r'[^A-Za-z0-9_-]'), '_');

      await Printing.layoutPdf(
        name: 'bordereau_colis_$safeCode.pdf',
        onLayout: (_) async => bytes,
      );
    } catch (error) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Impossible de générer le PDF du billet : '
            '${error.toString().replaceFirst('Exception: ', '')}',
          ),
          backgroundColor: Color(0xFFB42318),
        ),
      );
    }
  }

  Future<Uint8List> _buildTicketPdf({
    required String date,
    required String time,
    required ColisPrintSettings settings,
  }) async {
    final pdf = pw.Document();
    final accent = PdfColor.fromHex(settings.accentColor);
    final hasMecef = mecefResponse != null;
    final confirmedMecef = mecefResponse?['status']?.toString() == 'confirmed';
    final mecefQr = mecefResponse?['qr_code']?.toString();
    final qrData = confirmedMecef && mecefQr?.isNotEmpty == true
        ? mecefQr!
        : code;
    final qrBytes = await QrPainter(
      data: qrData,
      version: QrVersions.auto,
      gapless: true,
    ).toImageData(480, format: ui.ImageByteFormat.png);
    if (qrBytes == null) {
      throw Exception('Impossible de préparer le QR code du billet.');
    }
    final qrImage = pw.MemoryImage(qrBytes.buffer.asUint8List());
    final logoImage = await _loadLogo(settings);
    final pageFormat = settings.width == '58mm'
        ? PdfPageFormat.roll57
        : PdfPageFormat.roll80;
    final total = double.tryParse(deliveryFee.replaceAll(',', '.')) ?? 0;
    final base = montantBase > 0 ? montantBase : total - montantTaxe;
    final nature = parcelNature.trim().isEmpty ? 'Colis' : parcelNature;
    final fullName = '$recipientLastName $recipientFirstName'.trim();
    final printableDescription = description.length > 30
        ? description.substring(0, 30)
        : description;
    final dateLabel = confirmedMecef
        ? _formatMecefDate(mecefResponse?['date_mecef']?.toString())
        : '$date $time';
    pdf.addPage(
      pw.Page(
        pageFormat: pageFormat,
        theme: pw.ThemeData.withFont(
          base: pw.Font.courier(),
          bold: pw.Font.courierBold(),
        ),
        margin: pw.EdgeInsets.zero,
        build: (_) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.stretch,
          children: [
            _tornEdge(pageFormat.width),
            pw.Padding(
              padding: const pw.EdgeInsets.fromLTRB(12, 12, 12, 6),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.stretch,
                children: [
                  if (logoImage != null)
                    pw.Center(
                      child: pw.Container(
                        width: 30,
                        height: 30,
                        decoration: pw.BoxDecoration(
                          shape: pw.BoxShape.circle,
                          border: pw.Border.all(color: PdfColors.grey300),
                        ),
                        child: pw.ClipOval(child: pw.Image(logoImage)),
                      ),
                    ),
                  pw.Center(
                    child: pw.Text(
                      settings.agencyName.toUpperCase(),
                      style: pw.TextStyle(
                        color: PdfColors.grey800,
                        fontSize: 9,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                  ),
                  pw.SizedBox(height: 3),
                  pw.Center(
                    child: pw.Text(
                      hasMecef
                          ? 'BORDEREAU NORMALISÉ'
                          : (settings.headerText.isEmpty
                                ? settings.title
                                : settings.headerText),
                      textAlign: pw.TextAlign.center,
                      style: pw.TextStyle(
                        color: accent,
                        fontSize: 10,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                  ),
                  if (settings.showEmetteur)
                    _pdfRow('Émetteur', settings.agencyName),
                  if (settings.showContact && settings.telephone.isNotEmpty)
                    _pdfRow('Tél', settings.telephone),
                  if (settings.showContact && settings.email.isNotEmpty)
                    _pdfRow('Email', settings.email),
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Expanded(child: _pdfRow('N°', code)),
                      pw.SizedBox(width: 6),
                      pw.Text(
                        date,
                        style: const pw.TextStyle(
                          color: PdfColors.grey600,
                          fontSize: 8,
                        ),
                      ),
                    ],
                  ),
                  _dashedLine(accent),
                  _pdfRow('Exp.', senderName.isEmpty ? '—' : senderName),
                  _pdfRow('Tél exp.', senderPhone),
                  _pdfRow('Dest.', fullName.isEmpty ? '—' : fullName),
                  _pdfRow('Tél dest.', recipientPhone),
                  _pdfRow('Trajet', '$departureCity → $destinationCity'),
                  _pdfRow('Nature', nature),
                  _pdfRow('Nombre', '$parcelCount colis'),
                  if (poidsTotal > 0)
                    _pdfRow('Poids', '${_formatRate(poidsTotal)} kg'),
                  if (printableDescription.isNotEmpty)
                    _pdfRow('Description', printableDescription),
                  _dashedLine(accent),
                  if (taxGroupLabel.isNotEmpty)
                    _pdfRow('Groupe taxe', taxGroupLabel),
                  _pdfRow('Montant HT', _formatAmount(base)),
                  _pdfRow(
                    'Taxe (${_formatRate(taxeTaux)}%)',
                    _formatAmount(montantTaxe),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.symmetric(vertical: 4),
                    child: pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Text(
                          'TOTAL À PAYER',
                          style: pw.TextStyle(
                            color: accent,
                            fontSize: 10,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                        pw.Text(
                          _formatAmount(total),
                          style: pw.TextStyle(
                            color: accent,
                            fontSize: 10,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (settings.showDgi && hasMecef) ...[
                    pw.SizedBox(height: 6),
                    pw.Container(
                      padding: const pw.EdgeInsets.all(6),
                      decoration: pw.BoxDecoration(
                        color: PdfColors.grey100,
                        border: pw.Border.all(color: PdfColors.grey400),
                        borderRadius: const pw.BorderRadius.all(
                          pw.Radius.circular(4),
                        ),
                      ),
                      child: pw.Column(
                        children: [
                          pw.Text(
                            'ÉLÉMENTS DE SÉCURITÉ DGI',
                            style: pw.TextStyle(
                              color: PdfColors.grey600,
                              fontSize: 7,
                              fontWeight: pw.FontWeight.bold,
                            ),
                          ),
                          _pdfRow(
                            'CODE',
                            mecefResponse?['code_mecef']?.toString() ?? '',
                          ),
                          _pdfRow(
                            'NIM',
                            mecefResponse?['nim']?.toString() ?? '',
                          ),
                          _pdfRow(
                            'COMPT',
                            mecefResponse?['counters']?.toString() ?? '',
                          ),
                          _pdfRow('DATE', dateLabel),
                        ],
                      ),
                    ),
                  ],
                  if (code.isNotEmpty &&
                      (settings.showBarcode || !confirmedMecef)) ...[
                    pw.SizedBox(height: 8),
                    pw.Center(
                      child: pw.Container(
                        padding: const pw.EdgeInsets.all(6),
                        decoration: pw.BoxDecoration(
                          border: pw.Border.all(color: PdfColors.grey300),
                          borderRadius: const pw.BorderRadius.all(
                            pw.Radius.circular(6),
                          ),
                        ),
                        child: pw.Image(qrImage, width: 58, height: 58),
                      ),
                    ),
                    pw.Center(
                      child: pw.Text(
                        confirmedMecef
                            ? 'VÉRIFIER SUR EFACTURE.IMPOTS.BJ'
                            : code,
                        textAlign: pw.TextAlign.center,
                        style: const pw.TextStyle(
                          color: PdfColors.grey500,
                          fontSize: 7,
                        ),
                      ),
                    ),
                  ],
                  if (settings.showEnregistrePar && issuerName.isNotEmpty)
                    _pdfRow('Bordereau enregistré par', issuerName),
                  pw.SizedBox(height: 4),
                  pw.Center(
                    child: pw.Text(
                      settings.footerText,
                      textAlign: pw.TextAlign.center,
                      style: const pw.TextStyle(
                        color: PdfColors.grey500,
                        fontSize: 8,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            _tornEdge(pageFormat.width),
          ],
        ),
      ),
    );

    return pdf.save();
  }

  Future<pw.MemoryImage?> _loadLogo(ColisPrintSettings settings) async {
    final logoUrl = settings.agencyLogo;
    if (logoUrl != null && logoUrl.startsWith('http')) {
      try {
        final response = await http
            .get(Uri.parse(logoUrl))
            .timeout(const Duration(seconds: 5));
        if (response.statusCode == 200 && response.bodyBytes.isNotEmpty) {
          return pw.MemoryImage(response.bodyBytes);
        }
      } catch (_) {}
    }
    try {
      final bytes = await rootBundle.load(
        'assets/images/logo_fofana_no_background.png',
      );
      return pw.MemoryImage(bytes.buffer.asUint8List());
    } catch (_) {
      return null;
    }
  }

  pw.Widget _tornEdge(double width) => pw.SizedBox(
    height: 7.5,
    width: width,
    child: pw.CustomPaint(
      size: PdfPoint(width, 7.5),
      painter: (canvas, size) {
        const teeth = 16;
        final toothWidth = size.x / teeth;
        canvas
          ..setFillColor(PdfColors.white)
          ..moveTo(0, 0);
        for (var index = 0; index < teeth; index++) {
          canvas
            ..lineTo(index * toothWidth + toothWidth / 2, size.y)
            ..lineTo((index + 1) * toothWidth, 0);
        }
        canvas
          ..lineTo(size.x, size.y)
          ..lineTo(0, size.y)
          ..fillPath();
      },
    ),
  );

  pw.Widget _dashedLine(PdfColor accent) => pw.Padding(
    padding: const pw.EdgeInsets.symmetric(vertical: 3.2),
    child: pw.Container(
      decoration: pw.BoxDecoration(
        border: pw.Border(
          top: pw.BorderSide(
            color: accent,
            width: 0.7,
            style: pw.BorderStyle.dashed,
          ),
        ),
      ),
    ),
  );

  pw.Widget _pdfRow(String label, String value) => pw.Padding(
    padding: const pw.EdgeInsets.symmetric(vertical: 2),
    child: pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Expanded(
          flex: 5,
          child: pw.Text(
            label,
            style: const pw.TextStyle(color: PdfColors.grey600, fontSize: 8),
          ),
        ),
        pw.SizedBox(width: 6),
        pw.Expanded(
          flex: 8,
          child: pw.Text(
            value.isEmpty ? '—' : value,
            textAlign: pw.TextAlign.right,
            style: const pw.TextStyle(color: PdfColors.grey800, fontSize: 8),
          ),
        ),
      ],
    ),
  );

  String _formatAmount(double amount) {
    final digits = amount.round().toString();
    final grouped = digits.replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
      (_) => ' ',
    );
    return '$grouped FCFA';
  }

  String _formatRate(double rate) => rate == rate.roundToDouble()
      ? rate.toStringAsFixed(0)
      : rate.toStringAsFixed(2);

  String _formatMecefDate(String? raw) {
    final parsed = raw == null ? null : DateTime.tryParse(raw);
    if (parsed == null) return raw ?? '';
    return '${parsed.day.toString().padLeft(2, '0')}/'
        '${parsed.month.toString().padLeft(2, '0')}/'
        '${parsed.year} '
        '${parsed.hour.toString().padLeft(2, '0')}:'
        '${parsed.minute.toString().padLeft(2, '0')}';
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
                  icon: const Icon(Icons.print_rounded, size: 22),
                  label: const Text('Imprimer le bordereau'),
                ),
              ),
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
