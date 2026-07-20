part of 'parcel_pages.dart';

class ParcelMenuContent extends StatelessWidget {
  const ParcelMenuContent({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.only(top: 6, bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _ParcelIntroCard(),
          const SizedBox(height: 14),
          _ParcelActionsGrid(
            onSendParcel: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (_) => const SendParcelPage(),
              );
            },
            onTrackParcel: () => _showComingSoon(context, 'Suivre un colis'),
            onInitiations: () => _openPendingParcels(context),
            onMyParcels: () => _openMyParcels(context),
          ),
        ],
      ),
    );
  }

  void _openPendingParcels(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const ColisAttentePage(
          initialTabIndex: 1,
          filterClientParcels: true,
        ),
      ),
    );
  }

  void _openMyParcels(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const ColisAttentePage(
          initialTabIndex: 0,
          filterClientParcels: true,
        ),
      ),
    );
  }

  void _showComingSoon(BuildContext context, String title) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$title sera bientôt disponible'),
        backgroundColor: _deepBlue,
      ),
    );
  }
}

class _ParcelIntroCard extends StatelessWidget {
  const _ParcelIntroCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: _fofanaGreen.withValues(alpha: 0.12)),
        boxShadow: [
          BoxShadow(
            color: _deepBlue.withValues(alpha: 0.07),
            blurRadius: 18,
            offset: const Offset(0, 9),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: _fofanaGreen.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: _fofanaGreen.withValues(alpha: 0.18)),
            ),
            child: const Icon(
              Icons.local_shipping_rounded,
              color: _fofanaGreen,
              size: 27,
            ),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Gestion des colis',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: _logoRed,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  'Envoyez, suivez et retrouvez rapidement vos opérations.',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Color(0xFF5F6B86),
                    fontSize: 13.2,
                    height: 1.25,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
