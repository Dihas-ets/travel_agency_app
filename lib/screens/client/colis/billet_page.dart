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
  final List<ParcelLine> parcelItems;
  final VoidCallback? onReturnToHome;

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
    this.parcelItems = const [],
    this.onReturnToHome,
  });

  List<ParcelLine> get _expandedParcelItems {
    final items = parcelItems.isEmpty
        ? [
            ParcelLine(
              nature: parcelNature,
              quantity: parcelCount,
              weight: parcelCount > 0 ? poidsTotal / parcelCount : 0,
              description: description,
              attachmentPath: attachmentPath,
            ),
          ]
        : parcelItems;
    final expanded = <ParcelLine>[];
    for (final item in items) {
      final quantity = item.quantity > 0 ? item.quantity : 1;
      for (var index = 0; index < quantity; index++) {
        expanded.add(
          ParcelLine(
            nature: item.nature,
            quantity: 1,
            weight: item.weight,
            description: item.description,
            attachmentPath: item.attachmentPath,
          ),
        );
      }
    }
    return expanded;
  }

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
      parcelItems: _expandedParcelItems,
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
    final receiptPageFormat = pageFormat.copyWith(
      height: pageFormat.height + 150,
    );
    final total = double.tryParse(deliveryFee.replaceAll(',', '.')) ?? 0;
    final base = montantBase > 0 ? montantBase : total - montantTaxe;
    final nature = parcelNature.trim().isEmpty ? 'Colis' : parcelNature;
    final fullName = '$recipientLastName $recipientFirstName'.trim();
    final dateLabel = hasMecef
        ? _formatMecefDate(mecefResponse?['date_mecef']?.toString())
        : '$date $time';
    pdf.addPage(
      pw.Page(
        pageFormat: receiptPageFormat,
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
                      pw.Expanded(
                        child: pw.Text(
                          'N° $code',
                          style: const pw.TextStyle(
                            color: PdfColors.grey600,
                            fontSize: 8,
                          ),
                        ),
                      ),
                      pw.Text(
                        hasMecef
                            ? _formatMecefDate(
                                mecefResponse?['date_mecef']?.toString(),
                              ).split(' ').first
                            : _formatCurrentDate(),
                        style: const pw.TextStyle(
                          color: PdfColors.grey600,
                          fontSize: 8,
                        ),
                      ),
                    ],
                  ),
                  _dashedLine(accent),
                  _pdfRow('Exp.', senderName.isEmpty ? '—' : senderName),
                  _pdfRow('Dest.', fullName.isEmpty ? '—' : fullName),
                  _pdfRow('Trajet', '$departureCity → $destinationCity'),
                  _pdfRow('Nature', nature),
                  _pdfRow('Nombre', '$parcelCount colis'),
                  _pdfRow('Poids', '${_formatRate(poidsTotal)} kg'),
                  if (description.trim().isNotEmpty)
                    _pdfRow(
                      'Description',
                      description.trim().length > 30
                          ? '${description.trim().substring(0, 30)}…'
                          : description.trim(),
                    ),
                  _dashedLine(accent),
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
                  if (settings.showEnregistrePar && issuerName.isNotEmpty)
                    pw.Padding(
                      padding: const pw.EdgeInsets.only(top: 3),
                      child: pw.Center(
                        child: pw.Text(
                          'Bordereau enregistré par : $issuerName',
                          textAlign: pw.TextAlign.center,
                          style: const pw.TextStyle(
                            color: PdfColors.grey500,
                            fontSize: 7,
                          ),
                        ),
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
                  if (settings.showDgi && !hasMecef)
                    pw.Container(
                      margin: const pw.EdgeInsets.only(top: 6),
                      padding: const pw.EdgeInsets.all(6),
                      decoration: pw.BoxDecoration(
                        border: pw.Border.all(
                          color: PdfColors.grey300,
                          style: pw.BorderStyle.dashed,
                        ),
                      ),
                      child: pw.Column(
                        mainAxisSize: pw.MainAxisSize.min,
                        children: [
                          pw.Text(
                            'REÇU SIMPLE',
                            textAlign: pw.TextAlign.center,
                            style: pw.TextStyle(
                              color: PdfColors.grey500,
                              fontSize: 7.5,
                              fontWeight: pw.FontWeight.bold,
                              fontStyle: pw.FontStyle.italic,
                            ),
                          ),
                          pw.Text(
                            '(Document non normalisé DGI)',
                            textAlign: pw.TextAlign.center,
                            style: const pw.TextStyle(
                              color: PdfColors.grey500,
                              fontSize: 5.25,
                            ),
                          ),
                        ],
                      ),
                    ),
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
                        child: pw.Image(qrImage, width: 54, height: 54),
                      ),
                    ),
                    pw.Center(
                      child: pw.Text(
                        hasMecef ? 'VÉRIFIER SUR EFACTURE.IMPOTS.BJ' : code,
                        textAlign: pw.TextAlign.center,
                        style: pw.TextStyle(
                          color: PdfColor.fromHex('#94A3B8'),
                          fontSize: 6,
                        ),
                      ),
                    ),
                  ],
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
        '${parsed.minute.toString().padLeft(2, '0')}:'
        '${parsed.second.toString().padLeft(2, '0')}';
  }

  String _formatCurrentDate() {
    final now = DateTime.now();
    return '${now.day.toString().padLeft(2, '0')}/'
        '${now.month.toString().padLeft(2, '0')}/${now.year}';
  }

  Widget _buildTicketReceiptPreview({
    required ColisPrintSettings settings,
    required String date,
    required List<ParcelLine> items,
  }) {
    final parsedAccent = int.tryParse(
      settings.accentColor.replaceFirst('#', ''),
      radix: 16,
    );
    final accent = Color(
      parsedAccent == null
          ? 0xFF0F766E
          : parsedAccent <= 0xFFFFFF
          ? 0xFF000000 | parsedAccent
          : parsedAccent,
    );
    final confirmedMecef = mecefResponse?['status']?.toString() == 'confirmed';
    final mecefQr = mecefResponse?['qr_code']?.toString();
    final qrValue = confirmedMecef && mecefQr?.isNotEmpty == true
        ? mecefQr!
        : code;
    final total = double.tryParse(deliveryFee.replaceAll(',', '.')) ?? 0;
    final base = montantBase > 0 ? montantBase : total - montantTaxe;
    final nature = items.map((item) => item.nature).toSet().join(', ');
    final count = items.fold<int>(0, (sum, item) => sum + item.quantity);

    Widget row(String label, String value) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: Color(0xFF64748B))),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(
                color: Color(0xFF1E293B),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );

    Widget separator() => Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Container(height: 1, color: accent.withValues(alpha: 0.35)),
    );

    Widget fallbackLogo() => Image.asset(
      'assets/images/logo_fofana_no_background.png',
      fit: BoxFit.contain,
      errorBuilder: (_, __, ___) =>
          const Icon(Icons.local_shipping_rounded, color: Color(0xFF0F766E)),
    );

    final logo = settings.agencyLogo;
    final logoWidget = logo != null && logo.startsWith('http')
        ? Image.network(
            logo,
            fit: BoxFit.contain,
            errorBuilder: (_, __, ___) => fallbackLogo(),
          )
        : fallbackLogo();

    return Center(
      child: Container(
        width: settings.width == '58mm' ? 230 : 320,
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: const Color(0xFFE2E8F0)),
          boxShadow: const [
            BoxShadow(
              color: Color(0x14000000),
              blurRadius: 12,
              offset: Offset(0, 5),
            ),
          ],
        ),
        child: DefaultTextStyle(
          style: const TextStyle(fontFamily: 'monospace', fontSize: 11),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ClipOval(
                child: Container(
                  width: 42,
                  height: 42,
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                    shape: BoxShape.circle,
                  ),
                  child: logoWidget,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                settings.agencyName.toUpperCase(),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Color(0xFF1E293B),
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                mecefResponse != null
                    ? 'BORDEREAU NORMALISÉ'
                    : settings.headerText,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: accent,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
              if (settings.showEmetteur) row('Émetteur :', settings.agencyName),
              if (settings.showContact && settings.telephone.isNotEmpty)
                row('Tél :', settings.telephone),
              if (settings.showContact && settings.email.isNotEmpty)
                row('Email :', settings.email),
              row('N° $code', date),
              separator(),
              row('Exp.', senderName.isEmpty ? '—' : senderName),
              row(
                'Dest.',
                '$recipientLastName $recipientFirstName'.trim().isEmpty
                    ? '—'
                    : '$recipientLastName $recipientFirstName'.trim(),
              ),
              row('Trajet', '$departureCity → $destinationCity'),
              row('Nature', nature.isEmpty ? parcelNature : nature),
              row('Nombre', '$count colis'),
              row('Poids', '${_formatRate(poidsTotal)} kg'),
              if (description.trim().isNotEmpty)
                row(
                  'Description',
                  description.trim().length > 30
                      ? '${description.trim().substring(0, 30)}…'
                      : description.trim(),
                ),
              separator(),
              row('Montant HT', _formatAmount(base)),
              row(
                'Taxe (${_formatRate(taxeTaux)}%)',
                _formatAmount(montantTaxe),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 7),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'TOTAL À PAYER',
                        style: TextStyle(
                          color: accent,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Text(
                      deliveryFee.isEmpty
                          ? 'À déterminer'
                          : _formatAmount(total),
                      style: TextStyle(
                        color: accent,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              if (settings.showEnregistrePar && issuerName.isNotEmpty)
                Text(
                  'Bordereau enregistré par : $issuerName',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 9),
                ),
              if (settings.showDgi) ...[
                const SizedBox(height: 7),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(7),
                  decoration: BoxDecoration(
                    border: Border.all(color: const Color(0xFFCBD5E1)),
                    borderRadius: BorderRadius.circular(5),
                    color: const Color(0xFFF8FAFC),
                  ),
                  child: mecefResponse == null
                      ? const Column(
                          children: [
                            Text(
                              'REÇU SIMPLE',
                              style: TextStyle(
                                color: Color(0xFF94A3B8),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              '(Document non normalisé DGI)',
                              style: TextStyle(
                                color: Color(0xFF94A3B8),
                                fontSize: 9,
                              ),
                            ),
                          ],
                        )
                      : Column(
                          children: [
                            const Text(
                              'ÉLÉMENTS DE SÉCURITÉ DGI',
                              style: TextStyle(
                                color: Color(0xFF64748B),
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            row(
                              'CODE',
                              mecefResponse?['code_mecef']?.toString() ?? '',
                            ),
                            row('NIM', mecefResponse?['nim']?.toString() ?? ''),
                            row(
                              'COMPT',
                              mecefResponse?['counters']?.toString() ?? '',
                            ),
                            row(
                              'DATE',
                              _formatMecefDate(
                                mecefResponse?['date_mecef']?.toString(),
                              ),
                            ),
                          ],
                        ),
                ),
              ],
              if (code.isNotEmpty &&
                  (settings.showBarcode || !confirmedMecef)) ...[
                const SizedBox(height: 9),
                QrImageView(
                  data: qrValue,
                  version: QrVersions.auto,
                  size: 92,
                  padding: const EdgeInsets.all(6),
                  backgroundColor: Colors.white,
                ),
                Text(
                  mecefResponse != null
                      ? 'VÉRIFIER SUR EFACTURE.IMPOTS.BJ'
                      : code,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Color(0xFF94A3B8),
                    fontSize: 8,
                    letterSpacing: 1,
                  ),
                ),
              ],
              const SizedBox(height: 8),
              Text(
                settings.footerText,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Color(0xFF94A3B8),
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const Color deepBlue = Color(0xFF0B4F2A);
    const Color logoRed = Color(0xFF16A34A);
    const Color pageBg = Color(0xFFEAF7EF);
    final items = _expandedParcelItems;

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
              FutureBuilder<ColisPrintSettings>(
                future: ColisPrintSettingsService().getSettings(),
                builder: (context, snapshot) {
                  final settings =
                      snapshot.data ?? ColisPrintSettings.fromMap({});
                  return Column(
                    children: [
                      if (snapshot.hasError)
                        const Padding(
                          padding: EdgeInsets.only(bottom: 8),
                          child: Text(
                            'Aperçu standard : configuration du bordereau indisponible.',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Color(0xFFB42318)),
                          ),
                        ),
                      _buildTicketReceiptPreview(
                        settings: settings,
                        date: date,
                        items: items,
                      ),
                    ],
                  );
                },
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
              if (onReturnToHome != null) ...[
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 58,
                  child: OutlinedButton.icon(
                    onPressed: onReturnToHome,
                    icon: const Icon(Icons.home_rounded),
                    label: const Text("Retour à l'accueil"),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: deepBlue,
                      side: BorderSide(color: deepBlue.withValues(alpha: 0.24)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      textStyle: const TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 15.5,
                      ),
                    ),
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
