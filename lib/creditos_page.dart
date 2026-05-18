import 'package:flutter/material.dart';

class CreditosPage extends StatelessWidget {
  const CreditosPage({super.key});

  void _showPrivacyPolicy(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Política de Privacidade'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('1. Objetivo', style: TextStyle(fontWeight: FontWeight.bold)),
              const Text('Este aplicativo tem como finalidade auxiliar no controle de metas e tarefas para crianças, promovendo a harmonia familiar.'),
              const SizedBox(height: 12),
              const Text('2. Coleta de Dados e Biometria', style: TextStyle(fontWeight: FontWeight.bold)),
              const Text('O app utiliza a permissão de biometria do dispositivo exclusivamente para autenticar o acesso à Área do Responsável. Os dados biométricos são processados e armazenados localmente pelo sistema operacional do dispositivo; o aplicativo não tem acesso nem armazena as digitais ou reconhecimento facial em servidores.'),
              const SizedBox(height: 12),
              const Text('3. Segurança', style: TextStyle(fontWeight: FontWeight.bold)),
              const Text('Todas as configurações de metas e prêmios são armazenadas localmente no dispositivo do usuário, garantindo que as informações não saiam do aparelho.'),
              const SizedBox(height: 12),
              const Text('4. Contato', style: TextStyle(fontWeight: FontWeight.bold)),
              const Text('Para dúvidas ou solicitações, entre em contato com a equipe de desenvolvimento através dos canais institucionais da UNISAGRADO.'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Fechar'),
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
        title: const Text('Créditos'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white70,
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
              content: 'Gabriel Martielo da Silva\nGabriel Furlaneto de Luiz\nJoão Vitor de Paula Diniz',
            ),
            const SizedBox(height: 32),

            // ÁREA DE LOGOS OBRIGATÓRIAS.
            const Divider(),
            const SizedBox(height: 16),
            const Text('Desenvolvimento:', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Image.asset(
              'assets/images/logo_cc.jpg',
              height: 60,
              fit: BoxFit.contain,
            ),

            const SizedBox(height: 24),
            const Text('Apoio:', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Image.asset(
              'assets/images/logo_extensao.jpg',
              height: 60,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 32),
            
            OutlinedButton.icon(
              onPressed: () => _showPrivacyPolicy(context),
              icon: const Icon(Icons.privacy_tip_outlined),
              label: const Text('Política de Privacidade'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              ),
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
