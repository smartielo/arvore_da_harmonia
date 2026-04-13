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
  int placedLeavesCount = 0;
  int weeklyGoal = 20;

  // Posições fixas das folhas ajustadas para a sua árvore
  final List<Offset> predefinedLeafPositions = [
    const Offset(0.50, 0.30),
    const Offset(0.40, 0.35),
    const Offset(0.60, 0.35),
    const Offset(0.35, 0.45),
    const Offset(0.65, 0.45),
    const Offset(0.50, 0.40),
    const Offset(0.45, 0.50),
    const Offset(0.55, 0.50),
    const Offset(0.28, 0.55),
    const Offset(0.72, 0.55),
    const Offset(0.38, 0.58),
    const Offset(0.62, 0.58),
    const Offset(0.50, 0.48),
    const Offset(0.30, 0.48),
    const Offset(0.70, 0.48),
    const Offset(0.42, 0.42),
    const Offset(0.58, 0.42),
    const Offset(0.45, 0.60),
    const Offset(0.55, 0.60),
    const Offset(0.50, 0.55),
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

  void _addLeaf() {
    if (placedLeavesCount >= weeklyGoal) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('A meta semanal já foi atingida!')),
      );
      return;
    }

    setState(() {
      placedLeavesCount++;
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
                  MaterialPageRoute(builder: (context) => const AreaMestrePage()),
                );
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

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 1. CAMADA DE FUNDO (Agora faz todo o trabalho: Céu, Árvore e Grama juntos)
          Image.asset(
            getBackgroundImage(),
            fit: BoxFit.cover,
          ),

          // 2. CAMADA DAS FOLHAS (Desenhadas diretamente por cima do fundo)
          ...predefinedLeafPositions.take(placedLeavesCount).map((pos) {
            return Positioned(
              left: (pos.dx * screenSize.width) - 20,
              top: (pos.dy * screenSize.height) - 20,
              child: const Icon(
                Icons.eco,
                color: Colors.lightGreenAccent,
                size: 40,
                shadows: [
                  Shadow(color: Colors.black45, blurRadius: 4, offset: Offset(2, 2))
                ],
              ),
            );
          }),

          // 3. CAMADA DE UI: BARRA SUPERIOR
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
                        'Folhas: $placedLeavesCount / $weeklyGoal',
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

      // BOTÃO FLUTUANTE DE ADICIONAR FOLHA
      floatingActionButton: FloatingActionButton.large(
        onPressed: _addLeaf,
        backgroundColor: Colors.green,
        elevation: 6,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: const Icon(Icons.add, color: Colors.white, size: 40),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}