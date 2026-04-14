import 'package:flutter/material.dart';

class AreaMestrePage extends StatefulWidget {
  final int metaAtual;

  const AreaMestrePage({super.key, required this.metaAtual});

  @override
  State<AreaMestrePage> createState() => _AreaMestrePageState();
}

class _AreaMestrePageState extends State<AreaMestrePage> {
  late TextEditingController _metaController;
  final TextEditingController _premioController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _metaController = TextEditingController(text: widget.metaAtual.toString());
  }

  @override
  void dispose() {
    _metaController.dispose();
    _premioController.dispose();
    super.dispose();
  }

  void _salvarConfiguracoes() {
    int novaMeta = int.tryParse(_metaController.text) ?? widget.metaAtual;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Configurações salvas com sucesso!'), backgroundColor: Colors.green),
    );

    Navigator.pop(context, {'acao': 'salvar', 'novaMeta': novaMeta});
  }

  void _encerrarSemana() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Encerrar Semana?'),
        content: const Text('Isso fará as folhas caírem e preparará a árvore para a próxima semana. Tem certeza?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            onPressed: () {
              Navigator.pop(context);

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Semana encerrada! A árvore foi limpa.')),
              );

              Navigator.pop(context, {'acao': 'zerar'});
            },
            child: const Text('Sim, Encerrar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7F1),
      appBar: AppBar(
        title: const Text('Área do Mestre'),
        backgroundColor: Colors.blueGrey[800],
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Configurações da Semana',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.blueGrey),
            ),
            const SizedBox(height: 24),

            TextField(
              controller: _metaController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Meta de Folhas',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                prefixIcon: const Icon(Icons.eco, color: Colors.green),
              ),
            ),
            const SizedBox(height: 20),

            TextField(
              controller: _premioController,
              decoration: InputDecoration(
                labelText: 'Prêmio da Semana',
                hintText: 'Ex: Noite da Pizza, Passeio no Parque...',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                prefixIcon: const Icon(Icons.star, color: Colors.orange),
              ),
            ),
            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueGrey[800],
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: _salvarConfiguracoes,
                child: const Text('Salvar Configurações', style: TextStyle(fontSize: 16)),
              ),
            ),
            const SizedBox(height: 40),

            const Divider(),
            const SizedBox(height: 20),

            const Text(
              'Ações Especiais',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.redAccent),
            ),
            const SizedBox(height: 16),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red,
                  side: const BorderSide(color: Colors.red),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                icon: const Icon(Icons.refresh),
                label: const Text('Encerrar Semana (Limpar Árvore)', style: TextStyle(fontSize: 16)),
                onPressed: _encerrarSemana,
              ),
            ),
          ],
        ),
      ),
    );
  }
}