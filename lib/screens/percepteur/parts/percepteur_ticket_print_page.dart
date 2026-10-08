import 'dart:ui' as ui;
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:http/http.dart' as http;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:code_initial/models/ticket_print_settings.dart';
import 'package:code_initial/services/ticket_print_settings_service.dart';

String _formatTravelDate(String value) {
  final date = value.split(RegExp(r'[T ]')).first;
  final match = RegExp(r'^(\d{4})-(\d{2})-(\d{2})$').firstMatch(date);
  if (match == null) return value;
  return '${match.group(3)}/${match.group(2)}/${match.group(1)}';
}

class PercepteurTicketPrintPage extends StatefulWidget {
  final Map<String, dynamic> ticket;
  final VoidCallback? onReturnToHome;

  const PercepteurTicketPrintPage({
    super.key,
    required this.ticket,
    this.onReturnToHome,
  });

  @override
  State<PercepteurTicketPrintPage> createState() =>
      _PercepteurTicketPrintPageState();
}

class _PercepteurTicketPrintPageState extends State<PercepteurTicketPrintPage> {
  late final Future<TicketPrintSettings> _settingsFuture =
      TicketPrintSettingsService().getSettings();

  String get _reference => widget.ticket['reference']?.toString() ?? '';

  String _money(double amount) {
    final rounded = amount.round().toString();
    return '${rounded.replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (match) => '${match.group(1)} ')} FCFA';
  }

  double get _totalAmount {
    final raw = widget.ticket['price']?.toString() ?? '';
    final normalized = raw
        .replaceAll(RegExp(r'[^0-9,.-]'), '')
        .replaceAll(',', '.');
    return double.tryParse(normalized) ?? 0;
  }

  double _number(String key) =>
      double.tryParse(widget.ticket[key]?.toString() ?? '') ?? 0;

  double get _baseAmount {
    final value = widget.ticket['baseAmount'];
    return value == null ? _totalAmount : _number('baseAmount');
  }

  bool get _hasMecef =>
      (widget.ticket['mecefCode']?.toString().trim().isNotEmpty ?? false);

  String get _qrData {
    final mecefQr = widget.ticket['mecefQrCode']?.toString().trim();
    return _hasMecef && mecefQr?.isNotEmpty == true ? mecefQr! : _reference;
  }

