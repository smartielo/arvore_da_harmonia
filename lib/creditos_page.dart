import 'package:flutter/material.dart';

class CreditosPage extends StatelessWidget {
  const CreditosPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7F1),
      appBar: AppBar(
        title: const Text('Créditos'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Icon(Icons.park, size: 80, color: Colors.green),
            const SizedBox(height: 16),
            const Text(
              'A Árvore da Harmonia',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.green),
            ),
            const SizedBox(height: 32),

            _buildInfoCard(
              title: 'Disciplina',
              content: 'Desenvolvimento de Software\n1º Semestre de 2026',
            ),
            const SizedBox(height: 16),

            _buildInfoCard(
              title: 'Docente Responsável',
              content: 'Prof. Dr. Elvio Gilberto da Silva',
            ),
            const SizedBox(height: 16),

            _buildInfoCard(
              title: 'Equipe de Desenvolvimento',
              content: 'Gabriel M.\nGabriel F.\nJoão Vitor', // BACKEND/EQUIPE: Preencher os nomes aqui
            ),
            const SizedBox(height: 32),

            // ÁREA DE LOGOS OBRIGATÓRIAS
            const Divider(),
            const SizedBox(height: 16),
            const Text('Desenvolvimento:', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            // FRONTEND: Adicionar a imagem do logo da Ciência da Computação nos assets depois
            Container(
              height: 60,
              width: double.infinity,
              color: Colors.grey[300],
              alignment: Alignment.center,
              child: const Text('Logo Ciência da Computação'),
            ),

            const SizedBox(height: 24),
            const Text('Apoio:', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            // FRONTEND: Adicionar a imagem do logo da Coordenadoria de Extensão nos assets depois
            Container(
              height: 60,
              width: double.infinity,
              color: Colors.grey[300],
              alignment: Alignment.center,
              child: const Text('Logo Coordenadoria de Extensão'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard({required String title, required String content}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [
            BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))
          ]
      ),
      child: Column(
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.green)),
          const SizedBox(height: 8),
          Text(content, textAlign: TextAlign.center, style: const TextStyle(fontSize: 16)),
        ],
      ),
    );
  }
}