import 'package:flutter/material.dart';
import 'package:code_initial/models/models_and_stores.dart';
import 'package:code_initial/features/parcel/presentation/pages/colis_attente_page.dart';
import 'package:code_initial/features/parcel/presentation/pages/parcel_pages.dart';
import 'package:code_initial/presentation/pages/collector/parts/reservation_flow.dart';

// Gestion des colis cote percepteur: modes, listes, table de transit et statuts.

class CollectorColisContent extends StatefulWidget {
  const CollectorColisContent({super.key});

  @override
  State<CollectorColisContent> createState() => CollectorColisContentState();
}

class CollectorColisContentState extends State<CollectorColisContent> {
  static const Color _deepBlue = Color(0xFF0B4F2A);
  static const Color _green = Color(0xFF16A34A);
  static const Color _mutedText = Color(0xFF5F6B86);

  final List<CollectorParcelRecord> _availableParcels = [
    CollectorParcelRecord(
      id: 'CL-2401',
      collectorPhone: '+229 01 61 44 20 90',
      receiverName: 'Aminata Sanni',
      receiverPhone: '+229 01 97 12 43 10',
      image: 'assets/images/coli1.jpg',
      destination: 'Cotonou',
      status: 'En attente',
    ),
    CollectorParcelRecord(
      id: 'CL-2402',
      collectorPhone: '+229 01 66 30 18 75',
      receiverName: 'Boris Adjovi',
      receiverPhone: '+229 01 62 54 88 03',
      image: 'assets/images/coli3.jpg',
      destination: 'Porto-Novo',
      status: 'En attente',
    ),
    CollectorParcelRecord(
      id: 'CL-2403',
      collectorPhone: '+229 01 95 70 11 42',
      receiverName: 'Clarisse Hounkpe',
      receiverPhone: '+229 01 68 13 06 54',
      image: 'assets/images/coli4.jpg',
      destination: 'Abomey',
      status: 'En attente',
    ),
  ];

  final List<CollectorParcelRecord> _transitParcels = [
    CollectorParcelRecord(
      id: 'CL-2398',
      collectorPhone: '+229 01 64 91 82 77',
      receiverName: 'Didier Koto',
      receiverPhone: '+229 01 91 03 24 78',
      image: 'assets/images/coli2.jpg',
      destination: 'Parakou',
      status: 'Arriver',
    ),
  ];

  String? _selectedPhone;
  String _searchQuery = '';
  int _selectedColisMenuIndex = 0;

  List<CollectorParcelRecord> get _filteredParcels {
    if (_searchQuery.isEmpty) return _availableParcels;
    final query = _searchQuery.toLowerCase();
    return _availableParcels.where((parcel) {
      return parcel.id.toLowerCase().contains(query) ||
          parcel.receiverName.toLowerCase().contains(query) ||
          parcel.receiverPhone.toLowerCase().contains(query) ||
          parcel.collectorPhone.toLowerCase().contains(query);
    }).toList();
  }

  CollectorParcelRecord? get _selectedParcel {
    if (_selectedPhone == null) return null;
    for (final parcel in _availableParcels) {
      if (parcel.collectorPhone == _selectedPhone) return parcel;
    }
    return null;
  }

