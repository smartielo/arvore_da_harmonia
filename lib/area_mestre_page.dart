import 'package:flutter/material.dart';

import 'data/app_repository.dart';
import 'models/week_models.dart';
import 'tarefas_semana_page.dart';

class AreaMestrePage extends StatefulWidget {
  const AreaMestrePage({super.key});

  @override
  State<AreaMestrePage> createState() => _AreaMestrePageState();
}

class _AreaMestrePageState extends State<AreaMestrePage> {
  final TextEditingController _metaController = TextEditingController();
  final TextEditingController _premioController = TextEditingController();

  bool _loading = true;
  bool _vibrationEnabled = true;
  AppSnapshot? _snap;
  DateTime? _dataLimitePeriodo;

  @override
  void initState() {
    super.initState();
    _carregar();
  }

  Future<void> _carregar() async {
    final snap = await AppRepository.instance.load();
    if (!mounted) return;
    setState(() {
      _snap = snap;
      _metaController.text = snap.weeklyGoal.toString();
      _premioController.text = snap.weeklyPrize;
      _vibrationEnabled = snap.vibrationEnabled;
      _dataLimitePeriodo = snap.periodoFim;
      _loading = false;
    });
  }

  String _fmtData(DateTime d) {
    final dd = d.day.toString().padLeft(2, '0');
    final mm = d.month.toString().padLeft(2, '0');
    return '$dd/$mm/${d.year}';
  }

  Future<void> _escolherPrazo() async {
    final agora = DateTime.now();
    final inicial = _dataLimitePeriodo ?? agora.add(const Duration(days: 7));
    final escolhida = await showDatePicker(
      context: context,
      initialDate: inicial.isBefore(agora) ? agora.add(const Duration(days: 1)) : inicial,
      firstDate: DateTime(agora.year, agora.month, agora.day),
      lastDate: agora.add(const Duration(days: 365 * 3)),
      helpText: 'Prazo final do período',
    );
    if (escolhida != null && mounted) {
      setState(() => _dataLimitePeriodo = escolhida);
    }
  }

  @override
  void dispose() {
    _metaController.dispose();
    _premioController.dispose();
    super.dispose();
  }

  Future<void> _salvarConfiguracoes() async {
    final novaMeta = int.tryParse(_metaController.text) ?? _snap?.weeklyGoal ?? 100;
    final premio = _premioController.text.trim();

    await AppRepository.instance.saveWeeklyGoal(novaMeta);
    await AppRepository.instance.saveWeeklyPrize(premio);
    await AppRepository.instance.saveVibrationEnabled(_vibrationEnabled);
    await AppRepository.instance.savePeriodoFim(_dataLimitePeriodo);

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Configurações salvas com sucesso!'), backgroundColor: Colors.green),
    );

