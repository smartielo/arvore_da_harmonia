import 'package:flutter/material.dart';

class ManualResponsavelPage extends StatelessWidget {
  const ManualResponsavelPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7F1),
      appBar: AppBar(
        title: const Text('Manual do Responsável'),
        backgroundColor: Colors.blueGrey[800],
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Bem-vindo ao Guia de Uso',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.blueGrey),
            ),
            const SizedBox(height: 20),
            _buildSection(
              title: 'O que é a Árvore da Harmonia?',
              content: 'Um sistema de gamificação para ajudar crianças a cumprirem metas semanais através de tarefas, transformando a disciplina em recompensa visual e positiva.',
            ),
            _buildSection(
              title: 'Como configurar o período',
              content: 'Na Área do Responsável, você define a Meta de Folhas (quantidade de pontos) e o Prêmio Final. Defina também a data limite para que a criança saiba quanto tempo tem.',
            ),
            _buildSection(
              title: 'Gestão de Tarefas',
              content: 'Você pode criar tarefas específicas com pontuações variadas. A criança marca como concluída e a árvore cresce automaticamente.',
            ),
            _buildSection(
              title: 'Finalizando a Semana',
              content: 'Quando a meta for atingida, use o botão "Finalizar Período". Isso disparará a celebração das folhas caindo e permitirá limpar a árvore para iniciar um novo ciclo.',
            ),
            _buildSection(
              title: 'Segurança',
              content: 'O acesso às configurações é protegido pela biometria ou senha do seu aparelho, garantindo que apenas adultos alterem as metas.',
            ),
            const SizedBox(height: 40),
            Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueGrey[800],
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () => Navigator.pop(context),
                child: const Text('Entendi!'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({required String title, required String content}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green)),
          const SizedBox(height: 8),
          Text(content, style: TextStyle(fontSize: 16, color: Colors.grey[800], height: 1.5)),
        ],
      ),
    );
  }
}
