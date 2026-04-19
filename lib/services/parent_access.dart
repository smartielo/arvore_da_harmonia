import 'package:flutter/material.dart';

import '../data/app_repository.dart';
import '../models/parent_auth_mode.dart';
import '../widgets/app_pin_dialog.dart';
import 'device_auth_gate.dart';

/// Fluxo de desbloqueio conforme preferência nas configurações.
class ParentAccess {
  ParentAccess._();

  static const String defaultAppPin = '1234';

  static Future<bool> run(
    BuildContext context, {
    String title = 'Confirmar',
    String subtitle = 'Digite o PIN de 4 dígitos:',
  }) async {
    final snap = await AppRepository.instance.load();
    final mode = parentAuthModeFromStorage(snap.authModeStorage);

    switch (mode) {
      case ParentAuthMode.appPinOnly:
        if (!context.mounted) return false;
        return showAppPinDialog(
          context,
          expectedPin: defaultAppPin,
          title: title,
          subtitle: subtitle,
        );
      case ParentAuthMode.biometricOnly:
        return DeviceAuthGate.unlockBiometricOnly();
      case ParentAuthMode.biometricAndAppPin:
        final deviceOk = await DeviceAuthGate.unlockDeviceCredentials();
        if (!deviceOk) return false;
        if (!context.mounted) return false;
        return showAppPinDialog(
          context,
          expectedPin: defaultAppPin,
          title: title,
          subtitle: 'Agora o PIN do app (4 dígitos):',
        );
    }
  }
}
