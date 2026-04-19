import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:local_auth/local_auth.dart';

class DeviceAuthGate {
  DeviceAuthGate._();

  static final LocalAuthentication _auth = LocalAuthentication();

  /// Biometria ou PIN/padrão **do celular** (credenciais do dispositivo).
  static Future<bool> unlockDeviceCredentials() async {
    if (kIsWeb) return true;
    try {
      final supported = await _auth.isDeviceSupported();
      if (!supported) return true;

      return await _auth.authenticate(
        localizedReason: 'Confirme com biometria ou senha do celular',
        biometricOnly: false,
        sensitiveTransaction: true,
      );
    } on Object catch (_) {
      return false;
    }
  }

  /// Apenas biometria (digital/rosto), sem PIN de bloqueio do aparelho.
  static Future<bool> unlockBiometricOnly() async {
    if (kIsWeb) return true;
    try {
      final supported = await _auth.isDeviceSupported();
      if (!supported) return false;

      return await _auth.authenticate(
        localizedReason: 'Use sua biometria para continuar',
        biometricOnly: true,
        sensitiveTransaction: true,
      );
    } on Object catch (_) {
      return false;
    }
  }
}
