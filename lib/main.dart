import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';

import 'area_mestre_page.dart';
import 'creditos_page.dart';

void main() {
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
  static const String _parentPin = '1234';

  /// Desloca as moitas um pouco para baixo na copa (cobre galhos inferiores).
  static const double _moitaDyNudge = 0.045;

  // A lógica é 1 para 1: Cada avanço desenha 1 Moita inteira
  int placedMoitasCount = 0;
  int weeklyGoal = 100;

  /// Após encerrar o período com PIN e a animação de queda, some o botão até zerar a árvore.
  bool _periodoCelebrado = false;

  /// PIN correto em "Finalizar período": aguarda o usuário balançar o celular.
  bool _aguardandoShakePosEncerramento = false;

  StreamSubscription<UserAccelerometerEvent>? _accelSub;

  late final AnimationController _fallController;

  // 101 posições: espiral de Fibonacci numa elipse (copa), priorizando bordas e topo dos galhos.
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
  }

  void _onFallStatus(AnimationStatus status) {
    if (status != AnimationStatus.completed) return;
    setState(() {
      _aguardandoShakePosEncerramento = false;
      _periodoCelebrado = true;
    });
    _pararEscutaShake();
    _fallController.reset();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Que legal! Semana encerrada com chave de ouro.')),
    );
  }

  @override
  void dispose() {
    _pararEscutaShake();
    _fallController.removeStatusListener(_onFallStatus);
    _fallController.dispose();
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

  void _addMoita() {
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

    setState(() {
      placedMoitasCount++;
    });
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
    _fallController.forward(from: 0);
    setState(() {});
  }

  bool get _mostrarBotaoFinalizar =>
      placedMoitasCount >= weeklyGoal && !_aguardandoShakePosEncerramento && !_periodoCelebrado;

  void _abrirFinalizarPeriodo() {
    final pinController = TextEditingController();

    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Finalizar período', textAlign: TextAlign.center),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Digite o PIN dos pais para encerrar o período e celebrar:'),
            const SizedBox(height: 16),
            TextField(
              controller: pinController,
              keyboardType: TextInputType.number,
              obscureText: true,
              maxLength: 4,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 24, letterSpacing: 16),
              decoration: InputDecoration(
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                counterText: '',
              ),
            ),
          ],
        ),
        actionsAlignment: MainAxisAlignment.spaceEvenly,
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
            onPressed: () {
              if (pinController.text != _parentPin) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('PIN incorreto!'), backgroundColor: Colors.red),
                );
                return;
              }
              Navigator.pop(context);
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
            },
            child: const Text('Confirmar'),
          ),
        ],
      ),
    );
  }

  void _openParentMode() {
    final TextEditingController pinController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Acesso Restrito', textAlign: TextAlign.center),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Digite o PIN de 4 dígitos:'),
            const SizedBox(height: 16),
            TextField(
              controller: pinController,
              keyboardType: TextInputType.number,
              obscureText: true,
              maxLength: 4,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 24, letterSpacing: 16),
              decoration: InputDecoration(
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                counterText: '',
              ),
            ),
          ],
        ),
        actionsAlignment: MainAxisAlignment.spaceEvenly,
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
            onPressed: () {
              if (pinController.text == _parentPin) {
                Navigator.pop(context);

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AreaMestrePage(metaAtual: weeklyGoal),
                  ),
                ).then((resultado) {
                  if (resultado != null) {
                    setState(() {
                      if (resultado['acao'] == 'zerar') {
                        placedMoitasCount = 0;
                        _periodoCelebrado = false;
                        _aguardandoShakePosEncerramento = false;
                        _pararEscutaShake();
                        _fallController.reset();
                      } else if (resultado['acao'] == 'salvar') {
                        weeklyGoal = resultado['novaMeta'];
                      }
                    });
                  }
                });
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('PIN incorreto!'), backgroundColor: Colors.red),
                );
              }
            },
            child: const Text('Entrar'),
          ),
        ],
      ),
    );
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

  double _driftParaIndice(int i) => ((i * 17) % 11 - 5) * 6.0;

  Color _corFolhaQueda(int i) {
    const cores = <Color>[
      Colors.greenAccent,
      Colors.lightGreenAccent,
      Colors.green,
      Colors.lightGreen,
    ];
    return cores[i % cores.length];
  }

  Widget _buildCamadaQuedaFolhas(Size treeSize) {
    return AnimatedBuilder(
      animation: _fallController,
      builder: (context, child) {
        final t = Curves.easeIn.transform(_fallController.value);
        return Stack(
          clipBehavior: Clip.none,
          children: [
            for (int i = 0; i < placedMoitasCount; i++)
              Positioned(
                left: _anchoredMoita(predefinedLeafPositions[i]).dx * treeSize.width -
                    36 +
                    _driftParaIndice(i) * t,
                top: _anchoredMoita(predefinedLeafPositions[i]).dy * treeSize.height - 36 + t * treeSize.height * 0.68,
                child: Opacity(
                  opacity: (1.0 - t * 0.9).clamp(0.0, 1.0),
                  child: Icon(Icons.eco, size: 44, color: _corFolhaQueda(i), shadows: const [
                    Shadow(color: Colors.black38, blurRadius: 3, offset: Offset(1, 1)),
                  ]),
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
    final bool ocultarMoitasEstaticas = _fallController.isAnimating;

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
              size: treeSize,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  GestureDetector(
                    onTapDown: (_) => _openParentMode(),
                    child: Container(
                      color: Colors.transparent,
                      width: treeSize.width,
                      height: treeSize.height,
                    ),
                  ),

                  if (!ocultarMoitasEstaticas)
                    ...predefinedLeafPositions.take(placedMoitasCount).map((pos) {
                      final p = _anchoredMoita(pos);
                      return Positioned(
                        left: p.dx * treeSize.width - 40.0,
                        top: p.dy * treeSize.height - 40.0,
                        child: IgnorePointer(child: _buildMoitaWidget()),
                      );
                    }),

                  if (ocultarMoitasEstaticas)
                    IgnorePointer(
                      child: _buildCamadaQuedaFolhas(treeSize),
                    ),
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
                      child: Text(
                        'Progresso: $placedMoitasCount / $weeklyGoal',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.green),
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
