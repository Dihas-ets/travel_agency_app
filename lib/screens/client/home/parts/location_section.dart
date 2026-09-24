part of '../home_page.dart';

// Widgets de localisation et de carte des agences utilises sur l accueil client.

class _BeninCityField extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final VoidCallback onTap;

  const _BeninCityField({
    required this.controller,
    required this.label,
    required this.hint,
    required this.onTap,
  });

  @override
  State<_BeninCityField> createState() => _BeninCityFieldState();
}

class _BeninCityFieldState extends State<_BeninCityField> {
  List<String> _villes = [];
  bool _isLoadingVilles = true;

  @override
  void initState() {
    super.initState();
    _loadVilles();
  }

  Future<void> _loadVilles() async {
    try {
      final villes = await LigneService().getVillesDisponibles();
      if (!mounted) return;
      setState(() {
        _villes = villes;
        _isLoadingVilles = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _isLoadingVilles = false);
    }
  }

  Future<void> _showCityPicker(BuildContext context, String pickerTitle) async {
    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (_) {
        final picked = widget.controller.text.trim();
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 8),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        pickerTitle,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1A1A2E),
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close, color: Color(0xFF1A1A2E)),
                    ),
                  ],
                ),
              ),
              if (_isLoadingVilles)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 40),
                  child: Center(child: CircularProgressIndicator(strokeWidth: 2.5)),
                )
              else if (_villes.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 40, horizontal: 24),
                  child: Center(
                    child: Text(
                      'Aucune ville disponible pour le moment.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Color(0xFF7B849B), fontWeight: FontWeight.w600),
                    ),
                  ),
                )
              else
                Flexible(
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: _villes.length,
                    separatorBuilder: (_, __) => Divider(height: 1, color: Colors.grey.shade200),
                    itemBuilder: (context, index) {
                      final city = _villes[index];
                      final isSelected = picked == city;

                      return CheckboxListTile(
                        value: isSelected,
                        onChanged: (_) {
                          widget.controller.text = city;
                          Navigator.pop(context);
                        },
                        activeColor: const Color(0xFF16A34A),
                        checkColor: Colors.white,
                        controlAffinity: ListTileControlAffinity.leading,
                        title: Text(
                          city,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1A1A2E),
                          ),
                        ),
                      );
                    },
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
      child: Row(
        children: [
          const Icon(Icons.location_on_outlined, color: Color(0xFF16A34A), size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.label,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF999999),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                TextField(
                  controller: widget.controller,
                  readOnly: true,
                  showCursor: false,
                  onTap: () async {
                    widget.onTap();
                    await _showCityPicker(
                      context,
                      widget.label == 'De'
                          ? 'Choisir la ville de départ'
                          : 'Choisir la ville d’arrivée',
                    );
                  },
                  decoration: InputDecoration(
                    hintText: widget.hint,
                    hintStyle: const TextStyle(
                      color: Color(0xFF444444),
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(vertical: 4),
                  ),
                  style: const TextStyle(
                    fontSize: 15,
                    color: Color(0xFF1A1A2E),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 44),
        ],
      ),
    );
  }
}
class _AgencyMapCard extends StatefulWidget {
  const _AgencyMapCard();

  @override
  State<_AgencyMapCard> createState() => _AgencyMapCardState();
}

enum _AgencesLoadState { loading, success, error }

class _LocationDisabledCard extends StatefulWidget {
  final bool isLoading;
  final VoidCallback onEnableLocation;

  const _LocationDisabledCard({
    required this.isLoading,
    required this.onEnableLocation,
  });

  @override
  State<_LocationDisabledCard> createState() => _LocationDisabledCardState();
}

