import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:fofanavoyage/config/couleurs/app_colors.dart';
import 'package:fofanavoyage/services/app_update_service.dart';

class AppUpdateOverlay extends StatefulWidget {
  final Widget child;

  const AppUpdateOverlay({required this.child, super.key});

  @override
  State<AppUpdateOverlay> createState() => _AppUpdateOverlayState();
}

class _AppUpdateOverlayState extends State<AppUpdateOverlay>
    with WidgetsBindingObserver {
  static const double _bubbleSize = 58;
  static const Color _green = Color(0xFF16A34A);
  static const Color _red = AppColors.accentRed;

  AppUpdate? _update;
  bool _isPromptVisible = false;
  bool _isCheckingUpdate = false;
  String? _storeError;
  Offset? _bubblePosition;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    unawaited(_checkForUpdate());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) unawaited(_checkForUpdate());
  }

  Future<void> _checkForUpdate() async {
    if (_isCheckingUpdate) return;
    _isCheckingUpdate = true;
    try {
      final update = await AppUpdateService().getAvailableUpdate();
      if (!mounted) return;
      setState(() {
        if (update == null) {
          _update = null;
          _isPromptVisible = false;
        } else {
          final isNewAnnouncement = _update?.version != update.version;
          _update = update;
          if (isNewAnnouncement) _isPromptVisible = true;
        }
      });
    } on Exception catch (error) {
      debugPrint('Vérification de mise à jour impossible : $error');
    } finally {
      _isCheckingUpdate = false;
    }
  }

  Future<void> _openStore() async {
    final update = _update;
    if (update == null) return;

    try {
      final opened = await launchUrl(
        Uri.parse(update.storeUrl),
        mode: LaunchMode.externalApplication,
      );
      if (!mounted) return;
      setState(() {
        _storeError = opened
            ? null
            : 'Impossible d’ouvrir le store. Réessayez plus tard.';
        if (opened) _isPromptVisible = false;
      });
    } on PlatformException catch (error) {
      if (!mounted) return;
      setState(
        () => _storeError =
            'Impossible d’ouvrir le store : ${error.message ?? error.code}',
      );
    }
  }

  void _dismissPrompt() {
    setState(() {
      _isPromptVisible = false;
      _storeError = null;
    });
  }

  Offset _clampBubblePosition(Offset position, Size size) {
    final maxLeft = (size.width - _bubbleSize - 8).clamp(8.0, double.infinity);
    final maxTop = (size.height - _bubbleSize - 8).clamp(8.0, double.infinity);
    return Offset(
      position.dx.clamp(8.0, maxLeft).toDouble(),
      position.dy.clamp(8.0, maxTop).toDouble(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = Size(constraints.maxWidth, constraints.maxHeight);
        final bubblePosition = _clampBubblePosition(
          _bubblePosition ??
              Offset(size.width - _bubbleSize - 16, size.height * 0.68),
          size,
        );

        return Stack(
          fit: StackFit.expand,
          children: [
            widget.child,
            if (_update != null && !_isPromptVisible)
              Positioned(
                left: bubblePosition.dx,
                top: bubblePosition.dy,
                child: GestureDetector(
                  onPanUpdate: (details) {
                    setState(() {
                      _bubblePosition = _clampBubblePosition(
                        bubblePosition + details.delta,
                        size,
                      );
                    });
                  },
                  onTap: () => setState(() {
                    _isPromptVisible = true;
                    _storeError = null;
                  }),
                  child: Material(
                    color: _red,
                    elevation: 8,
                    shape: const CircleBorder(),
                    child: const SizedBox(
                      width: _bubbleSize,
                      height: _bubbleSize,
                      child: Icon(
                        Icons.upgrade_rounded,
                        size: 30,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            if (_update != null && _isPromptVisible)
              Positioned.fill(
                child: Material(
                  color: Colors.black54,
                  child: Center(
                    child: Semantics(
                      namesRoute: true,
                      label: 'Mise à jour de l’application disponible',
                      child: Dialog(
                        insetPadding: const EdgeInsets.all(24),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: SingleChildScrollView(
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(24, 28, 24, 22),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 58,
                                  height: 58,
                                  decoration: BoxDecoration(
                                    color: AppColors.softRed,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.upgrade_rounded,
                                    size: 30,
                                    color: _red,
                                  ),
                                ),
                                const SizedBox(height: 18),
                                const Text(
                                  'Mise à jour disponible',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'La version ${_update!.version} est disponible.',
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    color: Color(0xFF536170),
                                    height: 1.4,
                                  ),
                                ),
                                if ((_update!.releaseNotes ?? '')
                                    .trim()
                                    .isNotEmpty) ...[
                                  const SizedBox(height: 12),
                                  Text(
                                    _update!.releaseNotes!,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      color: Color(0xFF536170),
                                      height: 1.4,
                                    ),
                                  ),
                                ],
                                if (_storeError != null) ...[
                                  const SizedBox(height: 12),
                                  Text(
                                    _storeError!,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(color: Colors.red),
                                  ),
                                ],
                                const SizedBox(height: 22),
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    onPressed: _openStore,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: _green,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 14,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(14),
                                      ),
                                    ),
                                    child: const Text(
                                      'Mettre à jour',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                  ),
                                ),
                                TextButton(
                                  onPressed: _dismissPrompt,
                                  child: const Text(
                                    'Plus tard',
                                    style: TextStyle(
                                      color: Color(0xFF536170),
                                      fontWeight: FontWeight.w700,
                                    ),
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
              ),
          ],
        );
      },
    );
  }
}
