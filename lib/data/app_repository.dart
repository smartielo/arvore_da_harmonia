import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/week_models.dart';

class AppSnapshot {
  int weeklyGoal;
  String weeklyPrize;
  int placedMoitasCount;
  bool periodoCelebrado;
  bool vibrationEnabled;
  /// 1 = leve, 2 = médio, 3 = forte
  int vibrationIntensity;
  String authModeStorage;
  bool soundTaskEnabled;
  bool soundCycleEnabled;
  bool soundAmbientEnabled;
  bool soundAmbientAnimated;
  /// 1 = suave, 2 = equilibrado, 3 = vivo
  int soundIntensity;
  List<TarefaSemana> tarefas;
  Set<String> tarefasConcluidasIds;
  List<HistoricoPeriodo> historico;
  DateTime? periodoInicio;
  DateTime? periodoFim;

  AppSnapshot({
    required this.weeklyGoal,
    required this.weeklyPrize,
    required this.placedMoitasCount,
    required this.periodoCelebrado,
    required this.vibrationEnabled,
    required this.vibrationIntensity,
    required this.authModeStorage,
    required this.soundTaskEnabled,
    required this.soundCycleEnabled,
    required this.soundAmbientEnabled,
    required this.soundAmbientAnimated,
    required this.soundIntensity,
    required this.tarefas,
    required this.tarefasConcluidasIds,
    required this.historico,
    required this.periodoInicio,
    required this.periodoFim,
  });

  int get somaPontosTarefas => tarefas.fold<int>(0, (s, t) => s + t.pontos);

  bool get tarefasBatemMeta => tarefas.isNotEmpty && somaPontosTarefas == weeklyGoal;
}

class AppRepository {
  AppRepository._();
  static final AppRepository instance = AppRepository._();

  static const _kGoal = 'weekly_goal';
  static const _kPrize = 'weekly_prize';
  static const _kMoitas = 'placed_moitas';
  static const _kPeriodoCelebrado = 'periodo_celebrado';
  static const _kVibration = 'vibration_enabled';
  static const _kVibrationIntensity = 'vibration_intensity';
  static const _kAuthMode = 'parent_auth_mode';
  static const _kSoundTask = 'sound_task';
  static const _kSoundCycle = 'sound_cycle';
  static const _kSoundAmbient = 'sound_ambient';
  static const _kSoundAmbientAnimated = 'sound_ambient_animated';
  static const _kSoundIntensity = 'sound_intensity';
  static const _kTarefas = 'tarefas_json';
  static const _kConcluidas = 'tarefas_concluidas_json';
  static const _kHistorico = 'historico_json';
  static const _kPeriodoInicio = 'periodo_inicio_iso';
  static const _kPeriodoFim = 'periodo_fim_iso';
  static const _kAppPin = 'app_pin';

  Future<AppSnapshot> load() async {
    final p = await SharedPreferences.getInstance();
    final goal = p.getInt(_kGoal) ?? 100;
    final prize = p.getString(_kPrize) ?? '';
    final moitas = p.getInt(_kMoitas) ?? 0;
    final celebrado = p.getBool(_kPeriodoCelebrado) ?? false;
    final vib = p.getBool(_kVibration) ?? true;
    final vibInt = (p.getInt(_kVibrationIntensity) ?? 2).clamp(1, 3);
    final auth = p.getString(_kAuthMode) ?? 'app_pin_only';
    final st = p.getBool(_kSoundTask) ?? true;
    final sc = p.getBool(_kSoundCycle) ?? true;
    final sa = p.getBool(_kSoundAmbient) ?? false;
    final saa = p.getBool(_kSoundAmbientAnimated) ?? false;
    final si = (p.getInt(_kSoundIntensity) ?? 2).clamp(1, 3);
    final inicioStr = p.getString(_kPeriodoInicio);
    final DateTime? inicio = inicioStr != null ? DateTime.tryParse(inicioStr) : null;
    final fimStr = p.getString(_kPeriodoFim);
    final DateTime? fim = fimStr != null ? DateTime.tryParse(fimStr) : null;

    List<TarefaSemana> tarefas = [];
    final tJson = p.getString(_kTarefas);
    if (tJson != null && tJson.isNotEmpty) {
      final list = jsonDecode(tJson) as List<dynamic>;
      tarefas = list.map((e) => TarefaSemana.fromJson(Map<String, dynamic>.from(e as Map))).toList();
    }

    Set<String> concluidas = {};
    final cJson = p.getString(_kConcluidas);
    if (cJson != null && cJson.isNotEmpty) {
      final list = jsonDecode(cJson) as List<dynamic>;
      concluidas = list.map((e) => e as String).toSet();
    }

    List<HistoricoPeriodo> hist = [];
    final hJson = p.getString(_kHistorico);
    if (hJson != null && hJson.isNotEmpty) {
      final list = jsonDecode(hJson) as List<dynamic>;
      hist = list.map((e) => HistoricoPeriodo.fromJson(Map<String, dynamic>.from(e as Map))).toList();
    }

    return AppSnapshot(
      weeklyGoal: goal,
      weeklyPrize: prize,
      placedMoitasCount: moitas,
      periodoCelebrado: celebrado,
      vibrationEnabled: vib,
      vibrationIntensity: vibInt,
      authModeStorage: auth,
      soundTaskEnabled: st,
      soundCycleEnabled: sc,
      soundAmbientEnabled: sa,
      soundAmbientAnimated: saa,
      soundIntensity: si,
      tarefas: tarefas,
      tarefasConcluidasIds: concluidas,
      historico: hist,
      periodoInicio: inicio,
      periodoFim: fim,
    );
  }

