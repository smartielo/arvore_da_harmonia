import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/services.dart';
import 'package:vibration/vibration.dart';

/// Vibração perceptível na celebração: motor do aparelho (Android) + fallback háptico.
class CelebrationVibration {
  CelebrationVibration._();

  static bool? _hasMotor;
  static bool _inited = false;

  static Future<void> init() async {
    if (_inited || kIsWeb) return;
    _inited = true;
    try {
      _hasMotor = await Vibration.hasVibrator();
    } catch (_) {
      _hasMotor = false;
    }
  }

  /// Pulso curto — chamar várias vezes durante a animação.
  static Future<void> pulse() async {
    if (kIsWeb) return;
    await init();
    try {
      if (_hasMotor == true) {
        await Vibration.vibrate(duration: 95);
        return;
      }
    } catch (_) {
      // fallback abaixo
    }
    HapticFeedback.heavyImpact();
  }
}