  Future<void> _shareTicketPdf(TicketPrintSettings settings) async {
    if (!settings.enabled) {
      _showError('L’impression des billets est désactivée.');
      return;
    }
    try {
      final bytes = await _buildPdf(settings);
      await Printing.layoutPdf(
        name: 'ticket_$_reference.pdf',
        onLayout: (_) async => bytes,
      );
    } catch (error) {
      _showError(
        'Impossible de générer le PDF : '
        '${error.toString().replaceFirst('Exception: ', '')}',
      );
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFFB42318),
      ),
    );
  }

  Future<Uint8List> _buildPdf(TicketPrintSettings settings) async {
    final qrImageData = await QrPainter(
      data: _qrData,
      version: QrVersions.auto,
      gapless: true,
    ).toImageData(480, format: ui.ImageByteFormat.png);
    if (qrImageData == null) {
      throw Exception('Impossible de préparer le QR code du ticket.');
    }

    final qrImage = pw.MemoryImage(qrImageData.buffer.asUint8List());
    final logoImage = await _loadLogo(settings.agencyLogo);
    final document = pw.Document();
    final accent = PdfColor.fromHex(settings.accentColor);
    final format = settings.width == '58mm'
        ? PdfPageFormat.roll57
        : PdfPageFormat.roll80;
    final mecefCode = widget.ticket['mecefCode']?.toString() ?? '';
    final mecefNim = widget.ticket['mecefNim']?.toString() ?? '';
    final mecefCounters = widget.ticket['mecefCounters']?.toString() ?? '';
    final mecefDate = widget.ticket['mecefDate']?.toString() ?? '';
    final issuerName = widget.ticket['issuerName']?.toString() ?? '';
    final cancellationNotice =
        'Annulation possible jusqu’à ${settings.cancellationDelayDays} jour'
        '${settings.cancellationDelayDays > 1 ? 's' : ''} avant le départ. '
        'Au-delà, une retenue de ${settings.cancellationPenaltyPercent}% '
        'peut être appliquée sur le remboursement.';

    document.addPage(
      pw.Page(
        pageFormat: format,
        theme: pw.ThemeData.withFont(
          base: pw.Font.courier(),
          bold: pw.Font.courierBold(),
        ),
        margin: pw.EdgeInsets.zero,
        build: (_) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.stretch,
          children: [
            _tornEdge(format.width, isTop: true),
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
                      _hasMecef
                          ? 'FACTURE NORMALISÉE'
                          : (settings.headerText.isEmpty
                                ? settings.title
                                : settings.headerText),
                      style: pw.TextStyle(
                        color: accent,
                        fontSize: 10.5,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                  ),
                  if (settings.showEmetteur)
                    _metaLine('Émetteur', settings.agencyName),
                  if (settings.showContact && settings.telephone.isNotEmpty)
                    _metaLine('Tél', settings.telephone),
                  if (settings.showContact && settings.email.isNotEmpty)
                    _metaLine('Email', settings.email),
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text(
                        'N° $_reference',
                        style: const pw.TextStyle(
                          color: PdfColors.grey600,
                          fontSize: 7.5,
                        ),
                      ),
                      pw.Text(
                        _formatDate(DateTime.now()),
                        style: const pw.TextStyle(
                          color: PdfColors.grey600,
                          fontSize: 7.5,
                        ),
                      ),
                    ],
                  ),
                  _dashedLine(accent),
                  _pdfRow(
                    'Passager',
                    widget.ticket['passengerName']?.toString() ?? '',
                  ),
                  _routeRow(
                    widget.ticket['departure']?.toString() ?? '',
                    widget.ticket['destination']?.toString() ?? '',
                  ),
                  _pdfRow(
                    'Départ',
                    '${_formatTravelDate(widget.ticket['date']?.toString() ?? '')} · ${widget.ticket['time'] ?? ''}',
                  ),
                  _pdfRow(
                    'Places',
                    '${widget.ticket['passengerCount'] ?? 1} place(s)',
                  ),
                  if ((widget.ticket['phone']?.toString().isNotEmpty ?? false))
                    _pdfRow('Tél', widget.ticket['phone'].toString()),
                  _dashedLine(accent),
                  _pdfRow('Montant HT', _money(_baseAmount), fontSize: 7.5),
                  _pdfRow(
                    'Taxe (${_rate(_number('taxRate'))}%)',
                    _money(_number('taxAmount')),
                    fontSize: 7.5,
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.symmetric(vertical: 4),
                    child: pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Text(
                          'TOTAL TTC',
                          style: pw.TextStyle(
                            color: accent,
                            fontSize: 10.5,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                        pw.Text(
                          _money(_totalAmount),
                          style: pw.TextStyle(
                            color: accent,
                            fontSize: 10.5,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (settings.showEnregistrePar && issuerName.isNotEmpty)
                    _centered(
                      'Facture enregistrée par : $issuerName',
                      PdfColors.grey500,
                      6.75,
                    ),
                  if (settings.showDgi) ...[
                    pw.SizedBox(height: 6),
                    if (_hasMecef)
                      pw.Container(
                        padding: const pw.EdgeInsets.all(6),
                        decoration: pw.BoxDecoration(
                          color: PdfColor.fromHex('#F8FAFC'),
                          border: pw.Border.all(
                            color: PdfColor.fromHex('#CBD5E1'),
                          ),
                          borderRadius: const pw.BorderRadius.all(
                            pw.Radius.circular(4.5),
                          ),
                        ),
                        child: pw.Column(
                          children: [
                            pw.Text(
                              'ÉLÉMENTS DE SÉCURITÉ DGI',
                              style: pw.TextStyle(
                                color: PdfColor.fromHex('#64748B'),
                                fontSize: 6,
                                fontWeight: pw.FontWeight.bold,
                              ),
                            ),
                            _singleLineRow('CODE', mecefCode),
                            if (mecefNim.isNotEmpty)
                              _pdfRow('NIM', mecefNim, fontSize: 6.75),
                            if (mecefCounters.isNotEmpty)
                              _pdfRow(
                                'COMPTEURS',
                                mecefCounters,
                                fontSize: 6.75,
                              ),
                            if (mecefDate.isNotEmpty)
                              _pdfRow(
                                'DATE',
                                _formatMecefDate(mecefDate),
                                fontSize: 6.75,
                              ),
                          ],
                        ),
                      )
                  ],
                  if (settings.showBarcode) ...[
                    pw.SizedBox(height: 6),
                    pw.Center(
                      child: pw.Container(
                        width: 72,
                        height: 72,
                        padding: const pw.EdgeInsets.all(6),
                        decoration: pw.BoxDecoration(
                          color: PdfColors.white,
                          border: pw.Border.all(color: PdfColors.grey300),
                          borderRadius: const pw.BorderRadius.all(
                            pw.Radius.circular(9.6),
                          ),
                        ),
                        child: pw.Image(qrImage, width: 54, height: 54),
                      ),
                    ),
                    pw.SizedBox(height: 6),
                    pw.Center(
                      child: pw.Text(
                        _hasMecef
                            ? 'VÉRIFIER SUR EFACTURE.IMPOTS.BJ'
                            : _reference,
                        style: pw.TextStyle(
                          color: PdfColor.fromHex('#94A3B8'),
                          fontSize: 6,
                        ),
                        textAlign: pw.TextAlign.center,
                      ),
                    ),
                  ],
                  pw.SizedBox(height: 6),
                  pw.Center(
                    child: pw.Text(
                      settings.footerText,
                      style: pw.TextStyle(
                        fontSize: 7.5,
                        color: PdfColors.grey600,
                        fontStyle: pw.FontStyle.italic,
                      ),
                    ),
                  ),
                  if (settings.showCancellationNotice) ...[
                    pw.SizedBox(height: 3),
                    pw.Center(
                      child: pw.Text(
                        cancellationNotice,
                        textAlign: pw.TextAlign.center,
                        style: pw.TextStyle(
                          color: PdfColor.fromHex('#64748B'),
                          fontSize: 6,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            _tornEdge(format.width, isTop: false),
          ],
        ),
      ),
    );
    return document.save();
  }

  Future<pw.MemoryImage?> _loadLogo(String? url) async {
    if (url != null && url.startsWith('http')) {
      try {
        final response = await http
            .get(Uri.parse(url))
            .timeout(const Duration(seconds: 5));
        if (response.statusCode == 200 && response.bodyBytes.isNotEmpty) {
          return pw.MemoryImage(response.bodyBytes);
        }
      } catch (_) {
        // Use the bundled agency logo if the configured logo is unavailable.
      }
    }
    final bytes = await rootBundle.load(
      'assets/images/logo_fofana_no_background.png',
    );
    return pw.MemoryImage(bytes.buffer.asUint8List());
  }

  String _formatDate(DateTime date) =>
      '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';

  String _formatMecefDate(String raw) {
    final date = DateTime.tryParse(raw);
    if (date == null) return raw;
    return '${_formatDate(date)} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}:${date.second.toString().padLeft(2, '0')}';
  }

  String _rate(double value) => value == value.roundToDouble()
      ? value.toStringAsFixed(0)
      : value.toStringAsFixed(2);

  pw.Widget _tornEdge(double width, {required bool isTop}) => pw.SizedBox(
    height: 7.5,
    width: width,
    child: pw.CustomPaint(
      size: PdfPoint(width, 7.5),
      painter: (canvas, size) {
        const teeth = 16;
        final toothWidth = size.x / teeth;
        canvas
          ..setFillColor(PdfColors.grey400)
          ..moveTo(0, isTop ? 0 : size.y);
        for (var index = 0; index < teeth; index++) {
          canvas
            ..lineTo(index * toothWidth + toothWidth / 2, isTop ? size.y : 0)
            ..lineTo((index + 1) * toothWidth, isTop ? 0 : size.y);
        }
        canvas
          ..lineTo(size.x, isTop ? size.y : 0)
          ..lineTo(0, isTop ? size.y : 0)
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

  pw.Widget _pdfRow(String label, String value, {double fontSize = 8.25}) =>
      pw.Padding(
        padding: const pw.EdgeInsets.symmetric(vertical: 2),
        child: pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Expanded(
              flex: 5,
              child: pw.Text(
                label,
                style: pw.TextStyle(
                  color: PdfColor.fromHex('#94A3B8'),
                  fontSize: fontSize,
                ),
              ),
            ),
            pw.Expanded(
              flex: 7,
              child: pw.Text(
                value,
                textAlign: pw.TextAlign.right,
                style: pw.TextStyle(
                  color: PdfColor.fromHex('#1E293B'),
                  fontSize: fontSize,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      );

  pw.Widget _metaLine(String label, String value) => pw.Padding(
    padding: const pw.EdgeInsets.only(bottom: 3),
    child: pw.RichText(
      text: pw.TextSpan(
        style: pw.TextStyle(color: PdfColor.fromHex('#64748B'), fontSize: 7.5),
        children: [
          pw.TextSpan(
            text: '$label : ',
            style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
          ),
          pw.TextSpan(text: value),
        ],
      ),
    ),
  );

  pw.Widget _singleLineRow(String label, String value) => pw.Padding(
    padding: const pw.EdgeInsets.symmetric(vertical: 2.4),
    child: pw.Row(
      children: [
        pw.Expanded(
          flex: 5,
          child: pw.Text(
            label,
            style: pw.TextStyle(
              color: PdfColor.fromHex('#94A3B8'),
              fontSize: 6,
            ),
          ),
        ),
        pw.Expanded(
          flex: 7,
          child: pw.FittedBox(
            fit: pw.BoxFit.scaleDown,
            alignment: pw.Alignment.centerRight,
            child: pw.Text(
              value,
              style: pw.TextStyle(fontSize: 6, fontWeight: pw.FontWeight.bold),
            ),
          ),
        ),
      ],
    ),
  );

  pw.Widget _routeRow(String departure, String destination) => pw.Padding(
    padding: const pw.EdgeInsets.symmetric(vertical: 2.4),
    child: pw.Row(
      children: [
        pw.Expanded(
          flex: 5,
          child: pw.Text(
            'Trajet',
            style: pw.TextStyle(
              color: PdfColor.fromHex('#94A3B8'),
              fontSize: 8.25,
            ),
          ),
        ),
        pw.Expanded(
          flex: 7,
          child: pw.FittedBox(
            fit: pw.BoxFit.scaleDown,
            alignment: pw.Alignment.centerRight,
            child: pw.Text(
              '$departure → $destination',
              style: pw.TextStyle(
                fontSize: 8.25,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    ),
  );

  pw.Widget _centered(String text, PdfColor color, double size) => pw.Padding(
    padding: const pw.EdgeInsets.only(top: 3.2),
    child: pw.Center(
      child: pw.Text(
        text,
        textAlign: pw.TextAlign.center,
        style: pw.TextStyle(color: color, fontSize: size),
      ),
    ),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEAF7EF),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0B4F2A),
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Billet généré',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
      ),
      body: SafeArea(
        child: FutureBuilder<TicketPrintSettings>(
          future: _settingsFuture,
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Impossible de charger le modèle du ticket : ${snapshot.error}',
                        textAlign: TextAlign.center,
                      ),
                      TextButton(
                        onPressed: () => setState(() {}),
                        child: const Text('Réessayer'),
                      ),
                    ],
                  ),
                ),
              );
            }
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }
            final settings = snapshot.data!;
            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(18, 18, 18, 24),
              child: Column(
                children: [
                  _TicketPreview(ticket: widget.ticket, settings: settings),
                  const SizedBox(height: 18),
                  SizedBox(
                    height: 54,
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: settings.enabled
                          ? () => _shareTicketPdf(settings)
                          : null,
                      icon: const Icon(Icons.print_rounded),
                      label: const Text('Imprimer / télécharger le ticket'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF16A34A),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        textStyle: const TextStyle(fontWeight: FontWeight.w900),
                      ),
                    ),
                  ),
                  if (!settings.enabled)
                    const Padding(
                      padding: EdgeInsets.only(top: 10),
                      child: Text(
                        'L’impression des billets est désactivée dans les paramètres.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Color(0xFFB42318)),
                      ),
                    ),
                  if (widget.onReturnToHome != null) ...[
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 54,
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: widget.onReturnToHome,
                        icon: const Icon(Icons.home_rounded),
                        label: const Text("Retour à l'accueil"),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF0B4F2A),
                          side: BorderSide(
                            color: const Color(
                              0xFF0B4F2A,
                            ).withValues(alpha: 0.24),
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          textStyle: const TextStyle(
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _TicketPreview extends StatelessWidget {
  final Map<String, dynamic> ticket;
  final TicketPrintSettings settings;

  const _TicketPreview({required this.ticket, required this.settings});

  Color _colorFromHex(String value) {
    final hex = value.replaceFirst('#', '');
    final parsed = int.tryParse(hex, radix: 16) ?? 0xFF2563EB;
    return Color(hex.length == 6 ? 0xFF000000 | parsed : parsed);
  }

  String _formatMoney(double amount) {
    final value = amount.round().toString().replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
      (match) => '${match.group(1)} ',
    );
    return '$value FCFA';
  }

  Widget _row(String label, String value, {double fontSize = 11}) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 2),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 5,
          child: Text(
            label,
            style: TextStyle(
              color: const Color(0xFF94A3B8),
              fontSize: fontSize,
            ),
          ),
        ),
        Expanded(
          flex: 7,
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: TextStyle(
              color: Color(0xFF1E293B),
              fontSize: fontSize,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    ),
  );

  Widget _metaLine(String label, String value) => Align(
    alignment: Alignment.centerLeft,
    child: Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: RichText(
        text: TextSpan(
          style: const TextStyle(
            color: Color(0xFF64748B),
            fontFamily: 'monospace',
            fontSize: 10,
          ),
          children: [
            TextSpan(
              text: '$label : ',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            TextSpan(text: value),
          ],
        ),
      ),
    ),
  );

  @override
  Widget build(BuildContext context) {
    final accent = _colorFromHex(settings.accentColor);
    final reference = ticket['reference']?.toString() ?? '';
    final mecefCode = ticket['mecefCode']?.toString() ?? '';
    final mecefQr = ticket['mecefQrCode']?.toString().trim();
    final qrValue = mecefCode.isNotEmpty && mecefQr?.isNotEmpty == true
        ? mecefQr!
        : reference;
    final rawTotal = ticket['price']?.toString() ?? '';
    final total =
        double.tryParse(
          rawTotal.replaceAll(RegExp(r'[^0-9,.-]'), '').replaceAll(',', '.'),
        ) ??
        0;
    final base = ticket['baseAmount'] == null
        ? total
        : (double.tryParse(ticket['baseAmount']?.toString() ?? '') ?? 0);
    final tax = double.tryParse(ticket['taxAmount']?.toString() ?? '') ?? 0;
    final rate = double.tryParse(ticket['taxRate']?.toString() ?? '') ?? 0;
    final configuredWidth = settings.width == '58mm' ? 200.0 : 260.0;

    return Center(
      child: ClipPath(
        clipper: const _TicketEdgeClipper(),
        child: Container(
          width: configuredWidth,
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
          color: Colors.white,
          child: DefaultTextStyle(
            style: const TextStyle(fontFamily: 'monospace'),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (settings.agencyLogo?.startsWith('http') == true)
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                      color: Colors.white,
                    ),
                    child: ClipOval(
                      child: Image.network(
                        settings.agencyLogo!,
                        width: 40,
                        height: 40,
                        fit: BoxFit.contain,
                        errorBuilder: (_, _, _) => Image.asset(
                          'assets/images/logo_fofana_no_background.png',
                          width: 40,
                          height: 40,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  )
                else
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                      color: Colors.white,
                    ),
                    child: ClipOval(
                      child: Image.asset(
                        'assets/images/logo_fofana_no_background.png',
                        width: 40,
                        height: 40,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                const SizedBox(height: 4),
                Text(
                  settings.agencyName.toUpperCase(),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Color(0xFF1E293B),
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.25,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  mecefCode.isNotEmpty
                      ? 'FACTURE NORMALISÉE'
                      : (settings.headerText.isEmpty
                            ? settings.title
                            : settings.headerText),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: accent,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                if (settings.showEmetteur) ...[
                  const SizedBox(height: 7),
                  _metaLine('Émetteur', settings.agencyName),
                ],
                if (settings.showContact && settings.telephone.isNotEmpty)
                  _metaLine('Tél', settings.telephone),
                if (settings.showContact && settings.email.isNotEmpty)
                  _metaLine('Email', settings.email),
                const SizedBox(height: 5),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        'N° $reference',
                        style: const TextStyle(
                          color: Color(0xFF94A3B8),
                          fontSize: 10,
                        ),
                      ),
                    ),
                    Text(
                      _formatNow(),
                      style: const TextStyle(
                        color: Color(0xFF64748B),
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
                _TicketDashedDivider(color: accent),
                _row('Passager', ticket['passengerName']?.toString() ?? ''),
                _row(
                  'Trajet',
                  '${ticket['departure'] ?? ''} → ${ticket['destination'] ?? ''}',
                ),
                _row(
                  'Départ',
                  '${_formatTravelDate(ticket['date']?.toString() ?? '')} · ${ticket['time'] ?? ''}',
                ),
                _row('Places', '${ticket['passengerCount'] ?? 1} place(s)'),
                if ((ticket['phone']?.toString().isNotEmpty ?? false))
                  _row('Tél', ticket['phone'].toString()),
                _TicketDashedDivider(color: accent),
                _row('Montant HT', _formatMoney(base), fontSize: 10),
                _row(
                  'Taxe (${rate == rate.roundToDouble() ? rate.toStringAsFixed(0) : rate.toStringAsFixed(2)}%)',
                  _formatMoney(tax),
                  fontSize: 10,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 7),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'TOTAL TTC',
                        style: TextStyle(
                          color: accent,
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      Text(
                        _formatMoney(total),
                        style: TextStyle(
                          color: accent,
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                ),
                if (settings.showEnregistrePar &&
                    (ticket['issuerName']?.toString().isNotEmpty ?? false))
                  Text(
                    'Facture enregistrée par : ${ticket['issuerName']}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Color(0xFF94A3B8),
                      fontSize: 9,
                    ),
                  ),
                if (settings.showDgi) ...[
                  const SizedBox(height: 7),
                  if (mecefCode.isNotEmpty)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        border: Border.all(color: const Color(0xFFCBD5E1)),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Column(
                        children: [
                          const Text(
                            'ÉLÉMENTS DE SÉCURITÉ DGI',
                            style: TextStyle(
                              color: Color(0xFF64748B),
                              fontSize: 8,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1,
                            ),
                          ),
                          _row('CODE', mecefCode, fontSize: 8),
                          if ((ticket['mecefNim']?.toString().isNotEmpty ??
                              false))
                            _row(
                              'NIM',
                              ticket['mecefNim'].toString(),
                              fontSize: 9,
                            ),
                          if ((ticket['mecefCounters']?.toString().isNotEmpty ??
                              false))
                            _row(
                              'COMPTEURS',
                              ticket['mecefCounters'].toString(),
                              fontSize: 9,
                            ),
                          if ((ticket['mecefDate']?.toString().isNotEmpty ??
                              false))
                            _row(
                              'DATE',
                              _formatMecefDateForPreview(
                                ticket['mecefDate'].toString(),
                              ),
                              fontSize: 9,
                            ),
                        ],
                      ),
                    )
                ],
                if (settings.showBarcode) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: QrImageView(
                      data: qrValue,
                      version: QrVersions.auto,
                      size: 72,
                      backgroundColor: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    mecefCode.isNotEmpty
                        ? 'VÉRIFIER SUR EFACTURE.IMPOTS.BJ'
                        : reference,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: const Color(0xFF94A3B8),
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
                    fontSize: 10,
                    fontStyle: FontStyle.italic,
                  ),
                ),
                if (settings.showCancellationNotice) ...[
                  const SizedBox(height: 5),
                  Text(
                    "Annulation possible jusqu'à ${settings.cancellationDelayDays} jour${settings.cancellationDelayDays > 1 ? 's' : ''} avant le départ. Au-delà, une retenue de ${settings.cancellationPenaltyPercent}% peut être appliquée sur le remboursement.",
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Color(0xFF64748B),
                      fontSize: 8,
                      height: 1.25,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatNow() {
    final now = DateTime.now();
    return '${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year}';
  }

  String _formatMecefDateForPreview(String value) {
    final date = DateTime.tryParse(value);
    if (date == null) return value;
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}:${date.second.toString().padLeft(2, '0')}';
  }
}

class _TicketDashedDivider extends StatelessWidget {
  final Color color;

  const _TicketDashedDivider({required this.color});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 5),
    child: LayoutBuilder(
      builder: (context, constraints) {
        final segmentCount = (constraints.maxWidth / 6).floor();
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(
            segmentCount,
            (_) => SizedBox(
              width: 3,
              height: 1,
              child: ColoredBox(color: color.withValues(alpha: 0.4)),
            ),
          ),
        );
      },
    ),
  );
}

class _TicketEdgeClipper extends CustomClipper<Path> {
  const _TicketEdgeClipper();

  @override
  Path getClip(Size size) {
    const teeth = 16;
    final toothWidth = size.width / teeth;
    final path = Path()..moveTo(0, 8);
    for (var i = 0; i < teeth; i++) {
      path
        ..lineTo(i * toothWidth + toothWidth / 2, 0)
        ..lineTo((i + 1) * toothWidth, 8);
    }
    path.lineTo(size.width, size.height - 8);
    for (var i = teeth - 1; i >= 0; i--) {
      path
        ..lineTo(i * toothWidth + toothWidth / 2, size.height)
        ..lineTo(i * toothWidth, size.height - 8);
    }
    return path..close();
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}
