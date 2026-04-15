import 'package:flutter/material.dart';
import 'creditos_page.dart';
import 'area_mestre_page.dart';

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

class _HomePageState extends State<HomePage> {
  // =========================================================================
  // ÁREA DO BACKEND & LÓGICA DE DADOS
  // =========================================================================

  // A lógica é 1 para 1: Cada avanço desenha 1 Moita inteira
  int placedMoitasCount = 0;
  int weeklyGoal = 100; // Meta padrão ajustada para a capacidade da sua árvore

  // A sua lista oficial de 101 posições - AGORA AJUSTADAS PARA CIMA!
  final List<Offset> predefinedLeafPositions = [
    const Offset(0.496, 0.461), const Offset(0.372, 0.449), const Offset(0.285, 0.424),
    const Offset(0.194, 0.400), const Offset(0.078, 0.362), const Offset(0.045, 0.424),
    const Offset(0.094, 0.327), const Offset(0.012, 0.289), const Offset(0.070, 0.251),
    const Offset(0.169, 0.244), const Offset(0.243, 0.240), const Offset(0.297, 0.249),
    const Offset(0.380, 0.301), const Offset(0.454, 0.339), const Offset(0.454, 0.386),
    const Offset(0.471, 0.407), const Offset(0.421, 0.322), const Offset(0.384, 0.292),
    const Offset(0.342, 0.358), const Offset(0.252, 0.355), const Offset(0.503, 0.372),
    const Offset(0.574, 0.301), const Offset(0.602, 0.268), const Offset(0.690, 0.266),
    const Offset(0.735, 0.214), const Offset(0.781, 0.183), const Offset(0.847, 0.181),
    const Offset(0.648, 0.195), const Offset(0.644, 0.162), const Offset(0.619, 0.131),
    const Offset(0.607, 0.093), const Offset(0.483, 0.249), const Offset(0.475, 0.190),
    const Offset(0.384, 0.207), const Offset(0.388, 0.148), const Offset(0.392, 0.105),
    const Offset(0.487, 0.060), const Offset(0.338, 0.188), const Offset(0.272, 0.150),
    const Offset(0.252, 0.115), const Offset(0.252, 0.115), const Offset(0.169, 0.202),
    const Offset(0.107, 0.164), const Offset(0.177, 0.119), const Offset(0.578, 0.424),
    const Offset(0.657, 0.365), const Offset(0.694, 0.417), const Offset(0.805, 0.405),
    const Offset(0.901, 0.389), const Offset(0.793, 0.346), const Offset(0.822, 0.278),
    const Offset(0.847, 0.315), const Offset(0.847, 0.278), const Offset(0.888, 0.254),
    const Offset(0.962, 0.322), const Offset(0.946, 0.350), const Offset(0.615, 0.421),
    const Offset(0.702, 0.469), const Offset(0.512, 0.429), const Offset(0.313, 0.429),
    const Offset(0.334, 0.320), const Offset(0.380, 0.238), const Offset(0.467, 0.242),
    const Offset(0.313, 0.365), const Offset(0.235, 0.457), const Offset(0.169, 0.188),
    const Offset(0.127, 0.171), const Offset(0.222, 0.176), const Offset(0.437, 0.190),
    const Offset(0.553, 0.150), const Offset(0.528, 0.136), const Offset(0.661, 0.124),
    const Offset(0.756, 0.162), const Offset(0.760, 0.221), const Offset(0.826, 0.256),
    const Offset(0.789, 0.292), const Offset(0.813, 0.334), const Offset(0.912, 0.386),
    const Offset(0.809, 0.426), const Offset(0.698, 0.424), const Offset(0.632, 0.438),
    const Offset(0.553, 0.447), const Offset(0.417, 0.443), const Offset(0.272, 0.433),
    const Offset(0.222, 0.429), const Offset(0.136, 0.350), const Offset(0.062, 0.289),
    const Offset(0.037, 0.308), const Offset(0.152, 0.176), const Offset(0.098, 0.103),
    const Offset(0.268, 0.068), const Offset(0.334, 0.063), const Offset(0.412, 0.068),
    const Offset(0.591, 0.096), const Offset(0.677, 0.152), const Offset(0.764, 0.176),
    const Offset(0.867, 0.223), const Offset(0.917, 0.240), const Offset(0.917, 0.318),
    const Offset(0.888, 0.386), const Offset(0.872, 0.421), const Offset(0.802, 0.421),
  ];

  // =========================================================================
  // MÉTODOS DE AÇÃO
  // =========================================================================

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
              if (pinController.text == '1234') {
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
                        placedMoitasCount = 0; // Limpa o contador
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

  // =========================================================================
  // RENDERIZAÇÃO DA MOITA (5 FOLHAS)
  // =========================================================================
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

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    // Mantemos o tamanho da caixa gigante que usamos para mapear!
    final Size treeSize = const Size(400, 700);

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 1. CAMADA DE FUNDO
          Image.asset(
            getBackgroundImage(),
            fit: BoxFit.cover,
          ),

          // 2. CAMADA DA ÁRVORE E DAS MOITAS
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              // Sem padding para a caixa usar a tela toda, assim como no mapeador
              padding: const EdgeInsets.only(bottom: 0.0),
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

                    // Renderiza as moitas perfeitamente nas suas coordenadas customizadas
                    ...predefinedLeafPositions.take(placedMoitasCount).map((pos) {
                      return Positioned(
                        // Subtrai 40 para centralizar a moita de 80x80 na coordenada
                        left: (pos.dx * treeSize.width) - 40.0,
                        top: (pos.dy * treeSize.height) - 40.0,
                        child: IgnorePointer(child: _buildMoitaWidget()),
                      );
                    }),
                  ],
                ),
              ),
            ),
          ),

          // 3. CAMADA DA GRAMA (Rodapé Responsivo)
          Align(
            alignment: Alignment.bottomCenter,
            child: IgnorePointer(
              child: Image.asset(
                'assets/images/grama.png',
                fit: BoxFit.cover,
                width: double.infinity,
                height: screenSize.height * 0.18,
              ),
            ),
          ),

          // 4. CAMADA DE UI: BARRA SUPERIOR
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
                          color: Colors.white.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: const [
                            BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2))
                          ]
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

      // BOTÃO ÚNICO DE RECOMPENSA
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addMoita,
        backgroundColor: Colors.green,
        elevation: 6,
        icon: const Icon(Icons.park, color: Colors.white),
        label: const Text('+1 Tarefa', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}