import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

import '../data/app_repository.dart';

/// Efeitos sonoros e fundo opcional (tudo pode ser desligado nas configurações).
class AppSounds {
  AppSounds._();

  static final AudioPlayer _sfx = AudioPlayer();
  static final AudioPlayer _ambient = AudioPlayer();
  static bool _ambientPlaying = false;

  static Future<void> _playSfx(String asset, {double volume = 1.0}) async {
    if (kIsWeb) return;
    try {
      await _sfx.stop();
      await _sfx.setVolume(volume.clamp(0.0, 1.0));
      await _sfx.play(AssetSource(asset));
    } on Object catch (_) {}
  }

  static Future<void> playTarefaConcluida() async {
    final s = await AppRepository.instance.load();
    if (!s.soundTaskEnabled) return;
    await _playSfx('sounds/tarefa.wav', volume: 0.85);
  }

  static Future<void> playMetaAtingida() async {
    final s = await AppRepository.instance.load();
    if (!s.soundCycleEnabled) return;
    await _playSfx('sounds/ciclo.wav', volume: 0.9);
  }

  /// Inicia fundo bem baixo em loop (se habilitado).
  static Future<void> startAmbientIfEnabled() async {
    if (kIsWeb || _ambientPlaying) return;
    final s = await AppRepository.instance.load();
    if (!s.soundAmbientEnabled) return;
    try {
      await _ambient.setReleaseMode(ReleaseMode.loop);
      await _ambient.setVolume(0.08);
      await _ambient.play(AssetSource('sounds/fundo.wav'));
      _ambientPlaying = true;
    } on Object catch (_) {}
  }

  static Future<void> stopAmbient() async {
    if (!_ambientPlaying) return;
    try {
      await _ambient.stop();
    } on Object catch (_) {}
    _ambientPlaying = false;
  }

  static Future<void> refreshAmbientFromSettings() async {
    final s = await AppRepository.instance.load();
    if (s.soundAmbientEnabled) {
      await startAmbientIfEnabled();
    } else {
      await stopAmbient();
    }
  }

  static Future<void> dispose() async {
    await stopAmbient();
    await _sfx.dispose();
    await _ambient.dispose();
  }
}
