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

  // Agora a lógica é 1 para 1: Cada avanço desenha 1 Moita inteira
  int placedMoitasCount = 0;
  int weeklyGoal = 60; // A meta agora significa "60 Moitas"

  // 85 posições REVISADAS:
  // - Removidas as posições Y < 0.30 (nada na lua)
  // - Foco na expansão lateral (X indo de 0.20 até 0.80)
  final List<Offset> predefinedLeafPositions = [
    // Centro e Miolo
    const Offset(0.50, 0.45), const Offset(0.45, 0.48), const Offset(0.55, 0.48),
    const Offset(0.50, 0.52), const Offset(0.40, 0.45), const Offset(0.60, 0.45),
    const Offset(0.42, 0.40), const Offset(0.58, 0.40), const Offset(0.38, 0.52),

    // Expansão Lateral Interna
    const Offset(0.62, 0.52), const Offset(0.45, 0.56), const Offset(0.55, 0.56),
    const Offset(0.35, 0.48), const Offset(0.65, 0.48), const Offset(0.48, 0.38),
    const Offset(0.52, 0.38), const Offset(0.35, 0.42), const Offset(0.65, 0.42),

    // Base e Laterais Médias
    const Offset(0.32, 0.55), const Offset(0.68, 0.55), const Offset(0.40, 0.60),
    const Offset(0.60, 0.60), const Offset(0.50, 0.58), const Offset(0.50, 0.35),
    const Offset(0.30, 0.45), const Offset(0.70, 0.45), const Offset(0.28, 0.50),

    // Extremidades e Pontas dos Galhos
    const Offset(0.72, 0.50), const Offset(0.25, 0.55), const Offset(0.75, 0.55),
    const Offset(0.45, 0.62), const Offset(0.55, 0.62), const Offset(0.35, 0.60),
    const Offset(0.65, 0.60), const Offset(0.45, 0.32), const Offset(0.55, 0.32),
    const Offset(0.22, 0.52), const Offset(0.78, 0.52), const Offset(0.20, 0.58),

    // Contorno Inferior
    const Offset(0.80, 0.58), const Offset(0.28, 0.60), const Offset(0.72, 0.60),
    const Offset(0.32, 0.64), const Offset(0.68, 0.64), const Offset(0.40, 0.65),
    const Offset(0.60, 0.65), const Offset(0.48, 0.66), const Offset(0.52, 0.66),

    // Preenchimento Fino e Topo Seguro
    const Offset(0.38, 0.35), const Offset(0.62, 0.35), const Offset(0.42, 0.30),
    const Offset(0.58, 0.30), const Offset(0.48, 0.45), const Offset(0.52, 0.45),
    const Offset(0.45, 0.50), const Offset(0.55, 0.50), const Offset(0.40, 0.50),
    const Offset(0.60, 0.50), const Offset(0.38, 0.48), const Offset(0.62, 0.48),
    const Offset(0.48, 0.52), const Offset(0.52, 0.52), const Offset(0.42, 0.55),
    const Offset(0.58, 0.55), const Offset(0.45, 0.40), const Offset(0.55, 0.40),
    const Offset(0.48, 0.40), const Offset(0.52, 0.40), const Offset(0.35, 0.50),
    const Offset(0.65, 0.50), const Offset(0.32, 0.52), const Offset(0.68, 0.52),
    const Offset(0.38, 0.58), const Offset(0.62, 0.58), const Offset(0.42, 0.62),
    const Offset(0.58, 0.62), const Offset(0.48, 0.60), const Offset(0.52, 0.60),
    const Offset(0.45, 0.65), const Offset(0.55, 0.65), const Offset(0.38, 0.42),
    const Offset(0.62, 0.42), const Offset(0.42, 0.38), const Offset(0.58, 0.38),
    const Offset(0.48, 0.35), const Offset(0.52, 0.35), const Offset(0.45, 0.30),
    const Offset(0.55, 0.30),
  ];

  // ========================================================================
  // MÉTODOS DE AÇÃO
  // ========================================================================

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
    final Size treeSize = Size(350, 450);

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
              padding: const EdgeInsets.only(bottom: 70.0),
              child: SizedBox.fromSize(
                size: treeSize,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    GestureDetector(
                      onTapDown: (_) => _openParentMode(),
                      child: Image.asset(
                        'assets/images/arvore.png',
                        width: treeSize.width,
                        height: treeSize.height,
                        fit: BoxFit.contain,
                      ),
                    ),

                    // Renderiza apenas a quantidade de moitas que o usuário ganhou
                    ...predefinedLeafPositions.take(placedMoitasCount).map((pos) {
                      return Positioned(
                        // Subtrai 40 para centralizar a moita de 80x80 na coordenada
                        left: (pos.dx * treeSize.width) - 40.0,
                        top: (pos.dy * treeSize.height) - 40.0,
                        child: _buildMoitaWidget(),
                      );
                    }),
                  ],
                ),
              ),
            ),
          ),

          // 3. CAMADA DA GRAMA
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

      // BOTÃO ÚNICO DE RECOMPENSA (Mais simples e direto)
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