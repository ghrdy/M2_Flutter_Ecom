import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
// ignore: avoid_web_libraries_in_flutter
import 'dart:js' as js;

/// Widget pour afficher un bouton d'installation PWA sur le web
class PWAInstallButton extends StatefulWidget {
  final String? text;
  final IconData? icon;
  final Color? backgroundColor;
  final Color? textColor;

  const PWAInstallButton({
    super.key,
    this.text,
    this.icon,
    this.backgroundColor,
    this.textColor,
  });

  @override
  State<PWAInstallButton> createState() => _PWAInstallButtonState();
}

class _PWAInstallButtonState extends State<PWAInstallButton> {
  bool _canInstall = false;
  bool _isInstalled = false;

  @override
  void initState() {
    super.initState();
    if (kIsWeb) {
      _checkInstallability();
      _checkIfInstalled();
    }
  }

  void _checkInstallability() {
    if (!kIsWeb) return;

    try {
      // Écouter l'événement beforeinstallprompt
      js.context.callMethod('eval', [
        '''
        window.addEventListener('beforeinstallprompt', (e) => {
          e.preventDefault();
          window.deferredPrompt = e;
          window.dispatchEvent(new CustomEvent('pwa-installable'));
        });
        
        window.addEventListener('pwa-installable', () => {
          window.flutterCanInstall = true;
        });
        
        // Vérifier si déjà installé
        window.addEventListener('appinstalled', () => {
          window.flutterIsInstalled = true;
          window.dispatchEvent(new CustomEvent('pwa-installed'));
        });
      ''',
      ]);

      // Vérifier périodiquement si l'installation est possible
      _checkInstallStatus();
    } catch (e) {
      debugPrint('Erreur PWA setup: $e');
    }
  }

  void _checkInstallStatus() {
    try {
      final canInstall = js.context['flutterCanInstall'] ?? false;
      final isInstalled = js.context['flutterIsInstalled'] ?? false;

      if (mounted) {
        setState(() {
          _canInstall = canInstall;
          _isInstalled = isInstalled;
        });
      }

      // Reprendre la vérification après 1 seconde
      if (!isInstalled) {
        Future.delayed(const Duration(seconds: 1), _checkInstallStatus);
      }
    } catch (e) {
      debugPrint('Erreur vérification PWA: $e');
    }
  }

  void _checkIfInstalled() {
    if (!kIsWeb) return;

    try {
      // Vérifier si l'app est en mode standalone (déjà installée)
      final isStandalone = js.context.callMethod('eval', [
        'window.matchMedia("(display-mode: standalone)").matches || window.navigator.standalone',
      ]);

      if (mounted) {
        setState(() {
          _isInstalled = isStandalone ?? false;
        });
      }
    } catch (e) {
      debugPrint('Erreur vérification installation: $e');
    }
  }

  Future<void> _installPWA() async {
    if (!kIsWeb || !_canInstall) return;

    try {
      // Déclencher l'invite d'installation
      js.context.callMethod('eval', [
        '''
        if (window.deferredPrompt) {
          window.deferredPrompt.prompt();
          window.deferredPrompt.userChoice.then((choiceResult) => {
            if (choiceResult.outcome === 'accepted') {
              console.log('Installation PWA acceptée');
              window.flutterIsInstalled = true;
              window.dispatchEvent(new CustomEvent('pwa-installed'));
            }
            window.deferredPrompt = null;
            window.flutterCanInstall = false;
          });
        }
      ''',
      ]);

      // Mettre à jour l'état local
      if (mounted) {
        setState(() {
          _canInstall = false;
        });
      }
    } catch (e) {
      debugPrint('Erreur installation PWA: $e');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Impossible d\'installer l\'application'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Ne pas afficher le bouton si ce n'est pas le web
    if (!kIsWeb) return const SizedBox.shrink();

    // Ne pas afficher si déjà installé
    if (_isInstalled) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.green.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.green),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.check_circle, color: Colors.green, size: 16),
            const SizedBox(width: 4),
            Text(
              'App installée',
              style: TextStyle(
                color: Colors.green,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    // Ne pas afficher si l'installation n'est pas possible
    if (!_canInstall) return const SizedBox.shrink();

    return ElevatedButton.icon(
      onPressed: _installPWA,
      icon: Icon(
        widget.icon ?? Icons.download,
        color: widget.textColor ?? Colors.white,
      ),
      label: Text(
        widget.text ?? 'Installer l\'app',
        style: TextStyle(
          color: widget.textColor ?? Colors.white,
          fontWeight: FontWeight.w600,
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: widget.backgroundColor ?? Colors.blue,
        foregroundColor: widget.textColor ?? Colors.white,
        elevation: 2,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
      ),
    );
  }
}

/// Version compacte du bouton PWA pour la barre d'applications
class PWAInstallIconButton extends StatefulWidget {
  final Color? iconColor;
  final double? iconSize;

  const PWAInstallIconButton({super.key, this.iconColor, this.iconSize});

  @override
  State<PWAInstallIconButton> createState() => _PWAInstallIconButtonState();
}

class _PWAInstallIconButtonState extends State<PWAInstallIconButton> {
  bool _canInstall = false;
  bool _isInstalled = false;

  @override
  void initState() {
    super.initState();
    if (kIsWeb) {
      _checkInstallability();
    }
  }

  void _checkInstallability() {
    if (!kIsWeb) return;

    try {
      js.context.callMethod('eval', [
        '''
        window.addEventListener('beforeinstallprompt', (e) => {
          e.preventDefault();
          window.deferredPrompt = e;
          window.flutterCanInstall = true;
        });
        
        // Vérifier si déjà installé
        const isStandalone = window.matchMedia('(display-mode: standalone)').matches || window.navigator.standalone;
        window.flutterIsInstalled = isStandalone;
      ''',
      ]);

      _checkInstallStatus();
    } catch (e) {
      debugPrint('Erreur PWA icon setup: $e');
    }
  }

  void _checkInstallStatus() {
    try {
      final canInstall = js.context['flutterCanInstall'] ?? false;
      final isInstalled = js.context['flutterIsInstalled'] ?? false;

      if (mounted) {
        setState(() {
          _canInstall = canInstall;
          _isInstalled = isInstalled;
        });
      }

      if (!isInstalled) {
        Future.delayed(const Duration(seconds: 1), _checkInstallStatus);
      }
    } catch (e) {
      debugPrint('Erreur vérification PWA icon: $e');
    }
  }

  Future<void> _installPWA() async {
    if (!kIsWeb || !_canInstall) return;

    try {
      js.context.callMethod('eval', [
        '''
        if (window.deferredPrompt) {
          window.deferredPrompt.prompt();
          window.deferredPrompt.userChoice.then((choiceResult) => {
            if (choiceResult.outcome === 'accepted') {
              window.flutterIsInstalled = true;
            }
            window.deferredPrompt = null;
            window.flutterCanInstall = false;
          });
        }
      ''',
      ]);

      if (mounted) {
        setState(() {
          _canInstall = false;
        });
      }
    } catch (e) {
      debugPrint('Erreur installation PWA icon: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!kIsWeb || _isInstalled || !_canInstall) {
      return const SizedBox.shrink();
    }

    return IconButton(
      onPressed: _installPWA,
      icon: Icon(
        Icons.download,
        color: widget.iconColor ?? Colors.white,
        size: widget.iconSize ?? 24,
      ),
      tooltip: 'Installer l\'application',
    );
  }
}