    Navigator.pop(context, {'acao': 'salvar', 'novaMeta': novaMeta, 'premio': premio, 'vibration': _vibrationEnabled});
  }

  Future<void> _abrirTarefas() async {
    final meta = int.tryParse(_metaController.text) ?? _snap?.weeklyGoal ?? 100;
    await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (context) => TarefasSemanaPage(metaSemanal: meta)),
    );
    await _carregar();
  }

  void _encerrarSemana() {
    final pageContext = context;
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Encerrar semana?'),
        content: const Text(
          'Isso limpa a árvore, zera o progresso do período e registra esta semana no histórico. Tem certeza?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            onPressed: () async {
              Navigator.pop(dialogContext);
              final snap = await AppRepository.instance.load();
              final agora = DateTime.now();
              final inicio = snap.periodoInicio ?? agora;
              final h = HistoricoPeriodo(
                inicio: inicio,
                fim: agora,
                meta: snap.weeklyGoal,
                pontos: snap.placedMoitasCount,
                metaCumprida: snap.placedMoitasCount >= snap.weeklyGoal,
                premio: snap.weeklyPrize,
              );
              await AppRepository.instance.iniciarNovoPeriodo(
                encerrarAnteriorCom: h,
                novoPeriodoFim: DateTime.now().add(const Duration(days: 7)),
              );
              if (!pageContext.mounted) return;
              ScaffoldMessenger.of(pageContext).showSnackBar(
                const SnackBar(content: Text('Semana encerrada! A árvore foi limpa e o histórico atualizado.')),
              );
              Navigator.pop(pageContext, {'acao': 'zerar'});
            },
            child: const Text('Sim, encerrar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading || _snap == null) {
      return Scaffold(
        backgroundColor: const Color(0xFFF4F7F1),
        appBar: AppBar(
          title: const Text('Área do responsável'),
          backgroundColor: Colors.blueGrey[800],
          foregroundColor: Colors.white,
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final snap = _snap!;
    final somaT = snap.somaPontosTarefas;
    final okTarefas = snap.tarefasBatemMeta;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7F1),
      appBar: AppBar(
        title: const Text('Área do responsável'),
        backgroundColor: Colors.blueGrey[800],
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Configurações do período',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.blueGrey),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _metaController,
              keyboardType: TextInputType.number,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                labelText: 'Meta de folhas (pontos)',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                prefixIcon: const Icon(Icons.eco, color: Colors.green),
              ),
            ),
            const SizedBox(height: 12),
            Material(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              child: ListTile(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: Colors.blueGrey.shade300),
                ),
                leading: Icon(Icons.event, color: Colors.blueGrey[700]),
                title: const Text('Prazo final do período'),
                subtitle: Text(
                  _dataLimitePeriodo == null
                      ? 'Toque para escolher no calendário'
                      : 'Até ${_fmtData(_dataLimitePeriodo!)}',
                ),
                trailing: const Icon(Icons.calendar_month),
                onTap: _escolherPrazo,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _premioController,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                labelText: 'Prêmio do período',
                hintText: 'Ex.: Noite da pizza, passeio no parque…',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                prefixIcon: const Icon(Icons.star, color: Colors.orange),
              ),
            ),
            const SizedBox(height: 8),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Vibração leve ao celebrar (folhas caindo)'),
              subtitle: const Text('Desative se preferir sem feedback tátil.'),
              value: _vibrationEnabled,
              onChanged: (v) => setState(() => _vibrationEnabled = v),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal[700],
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: _abrirTarefas,
                icon: const Icon(Icons.checklist),
                label: const Text('Tarefas da criança (pontos por tarefa)', style: TextStyle(fontSize: 16)),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              okTarefas
                  ? 'Tarefas: soma $somaT pontos — conferem com a meta.'
                  : (snap.tarefas.isEmpty
                      ? 'Nenhuma tarefa cadastrada. A criança usa +1 ponto por toque na tela inicial.'
                      : 'Tarefas: soma $somaT ≠ meta ${snap.weeklyGoal}. Ajuste na tela de tarefas.'),
              style: TextStyle(
                fontSize: 13,
                color: okTarefas ? Colors.green[800] : Colors.orange[900],
              ),
            ),
            const SizedBox(height: 20),
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
                child: const Text('Salvar configurações', style: TextStyle(fontSize: 16)),
              ),
            ),
            const SizedBox(height: 36),
            const Divider(),
            const SizedBox(height: 16),
            const Text(
              'Histórico de períodos',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.blueGrey),
            ),
            const SizedBox(height: 8),
            Text(
              'Registrado ao encerrar a semana (limpar a árvore).',
              style: TextStyle(fontSize: 13, color: Colors.grey[700]),
            ),
            const SizedBox(height: 12),
            if (snap.historico.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Center(
                  child: Text(
                    'Ainda não há registros.',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ),
              )
            else
              ...snap.historico.reversed.map((h) => _HistoricoCard(item: h)),
            const SizedBox(height: 28),
            const Divider(),
            const SizedBox(height: 16),
            const Text(
              'Ações especiais',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.redAccent),
            ),
            const SizedBox(height: 12),
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
                label: const Text('Encerrar semana (limpar árvore)', style: TextStyle(fontSize: 16)),
                onPressed: _encerrarSemana,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HistoricoCard extends StatelessWidget {
  final HistoricoPeriodo item;

  const _HistoricoCard({required this.item});

  String _fmt(DateTime d) {
    final dd = d.day.toString().padLeft(2, '0');
    final mm = d.month.toString().padLeft(2, '0');
    return '$dd/$mm/${d.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  item.metaCumprida ? Icons.emoji_events : Icons.flag_outlined,
                  color: item.metaCumprida ? Colors.amber : Colors.grey,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '${_fmt(item.inicio)} → ${_fmt(item.fim)}',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: item.metaCumprida ? Colors.green[100] : Colors.orange[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    item.metaCumprida ? 'Meta cumprida' : 'Meta não cumprida',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: item.metaCumprida ? Colors.green[900] : Colors.orange[900],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text('Pontos: ${item.pontos} / meta ${item.meta}'),
            if (item.premio.isNotEmpty) Text('Prêmio: ${item.premio}'),
          ],
        ),
      ),
    );
  }
}
