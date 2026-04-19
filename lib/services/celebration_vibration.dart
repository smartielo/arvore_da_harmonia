import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/services.dart';
import 'package:vibration/vibration.dart';

/// Vibração na celebração: motor (Android) + fallback háptico. [intensity] 1–3.
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

  static int _durationForIntensity(int intensity) {
    switch (intensity.clamp(1, 3)) {
      case 1:
        return 42;
      case 2:
        return 75;
      case 3:
      default:
        return 115;
    }
  }

  /// Pulso curto — [intensity] 1 = leve, 3 = forte.
  static Future<void> pulse({required int intensity}) async {
    if (kIsWeb) return;
    await init();
    final ms = _durationForIntensity(intensity);
    try {
      if (_hasMotor == true) {
        await Vibration.vibrate(duration: ms);
        return;
      }
    } catch (_) {
      // fallback abaixo
    }
    switch (intensity.clamp(1, 3)) {
      case 1:
        HapticFeedback.selectionClick();
        break;
      case 2:
        HapticFeedback.mediumImpact();
        break;
      default:
        HapticFeedback.heavyImpact();
    }
  }
}
