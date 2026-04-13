import 'package:flutter/material.dart';
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

class _HomePageState extends State<HomePage> {
  // =========================================================================
  // ÁREA DO BACKEND
  // =========================================================================
  // BACKEND: atenção nisso. Em vez de salvar apenas um 'int' com a quantidade,
  // agora será necessário salvar uma lista de objetos ou um JSON contendo
  // as coordenadas (dx, dy) de cada folha já colocada.
  List<Offset> placedLeaves = [];

  // BACKEND: recuperar este valor da configuração da Área do Mestre.
  int weeklyGoal = 20;

  // =========================================================================
  // LÓGICA DE FRONTEND
  // =========================================================================
  bool isPlacingMode = false; // Controla se o usuário está prestes a colocar uma folha

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

  void _activatePlacingMode() {
    if (placedLeaves.length >= weeklyGoal) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('A meta semanal já foi atingida!')),
      );
      return;
    }

    setState(() {
      isPlacingMode = true;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Toque em qualquer lugar da árvore para colocar a folha!'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _handleScreenTap(TapDownDetails details, Size screenSize) {
    if (!isPlacingMode) return; // Se não clicou no '+', o toque não faz nada

    setState(() {
      // Transformamos os pixels exatos do toque em uma porcentagem (0.0 a 1.0)
      // Isso garante que a folha fique no mesmo galho em qualquer tamanho de celular
      double relativeX = details.localPosition.dx / screenSize.width;
      double relativeY = details.localPosition.dy / screenSize.height;

      placedLeaves.add(Offset(relativeX, relativeY));
      isPlacingMode = false; // Desativa o modo após colocar a folha
    });

    // BACKEND: seguir com a rotina de salvar a lista 'placedLeaves' atualizada no banco local.
    // BACKEND: verificar aqui se placedLeaves.length == weeklyGoal para disparar o evento do Fruto Dourado.
  }

  void _openParentMode() {
    // BACKEND: integrar a validação do PIN de segurança antes de liberar o Navigator.
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
    // Pegamos o tamanho total da tela para calcular as posições
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      body: GestureDetector(
        // O GestureDetector captura o toque na tela inteira
        onTapDown: (details) => _handleScreenTap(details, screenSize),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // 1. CAMADA DE FUNDO
            Image.asset(
              getBackgroundImage(),
              fit: BoxFit.cover,
            ),

            // 2. CAMADA DAS FOLHAS (Renderizadas dinamicamente onde o usuário tocou)
            ...placedLeaves.map((pos) {
              return Positioned(
                // Multiplicamos a porcentagem pelo tamanho da tela para achar o pixel exato
                // Subtraímos 20 para que o centro do ícone (que tem tamanho 40) fique exatamente onde o dedo tocou
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

// 3. CAMADA DE UI: AVISO VISUAL DE MODO DE COLOCAÇÃO ATIVO
            if (isPlacingMode)
              Container(
                color: Colors.green.withOpacity(0.2),
              ),

            // 4. CAMADA DE UI: BARRA SUPERIOR (Créditos, Progresso e Cadeado)
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
                      // BOTÃO DE CRÉDITOS
                      IconButton(
                        icon: const Icon(Icons.info_outline, color: Colors.white, size: 32),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => CreditosPage()),
                          );
                        },
                        tooltip: 'Créditos',
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.black26, // Fundo levemente escuro para dar contraste
                        ),
                      ),

                      // CONTADOR DE PROGRESSO
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
                          'Folhas: ${placedLeaves.length} / $weeklyGoal',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: Colors.green,
                          ),
                        ),
                      ),

                      // BOTÃO MODO PAIS (Cadeado)
                      IconButton(
                        icon: const Icon(Icons.lock_outline, color: Colors.white, size: 32),
                        onPressed: _openParentMode,
                        tooltip: 'Área do Mestre',
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.black26,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),

      // BOTÃO FLUTUANTE DE ADICIONAR FOLHA
      floatingActionButton: isPlacingMode
          ? null
          : FloatingActionButton.large(
        onPressed: _activatePlacingMode,
        backgroundColor: Colors.green,
        elevation: 6,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: const Icon(Icons.add, color: Colors.white, size: 40),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}