import 'dart:io';

import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:code_initial/data/local/session_store.dart';
import 'package:code_initial/screens/client/colis/billet_page.dart';
import 'package:code_initial/models/store/colis_store.dart';
import 'package:code_initial/services/colis_service.dart';

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
  bool _isLoadingHistory = false;
  List<ParcelRecord> _remotePending = [];
  List<ParcelRecord> _remoteRegistered = [];

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialTabIndex;
    _fetchRemoteHistory();
  }

  Future<void> _fetchRemoteHistory() async {
    if (!mounted) return;
    setState(() => _isLoadingHistory = true);
    try {
      final list = await ColisService().getHistoriqueClient();
      final pendingList = <ParcelRecord>[];
      final registeredList = <ParcelRecord>[];

      for (final colis in list) {
        final rec = colis.toParcelRecord();
        if (colis.statut == 'brouillon' || colis.statutPaiement != 'payé') {
          pendingList.add(rec);
        } else {
          registeredList.add(rec);
        }
      }

      if (!mounted) return;
      setState(() {
        _remotePending = pendingList;
        _remoteRegistered = registeredList;
        _isLoadingHistory = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _isLoadingHistory = false);
    }
  }

  void _openPendingDetails(ParcelRecord parcel) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => _PendingParcelDetailsPage(
          parcel: parcel,
        ),
      ),
    );
    if (mounted) {
      _fetchRemoteHistory();
    }
  }

  void _openRegisteredTicket(ParcelRecord parcel) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => _RegisteredParcelDetailsPage(
          parcel: parcel,
        ),
      ),
    );
  }

  List<ParcelRecord> _visibleParcels(
    List<ParcelRecord> localParcels,
    List<ParcelRecord> remoteParcels,
  ) {
    // Les données du backend sont la source de vérité prioritaire
    final Map<String, ParcelRecord> map = {};
    for (final p in localParcels) {
      if (!widget.filterClientParcels ||
          !SessionStore.hasClientPhone ||
          p.senderPhone == SessionStore.currentClientPhone) {
        map[p.code] = p;
      }
    }
    // Écrase avec les colis récents du backend
    for (final p in remoteParcels) {
      map[p.code] = p;
    }
    return map.values.toList();
  }

  @override
  Widget build(BuildContext context) {
    final pending = _visibleParcels(ParcelStore.pendingParcels, _remotePending);
    final registered = _visibleParcels(ParcelStore.registeredParcels, _remoteRegistered);
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
              child: _isLoadingHistory
                  ? const Center(
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: _deepBlue,
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _fetchRemoteHistory,
                      color: _deepBlue,
                      child: currentList.isEmpty
                          ? _EmptyState(isRegistered: _selectedIndex == 0)
                          : ListView.separated(
                              physics: const AlwaysScrollableScrollPhysics(
                                parent: BouncingScrollPhysics(),
                              ),
                              padding: const EdgeInsets.fromLTRB(18, 4, 18, 26),
                              itemCount: currentList.length,
                              separatorBuilder: (_, __) =>
                                  const SizedBox(height: 14),
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
            ),
          ],
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

  Color _statusColor(String status) {
    switch (parcel.rawStatus) {
      case 'brouillon':
        return Colors.orange.shade800;
      case 'a_expedier':
        return const Color(0xFF17A34A);
      case 'en_transit':
        return const Color(0xFF2563EB);
      case 'arrive':
        return const Color(0xFF7C3AED);
      case 'livre':
        return const Color(0xFF17A34A);
      case 'perdu':
        return _logoRed;
      default:
        return isRegistered ? const Color(0xFF17A34A) : Colors.orange.shade800;
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusText = isRegistered ? parcel.readableStatus : 'En attente en agence';
    final pillColor = _statusColor(parcel.status);

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
                    text: statusText,
                    color: pillColor,
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${parcel.parcelNature} x${parcel.parcelCount}',
                    style: const TextStyle(
                      color: _deepBlue,
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  Text(
                    parcel.code,
                    style: TextStyle(
                      color: _deepBlue.withValues(alpha: 0.6),
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                'Destinataire : ${parcel.recipientPhone}',
                style: const TextStyle(
                  color: _mutedText,
                  fontSize: 13.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Icon(
                    isRegistered
                        ? Icons.visibility_rounded
                        : Icons.storefront_rounded,
                    color: _deepBlue.withValues(alpha: 0.65),
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      isRegistered
                          ? 'Touchez pour consulter le suivi et le billet'
                          : 'Finalisation et paiement à l\'agence • Touchez pour voir',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: _deepBlue.withValues(alpha: 0.75),
                        fontSize: 12.5,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PendingParcelDetailsPage extends StatelessWidget {
  final ParcelRecord parcel;

  const _PendingParcelDetailsPage({required this.parcel});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _pageBackground,
      appBar: AppBar(
        backgroundColor: _deepBlue,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Détails du colis en attente',
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
              _AgencyPaymentBanner(parcel: parcel),
              const SizedBox(height: 16),
              _ParcelDetailsCard(parcel: parcel),
              const SizedBox(height: 22),
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton.icon(
                  onPressed: () {
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
                          showValidation: false,
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.qr_code_2_rounded, size: 22),
                  label: const Text('Afficher le billet & QR Code'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _deepBlue,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    textStyle: const TextStyle(
                      fontSize: 15.5,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: _deepBlue,
                    side: BorderSide(color: _deepBlue.withValues(alpha: 0.3)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text('Retour à la liste'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RegisteredParcelDetailsPage extends StatelessWidget {
  final ParcelRecord parcel;

  const _RegisteredParcelDetailsPage({required this.parcel});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _pageBackground,
      appBar: AppBar(
        backgroundColor: _deepBlue,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Suivi du colis',
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
              _StatusStepperCard(parcel: parcel),
              const SizedBox(height: 16),
              _ParcelDetailsCard(parcel: parcel),
              const SizedBox(height: 22),
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton.icon(
                  onPressed: () {
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
                  },
                  icon: const Icon(Icons.confirmation_number_outlined, size: 22),
                  label: const Text('Consulter le billet officiel'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _deepBlue,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    textStyle: const TextStyle(
                      fontSize: 15.5,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AgencyPaymentBanner extends StatelessWidget {
  final ParcelRecord parcel;

  const _AgencyPaymentBanner({required this.parcel});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF7ED),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFFDBA74)),
        boxShadow: [
          BoxShadow(
            color: Colors.orange.withValues(alpha: 0.08),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.orange.shade100,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(Icons.storefront_rounded, color: Colors.orange.shade900, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Paiement & Dépôt à l\'agence',
                      style: TextStyle(
                        color: Colors.orange,
                        fontSize: 16.5,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Agence de départ : ${parcel.departureCity}',
                      style: TextStyle(
                        color: Colors.orange.shade800,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Ce colis a été pré-enregistré. Veuillez vous rendre physiquement à l\'agence de départ muni de votre colis pour la pesée et le règlement des frais d\'expédition.',
            style: TextStyle(
              color: Colors.orange,
              fontSize: 13.5,
              height: 1.42,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusStepperCard extends StatelessWidget {
  final ParcelRecord parcel;

  const _StatusStepperCard({required this.parcel});

  int get _stepIndex {
    switch (parcel.rawStatus) {
      case 'brouillon':
        return 0;
      case 'a_expedier':
        return 1;
      case 'en_transit':
        return 2;
      case 'arrive':
        return 3;
      case 'livre':
        return 4;
      default:
        return 1;
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentStep = _stepIndex;
    final steps = [
      'Pré-enregistré',
      'Enregistré en agence',
      'En transit',
      'Arrivé',
      'Livré',
    ];

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
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Statut d\'acheminement',
                style: TextStyle(
                  color: _deepBlue,
                  fontSize: 16.5,
                  fontWeight: FontWeight.w900,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: const Color(0xFF17A34A).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  parcel.readableStatus,
                  style: const TextStyle(
                    color: Color(0xFF17A34A),
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          for (var i = 0; i < steps.length; i++) ...[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  children: [
                    Container(
                      width: 22,
                      height: 22,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: i <= currentStep ? const Color(0xFF17A34A) : Colors.grey.shade300,
                      ),
                      child: Center(
                        child: i <= currentStep
                            ? const Icon(Icons.check, size: 14, color: Colors.white)
                            : Container(width: 8, height: 8, decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.white)),
                      ),
                    ),
                    if (i < steps.length - 1)
                      Container(
                        width: 2,
                        height: 24,
                        color: i < currentStep ? const Color(0xFF17A34A) : Colors.grey.shade300,
                      ),
                  ],
                ),
                const SizedBox(width: 12),
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Text(
                    steps[i],
                    style: TextStyle(
                      color: i <= currentStep ? _deepBlue : _mutedText,
                      fontWeight: i == currentStep ? FontWeight.w900 : FontWeight.w700,
                      fontSize: 13.5,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _ParcelDetailsCard extends StatelessWidget {
  final ParcelRecord parcel;

  const _ParcelDetailsCard({required this.parcel});

  @override
  Widget build(BuildContext context) {
    final qrData = parcel.qrCode ?? parcel.code;

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
          Center(
            child: Column(
              children: [
                Text(
                  'Code de référence',
                  style: TextStyle(
                    color: _mutedText,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  parcel.code,
                  style: const TextStyle(
                    color: _deepBlue,
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.6,
                  ),
                ),
                const SizedBox(height: 12),
                QrImageView(
                  data: qrData,
                  version: QrVersions.auto,
                  size: 130,
                  padding: const EdgeInsets.all(0),
                  backgroundColor: Colors.white,
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          const Divider(height: 1),
          const SizedBox(height: 14),
          _DetailRow(label: 'Départ', value: parcel.departureCity),
          _DetailRow(label: 'Destination', value: parcel.destinationCity),
          _DetailRow(label: 'Destinataire', value: parcel.recipientFullName),
          _DetailRow(label: 'Téléphone dest.', value: parcel.recipientPhone),
          _DetailRow(label: 'Nature du colis', value: parcel.parcelNature),
          _DetailRow(label: 'Nombre de pièces', value: 'x${parcel.parcelCount}'),
          if (parcel.estimatedValue != null && parcel.estimatedValue! > 0)
            _DetailRow(
              label: 'Valeur déclarée',
              value: '${parcel.estimatedValue!.toStringAsFixed(0)} FCFA',
            ),
          _DetailRow(
            label: 'Frais de transport',
            value: (parcel.deliveryFee != null && parcel.deliveryFee!.isNotEmpty)
                ? '${parcel.deliveryFee} FCFA'
                : 'Calculés en agence',
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
            width: 130,
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
      return const SizedBox.shrink();
    }

    if (path.startsWith('http://') || path.startsWith('https://')) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Image.network(
          path,
          width: double.infinity,
          height: 190,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => const SizedBox.shrink(),
        ),
      );
    }

    if (File(path).existsSync()) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Image.file(
          File(path),
          width: double.infinity,
          height: 190,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => const SizedBox.shrink(),
        ),
      );
    }

    return const SizedBox.shrink();
  }
}

class _ParcelThumbnail extends StatelessWidget {
  final ParcelRecord parcel;
  final double size;

  const _ParcelThumbnail({required this.parcel, required this.size});

  @override
  Widget build(BuildContext context) {
    final path = parcel.attachmentPath;

    if (path != null && path.trim().isNotEmpty) {
      if (path.startsWith('http://') || path.startsWith('https://')) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: Image.network(
            path,
            width: size,
            height: size,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => _ImageFallback(size: size),
          ),
        );
      }
      if (File(path).existsSync()) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: Image.file(
            File(path),
            width: size,
            height: size,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => _ImageFallback(size: size),
          ),
        );
      }
    }

    return _ImageFallback(size: size);
  }
}

class _ImageFallback extends StatelessWidget {
  final double size;

  const _ImageFallback({required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: _deepBlue.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _deepBlue.withValues(alpha: 0.16)),
      ),
      child: Icon(Icons.inventory_2_rounded, color: _deepBlue, size: size * 0.5),
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
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.28)),
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
            const SizedBox(height: 6),
            Text(
              isRegistered
                  ? 'Vos colis validés en agence apparaîtront ici.'
                  : 'Vos demandes d\'envoi en attente de passage en agence apparaîtront ici.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: _mutedText,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
