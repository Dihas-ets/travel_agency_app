import 'package:flutter/material.dart';
import 'package:code_initial/presentation/pages/parcel/billet_page.dart';
import 'package:code_initial/presentation/pages/parcel/parcel_store.dart';

const Color _deepBlue = Color(0xFF060663);
const Color _logoRed = Color(0xFFF80C0D);
const Color _pageBackground = Color(0xFFF6F8FF);
const Color _mutedText = Color(0xFF6F7890);

class ColisAttentePage extends StatefulWidget {
  final int initialTabIndex;

  const ColisAttentePage({super.key, this.initialTabIndex = 1});

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
          showValidation: true,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pending = ParcelStore.pendingParcels;
    final registered = ParcelStore.registeredParcels;
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
                  Row(
                    children: [
                      _IconButton(
                        icon: Icons.arrow_back_rounded,
                        onTap: () => Navigator.of(context).maybePop(),
                      ),
                      const Spacer(),
                      Image.asset(
                        'assets/images/logo_ticbus_no_background.png',
                        height: 44,
                        fit: BoxFit.contain,
                      ),
                      const Spacer(),
                      _NotificationBell(),
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
                    onChanged: (index) => setState(() => _selectedIndex = index),
                  ),
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
                              : null,
                          onPay: _selectedIndex == 1
                              ? () => _openPayment(parcel)
                              : null,
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
  String? _selectedMethod;

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
      MaterialPageRoute(builder: (_) => const ColisAttentePage(initialTabIndex: 0)),
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
                'Moyen de paiement',
                style: TextStyle(
                  color: _deepBlue,
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 14),
              _PaymentMethodTile(
                value: 'moov',
                label: 'Moov Money',
                icon: Icons.phone_android_rounded,
                selectedValue: _selectedMethod,
                onTap: () => setState(() => _selectedMethod = 'moov'),
              ),
              const SizedBox(height: 12),
              _PaymentMethodTile(
                value: 'mtn',
                label: 'MTN Mobile Money',
                icon: Icons.phone_iphone_rounded,
                selectedValue: _selectedMethod,
                onTap: () => setState(() => _selectedMethod = 'mtn'),
              ),
              const SizedBox(height: 12),
              _PaymentMethodTile(
                value: 'celtiis',
                label: 'Celtiis Cash',
                icon: Icons.account_balance_wallet_rounded,
                selectedValue: _selectedMethod,
                onTap: () => setState(() => _selectedMethod = 'celtiis'),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _selectedMethod == null
                      ? null
                      : () => _registerParcel('Paiement effectué'),
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
                  child: const Text('Payer'),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: OutlinedButton(
                  onPressed: () => _registerParcel('À la livraison'),
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
  final VoidCallback? onPay;

  const _ParcelListCard({
    required this.parcel,
    required this.isRegistered,
    this.onTap,
    this.onPay,
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
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: _logoRed.withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(
                      isRegistered
                          ? Icons.verified_rounded
                          : Icons.pending_actions_rounded,
                      color: _logoRed,
                    ),
                  ),
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
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: onPay,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _logoRed,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      textStyle: const TextStyle(
                        fontSize: 15.5,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    child: const Text('Payer'),
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

class _NotificationBell extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: ParcelStore.notificationCount,
      builder: (context, count, _) {
        return Stack(
          clipBehavior: Clip.none,
          children: [
            _IconButton(
              icon: Icons.notifications_none_rounded,
              onTap: () {
                ParcelStore.clearNotifications();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      count == 0
                          ? 'Aucune notification'
                          : '$count notification(s) colis consultée(s)',
                    ),
                    backgroundColor: _deepBlue,
                  ),
                );
              },
            ),
            if (count > 0)
              Positioned(
                right: -2,
                top: -2,
                child: Container(
                  width: 20,
                  height: 20,
                  decoration: const BoxDecoration(
                    color: _logoRed,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      count > 9 ? '9+' : '$count',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        );
      },
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
