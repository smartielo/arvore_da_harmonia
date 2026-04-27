import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/foundation.dart' show kDebugMode, debugPrint;

import '../data/app_repository.dart';

/// Efeitos sonoros e fundo opcional (tudo pode ser desligado nas configurações).
class AppSounds {
  AppSounds._();

  static final AudioPlayer _taskSfx = AudioPlayer();
  static final AudioPlayer _cycleSfx = AudioPlayer();
  static final AudioPlayer _ambient = AudioPlayer();
  static bool _playersConfigured = false;
  static bool _ambientPlaying = false;

  static Future<void> _ensurePlayersConfigured() async {
    if (_playersConfigured) return;
    _playersConfigured = true;
    try {
      await _taskSfx.setPlayerMode(PlayerMode.lowLatency);
      await _cycleSfx.setPlayerMode(PlayerMode.lowLatency);
      await _ambient.setPlayerMode(PlayerMode.mediaPlayer);
    } on Object catch (e) {
      _log('Falha ao configurar players: $e');
    }
  }

  static void _log(String message) {
    if (kDebugMode) {
      debugPrint('[AppSounds] $message');
    }
  }

  static Future<void> _playSfx(AudioPlayer player, String asset, {double volume = 1.0}) async {
    if (kIsWeb) return;
    await _ensurePlayersConfigured();
    try {
      await player.setVolume(volume.clamp(0.0, 1.0));
      await player.play(AssetSource(asset));
    } on Object catch (e) {
      _log('Falha ao reproduzir "$asset": $e');
    }
  }

  static Future<void> playTarefaConcluida() async {
    final s = await AppRepository.instance.load();
    if (!s.soundTaskEnabled) return;
    await _playSfx(_taskSfx, 'sounds/tarefa.wav', volume: 0.85);
  }

  static Future<void> playMetaAtingida() async {
    final s = await AppRepository.instance.load();
    if (!s.soundCycleEnabled) return;
    await _playSfx(_cycleSfx, 'sounds/ciclo.wav', volume: 0.9);
  }

  static Future<void> testTaskSfx() async {
    await _playSfx(_taskSfx, 'sounds/tarefa.wav', volume: 0.85);
  }

  static Future<void> testCycleSfx() async {
    await _playSfx(_cycleSfx, 'sounds/ciclo.wav', volume: 0.9);
  }

  /// Inicia fundo bem baixo em loop (se habilitado).
  static Future<void> startAmbientIfEnabled() async {
    if (kIsWeb || _ambientPlaying) return;
    final s = await AppRepository.instance.load();
    if (!s.soundAmbientEnabled) return;
    await _ensurePlayersConfigured();
    try {
      await _ambient.setReleaseMode(ReleaseMode.loop);
      await _ambient.setVolume(0.08);
      await _ambient.play(AssetSource('sounds/fundo.wav'));
      _ambientPlaying = true;
    } on Object catch (e) {
      _ambientPlaying = false;
      _log('Falha ao iniciar som ambiente: $e');
    }
  }

  static Future<void> stopAmbient() async {
    if (!_ambientPlaying) return;
    try {
      await _ambient.stop();
    } on Object catch (e) {
      _log('Falha ao parar som ambiente: $e');
    }
    _ambientPlaying = false;
  }

  static Future<void> testAmbientLoop() async {
    await _ensurePlayersConfigured();
    if (_ambientPlaying) {
      await stopAmbient();
      return;
    }
    try {
      await _ambient.setReleaseMode(ReleaseMode.loop);
      await _ambient.setVolume(0.08);
      await _ambient.play(AssetSource('sounds/fundo.wav'));
      _ambientPlaying = true;
    } on Object catch (e) {
      _ambientPlaying = false;
      _log('Falha ao testar som ambiente: $e');
    }
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
    await _taskSfx.dispose();
    await _cycleSfx.dispose();
    await _ambient.dispose();
  }
}
