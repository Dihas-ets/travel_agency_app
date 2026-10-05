import 'package:flutter/material.dart';
import 'package:code_initial/data/local/session_store.dart';
import 'package:code_initial/screens/percepteur/parts/percepteur_access_gate.dart';
import 'package:code_initial/screens/percepteur/parts/tab_content.dart';
import 'package:code_initial/screens/percepteur/parts/notifications_section.dart';
import 'package:code_initial/menus/menu_percepteur/menu_profil_percepteur.dart';
import 'package:code_initial/screens/percepteur/parts/history_news_section.dart';
import 'package:code_initial/services/cash_service.dart';

// Page racine de l espace percepteur: garde le shell Scaffold et delegue les sections aux fichiers part.

class PercepteurHomePage extends StatefulWidget {
  const PercepteurHomePage({super.key});

  @override
  State<PercepteurHomePage> createState() => _PercepteurHomePageState();
}

class _PercepteurHomePageState extends State<PercepteurHomePage> {
  @override
  Widget build(BuildContext context) => PercepteurAccessGate(
    child: _PercepteurWorkspace(key: const ValueKey('percepteur-workspace')),
  );
}

class _PercepteurWorkspace extends StatefulWidget {
  const _PercepteurWorkspace({super.key});

  @override
  State<_PercepteurWorkspace> createState() => _PercepteurWorkspaceState();
}

