import 'package:flutter/material.dart';
import 'package:code_initial/models/access_session_model.dart';
import 'package:code_initial/screens/percepteur/parts/assignments_section.dart';
import 'package:code_initial/services/affectation_service.dart';

class PercepteurAccessGate extends StatefulWidget {
  final Widget child;
  final AffectationService? service;

  const PercepteurAccessGate({super.key, required this.child, this.service});

  @override
  State<PercepteurAccessGate> createState() => _PercepteurAccessGateState();
}

class _PercepteurAccessGateState extends State<PercepteurAccessGate> {
  late final AffectationService _service =
      widget.service ?? AffectationService();
  bool _isLoading = true;
  bool _hasActiveSession = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _checkSession();
  }

  Future<void> _checkSession() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final response = await _service.getMySession();
      final session = AccessSession.fromJson(response);
      if (!mounted) return;
      setState(() {
        _hasActiveSession = session.isActive;
        _isLoading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _error = error.toString().replaceFirst('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  Future<void> _openSession() async {
    await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => PercepteurConnectionPage(
          service: _service,
          closeOnActivation: true,
        ),
      ),
    );
    if (mounted) await _checkSession();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_hasActiveSession) return widget.child;

    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FF),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.lock_clock_rounded,
                  color: Color(0xFF0B4F2A),
                  size: 56,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Ouverture de session requise',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 8),
                Text(
                  _error ??
                      'Saisissez un code d’accès valide pour réserver ou traiter des colis.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Color(0xFF5F6B86), height: 1.4),
                ),
                const SizedBox(height: 20),
                if (_error != null)
                  TextButton.icon(
                    onPressed: _checkSession,
                    icon: const Icon(Icons.refresh_rounded),
                    label: const Text('Réessayer'),
                  ),
                FilledButton.icon(
                  onPressed: _openSession,
                  icon: const Icon(Icons.lock_open_rounded),
                  label: const Text('Demander l’ouverture de section'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
