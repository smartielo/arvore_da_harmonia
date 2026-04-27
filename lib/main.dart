import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';

import 'area_mestre_page.dart';
import 'creditos_page.dart';
import 'data/app_repository.dart';
import 'models/week_models.dart';
import 'services/app_sounds.dart';
import 'services/celebration_vibration.dart';
import 'services/parent_access.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ArvoreDaHarmoniaApp());
}

class ArvoreDaHarmoniaApp extends StatelessWidget {
  const ArvoreDaHarmoniaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Árvore da Harmonia',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  static const double _moitaDyNudge = 0.045;

  int placedMoitasCount = 0;
  int weeklyGoal = 100;
  String _weeklyPrize = '';
  bool _periodoCelebrado = false;
  bool _aguardandoShakePosEncerramento = false;
  bool _vibrationEnabled = true;
  int _vibrationIntensity = 2;
  DateTime? _prazoPeriodo;

  StreamSubscription<UserAccelerometerEvent>? _accelSub;
  late final AnimationController _fallController;
  late final AnimationController _goldenFruitPulseController;
  int _lastHapticStep = -1;

  final List<Offset> predefinedLeafPositions = [
    const Offset(0.605, 0.330), const Offset(0.409, 0.298), const Offset(0.512, 0.382), const Offset(0.589, 0.285),
    const Offset(0.347, 0.340), const Offset(0.638, 0.364), const Offset(0.456, 0.266), const Offset(0.418, 0.391),
    const Offset(0.673, 0.306), const Offset(0.325, 0.302), const Offset(0.583, 0.398), const Offset(0.560, 0.256),
    const Offset(0.322, 0.370), const Offset(0.706, 0.348), const Offset(0.376, 0.262), const Offset(0.472, 0.415),
    const Offset(0.672, 0.274), const Offset(0.271, 0.326), const Offset(0.666, 0.394), const Offset(0.489, 0.238),
    const Offset(0.345, 0.402), const Offset(0.743, 0.317), const Offset(0.295, 0.275), const Offset(0.556, 0.425),
    const Offset(0.628, 0.244), const Offset(0.252, 0.361), const Offset(0.740, 0.373), const Offset(0.397, 0.235),
    const Offset(0.408, 0.428), const Offset(0.743, 0.281), const Offset(0.232, 0.303), const Offset(0.652, 0.421),
    const Offset(0.548, 0.222), const Offset(0.273, 0.398), const Offset(0.789, 0.339), const Offset(0.301, 0.247),
    const Offset(0.501, 0.444), const Offset(0.701, 0.244), const Offset(0.199, 0.341), const Offset(0.743, 0.401),
    const Offset(0.445, 0.213), const Offset(0.335, 0.432), const Offset(0.802, 0.298), const Offset(0.219, 0.274),
    const Offset(0.611, 0.445), const Offset(0.621, 0.215), const Offset(0.207, 0.384), const Offset(0.812, 0.367),
    const Offset(0.334, 0.220), const Offset(0.430, 0.455), const Offset(0.773, 0.255), const Offset(0.166, 0.314),
    const Offset(0.720, 0.430), const Offset(0.512, 0.198), const Offset(0.258, 0.425), const Offset(0.846, 0.323),
    const Offset(0.231, 0.244), const Offset(0.549, 0.464), const Offset(0.701, 0.217), const Offset(0.153, 0.361),
    const Offset(0.812, 0.398), const Offset(0.389, 0.197), const Offset(0.349, 0.458), const Offset(0.836, 0.275),
    const Offset(0.154, 0.283), const Offset(0.674, 0.456), const Offset(0.593, 0.191), const Offset(0.186, 0.409),
    const Offset(0.871, 0.354), const Offset(0.267, 0.215), const Offset(0.470, 0.477), const Offset(0.780, 0.229),
    const Offset(0.115, 0.331), const Offset(0.788, 0.430), const Offset(0.462, 0.180), const Offset(0.265, 0.451),
    const Offset(0.887, 0.302), const Offset(0.164, 0.249), const Offset(0.607, 0.478), const Offset(0.681, 0.192),
    const Offset(0.124, 0.385), const Offset(0.874, 0.388), const Offset(0.325, 0.189), const Offset(0.382, 0.481),
    const Offset(0.852, 0.249), const Offset(0.098, 0.297), const Offset(0.741, 0.460), const Offset(0.549, 0.171),
    const Offset(0.184, 0.435), const Offset(0.919, 0.335), const Offset(0.199, 0.216), const Offset(0.524, 0.490),
    const Offset(0.769, 0.203), const Offset(0.078, 0.354), const Offset(0.854, 0.423), const Offset(0.402, 0.168),
    const Offset(0.289, 0.476), const Offset(0.912, 0.278), const Offset(0.103, 0.261), const Offset(0.673, 0.485),
    const Offset(0.645, 0.170),
  ];

