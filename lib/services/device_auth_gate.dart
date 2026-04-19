import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:local_auth/local_auth.dart';

/// Biometria ou PIN/padrão do próprio celular (antes do PIN do app).
class DeviceAuthGate {
  DeviceAuthGate._();

  static final LocalAuthentication _auth = LocalAuthentication();

  static Future<bool> unlock() async {
    if (kIsWeb) return true;
    try {
      final supported = await _auth.isDeviceSupported();
      if (!supported) return true;

      return await _auth.authenticate(
        localizedReason: 'Confirme com biometria ou senha do celular para continuar',
        biometricOnly: false,
        sensitiveTransaction: true,
      );
    } on Object catch (_) {
      return false;
    }
  }
}