  Future<void> _write(void Function(SharedPreferences p) fn) async {
    final p = await SharedPreferences.getInstance();
    fn(p);
  }

  Future<void> saveWeeklyGoal(int v) async {
    await _write((p) => p.setInt(_kGoal, v));
  }

  Future<void> saveWeeklyPrize(String v) async {
    await _write((p) => p.setString(_kPrize, v));
  }

  Future<void> savePlacedMoitas(int v) async {
    await _write((p) => p.setInt(_kMoitas, v));
  }

  Future<void> savePeriodoCelebrado(bool v) async {
    await _write((p) => p.setBool(_kPeriodoCelebrado, v));
  }

  Future<void> saveVibrationEnabled(bool v) async {
    await _write((p) => p.setBool(_kVibration, v));
  }

  Future<void> saveVibrationIntensity(int v) async {
    await _write((p) => p.setInt(_kVibrationIntensity, v.clamp(1, 3)));
  }

  Future<void> saveAuthModeStorage(String v) async {
    await _write((p) => p.setString(_kAuthMode, v));
  }

  Future<void> saveSoundTaskEnabled(bool v) async {
    await _write((p) => p.setBool(_kSoundTask, v));
  }

  Future<void> saveSoundCycleEnabled(bool v) async {
    await _write((p) => p.setBool(_kSoundCycle, v));
  }

  Future<void> saveSoundAmbientEnabled(bool v) async {
    await _write((p) => p.setBool(_kSoundAmbient, v));
  }

  Future<void> saveSoundAmbientAnimated(bool v) async {
    await _write((p) => p.setBool(_kSoundAmbientAnimated, v));
  }

  Future<void> saveSoundIntensity(int v) async {
    await _write((p) => p.setInt(_kSoundIntensity, v.clamp(1, 3)));
  }

  Future<void> saveTarefas(List<TarefaSemana> list) async {
    final p = await SharedPreferences.getInstance();
    await p.setString(_kTarefas, jsonEncode(list.map((e) => e.toJson()).toList()));
  }

  Future<void> saveTarefasConcluidas(Set<String> ids) async {
    final p = await SharedPreferences.getInstance();
    await p.setString(_kConcluidas, jsonEncode(ids.toList()));
  }

  Future<void> saveHistorico(List<HistoricoPeriodo> list) async {
    final p = await SharedPreferences.getInstance();
    await p.setString(_kHistorico, jsonEncode(list.map((e) => e.toJson()).toList()));
  }

  Future<void> savePeriodoInicio(DateTime? d) async {
    final p = await SharedPreferences.getInstance();
    if (d == null) {
      await p.remove(_kPeriodoInicio);
    } else {
      await p.setString(_kPeriodoInicio, d.toIso8601String());
    }
  }

  Future<void> savePeriodoFim(DateTime? d) async {
    final p = await SharedPreferences.getInstance();
    if (d == null) {
      await p.remove(_kPeriodoFim);
    } else {
      await p.setString(_kPeriodoFim, d.toIso8601String());
    }
  }

  Future<void> appendHistorico(HistoricoPeriodo h) async {
    final snap = await load();
    final list = [...snap.historico, h];
    await saveHistorico(list);
  }

  Future<String> loadAppPin({String fallback = '1234'}) async {
    final p = await SharedPreferences.getInstance();
    final stored = p.getString(_kAppPin);
    if (stored == null || stored.length != 4) return fallback;
    return stored;
  }

  Future<void> saveAppPin(String pin) async {
    await _write((p) => p.setString(_kAppPin, pin));
  }

  /// Novo período: zera folhas, conclusões e celebração; opcionalmente grava histórico do período anterior.
  Future<void> iniciarNovoPeriodo({
    HistoricoPeriodo? encerrarAnteriorCom,
    DateTime? novoPeriodoFim,
  }) async {
    final p = await SharedPreferences.getInstance();
    if (encerrarAnteriorCom != null) {
      final snap = await load();
      final list = [...snap.historico, encerrarAnteriorCom];
      await p.setString(_kHistorico, jsonEncode(list.map((e) => e.toJson()).toList()));
    }
    await p.setInt(_kMoitas, 0);
    await p.setBool(_kPeriodoCelebrado, false);
    await p.remove(_kConcluidas);
    await p.setString(_kPeriodoInicio, DateTime.now().toIso8601String());
    if (novoPeriodoFim != null) {
      await p.setString(_kPeriodoFim, novoPeriodoFim.toIso8601String());
    } else {
      await p.remove(_kPeriodoFim);
    }
  }
}
