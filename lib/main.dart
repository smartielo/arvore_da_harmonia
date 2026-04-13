import 'package:flutter/material.dart';

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
  // ÁREA DO BACKEND: VARIÁVEIS DE ESTADO
  // =========================================================================
  // Colegas do backend: Aqui vocês devem integrar o Hive ou SharedPreferences.
  // Esta variável 'leafCount' deve ser inicializada lendo do armazenamento local.
  int leafCount = 0;

  // Variável para a meta semanal. Deve vir do modo Área do Mestre.
  int weeklyGoal = 20;

  // =========================================================================
  // LÓGICA DE FRONTEND: DEFINIR BACKGROUND POR HORA
  // =========================================================================
  String getBackgroundImage() {
    final hour = DateTime.now().hour;
    // Retorna a imagem baseada na hora atual do dispositivo.
    if (hour >= 6 && hour < 12) {
      return 'assets/images/manha.png'; // Foto das 08:00
    } else if (hour >= 12 && hour < 16) {
      return 'assets/images/tarde.png'; // Foto das 12:00
    } else if (hour >= 16 && hour < 19) {
      return 'assets/images/entardecer.png'; // Foto das 17:00
    } else {
      return 'assets/images/noite.png'; // Foto das 20:00
    }
  }

  // =========================================================================
  // ÁREA DO BACKEND: FUNÇÕES DE AÇÃO
  // =========================================================================
  void _addLeaf() {
    // Colegas do backend:
    // 1. Atualizar o valor no banco de dados local (Hive/SharedPrefs).
    // 2. Chamar o setState para atualizar a UI.
    // 3. Verificar se 'leafCount == weeklyGoal' para disparar a animação Lottie do "Fruto Dourado".
    setState(() {
      leafCount++;
    });
  }

  void _openParentMode() {
    // Colegas do backend:
    // Em vez de navegar direto, abram um AlertDialog com um TextField para o PIN.
    // Só após validar o PIN gravado no banco, chamem o Navigator para a tela 'AreaDoMestre'.
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Modo Pais'),
        content: const Text('BACKEND: Inserir teclado numérico para PIN aqui.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Utilizamos um Stack para sobrepor a imagem de fundo, a árvore, as folhas e a UI.
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 1. CAMADA DE FUNDO (Background dinâmico)
          Image.asset(
            getBackgroundImage(),
            fit: BoxFit.cover,
          ),

          // 2. CAMADA DAS FOLHAS (Placeholder)
          // Colegas do backend/frontend:
          // Como a árvore já está na imagem de fundo, precisaremos usar o Positioned
          // ou um CustomPainter para desenhar as folhas nos galhos.
          // Este Container é onde as animações do pacote 'lottie' vão entrar depois.
          Center(
            child: Text(
              'BACKEND: Renderizar $leafCount folhas aqui',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                backgroundColor: Colors.black54,
              ),
            ),
          ),

          // 3. CAMADA DE UI: BOTÃO MODO PAIS (Cadeado/Engrenagem)
          Positioned(
            top: 50, // Ajuste para SafeArea dependendo do aparelho
            right: 20,
            child: IconButton(
              icon: const Icon(Icons.lock_outline, color: Colors.white, size: 32),
              onPressed: _openParentMode,
              tooltip: 'Área do Mestre',
            ),
          ),

          // 4. CAMADA DE UI: PROGRESSO (Opcional, mas útil visualmente)
          Positioned(
            top: 60,
            left: 20,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.8),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'Folhas: $leafCount / $weeklyGoal',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
          ),
        ],
      ),

      // BOTÃO FLUTUANTE PARA ADICIONAR FOLHAS
      floatingActionButton: FloatingActionButton.large(
        onPressed: _addLeaf,
        backgroundColor: Colors.green,
        child: const Icon(Icons.add, color: Colors.white, size: 40),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}