class _PercepteurWorkspaceState extends State<_PercepteurWorkspace>
    with WidgetsBindingObserver {
  int _currentIndex = 0;
  final CashService _cashService = CashService();
  final TextEditingController _openingAmountController = TextEditingController(
    text: '0',
  );
  final TextEditingController _openingNoteController = TextEditingController();
  bool _isCheckingCash = true;
  bool _isOpeningCash = false;
  bool _hasOpenCash = false;
  bool _cashCheckFailed = false;
  String? _cashError;

  final List<PercepteurTab> _tabs = const [
    PercepteurTab('Voyage', Icons.directions_bus_filled_rounded),
    PercepteurTab('Colis', Icons.inventory_2_rounded),
    PercepteurTab('Depense', Icons.payments_rounded),
    PercepteurTab('Profil', Icons.person_rounded),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkOpenCash();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _openingAmountController.dispose();
    _openingNoteController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _checkOpenCash();
  }

  Future<void> _checkOpenCash() async {
    setState(() {
      _isCheckingCash = true;
      _cashCheckFailed = false;
      _cashError = null;
    });
    try {
      final register = await _cashService.getOpenRegister();
      if (!mounted) return;
      setState(() {
        _hasOpenCash = register != null;
        _isCheckingCash = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _cashCheckFailed = true;
        _cashError = error.toString().replaceFirst('Exception: ', '');
        _isCheckingCash = false;
      });
    }
  }

  Future<void> _openCash() async {
    final agencyId = SessionStore.currentUser?.agenceId;
    final amount = double.tryParse(
      _openingAmountController.text.trim().replaceAll(',', '.'),
    );
    if (agencyId == null) {
      setState(() => _cashError = 'Aucune agence n’est associée à ce compte.');
      return;
    }
    if (amount == null || amount < 0) {
      setState(() => _cashError = 'Saisissez un montant initial valide.');
      return;
    }

    setState(() {
      _isOpeningCash = true;
      _cashError = null;
    });
    try {
      await _cashService.openRegister(
        agencyId: agencyId,
        openingAmount: amount,
        openingNote: _openingNoteController.text.trim(),
      );
      if (!mounted) return;
      setState(() {
        _hasOpenCash = true;
        _isOpeningCash = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _cashError = error.toString().replaceFirst('Exception: ', '');
        _isOpeningCash = false;
      });
    }
  }

  void _openMainMenu() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => PercepteurMainMenuSheet(
        onOpenParcels: () => setState(() => _currentIndex = 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isCheckingCash) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (!_hasOpenCash) {
      return Scaffold(
        backgroundColor: const Color(0xFFF6F8FF),
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 460),
                child: _cashCheckFailed ? _cashErrorView() : _cashOpeningView(),
              ),
            ),
          ),
        ),
      );
    }

    final currentTab = _tabs[_currentIndex];
    const navigationGreen = Color(0xFF16A34A);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFF8FBFF), Color(0xFFFFFFFF), Color(0xFFFFF9F5)],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(22, 12, 22, 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: PercepteurHeaderIconButton(
                        icon: Icons.menu_rounded,
                        onTap: _openMainMenu,
                      ),
                    ),
                    Image.asset(
                      'assets/images/logo_fofana_no_background.png',
                      height: 64,
                      fit: BoxFit.contain,
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: PercepteurNotificationIconButton(),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                const Text(
                  'Espace percepteur',
                  style: TextStyle(
                    color: Color(0xFF0B4F2A),
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  currentTab.title,
                  style: const TextStyle(
                    color: Color(0xFF5F6B86),
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 24),
                Expanded(child: PercepteurTabContent(tab: currentTab)),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Container(
          margin: const EdgeInsets.fromLTRB(18, 0, 18, 14),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(26),
            border: Border.all(color: navigationGreen.withValues(alpha: 0.10)),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF0B4F2A).withValues(alpha: 0.12),
                blurRadius: 24,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Row(
            children: List.generate(_tabs.length, (index) {
              final tab = _tabs[index];
              final isActive = index == _currentIndex;

              return Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _currentIndex = index),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 220),
                    padding: const EdgeInsets.symmetric(vertical: 7),
                    decoration: BoxDecoration(
                      color: isActive ? navigationGreen : Colors.transparent,
                      borderRadius: BorderRadius.circular(20),
                      border: isActive
                          ? Border.all(
                              color: Colors.white.withValues(alpha: 0.30),
                            )
                          : null,
                      boxShadow: isActive
                          ? [
                              BoxShadow(
                                color: navigationGreen.withValues(alpha: 0.24),
                                blurRadius: 12,
                                offset: const Offset(0, 5),
                              ),
                            ]
                          : null,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          tab.icon,
                          color: isActive
                              ? Colors.white
                              : const Color(0xFF7B849B),
                          size: 20,
                        ),
                        const SizedBox(height: 2),
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            tab.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: isActive
                                  ? Colors.white
                                  : const Color(0xFF7B849B),
                              fontSize: 10.8,
                              fontWeight: isActive
                                  ? FontWeight.w900
                                  : FontWeight.w800,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }

  Widget _cashOpeningView() {
    final user = SessionStore.currentUser;
    final agencyName = user?.agence?['nom_agence']?.toString();
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(
          Icons.account_balance_wallet_rounded,
          size: 58,
          color: Color(0xFF16A34A),
        ),
        const SizedBox(height: 14),
        const Text(
          'Ouvrez votre caisse',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Color(0xFF0B4F2A),
            fontSize: 23,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Pour commencer les opérations dans votre espace percepteur, '
          'ouvrez la caisse${agencyName == null ? '' : ' de $agencyName'}.',
          textAlign: TextAlign.center,
          style: const TextStyle(color: Color(0xFF5F6B86), height: 1.45),
        ),
        const SizedBox(height: 22),
        TextField(
          controller: _openingAmountController,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(
            labelText: 'Montant initial en caisse',
            suffixText: 'FCFA',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _openingNoteController,
          decoration: const InputDecoration(
            labelText: 'Note d’ouverture (facultatif)',
            border: OutlineInputBorder(),
          ),
        ),
        if (_cashError != null) ...[
          const SizedBox(height: 12),
          Text(
            _cashError!,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.red),
          ),
          if (_cashError!.toLowerCase().contains('code d’accès'))
            const Padding(
              padding: EdgeInsets.only(top: 6),
              child: Text(
                'Activez d’abord votre code d’accès depuis la section Voyage.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Color(0xFF5F6B86)),
              ),
            ),
        ],
        const SizedBox(height: 18),
        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: _isOpeningCash ? null : _openCash,
            icon: _isOpeningCash
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.lock_open_rounded),
            label: Text(_isOpeningCash ? 'Ouverture...' : 'Ouvrir ma caisse'),
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFF16A34A),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
          ),
        ),
      ],
    );
  }

  Widget _cashErrorView() => Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      const Icon(Icons.cloud_off_rounded, size: 52, color: Colors.red),
      const SizedBox(height: 12),
      const Text(
        'Impossible de vérifier la caisse',
        style: TextStyle(
          color: Color(0xFF0B4F2A),
          fontSize: 20,
          fontWeight: FontWeight.w900,
        ),
      ),
      const SizedBox(height: 8),
      Text(_cashError ?? '', textAlign: TextAlign.center),
      const SizedBox(height: 16),
      FilledButton.icon(
        onPressed: _isCheckingCash ? null : _checkOpenCash,
        icon: const Icon(Icons.refresh_rounded),
        label: const Text('Réessayer'),
      ),
    ],
  );
}
