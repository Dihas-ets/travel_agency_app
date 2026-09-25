part of 'pages_colis.dart';

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
            onTrackParcel: () => _openTrackParcelDialog(context),
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

  void _openTrackParcelDialog(BuildContext context) {
    final controller = TextEditingController();
    bool isLoading = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (modalContext) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final bottomInset = MediaQuery.of(context).viewInsets.bottom;

            return Container(
              padding: EdgeInsets.fromLTRB(20, 20, 20, 24 + bottomInset),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: _fofanaGreen.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(Icons.manage_search_rounded, color: _fofanaGreen, size: 24),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'Suivre un colis',
                        style: TextStyle(
                          color: _deepBlue,
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  const Text(
                    'Entrez le numéro de référence du colis (ex: FV-COLIS-...)',
                    style: TextStyle(
                      color: Color(0xFF5F6B86),
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: controller,
                    autofocus: true,
                    style: const TextStyle(
                      color: _deepBlue,
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                    decoration: InputDecoration(
                      hintText: 'ex: FV-COLIS-20260924-0001',
                      prefixIcon: const Icon(Icons.qr_code_rounded, color: _fofanaGreen),
                      filled: true,
                      fillColor: const Color(0xFFF8FBFF),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(color: Color(0xFFE1E4EC)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(color: Color(0xFFE1E4EC)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(color: _fofanaGreen, width: 1.5),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton.icon(
                      onPressed: isLoading
                          ? null
                          : () async {
                              final ref = controller.text.trim();
                              if (ref.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Veuillez saisir une référence valide.'),
                                    backgroundColor: _logoRed,
                                  ),
                                );
                                return;
                              }

                              setModalState(() => isLoading = true);

                              try {
                                final colis = await ColisService().showColis(ref);
                                setModalState(() => isLoading = false);
                                if (!context.mounted) return;

                                if (colis != null) {
                                  Navigator.pop(modalContext);
                                  _showParcelTrackingResult(context, colis);
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Colis introuvable avec la référence "$ref".'),
                                      backgroundColor: _logoRed,
                                    ),
                                  );
                                }
                              } catch (e) {
                                setModalState(() => isLoading = false);
                                if (!context.mounted) return;
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Erreur de recherche : ${e.toString().replaceFirst('Exception: ', '')}'),
                                    backgroundColor: _logoRed,
                                  ),
                                );
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _fofanaGreen,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      icon: isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                            )
                          : const Icon(Icons.search_rounded),
                      label: Text(
                        isLoading ? 'Recherche...' : 'Rechercher',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showParcelTrackingResult(BuildContext context, ColisModel colis) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        String statusLabel;
        Color statusColor;

        switch (colis.statut) {
          case 'brouillon':
            statusLabel = 'Pré-enregistré';
            statusColor = Colors.orange;
            break;
          case 'a_expedier':
            statusLabel = 'À expédier';
            statusColor = _fofanaGreen;
            break;
          case 'en_transit':
            statusLabel = 'En transit';
            statusColor = Colors.blue;
            break;
          case 'arrive':
            statusLabel = 'Arrivé à destination';
            statusColor = Colors.purple;
            break;
          case 'livre':
            statusLabel = 'Livré';
            statusColor = _fofanaGreen;
            break;
          default:
            statusLabel = colis.statut;
            statusColor = Colors.grey;
        }

        return Container(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Détails du colis',
                          style: TextStyle(color: _deepBlue, fontSize: 20, fontWeight: FontWeight.w900),
                        ),
                        Text(
                          colis.reference,
                          style: const TextStyle(color: _fofanaGreen, fontSize: 14, fontWeight: FontWeight.w800),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: statusColor.withValues(alpha: 0.3)),
                      ),
                      child: Text(
                        statusLabel,
                        style: TextStyle(color: statusColor, fontWeight: FontWeight.w900, fontSize: 13),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FBFF),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFE1E4EC)),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Trajet :', style: TextStyle(color: Color(0xFF5F6B86), fontWeight: FontWeight.w700)),
                          Text(
                            '${colis.agenceDepotNom ?? "Départ"} → ${colis.agenceRetraitNom ?? "Arrivée"}',
                            style: const TextStyle(color: _deepBlue, fontWeight: FontWeight.w900),
                          ),
                        ],
                      ),
                      const Divider(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Expéditeur :', style: TextStyle(color: Color(0xFF5F6B86), fontWeight: FontWeight.w700)),
                          Text(
                            colis.expediteurNom?.isNotEmpty == true ? colis.expediteurNom! : (colis.expediteurTel ?? '--'),
                            style: const TextStyle(color: _deepBlue, fontWeight: FontWeight.w800),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Destinataire :', style: TextStyle(color: Color(0xFF5F6B86), fontWeight: FontWeight.w700)),
                          Text(
                            colis.destinataireNom?.isNotEmpty == true ? colis.destinataireNom! : (colis.destinataireTel ?? '--'),
                            style: const TextStyle(color: _deepBlue, fontWeight: FontWeight.w800),
                          ),
                        ],
                      ),
                      const Divider(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Montant :', style: TextStyle(color: Color(0xFF5F6B86), fontWeight: FontWeight.w700)),
                          Text(
                            colis.montant > 0 ? '${colis.montant.toStringAsFixed(0)} FCFA' : 'En attente de calcul',
                            style: const TextStyle(color: _logoRed, fontWeight: FontWeight.w900, fontSize: 16),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Paiement :', style: TextStyle(color: Color(0xFF5F6B86), fontWeight: FontWeight.w700)),
                          Text(
                            colis.statutPaiement == 'payé' ? 'Payé (${colis.modePaiement})' : 'Non payé',
                            style: TextStyle(
                              color: colis.statutPaiement == 'payé' ? _fofanaGreen : Colors.orange,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _deepBlue,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    child: const Text('Fermer', style: TextStyle(fontWeight: FontWeight.w800)),
                  ),
                ),
              ],
            ),
          ),
        );
      },
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