  void _acceptSelectedParcel() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Confirmer',
          style: TextStyle(color: _deepBlue, fontWeight: FontWeight.w900),
        ),
        content: Text(
          'Êtes-vous sûr de vouloir accepter le colis ${_selectedParcel?.id} ?',
          style: const TextStyle(color: _mutedText, height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Non'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              final parcel = _selectedParcel;
              if (parcel == null) return;
              if (_transitParcels.any((item) => item.id == parcel.id)) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Ce colis est deja dans la liste en transit.',
                    ),
                    backgroundColor: _deepBlue,
                  ),
                );
                return;
              }

              setState(() {
                parcel.status = 'Arriver';
                _transitParcels.insert(0, parcel);
                _selectedPhone = null;
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Colis ${parcel.id} accepte.'),
                  backgroundColor: _green,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: _green,
              foregroundColor: Colors.white,
            ),
            child: const Text('Oui'),
          ),
        ],
      ),
    );
  }

  void _clearSelection() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Confirmer',
          style: TextStyle(color: _deepBlue, fontWeight: FontWeight.w900),
        ),
        content: const Text(
          'Êtes-vous sûr de vouloir vider la sélection ?',
          style: TextStyle(color: _mutedText, height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Non'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              setState(() => _selectedPhone = null);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: _deepBlue,
              foregroundColor: Colors.white,
            ),
            child: const Text('Oui'),
          ),
        ],
      ),
    );
  }

  void _removeParcel(CollectorParcelRecord parcel) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Confirmer',
          style: TextStyle(color: _deepBlue, fontWeight: FontWeight.w900),
        ),
        content: Text(
          'Êtes-vous sûr de vouloir retirer le colis ${parcel.id} du transit ?',
          style: const TextStyle(color: _mutedText, height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Non'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              setState(
                () =>
                    _transitParcels.removeWhere((item) => item.id == parcel.id),
              );
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Colis ${parcel.id} retire du transit.'),
                  backgroundColor: _deepBlue,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE53935),
              foregroundColor: Colors.white,
            ),
            child: const Text('Oui'),
          ),
        ],
      ),
    );
  }

  void _toggleStatus(CollectorParcelRecord parcel) {
    setState(() {
      parcel.status = parcel.status == 'Arriver' ? 'Recuperer' : 'Arriver';
    });
  }

  void _showParcelDetail(CollectorParcelRecord parcel) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          parcel.id,
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w900,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: Image.asset(
                parcel.image,
                height: 130,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 12),
            Text('Percepteur : ${parcel.collectorPhone}'),
            Text('Recepteur : ${parcel.receiverName}'),
            Text('Telephone : ${parcel.receiverPhone}'),
            Text('Destination : ${parcel.destination}'),
            Text('Statut : ${parcel.status}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Fermer'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final selectedParcel = _selectedParcel;

    return Column(
      children: [
        CollectorColisModeTabs(
          selectedIndex: _selectedColisMenuIndex,
          onChanged: (index) => setState(() => _selectedColisMenuIndex = index),
        ),
        const SizedBox(height: 14),
        Expanded(
          child: _selectedColisMenuIndex == 0
              ? _buildEmbarquementContent(selectedParcel)
              : const ColisAttentePage(initialTabIndex: 0, showHeader: false),
        ),
      ],
    );
  }

  Widget _buildEmbarquementContent(CollectorParcelRecord? selectedParcel) {
    return Stack(
      children: [
        Positioned.fill(
          child: ListView(
            padding: const EdgeInsets.only(bottom: 120),
            children: [
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: _deepBlue,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: _deepBlue.withValues(alpha: 0.16),
                      blurRadius: 22,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.20),
                        ),
                      ),
                      child: const Icon(
                        Icons.local_shipping_rounded,
                        color: Colors.white,
                        size: 27,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Gestion des colis',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 19,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${_transitParcels.length} colis en transit',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.78),
                              fontSize: 13.5,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 9,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: const Text(
                        'Actif',
                        style: TextStyle(
                          color: Color(0xFFE53935),
                          fontSize: 12.5,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: _deepBlue.withValues(alpha: 0.08)),
                  boxShadow: [
                    BoxShadow(
                      color: _deepBlue.withValues(alpha: 0.07),
                      blurRadius: 18,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Nouveau colis à accepter',
                      style: TextStyle(
                        color: _deepBlue,
                        fontSize: 17,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 5),
                    const Text(
                      'Sélectionnez le numéro du percepteur pour afficher les informations du colis.',
                      style: TextStyle(
                        color: _mutedText,
                        fontSize: 13,
                        height: 1.35,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 16),
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final compact = constraints.maxWidth < 560;
                        final phoneField = DropdownButtonFormField<String>(
                          initialValue: _selectedPhone,
                          isExpanded: true,
                          decoration: collectorColisInputDecoration(
                            label: 'Numero du recepteur',
                            icon: Icons.phone_rounded,
                          ),
                          items: _filteredParcels
                              .map(
                                (parcel) => DropdownMenuItem(
                                  value: parcel.collectorPhone,
                                  child: Text(parcel.collectorPhone),
                                ),
                              )
                              .toList(),
                          onChanged: (value) =>
                              setState(() => _selectedPhone = value),
                        );
                        final receiverField = TextFormField(
                          readOnly: true,
                          initialValue: selectedParcel?.receiverName ?? '',
                          key: ValueKey(selectedParcel?.receiverName ?? ''),
                          decoration: collectorColisInputDecoration(
                            label: 'Nom du recepteur',
                            icon: Icons.person_rounded,
                          ),
                        );

                        if (compact) {
                          return Column(
                            children: [
                              phoneField,
                              const SizedBox(height: 12),
                              receiverField,
                            ],
                          );
                        }

                        return Row(
                          children: [
                            Expanded(child: phoneField),
                            const SizedBox(width: 12),
                            Expanded(child: receiverField),
                          ],
                        );
                      },
                    ),

                    ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        height: 170,
                        width: double.infinity,
                        color: const Color(0xFFF8FBFF),
                        child: selectedParcel == null
                            ? const Center(
                                child: Icon(
                                  Icons.inventory_2_rounded,
                                  color: _green,
                                  size: 54,
                                ),
                              )
                            : Image.asset(
                                selectedParcel.image,
                                fit: BoxFit.cover,
                              ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: selectedParcel == null
                                ? null
                                : _acceptSelectedParcel,
                            icon: const Icon(Icons.check_rounded),
                            label: const Text('Accepter'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _green,
                              foregroundColor: Colors.white,
                              disabledBackgroundColor: _green.withValues(
                                alpha: 0.35,
                              ),
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _selectedPhone == null
                                ? null
                                : _clearSelection,
                            icon: const Icon(Icons.cleaning_services_rounded),
                            label: const Text('Vider'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: _deepBlue,
                              side: BorderSide(
                                color: _deepBlue.withValues(alpha: 0.26),
                                width: 1.3,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Colis en transit',
                      style: TextStyle(
                        color: _deepBlue,
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  Text(
                    '${_transitParcels.length} élément${_transitParcels.length > 1 ? 's' : ''}',
                    style: const TextStyle(
                      color: _mutedText,
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              TextField(
                onChanged: (value) => setState(() => _searchQuery = value),
                decoration: InputDecoration(
                  labelText: 'Rechercher',
                  hintText: 'ID / Nom / Téléphone / N° de coli',
                  prefixIcon: const Icon(Icons.search_rounded, color: _green),
                  filled: true,
                  fillColor: const Color(0xFFF8FBFF),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: Color(0xFFE1E4EC)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: Color(0xFFE1E4EC)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: _green, width: 1.5),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              CollectorTransitParcelTable(
                parcels: _transitParcels,
                onView: _showParcelDetail,
                onRemove: _removeParcel,
                onToggleStatus: _toggleStatus,
              ),
            ],
          ),
        ),
        Positioned(
          bottom: 18,
          right: 18,
          child: FloatingActionButton(
            onPressed: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (_) => const SendParcelPage(showModeTabs: false),
              );
            },
            backgroundColor: _green,
            child: const Icon(Icons.add_rounded),
          ),
        ),
      ],
    );
  }
}

class CollectorColisModeTabs extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onChanged;

  const CollectorColisModeTabs({super.key, 
    required this.selectedIndex,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    const deepBlue = Color(0xFF0B4F2A);

    return Container(
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: deepBlue.withValues(alpha: 0.08)),
        boxShadow: [
          BoxShadow(
            color: deepBlue.withValues(alpha: 0.07),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          CollectorColisModeButton(
            label: 'Embarquement',
            icon: Icons.local_shipping_rounded,
            selected: selectedIndex == 0,
            onTap: () => onChanged(0),
          ),
          const SizedBox(width: 6),
          CollectorColisModeButton(
            label: 'Enregistrement',
            icon: Icons.check_circle_rounded,
            selected: selectedIndex == 1,
            onTap: () => onChanged(1),
          ),
        ],
      ),
    );
  }
}

class CollectorColisModeButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const CollectorColisModeButton({super.key, 
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    const deepBlue = Color(0xFF0B4F2A);
    const green = Color(0xFF16A34A);

    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 11),
          decoration: BoxDecoration(
            color: selected ? green : Colors.transparent,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: selected
                    ? Colors.white
                    : deepBlue.withValues(alpha: 0.72),
                size: 19,
              ),
              const SizedBox(width: 7),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: selected
                        ? Colors.white
                        : deepBlue.withValues(alpha: 0.72),
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
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

InputDecoration collectorColisInputDecoration({
  required String label,
  required IconData icon,
}) {
  return InputDecoration(
    labelText: label,
    prefixIcon: Icon(icon, color: const Color(0xFF16A34A)),
    filled: true,
    fillColor: const Color(0xFFF8FBFF),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: const BorderSide(color: Color(0xFFE1E4EC)),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: const BorderSide(color: Color(0xFFE1E4EC)),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: const BorderSide(color: Color(0xFF16A34A), width: 1.5),
    ),
  );
}

class CollectorTransitParcelTable extends StatelessWidget {
  final List<CollectorParcelRecord> parcels;
  final ValueChanged<CollectorParcelRecord> onView;
  final ValueChanged<CollectorParcelRecord> onRemove;
  final ValueChanged<CollectorParcelRecord> onToggleStatus;

  const CollectorTransitParcelTable({super.key, 
    required this.parcels,
    required this.onView,
    required this.onRemove,
    required this.onToggleStatus,
  });

  @override
  Widget build(BuildContext context) {
    const deepBlue = Color(0xFF0B4F2A);
    const green = Color(0xFF16A34A);
    const mutedText = Color(0xFF5F6B86);

    if (parcels.isEmpty) {
      return const CollectorEmptyCard(
        title: 'Aucun colis en transit',
        message: 'Les colis acceptes apparaitront ici.',
      );
    }

    return Column(
      children: List.generate(parcels.length, (index) {
        final parcel = parcels[index];
        final isRecovered = parcel.status == 'Recuperer';

        return Container(
          margin: EdgeInsets.only(bottom: index == parcels.length - 1 ? 0 : 12),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: deepBlue.withValues(alpha: 0.08)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.asset(
                      parcel.image,
                      width: 58,
                      height: 58,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        width: 58,
                        height: 58,
                        color: const Color(0xFFEAF7EF),
                        child: const Icon(
                          Icons.inventory_2_rounded,
                          color: green,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          parcel.id,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: deepBlue,
                            fontSize: 16.5,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          parcel.receiverName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: mutedText,
                            fontSize: 13.5,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                  CollectorParcelStatusPill(
                    label: isRecovered ? 'Récupéré' : 'Arrivé',
                    strong: isRecovered,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => onView(parcel),
                      icon: const Icon(Icons.visibility_rounded, size: 18),
                      label: const Text('Voir'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: deepBlue,
                        side: BorderSide(
                          color: deepBlue.withValues(alpha: 0.18),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        textStyle: const TextStyle(fontWeight: FontWeight.w900),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => onToggleStatus(parcel),
                      icon: Icon(
                        isRecovered
                            ? Icons.restart_alt_rounded
                            : Icons.check_circle_rounded,
                        size: 18,
                      ),
                      label: Text(isRecovered ? 'Remettre' : 'Récupérer'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: green,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        textStyle: const TextStyle(fontWeight: FontWeight.w900),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filledTonal(
                    onPressed: () => onRemove(parcel),
                    style: IconButton.styleFrom(
                      backgroundColor: const Color(0xFFEAF7EF),
                      foregroundColor: deepBlue,
                    ),
                    icon: const Icon(Icons.delete_outline_rounded),
                    tooltip: 'Retirer',
                  ),
                ],
              ),
            ],
          ),
        );
      }),
    );
  }
}

class CollectorParcelStatusPill extends StatelessWidget {
  final String label;
  final bool strong;

  const CollectorParcelStatusPill({super.key, required this.label, required this.strong});

  @override
  Widget build(BuildContext context) {
    const deepBlue = Color(0xFF0B4F2A);
    const green = Color(0xFF16A34A);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: strong
            ? green.withValues(alpha: 0.12)
            : deepBlue.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: strong
              ? green.withValues(alpha: 0.26)
              : deepBlue.withValues(alpha: 0.14),
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: strong ? green : deepBlue,
          fontSize: 12,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}


