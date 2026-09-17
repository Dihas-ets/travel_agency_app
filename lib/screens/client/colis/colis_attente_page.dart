import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:code_initial/data/local/session_store.dart';
import 'package:code_initial/screens/client/colis/billet_page.dart';
import 'package:code_initial/models/store/colis_store.dart';
import 'package:code_initial/models/payment_provider_model.dart';
import 'package:code_initial/services/payment_service.dart';
import 'package:code_initial/services/feexpay_service.dart';
import 'package:code_initial/services/kkiapay_service.dart';

const Color _deepBlue = Color(0xFF0B4F2A);
const Color _logoRed = Color(0xFFE53935);
const Color _pageBackground = Color(0xFFF6F8FF);
const Color _mutedText = Color(0xFF6F7890);

class ColisAttentePage extends StatefulWidget {
  final int initialTabIndex;
  final bool showHeader;
  final bool filterClientParcels;

  const ColisAttentePage({
    super.key,
    this.initialTabIndex = 1,
    this.showHeader = true,
    this.filterClientParcels = false,
  });

  @override
  State<ColisAttentePage> createState() => _ColisAttentePageState();
}

class _ColisAttentePageState extends State<ColisAttentePage> {
  late int _selectedIndex;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialTabIndex;
  }

  void _openPayment(ParcelRecord parcel) async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => _ParcelPaymentPage(parcel: parcel)),
    );
    if (mounted) setState(() {});
  }

  void _openPendingDetails(ParcelRecord parcel) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => _PendingParcelDetailsPage(
          parcel: parcel,
          onPay: () => _openPayment(parcel),
        ),
      ),
    );
    if (mounted) setState(() {});
  }

  void _openRegisteredTicket(ParcelRecord parcel) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => BilletPage(
          code: parcel.code,
          departureCity: parcel.departureCity,
          destinationCity: parcel.destinationCity,
          recipientLastName: parcel.recipientLastName,
          recipientFirstName: parcel.recipientFirstName,
          recipientPhone: parcel.recipientPhone,
          parcelNature: parcel.parcelNature,
          parcelCount: parcel.parcelCount,
          attachmentPath: parcel.attachmentPath,
          attachmentName: parcel.attachmentName,
          deliveryFee: parcel.deliveryFee ?? '',
          showValidation: true,
        ),
      ),
    );
  }

  List<ParcelRecord> _visibleParcels(List<ParcelRecord> parcels) {
    if (!widget.filterClientParcels || !SessionStore.hasClientPhone) {
      return parcels;
    }

    return parcels
        .where(
          (parcel) => parcel.senderPhone == SessionStore.currentClientPhone,
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final pending = _visibleParcels(ParcelStore.pendingParcels);
    final registered = _visibleParcels(ParcelStore.registeredParcels);
    final currentList = _selectedIndex == 0 ? registered : pending;

    return Scaffold(
      backgroundColor: _pageBackground,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 12, 18, 14),
              child: Column(
                children: [
                  if (widget.showHeader) ...[
                    Row(
                      children: [
                        _IconButton(
                          icon: Icons.arrow_back_rounded,
                          onTap: () => Navigator.of(context).maybePop(),
                        ),
                      ],
                    ),
                    const SizedBox(height: 22),
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Liste des colis',
                        style: TextStyle(
                          color: _deepBlue,
                          fontSize: 26,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    _SegmentedTabs(
                      selectedIndex: _selectedIndex,
                      registeredCount: registered.length,
                      pendingCount: pending.length,
                      onChanged: (index) =>
                          setState(() => _selectedIndex = index),
                    ),
                  ],
                ],
              ),
            ),
            Expanded(
              child: currentList.isEmpty
                  ? _EmptyState(isRegistered: _selectedIndex == 0)
                  : ListView.separated(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(18, 4, 18, 26),
                      itemCount: currentList.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 14),
                      itemBuilder: (context, index) {
                        final parcel = currentList[index];
                        return _ParcelListCard(
                          parcel: parcel,
                          isRegistered: _selectedIndex == 0,
                          onTap: _selectedIndex == 0
                              ? () => _openRegisteredTicket(parcel)
                              : () => _openPendingDetails(parcel),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ParcelPaymentPage extends StatefulWidget {
  final ParcelRecord parcel;

  const _ParcelPaymentPage({required this.parcel});

  @override
  State<_ParcelPaymentPage> createState() => _ParcelPaymentPageState();
}

class _ParcelPaymentPageState extends State<_ParcelPaymentPage> {
  List<PaymentProvider> _providers = [];
  bool _isLoadingProviders = true;
  String? _selectedProviderSlug;
  String? _selectedMethod;
  bool _isProcessing = false;
  Timer? _pollingTimer;

  @override
  void initState() {
    super.initState();
    _loadProviders();
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadProviders() async {
    try {
      final providers = await PaymentService().getProvidersActifs();
      if (!mounted) return;
      setState(() {
        _providers = providers;
        _isLoadingProviders = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _isLoadingProviders = false);
    }
  }

  Future<void> _startParcelPayment() async {
    if (_selectedProviderSlug == null || _selectedMethod == null) return;

    setState(() => _isProcessing = true);

    try {
      final result = await PaymentService().initierPaiement(
        payableRef: widget.parcel.code,
        provider: _selectedProviderSlug!,
        method: _selectedMethod!,
        payableType: 'colis',
      );

      final transaction = result['transaction'] as Map<String, dynamic>?;
      final transactionReference = transaction?['reference']?.toString();
      if (transactionReference == null || transactionReference.isEmpty) {
        throw Exception('La référence de transaction est absente.');
      }

      if (result['provider'] == 'feexpay') {
        if (!mounted) return;
        await FeexPayService.openPayment(
          context: context,
          amount: num.tryParse(result['amount']?.toString() ?? '') ?? 0,
          token: result['token']?.toString() ?? '',
          shopId: result['shop_id']?.toString() ?? '',
          reference: transactionReference,
          onResult: (paymentResult) async {
            if (!paymentResult.isSuccess) {
              if (mounted) {
                setState(() => _isProcessing = false);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(paymentResult.message ?? 'Paiement échoué.'),
                  ),
                );
              }
              return;
            }
            final verification = await PaymentService().verifierPaiement(
              reference: transactionReference,
              payableType: 'colis',
              externalId: paymentResult.reference,
            );
            if (mounted && verification['verified'] == true) {
              setState(() => _isProcessing = false);
              _registerParcel('Paiement effectué');
            }
          },
        );
        return;
      }

      if (result['provider'] == 'kkiapay') {
        if (!mounted) return;
        final customer = result['customer'] as Map<String, dynamic>?;
        final externalId = await KkiapayService.openPayment(
          context: context,
          amount: int.tryParse(result['amount']?.toString() ?? '') ?? 0,
          publicKey: result['public_key']?.toString() ?? '',
          sandbox: result['environment']?.toString() != 'live',
          reference: transactionReference,
          phone: customer?['phone']?.toString(),
          name:
              '${customer?['firstname']?.toString() ?? ''} ${customer?['lastname']?.toString() ?? ''}'
                  .trim(),
          email: customer?['email']?.toString(),
        );
        if (externalId == null || externalId.isEmpty) {
          if (mounted) {
            setState(() => _isProcessing = false);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Paiement Kkiapay annulé ou échoué.')),
            );
          }
          return;
        }
        final verification = await PaymentService().verifierPaiement(
          reference: transactionReference,
          payableType: 'colis',
          externalId: externalId,
        );
        if (mounted && verification['verified'] == true) {
          setState(() => _isProcessing = false);
          _registerParcel('Paiement effectué');
        }
        return;
      }

      final paymentUrl = result['payment_url']?.toString();

      if (paymentUrl != null && paymentUrl.isNotEmpty) {
        final uri = Uri.parse(paymentUrl);
        final opened = await launchUrl(
          uri,
          mode: LaunchMode.externalApplication,
        );

        if (!opened) {
          if (!mounted) return;
          setState(() => _isProcessing = false);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Impossible d\'ouvrir la page de paiement.'),
            ),
          );
          return;
        }
      }

      _pollParcelPaymentStatus(transactionReference);
    } catch (e) {
      if (!mounted) return;
      setState(() => _isProcessing = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
    }
  }

  void _pollParcelPaymentStatus(String transactionReference) {
    var attempts = 0;
    const maxAttempts = 45; // 3 minutes

    _pollingTimer = Timer.periodic(const Duration(seconds: 4), (timer) async {
      attempts++;
      if (!mounted) {
        timer.cancel();
        return;
      }

      if (attempts > maxAttempts) {
        timer.cancel();
        setState(() => _isProcessing = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Délai dépassé. Vérifiez le statut du colis.'),
          ),
        );
        return;
      }

      try {
        final result = await PaymentService().verifierPaiement(
          reference: transactionReference,
          payableType: 'colis',
        );
        final verified = result['verified'] == true;

        if (verified) {
          timer.cancel();
          if (!mounted) return;
          setState(() => _isProcessing = false);
          _registerParcel('Paiement effectué');
        }
      } catch (_) {
        // Continue polling
      }
    });
  }

  void _registerParcel(String status) {
    ParcelStore.registerParcel(widget.parcel, status: status);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          status == 'Paiement effectué'
              ? 'Paiement confirmé, colis enregistré'
              : 'Colis enregistré pour paiement à la livraison',
        ),
        backgroundColor: _deepBlue,
      ),
    );
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => const ColisAttentePage(initialTabIndex: 0),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _pageBackground,
      appBar: AppBar(
        backgroundColor: _deepBlue,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Paiement colis',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(18, 22, 18, 26),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _PaymentSummary(parcel: widget.parcel),
              const SizedBox(height: 22),
              const Text(
                'Choix de l\'agrégateur',
                style: TextStyle(
                  color: _deepBlue,
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 14),

              if (_isLoadingProviders)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 24),
                    child: CircularProgressIndicator(strokeWidth: 2.5),
                  ),
                )
              else if (_isProcessing)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: Column(
                    children: const [
                      CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: _deepBlue,
                      ),
                      SizedBox(height: 16),
                      Text(
                        'En attente de confirmation du paiement par le backend...\nRevenez ici une fois le paiement effectué.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: _deepBlue,
                          fontWeight: FontWeight.w700,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                )
              else if (_providers.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Text(
                    'Aucun agrégateur de paiement disponible.',
                    style: TextStyle(
                      color: _mutedText,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                )
              else ...[
                ..._providers.map((provider) {
                  final isSelected = _selectedProviderSlug == provider.slug;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        GestureDetector(
                          onTap: () => setState(() {
                            _selectedProviderSlug = provider.slug;
                            _selectedMethod = null;
                          }),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 14,
                            ),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? _deepBlue.withValues(alpha: 0.08)
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: isSelected
                                    ? _deepBlue
                                    : const Color(0xFFE1E4EC),
                                width: isSelected ? 1.8 : 1,
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  isSelected
                                      ? Icons.check_circle_rounded
                                      : Icons.circle_outlined,
                                  color: isSelected
                                      ? _deepBlue
                                      : const Color(0xFFB1B8C8),
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  provider.name,
                                  style: const TextStyle(
                                    color: _deepBlue,
                                    fontWeight: FontWeight.w900,
                                    fontSize: 15,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        if (isSelected) ...[
                          const SizedBox(height: 8),
                          Padding(
                            padding: const EdgeInsets.only(left: 8),
                            child: Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: provider.methods.entries
                                  .where((m) => m.key != 'all')
                                  .map((m) {
                                    final isSelectedMethod =
                                        _selectedMethod == m.key;
                                    return GestureDetector(
                                      onTap: () => setState(
                                        () => _selectedMethod = m.key,
                                      ),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 14,
                                          vertical: 9,
                                        ),
                                        decoration: BoxDecoration(
                                          color: isSelectedMethod
                                              ? _deepBlue
                                              : const Color(0xFFF2F4F7),
                                          borderRadius: BorderRadius.circular(
                                            999,
                                          ),
                                        ),
                                        child: Text(
                                          m.value,
                                          style: TextStyle(
                                            color: isSelectedMethod
                                                ? Colors.white
                                                : _deepBlue,
                                            fontWeight: FontWeight.w800,
                                            fontSize: 12.5,
                                          ),
                                        ),
                                      ),
                                    );
                                  })
                                  .toList(),
                            ),
                          ),
                        ],
                      ],
                    ),
                  );
                }),
              ],

              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed:
                      (_selectedProviderSlug != null &&
                          _selectedMethod != null &&
                          !_isProcessing)
                      ? _startParcelPayment
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _logoRed,
                    disabledBackgroundColor: _logoRed.withValues(alpha: 0.38),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    textStyle: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  child: const Text('Payer en ligne'),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: OutlinedButton(
                  onPressed: _isProcessing
                      ? null
                      : () => _registerParcel('À la livraison'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: _deepBlue,
                    side: const BorderSide(color: _deepBlue, width: 1.4),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    textStyle: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  child: const Text('À la livraison'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SegmentedTabs extends StatelessWidget {
  final int selectedIndex;
  final int registeredCount;
  final int pendingCount;
  final ValueChanged<int> onChanged;

  const _SegmentedTabs({
    required this.selectedIndex,
    required this.registeredCount,
    required this.pendingCount,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _deepBlue.withValues(alpha: 0.08)),
      ),
      child: Row(
        children: [
          _TabButton(
            label: 'Enregistrés',
            count: registeredCount,
            isSelected: selectedIndex == 0,
            onTap: () => onChanged(0),
          ),
          const SizedBox(width: 6),
          _TabButton(
            label: 'En attente',
            count: pendingCount,
            isSelected: selectedIndex == 1,
            onTap: () => onChanged(1),
          ),
        ],
      ),
    );
  }
}

class _TabButton extends StatelessWidget {
  final String label;
  final int count;
  final bool isSelected;
  final VoidCallback onTap;

  const _TabButton({
    required this.label,
    required this.count,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          height: 48,
          decoration: BoxDecoration(
            color: isSelected ? _deepBlue : Colors.transparent,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Center(
            child: Text(
              '$label ($count)',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: isSelected ? Colors.white : _deepBlue,
                fontWeight: FontWeight.w900,
                fontSize: 14,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ParcelListCard extends StatelessWidget {
  final ParcelRecord parcel;
  final bool isRegistered;
  final VoidCallback? onTap;

  const _ParcelListCard({
    required this.parcel,
    required this.isRegistered,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: _deepBlue.withValues(alpha: 0.08)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 14,
                offset: const Offset(0, 7),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _ParcelThumbnail(parcel: parcel, size: 46),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          parcel.recipientFullName.isEmpty
                              ? 'Destinataire'
                              : parcel.recipientFullName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: _deepBlue,
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${parcel.departureCity} → ${parcel.destinationCity}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: _mutedText,
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  _StatusPill(
                    text: isRegistered ? parcel.status : 'En attente',
                    color: isRegistered ? const Color(0xFF17A34A) : _logoRed,
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Text(
                '${parcel.parcelNature} x${parcel.parcelCount}',
                style: const TextStyle(
                  color: _deepBlue,
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Téléphone : ${parcel.recipientPhone}',
                style: const TextStyle(
                  color: _mutedText,
                  fontSize: 13.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
              if (!isRegistered) ...[
                const SizedBox(height: 16),
                Row(
                  children: [
                    Icon(
                      Icons.touch_app_rounded,
                      color: _deepBlue.withValues(alpha: 0.56),
                      size: 18,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'Touchez pour vérifier les informations et payer',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: _deepBlue.withValues(alpha: 0.68),
                          fontSize: 12.5,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _PendingParcelDetailsPage extends StatelessWidget {
  final ParcelRecord parcel;
  final VoidCallback onPay;

  const _PendingParcelDetailsPage({required this.parcel, required this.onPay});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _pageBackground,
      appBar: AppBar(
        backgroundColor: _deepBlue,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Détails du colis',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(18, 18, 18, 26),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Avant le paiement, l'utilisateur revoit exactement les données
              // saisies dans le formulaire pour éviter les validations trop rapides.
              _ParcelDetailsCard(parcel: parcel),
              const SizedBox(height: 22),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    onPay();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _logoRed,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    textStyle: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  child: const Text('Payer'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ParcelDetailsCard extends StatelessWidget {
  final ParcelRecord parcel;

  const _ParcelDetailsCard({required this.parcel});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _deepBlue.withValues(alpha: 0.08)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _ParcelImageBanner(parcel: parcel),
          const SizedBox(height: 16),
          _DetailRow(label: 'Code', value: parcel.code),
          _DetailRow(label: 'Départ', value: parcel.departureCity),
          _DetailRow(label: 'Destination', value: parcel.destinationCity),
          _DetailRow(label: 'Nom', value: parcel.recipientLastName),
          _DetailRow(label: 'Prénom', value: parcel.recipientFirstName),
          _DetailRow(label: 'Téléphone', value: parcel.recipientPhone),
          _DetailRow(label: 'Nature', value: parcel.parcelNature),
          _DetailRow(label: 'Nombre de colis', value: 'x${parcel.parcelCount}'),
          _DetailRow(
            label: 'Image importée',
            value: parcel.attachmentName ?? 'Image du colis',
            isLast: true,
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isLast;

  const _DetailRow({
    required this.label,
    required this.value,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 118,
            child: Text(
              label,
              style: const TextStyle(
                color: _mutedText,
                fontSize: 13,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value.trim().isEmpty ? '-' : value,
              style: const TextStyle(
                color: _deepBlue,
                fontSize: 14.5,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ParcelImageBanner extends StatelessWidget {
  final ParcelRecord parcel;

  const _ParcelImageBanner({required this.parcel});

  @override
  Widget build(BuildContext context) {
    final path = parcel.attachmentPath;

    if (path == null || path.trim().isEmpty) {
      return _ImageFallback(height: 180, iconSize: 42);
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: Image.file(
        File(path),
        width: double.infinity,
        height: 210,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _ImageFallback(height: 180, iconSize: 42),
      ),
    );
  }
}

class _ParcelThumbnail extends StatelessWidget {
  final ParcelRecord parcel;
  final double size;

  const _ParcelThumbnail({required this.parcel, required this.size});

  @override
  Widget build(BuildContext context) {
    final path = parcel.attachmentPath;

    if (path == null || path.trim().isEmpty) {
      return _ImageFallback(height: size, width: size, iconSize: 22);
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: Image.file(
        File(path),
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) =>
            _ImageFallback(height: size, width: size, iconSize: 22),
      ),
    );
  }
}

class _ImageFallback extends StatelessWidget {
  final double height;
  final double? width;
  final double iconSize;

  const _ImageFallback({
    required this.height,
    this.width,
    required this.iconSize,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width ?? double.infinity,
      height: height,
      decoration: BoxDecoration(
        color: _logoRed.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _logoRed.withValues(alpha: 0.22)),
      ),
      child: Icon(Icons.inventory_2_rounded, color: _logoRed, size: iconSize),
    );
  }
}

class _PaymentSummary extends StatelessWidget {
  final ParcelRecord parcel;

  const _PaymentSummary({required this.parcel});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _deepBlue.withValues(alpha: 0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            parcel.recipientFullName.isEmpty
                ? 'Destinataire'
                : parcel.recipientFullName,
            style: const TextStyle(
              color: _deepBlue,
              fontSize: 17,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${parcel.departureCity} → ${parcel.destinationCity}',
            style: const TextStyle(
              color: _mutedText,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${parcel.parcelNature} x${parcel.parcelCount}',
            style: const TextStyle(
              color: _deepBlue,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _PaymentMethodTile extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;
  final String? selectedValue;
  final VoidCallback onTap;

  const _PaymentMethodTile({
    required this.value,
    required this.label,
    required this.icon,
    required this.selectedValue,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = value == selectedValue;

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          height: 62,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected
                  ? _logoRed.withValues(alpha: 0.55)
                  : _deepBlue.withValues(alpha: 0.08),
            ),
          ),
          child: Row(
            children: [
              Icon(icon, color: isSelected ? _logoRed : _deepBlue),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    color: _deepBlue,
                    fontSize: 15.5,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              Icon(
                isSelected
                    ? Icons.check_circle_rounded
                    : Icons.radio_button_unchecked_rounded,
                color: isSelected ? _logoRed : _mutedText,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  final String text;
  final Color color;

  const _StatusPill({required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.22)),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _IconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _IconButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
        width: 46,
        height: 46,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Icon(icon, color: _deepBlue),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final bool isRegistered;

  const _EmptyState({required this.isRegistered});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isRegistered
                  ? Icons.inventory_2_outlined
                  : Icons.pending_actions_rounded,
              color: _deepBlue.withValues(alpha: 0.45),
              size: 48,
            ),
            const SizedBox(height: 14),
            Text(
              isRegistered
                  ? 'Aucun colis enregistré'
                  : 'Aucun colis en attente',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: _deepBlue,
                fontSize: 17,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