  @override
  void initState() {
    super.initState();
    _fallController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2800),
    )..addStatusListener(_onFallStatus);
    _goldenFruitPulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
      lowerBound: 0.0,
      upperBound: 1.0,
    )..repeat(reverse: true);
    _fallController.addListener(_onFallTick);
    _bootstrap();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      unawaited(AppSounds.startAmbientIfEnabled());
    });
  }

  Future<void> _bootstrap() async {
    await CelebrationVibration.init();
    final s = await AppRepository.instance.load();
    if (!mounted) return;
    setState(() {
      weeklyGoal = s.weeklyGoal;
      _weeklyPrize = s.weeklyPrize;
      placedMoitasCount = s.placedMoitasCount;
      _periodoCelebrado = s.periodoCelebrado;
      _vibrationEnabled = s.vibrationEnabled;
      _vibrationIntensity = s.vibrationIntensity;
      _prazoPeriodo = s.periodoFim;
    });
  }

  void _onFallTick() {
    if (!_vibrationEnabled || !_fallController.isAnimating) return;
    final v = _fallController.value;
    final step = (v * 16).floor();
    if (step != _lastHapticStep) {
      _lastHapticStep = step;
      unawaited(CelebrationVibration.pulse(intensity: _vibrationIntensity));
    }
  }

  void _onFallStatus(AnimationStatus status) {
    if (status != AnimationStatus.completed) return;
    setState(() {
      _aguardandoShakePosEncerramento = false;
      _periodoCelebrado = true;
    });
    unawaited(AppRepository.instance.savePeriodoCelebrado(true));
    _pararEscutaShake();
    _fallController.reset();
    _lastHapticStep = -1;
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Que legal! Período celebrado com chave de ouro.')),
    );
  }

  @override
  void dispose() {
    unawaited(AppSounds.dispose());
    _pararEscutaShake();
    _fallController.removeListener(_onFallTick);
    _fallController.removeStatusListener(_onFallStatus);
    _fallController.dispose();
    _goldenFruitPulseController.dispose();
    super.dispose();
  }

  Offset _anchoredMoita(Offset normalized) {
    return Offset(
      normalized.dx,
      (normalized.dy + _moitaDyNudge).clamp(0.08, 0.54),
    );
  }

  String getBackgroundImage() {
    final hour = DateTime.now().hour;
    if (hour >= 6 && hour < 12) {
      return 'assets/images/manha.png';
    } else if (hour >= 12 && hour < 16) {
      return 'assets/images/tarde.png';
    } else if (hour >= 16 && hour < 19) {
      return 'assets/images/entardecer.png';
    } else {
      return 'assets/images/noite.png';
    }
  }

  Future<void> _garantirInicioPeriodo() async {
    final s = await AppRepository.instance.load();
    if (s.periodoInicio == null) {
      await AppRepository.instance.savePeriodoInicio(DateTime.now());
    }
  }

  Future<void> _addMoita() async {
    if (placedMoitasCount >= weeklyGoal) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('A meta semanal já foi atingida! Parabéns!')),
      );
      return;
    }

    if (placedMoitasCount >= predefinedLeafPositions.length) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('A árvore já está totalmente cheia!')),
      );
      return;
    }

    final snap = await AppRepository.instance.load();
    final pontosAntes = placedMoitasCount;

    if (snap.tarefasBatemMeta) {
      final pendentes = snap.tarefas.where((t) => !snap.tarefasConcluidasIds.contains(t.id)).toList();
      if (pendentes.isEmpty) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Todas as tarefas deste período já foram registradas!')),
        );
        return;
      }

      if (!mounted) return;
      final escolhida = await showModalBottomSheet<TarefaSemana>(
        context: context,
        showDragHandle: true,
        builder: (ctx) => SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Qual tarefa foi feita?',
                  style: Theme.of(ctx).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                ...pendentes.map(
                  (t) => Card(
                    child: ListTile(
                      leading: const Icon(Icons.task_alt, color: Colors.green),
                      title: Text(t.titulo),
                      subtitle: Text('${t.pontos} pontos na árvore'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => Navigator.pop(ctx, t),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );

      if (escolhida == null || !mounted) return;

      final novo = placedMoitasCount + escolhida.pontos;
      if (novo > weeklyGoal) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Isso ultrapassaria a meta. Verifique as tarefas com o responsável.')),
        );
        return;
      }

      setState(() {
        placedMoitasCount = novo;
      });
      final concluidas = {...snap.tarefasConcluidasIds, escolhida.id};
      await AppRepository.instance.saveTarefasConcluidas(concluidas);
      await AppRepository.instance.savePlacedMoitas(placedMoitasCount);
      await _garantirInicioPeriodo();
      unawaited(AppSounds.playTarefaConcluida());
      if (placedMoitasCount >= weeklyGoal && pontosAntes < weeklyGoal) {
        unawaited(AppSounds.playMetaAtingida());
      }
      return;
    }

    setState(() {
      placedMoitasCount++;
    });
    await AppRepository.instance.savePlacedMoitas(placedMoitasCount);
    await _garantirInicioPeriodo();
    unawaited(AppSounds.playTarefaConcluida());
    if (placedMoitasCount >= weeklyGoal && pontosAntes < weeklyGoal) {
      unawaited(AppSounds.playMetaAtingida());
    }
  }

  void _pararEscutaShake() {
    _accelSub?.cancel();
    _accelSub = null;
  }

  DateTime? _ultimoShakeDetectado;

  void _onUserAccel(UserAccelerometerEvent e) {
    if (!_aguardandoShakePosEncerramento || _fallController.isAnimating) return;
    final m = math.sqrt(e.x * e.x + e.y * e.y + e.z * e.z);
    if (m < 20) return;
    final agora = DateTime.now();
    if (_ultimoShakeDetectado != null && agora.difference(_ultimoShakeDetectado!) < const Duration(milliseconds: 450)) {
      return;
    }
    _ultimoShakeDetectado = agora;
    _dispararQuedaFolhas();
  }

  void _iniciarEscutaShake() {
    _pararEscutaShake();
    _ultimoShakeDetectado = null;
    if (kIsWeb) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No computador não há sensor: a animação vai começar sozinha. No celular, balance para ver as folhas caírem.'),
            duration: Duration(seconds: 4),
          ),
        );
        Future<void>.delayed(const Duration(milliseconds: 1800), () {
          if (!mounted || !_aguardandoShakePosEncerramento || _fallController.isAnimating) return;
          _dispararQuedaFolhas();
        });
      });
      return;
    }
    _accelSub = userAccelerometerEventStream(samplingPeriod: SensorInterval.gameInterval).listen(
      _onUserAccel,
      onError: (_) {},
    );
  }

  void _dispararQuedaFolhas() {
    _pararEscutaShake();
    _lastHapticStep = -1;
    _fallController.forward(from: 0);
    setState(() {});
  }

  bool get _mostrarBotaoFinalizar =>
      placedMoitasCount >= weeklyGoal && !_aguardandoShakePosEncerramento && !_periodoCelebrado;

  /// Após celebrar (folhas caindo), libera um novo ciclo com prazo no calendário.
  bool get _mostrarBotaoNovoPeriodo =>
      _periodoCelebrado && placedMoitasCount > 0 && placedMoitasCount >= weeklyGoal;

  String _fmtDia(DateTime d) {
    final dd = d.day.toString().padLeft(2, '0');
    final mm = d.month.toString().padLeft(2, '0');
    return '$dd/$mm/${d.year}';
  }

  Future<void> _abrirFinalizarPeriodo() async {
    final ok = await ParentAccess.run(
      context,
      title: 'Finalizar período',
      subtitle: 'Confirme para encerrar o período e celebrar:',
    );
    if (!mounted || !ok) {
      if (mounted && !ok) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Não foi possível confirmar. Tente de novo ou ajuste o modo de acesso nas configurações.')),
        );
      }
      return;
    }
    setState(() {
      _aguardandoShakePosEncerramento = true;
    });
    _iniciarEscutaShake();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Período liberado! Balance o celular para ver as folhas caírem.'),
        duration: Duration(seconds: 5),
      ),
    );
  }

  Future<void> _abrirIniciarNovoPeriodo() async {
    final okAuth = await ParentAccess.run(
      context,
      title: 'Novo período',
      subtitle: 'Confirme para encerrar o ciclo e definir o próximo prazo:',
    );
    if (!mounted || !okAuth) {
      if (mounted && !okAuth) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Não foi possível confirmar. Verifique biometria/PIN nas configurações.')),
        );
      }
      return;
    }

    final hoje = DateTime.now();
    final primeiroDia = DateTime(hoje.year, hoje.month, hoje.day);
    final sugerido = _prazoPeriodo != null && _prazoPeriodo!.isAfter(primeiroDia)
        ? _prazoPeriodo!
        : primeiroDia.add(const Duration(days: 7));

    final escolhida = await showDatePicker(
      context: context,
      initialDate: sugerido,
      firstDate: primeiroDia,
      lastDate: hoje.add(const Duration(days: 365 * 3)),
      helpText: 'Prazo final do próximo período',
    );
    if (escolhida == null || !mounted) return;

    final snap = await AppRepository.instance.load();
    final agora = DateTime.now();
    final inicio = snap.periodoInicio ?? agora;
    final h = HistoricoPeriodo(
      inicio: inicio,
      fim: agora,
      meta: snap.weeklyGoal,
      pontos: snap.placedMoitasCount,
      metaCumprida: snap.placedMoitasCount >= snap.weeklyGoal,
      premio: snap.weeklyPrize,
    );
    await AppRepository.instance.iniciarNovoPeriodo(
      encerrarAnteriorCom: h,
      novoPeriodoFim: escolhida,
    );

    if (!mounted) return;
    final s = await AppRepository.instance.load();
    if (!mounted) return;
    setState(() {
      weeklyGoal = s.weeklyGoal;
      _weeklyPrize = s.weeklyPrize;
      placedMoitasCount = s.placedMoitasCount;
      _periodoCelebrado = s.periodoCelebrado;
      _vibrationEnabled = s.vibrationEnabled;
      _vibrationIntensity = s.vibrationIntensity;
      _prazoPeriodo = s.periodoFim;
    });
    _pararEscutaShake();
    _fallController.reset();
    unawaited(AppSounds.refreshAmbientFromSettings());
    final msg = 'Novo período iniciado! Prazo até ${_fmtDia(escolhida)}.';
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
    });
  }

  void _aplicarSnapshot(AppSnapshot s) {
    setState(() {
      weeklyGoal = s.weeklyGoal;
      _weeklyPrize = s.weeklyPrize;
      placedMoitasCount = s.placedMoitasCount;
      _periodoCelebrado = s.periodoCelebrado;
      _vibrationEnabled = s.vibrationEnabled;
      _vibrationIntensity = s.vibrationIntensity;
      _prazoPeriodo = s.periodoFim;
    });
    unawaited(AppSounds.refreshAmbientFromSettings());
  }

  Future<void> _openParentMode() async {
    final ok = await ParentAccess.run(
      context,
      title: 'Área do responsável',
      subtitle: 'Confirme para continuar:',
    );
    if (!mounted || !ok) {
      if (mounted && !ok) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Acesso não confirmado.')),
        );
      }
      return;
    }

    await Navigator.push<void>(
      context,
      MaterialPageRoute(builder: (context) => const AreaMestrePage()),
    );

    if (!mounted) return;
    final s = await AppRepository.instance.load();
    _aplicarSnapshot(s);

    if (s.placedMoitasCount == 0) {
      _pararEscutaShake();
      _fallController.reset();
    }
  }

  Widget _buildMoitaWidget() {
    return SizedBox(
      width: 80,
      height: 80,
      child: Stack(
        clipBehavior: Clip.none,
        children: const [
          Positioned(left: 20, top: 0, child: Icon(Icons.eco, color: Colors.greenAccent, size: 45, shadows: [Shadow(color: Colors.black45, blurRadius: 4, offset: Offset(1, 1))])),
          Positioned(left: -5, top: 25, child: Icon(Icons.eco, color: Colors.lightGreenAccent, size: 40, shadows: [Shadow(color: Colors.black45, blurRadius: 4, offset: Offset(1, 1))])),
          Positioned(left: 45, top: 25, child: Icon(Icons.eco, color: Colors.green, size: 40, shadows: [Shadow(color: Colors.black45, blurRadius: 4, offset: Offset(1, 1))])),
          Positioned(left: 5, top: 50, child: Icon(Icons.eco, color: Colors.lightGreen, size: 40, shadows: [Shadow(color: Colors.black45, blurRadius: 4, offset: Offset(1, 1))])),
          Positioned(left: 35, top: 50, child: Icon(Icons.eco, color: Colors.greenAccent, size: 40, shadows: [Shadow(color: Colors.black45, blurRadius: 4, offset: Offset(1, 1))])),
        ],
      ),
    );
  }

  Future<void> _mostrarPremioDoFruto() async {
    final premio = _weeklyPrize.trim().isEmpty ? 'Prêmio definido pelos responsáveis' : _weeklyPrize.trim();
    if (!mounted) return;
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Maçã dourada!'),
        content: Text('Você bateu a meta do período!\n\nPrêmio: $premio'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Que legal!'),
          ),
        ],
      ),
    );
  }

  Widget _buildFrutoDourado(Size treeSize) {
    return Positioned(
      left: (treeSize.width * 0.50) - 43,
      top: (treeSize.height * 0.43) - 44,
      child: GestureDetector(
        onTap: _mostrarPremioDoFruto,
        child: AnimatedBuilder(
          animation: _goldenFruitPulseController,
          builder: (context, child) {
            final pulse = Curves.easeInOut.transform(_goldenFruitPulseController.value);
            final scale = 1.0 + (pulse * 0.06);
            return Transform.scale(scale: scale, child: child);
          },
          child: SizedBox(
            width: 86,
            height: 88,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Positioned(
                  left: 8,
                  top: 25,
                  child: Container(
                    width: 34,
                    height: 44,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24),
                      gradient: LinearGradient(
                        colors: [Colors.amber.shade100, Colors.amber.shade400, Colors.orange.shade700],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.amber.withValues(alpha: 0.56),
                          blurRadius: 16,
                          spreadRadius: 2,
                        ),
                      ],
                      border: Border.all(color: Colors.brown.shade700, width: 1.5),
                    ),
                  ),
                ),
                Positioned(
                  right: 8,
                  top: 25,
                  child: Container(
                    width: 34,
                    height: 44,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24),
                      gradient: LinearGradient(
                        colors: [Colors.amber.shade100, Colors.amber.shade500, Colors.orange.shade700],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      border: Border.all(color: Colors.brown.shade700, width: 1.5),
                    ),
                  ),
                ),
                Positioned(
                  left: 22,
                  top: 39,
                  child: Container(
                    width: 42,
                    height: 30,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(22),
                      gradient: LinearGradient(
                        colors: [Colors.amber.shade300, Colors.orange.shade700],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      border: Border.all(color: Colors.brown.shade700, width: 1.3),
                    ),
                  ),
                ),
                Positioned(
                  left: 39,
                  top: 2,
                  child: Transform.rotate(
                    angle: 0.1,
                    child: Container(
                      width: 7,
                      height: 20,
                      decoration: BoxDecoration(
                        color: Colors.brown.shade700,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  left: 46,
                  top: 8,
                  child: Transform.rotate(
                    angle: -0.5,
                    child: Container(
                      width: 24,
                      height: 12,
                      decoration: BoxDecoration(
                        color: Colors.lightGreen.shade600,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.green.shade900, width: 1),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  left: 26,
                  top: 37,
                  child: Container(
                    width: 18,
                    height: 11,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                Positioned(
                  right: 20,
                  top: 51,
                  child: Container(
                    width: 9,
                    height: 9,
                    decoration: BoxDecoration(
                      color: Colors.amber.shade50,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.amber.withValues(alpha: 0.5),
                          blurRadius: 8,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  double _driftParaIndice(int i) => ((i * 17) % 11 - 5) * 6.0;

  Widget _buildMoitasNaArvore(Size treeSize) {
    return AnimatedBuilder(
      animation: _fallController,
      builder: (context, child) {
        final t = _fallController.isDismissed ? 0.0 : Curves.easeIn.transform(_fallController.value);
        return Stack(
          clipBehavior: Clip.none,
          children: [
            for (int i = 0; i < placedMoitasCount; i++)
              Positioned(
                left: _anchoredMoita(predefinedLeafPositions[i]).dx * treeSize.width -
                    40.0 +
                    _driftParaIndice(i) * t,
                top: _anchoredMoita(predefinedLeafPositions[i]).dy * treeSize.height -
                    40.0 +
                    t * treeSize.height * 0.68,
                child: IgnorePointer(
                  child: Opacity(
                    opacity: (1.0 - t * 0.82).clamp(0.2, 1.0),
                    child: _buildMoitaWidget(),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final Size treeSize = const Size(400, 700);

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            getBackgroundImage(),
            fit: BoxFit.cover,
          ),

          Align(
            alignment: Alignment.bottomCenter,
            child: SizedBox.fromSize(
              key: ValueKey<int>(placedMoitasCount),
              size: treeSize,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    _buildMoitasNaArvore(treeSize),
                    if (placedMoitasCount >= weeklyGoal) _buildFrutoDourado(treeSize),
                  ],
                ),
              ),
          ),

          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.info_outline, color: Colors.white, size: 32),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const CreditosPage()),
                        );
                      },
                      style: IconButton.styleFrom(backgroundColor: Colors.black26),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.9),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: const [
                          BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2)),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Progresso: $placedMoitasCount / $weeklyGoal',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.green),
                          ),
                          if (_prazoPeriodo != null) ...[
                            const SizedBox(height: 4),
                            Text(
                              'Prazo: ${_fmtDia(_prazoPeriodo!)}',
                              style: TextStyle(fontSize: 12, color: Colors.grey[800]),
                            ),
                          ],
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.lock_outline, color: Colors.white, size: 32),
                      onPressed: _openParentMode,
                      style: IconButton.styleFrom(backgroundColor: Colors.black26),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),

      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (_mostrarBotaoNovoPeriodo) ...[
            FloatingActionButton.extended(
              heroTag: 'fab_new_period',
              onPressed: _abrirIniciarNovoPeriodo,
              backgroundColor: Colors.deepPurple,
              elevation: 6,
              icon: const Icon(Icons.restart_alt, color: Colors.white),
              label: const Text(
                'Novo período',
                style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 12),
          ],
          if (_mostrarBotaoFinalizar) ...[
            FloatingActionButton.extended(
              heroTag: 'fab_finalize_week',
              onPressed: _abrirFinalizarPeriodo,
              backgroundColor: Colors.amber.shade700,
              elevation: 6,
              icon: const Icon(Icons.celebration, color: Colors.white),
              label: const Text(
                'Finalizar período',
                style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 12),
          ],
          FloatingActionButton.extended(
            heroTag: 'fab_add_task',
            onPressed: _addMoita,
            backgroundColor: Colors.green,
            elevation: 6,
            icon: const Icon(Icons.park, color: Colors.white),
            label: const Text('+1 Tarefa', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
