import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/foundation.dart' show kDebugMode, debugPrint;

import '../data/app_repository.dart';

/// Efeitos sonoros e fundo opcional (tudo pode ser desligado nas configurações).
class AppSounds {
  AppSounds._();

  static AudioPlayer _taskSfx = AudioPlayer();
  static AudioPlayer _cycleSfx = AudioPlayer();
  static AudioPlayer _ambient = AudioPlayer();
  static bool _playersConfigured = false;
  static bool _ambientPlaying = false;
  static bool _ambientTemporary = false;
  static bool _ambientTestActive = false;

  static bool get isAmbientTestActive => _ambientTestActive;

  static String _stateOf(AudioPlayer player) => player.state.toString();

  static AudioPlayer _playerFor(_AudioChannel channel) {
    switch (channel) {
      case _AudioChannel.task:
        return _taskSfx;
      case _AudioChannel.cycle:
        return _cycleSfx;
      case _AudioChannel.ambient:
        return _ambient;
    }
  }

  static Future<void> _configurePlayer(
    AudioPlayer player, {
    required ReleaseMode releaseMode,
  }) async {
    await player.setPlayerMode(PlayerMode.mediaPlayer);
    await player.setReleaseMode(releaseMode);
  }

  static Future<void> _ensurePlayersConfigured() async {
    if (_playersConfigured) return;
    try {
      await _configurePlayer(_taskSfx, releaseMode: ReleaseMode.stop);
      await _configurePlayer(_cycleSfx, releaseMode: ReleaseMode.stop);
      await _configurePlayer(_ambient, releaseMode: ReleaseMode.loop);
      _playersConfigured = true;
    } on Object catch (e) {
      _log('Falha ao configurar players: $e');
      _playersConfigured = false;
    }
  }

  static void _log(String message) {
    if (kDebugMode) {
      debugPrint('[AppSounds] $message');
    }
  }

  static Future<void> _recreatePlayer(_AudioChannel channel) async {
    final oldPlayer = _playerFor(channel);
    try {
      await oldPlayer.dispose();
    } on Object catch (_) {}

    final newPlayer = AudioPlayer();
    switch (channel) {
      case _AudioChannel.task:
        _taskSfx = newPlayer;
        await _configurePlayer(_taskSfx, releaseMode: ReleaseMode.stop);
        break;
      case _AudioChannel.cycle:
        _cycleSfx = newPlayer;
        await _configurePlayer(_cycleSfx, releaseMode: ReleaseMode.stop);
        break;
      case _AudioChannel.ambient:
        _ambient = newPlayer;
        await _configurePlayer(_ambient, releaseMode: ReleaseMode.loop);
        break;
    }
    _log('Player recriado para canal ${channel.name}.');
  }

  static Future<void> _playSfx(
    _AudioChannel channel,
    String asset, {
    double volume = 1.0,
    bool retrying = false,
  }) async {
    if (kIsWeb) return;
    await _ensurePlayersConfigured();
    final player = _playerFor(channel);
    try {
      await player.setReleaseMode(ReleaseMode.stop);
      await player.stop();
      try {
        await player.seek(Duration.zero);
      } on Object catch (_) {}
      await player.setVolume(volume.clamp(0.0, 1.0));
      await player.play(AssetSource(asset));
      _log('Play "$asset" canal=${channel.name} state=${_stateOf(player)}');
    } on Object catch (e) {
      _log('Falha ao reproduzir "$asset" canal=${channel.name} state=${_stateOf(player)} erro=$e');
      if (retrying) return;
      try {
        await _recreatePlayer(channel);
        await _playSfx(channel, asset, volume: volume, retrying: true);
      } on Object catch (recreateError) {
        _log('Falha ao recuperar player ${channel.name}: $recreateError');
      }
    }
  }

  static Future<void> playTarefaConcluida() async {
    final s = await AppRepository.instance.load();
    if (!s.soundTaskEnabled) return;
    await _playSfx(_AudioChannel.task, 'sounds/tarefa.wav', volume: 0.85);
  }

  static Future<void> playMetaAtingida() async {
    final s = await AppRepository.instance.load();
    if (!s.soundCycleEnabled) return;
    await _playSfx(_AudioChannel.cycle, 'sounds/ciclo.wav', volume: 0.9);
  }

  static Future<void> testTaskSfx() async {
    await _playSfx(_AudioChannel.task, 'sounds/tarefa.wav', volume: 0.85);
  }

  static Future<void> testCycleSfx() async {
    await _playSfx(_AudioChannel.cycle, 'sounds/ciclo.wav', volume: 0.9);
  }

  /// Inicia fundo bem baixo em loop (se habilitado).
  static Future<void> startAmbientIfEnabled() async {
    if (kIsWeb) return;
    final s = await AppRepository.instance.load();
    if (!s.soundAmbientEnabled) return;
    if (_ambientPlaying && !_ambientTemporary) return;
    if (_ambientPlaying && _ambientTemporary) {
      await stopAmbient();
    }
    await _startAmbient(temporary: false);
  }

  static Future<void> _startAmbient({required bool temporary}) async {
    await _ensurePlayersConfigured();
    try {
      await _ambient.setReleaseMode(ReleaseMode.loop);
      await _ambient.setVolume(0.08);
      await _ambient.stop();
      try {
        await _ambient.seek(Duration.zero);
      } on Object catch (_) {}
      await _ambient.play(AssetSource('sounds/fundo.wav'));
      _ambientPlaying = true;
      _ambientTemporary = temporary;
      _log('Ambient iniciado state=${_stateOf(_ambient)} temporary=$temporary');
    } on Object catch (e) {
      _ambientPlaying = false;
      _ambientTemporary = false;
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
    _ambientTemporary = false;
    _log('Ambient parado state=${_stateOf(_ambient)}');
  }

  static Future<void> startAmbientTest({required bool settingsEnabled}) async {
    if (kIsWeb) return;
    _ambientTestActive = true;
    final temporary = !settingsEnabled;
    if (_ambientPlaying) {
      await stopAmbient();
    }
    await _startAmbient(temporary: temporary);
  }

  static Future<void> stopAmbientTest({required bool settingsEnabled}) async {
    if (!_ambientTestActive) return;
    _ambientTestActive = false;
    if (!settingsEnabled) {
      await stopAmbient();
      return;
    }
    await startAmbientIfEnabled();
  }

  static Future<void> refreshAmbientFromSettings() async {
    _ambientTestActive = false;
    final s = await AppRepository.instance.load();
    if (s.soundAmbientEnabled) {
      await startAmbientIfEnabled();
    } else {
      await stopAmbient();
    }
  }

  static Future<void> dispose() async {
    await stopAmbient();
    _ambientTestActive = false;
    await _taskSfx.dispose();
    await _cycleSfx.dispose();
    await _ambient.dispose();
  }
}

enum _AudioChannel {
  task,
  cycle,
  ambient,
}