class _LocationDisabledCardState extends State<_LocationDisabledCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _attentionController;

  @override
  void initState() {
    super.initState();
    _attentionController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _attentionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pulse = CurvedAnimation(
      parent: _attentionController,
      curve: Curves.easeInOut,
    );
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.07),
            blurRadius: 22,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const SizedBox(
                width: 44,
                height: 44,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: Color(0xFFEAF7EF),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.location_off_rounded,
                    color: Color(0xFF0B4F2A),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Localisation requise',
                  style: TextStyle(
                    color: Color(0xFF0B4F2A),
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: widget.isLoading ? null : widget.onEnableLocation,
              borderRadius: BorderRadius.circular(20),
              child: Ink(
                height: 140,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FBFF),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: const Color(0xFF0B4F2A).withValues(alpha: 0.08),
                  ),
                ),
                child: Center(
                  child: widget.isLoading
                      ? const SizedBox(
                          width: 26,
                          height: 26,
                          child: CircularProgressIndicator(strokeWidth: 3),
                        )
                      : Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: AnimatedBuilder(
                            animation: pulse,
                            builder: (context, child) => Transform.scale(
                              scale: 1 + (pulse.value * 0.05),
                              child: child,
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Text(
                                  'Activez la localisation pour voir les agences proches.',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Color(0xFF5F6B86),
                                    fontSize: 14.5,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 14),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 18,
                                    vertical: 11,
                                  ),
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [Color(0xFF16A34A), Color(0xFF0F9F4A)],
                                      begin: Alignment.centerLeft,
                                      end: Alignment.centerRight,
                                    ),
                                    borderRadius: BorderRadius.circular(16),
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color(0xFF16A34A).withValues(alpha: 0.32),
                                        blurRadius: 14,
                                        offset: const Offset(0, 8),
                                      ),
                                    ],
                                  ),
                                  child: const Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.my_location_rounded,
                                        color: Colors.white,
                                        size: 18,
                                      ),
                                      SizedBox(width: 8),
                                      Text(
                                        'Activé',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w900,
                                          letterSpacing: 0.3,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AgencyMapCardState extends State<_AgencyMapCard> {
  _AgencesLoadState _state = _AgencesLoadState.loading;
  List<Agence> _agences = [];
  final MapController _mapController = MapController(); // ⬅️ AJOUT

  @override
  void initState() {
    super.initState();
    _loadAgences();
  }

  Future<void> _loadAgences() async {
    setState(() => _state = _AgencesLoadState.loading);
    try {
      // ⬇️ AJOUT : récupérer la position GPS de l'utilisateur
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 6),
        ),
      ).timeout(const Duration(seconds: 8));

      // ⬇️ MODIF : on utilise l'endpoint /proches (trié par distance), avec un grand rayon pour tout couvrir
      final agences = await AgenceService().getAgencesProches(
        latitude: position.latitude,
        longitude: position.longitude,
        rayon: 1500, // large pour couvrir tout le Bénin et ses environs
      );

      if (!mounted) return;
      setState(() {
        _agences = agences
            .where((a) => a.latitude != null && a.longitude != null)
            .toList();
        _state = _AgencesLoadState.success;
      });

      // ⬇️ AJOUT : ajuste la caméra pour englober tous les marqueurs
      WidgetsBinding.instance.addPostFrameCallback((_) => _fitBounds());
    } catch (_) {
      if (!mounted) return;
      setState(() => _state = _AgencesLoadState.error);
    }
  }

  // ⬇️ AJOUT : centre + zoom automatique pour voir tous les marqueurs
  void _fitBounds() {
    if (_agences.isEmpty) return;

    if (_agences.length == 1) {
      _mapController.move(
        latlng.LatLng(_agences.first.latitude!, _agences.first.longitude!),
        13,
      );
      return;
    }

    final points = _agences
        .map((a) => latlng.LatLng(a.latitude!, a.longitude!))
        .toList();

    final bounds = LatLngBounds.fromPoints(points);

    _mapController.fitCamera(
      CameraFit.bounds(
        bounds: bounds,
        padding: const EdgeInsets.all(40),
      ),
    );
  }

  void _openFullMap() {
    if (_agences.isEmpty) return;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => _AgencyFullMapPage(agences: _agences),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.07), blurRadius: 22, offset: const Offset(0, 12)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const SizedBox(
                width: 44,
                height: 44,
                child: DecoratedBox(
                  decoration: BoxDecoration(color: Color(0xFFEAF7EF), shape: BoxShape.circle),
                  child: Icon(Icons.map_rounded, color: Color(0xFF0B4F2A)),
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Agences proches',
                  style: TextStyle(color: Color(0xFF0B4F2A), fontSize: 18, fontWeight: FontWeight.w900),
                ),
              ),
              if (_state == _AgencesLoadState.success && _agences.isNotEmpty)
                IconButton(
                  onPressed: _openFullMap,
                  icon: const Icon(Icons.fullscreen_rounded, color: Color(0xFF0B4F2A)),
                  tooltip: 'Agrandir la carte',
                ),
              if (_state != _AgencesLoadState.loading)
                IconButton(
                  onPressed: _loadAgences,
                  icon: const Icon(Icons.refresh_rounded, color: Color(0xFF0B4F2A)),
                ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: SizedBox(
              height: 220,
              width: double.infinity,
              child: GestureDetector(
                onTap: _state == _AgencesLoadState.success && _agences.isNotEmpty ? _openFullMap : null,
                child: _buildMapBody(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMapBody() {
    if (_state == _AgencesLoadState.loading) {
      return const Center(child: CircularProgressIndicator(strokeWidth: 3));
    }

    if (_state == _AgencesLoadState.error) {
      return Container(
        color: const Color(0xFFF8FBFF),
        child: Center(
          child: TextButton.icon(
            onPressed: _loadAgences,
            icon: const Icon(Icons.refresh_rounded, color: Color(0xFF16A34A)),
            label: const Text('Réessayer', style: TextStyle(color: Color(0xFF16A34A), fontWeight: FontWeight.w900)),
          ),
        ),
      );
    }

    if (_agences.isEmpty) {
      return Container(
        color: const Color(0xFFF8FBFF),
        child: const Center(
          child: Text(
            'Aucune agence disponible pour le moment.',
            style: TextStyle(color: Color(0xFF5F6B86), fontWeight: FontWeight.w700),
          ),
        ),
      );
    }

    final center = latlng.LatLng(_agences.first.latitude!, _agences.first.longitude!);

    return FlutterMap(
      mapController: _mapController, // ⬅️ AJOUT
      options: MapOptions(
        initialCenter: center,
        initialZoom: 12,
        interactionOptions: const InteractionOptions(
          flags: InteractiveFlag.none,
        ),
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.fofanavoyage.debug',
        ),
        MarkerLayer(
          markers: _agences.map((agence) {
            return Marker(
              point: latlng.LatLng(agence.latitude!, agence.longitude!),
              width: 60,
              height: 60,
              child: const Icon(Icons.location_on_rounded, color: Color(0xFF16A34A), size: 36),
            );
          }).toList(),
        ),
      ],
    );
  }
}



class _AgencyFullMapPage extends StatefulWidget {
  final List<Agence> agences;

  const _AgencyFullMapPage({required this.agences});

  @override
  State<_AgencyFullMapPage> createState() => _AgencyFullMapPageState();
}

class _AgencyFullMapPageState extends State<_AgencyFullMapPage> {
  final MapController _mapController = MapController();

  Future<void> _openGoogleMaps(Agence agence) async {
    final uri = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=${agence.latitude},${agence.longitude}',
    );
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  void _fitBounds() {
    if (widget.agences.length <= 1) return;

    final points = widget.agences
        .map((a) => latlng.LatLng(a.latitude!, a.longitude!))
        .toList();

    
    final bounds = LatLngBounds.fromPoints(points);

    _mapController.fitCamera(
      CameraFit.bounds(bounds: bounds, padding: const EdgeInsets.all(60)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final center = latlng.LatLng(widget.agences.first.latitude!, widget.agences.first.longitude!);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF0B4F2A),
        elevation: 0,
        title: const Text('Nos agences', style: TextStyle(fontWeight: FontWeight.w900)),
      ),
      body: FlutterMap(
        mapController: _mapController,
        options: MapOptions(
          initialCenter: center,
          initialZoom: 12,
          interactionOptions: const InteractionOptions(flags: InteractiveFlag.all),
          onMapReady: _fitBounds, // ⬅️ AJOUT : ajuste dès que la carte est prête
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.fofanavoyage.debug',
          ),
          MarkerLayer(
            markers: widget.agences.map((agence) {
              return Marker(
                point: latlng.LatLng(agence.latitude!, agence.longitude!),
                width: 70,
                height: 70,
                child: GestureDetector(
                  onTap: () => _openGoogleMaps(agence),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(999),
                          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 6)],
                        ),
                        child: Text(
                          agence.nomAgence,
                          style: const TextStyle(color: Color(0xFF0B4F2A), fontSize: 10, fontWeight: FontWeight.w900),
                        ),
                      ),
                      const Icon(Icons.location_on_rounded, color: Color(0xFF16A34A), size: 32),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
