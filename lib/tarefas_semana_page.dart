import 'package:flutter/material.dart';

import 'data/app_repository.dart';
import 'models/week_models.dart';

class TarefasSemanaPage extends StatefulWidget {
  final int metaSemanal;

  const TarefasSemanaPage({super.key, required this.metaSemanal});

  @override
  State<TarefasSemanaPage> createState() => _TarefasSemanaPageState();
}

class _TarefasSemanaPageState extends State<TarefasSemanaPage> {
  final List<_LinhaTarefa> _linhas = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _carregar();
  }

  Future<void> _carregar() async {
    final snap = await AppRepository.instance.load();
    if (!mounted) return;
    setState(() {
      _linhas.clear();
      if (snap.tarefas.isEmpty) {
        _linhas.add(_LinhaTarefa.vazia());
        _linhas.add(_LinhaTarefa.vazia());
      } else {
        for (final t in snap.tarefas) {
          _linhas.add(_LinhaTarefa(
            id: t.id,
            titulo: TextEditingController(text: t.titulo),
            pontos: TextEditingController(text: t.pontos.toString()),
          ));
        }
      }
      _loading = false;
    });
  }

  @override
  void dispose() {
    for (final l in _linhas) {
      l.titulo.dispose();
      l.pontos.dispose();
    }
    super.dispose();
  }

  int get _soma {
    var s = 0;
    for (final l in _linhas) {
      s += int.tryParse(l.pontos.text) ?? 0;
    }
    return s;
  }

  bool get _valido => _linhas.isNotEmpty && _soma == widget.metaSemanal && _linhas.every((l) => l.titulo.text.trim().isNotEmpty);

  Future<void> _salvar() async {
    if (!_valido) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _soma != widget.metaSemanal
                ? 'A soma dos pontos ($_soma) precisa ser exatamente igual à meta (${widget.metaSemanal}).'
                : 'Preencha o nome de cada tarefa.',
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final tarefas = <TarefaSemana>[];
    for (final l in _linhas) {
      final pts = int.tryParse(l.pontos.text.trim());
      if (pts == null || pts < 1) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cada tarefa precisa de pontos válidos (número ≥ 1).'), backgroundColor: Colors.red),
        );
        return;
      }
      tarefas.add(TarefaSemana(
        id: l.id,
        titulo: l.titulo.text.trim(),
        pontos: pts,
      ));
    }

    await AppRepository.instance.saveTarefas(tarefas);
    final snap = await AppRepository.instance.load();
    final ids = tarefas.map((e) => e.id).toSet();
    final filtrado = snap.tarefasConcluidasIds.where(ids.contains).toSet();
    await AppRepository.instance.saveTarefasConcluidas(filtrado);

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Tarefas salvas!'), backgroundColor: Colors.green),
    );
    Navigator.pop(context, true);
  }

  void _addLinha() {
    setState(() => _linhas.add(_LinhaTarefa.vazia()));
  }

  void _removeLinha(int i) {
    if (_linhas.length <= 1) return;
    setState(() {
      _linhas[i].titulo.dispose();
      _linhas[i].pontos.dispose();
      _linhas.removeAt(i);
    });
  }

  void _distribuirIgual() {
    final n = _linhas.length;
    if (n == 0) return;
    final base = widget.metaSemanal ~/ n;
    var resto = widget.metaSemanal % n;
    setState(() {
      for (var i = 0; i < n; i++) {
        var v = base;
        if (resto > 0) {
          v++;
          resto--;
        }
        _linhas[i].pontos.text = v.toString();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final soma = _soma;
    final diff = widget.metaSemanal - soma;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7F1),
      appBar: AppBar(
        title: const Text('Tarefas do período'),
        backgroundColor: Colors.blueGrey[800],
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            'Meta do período: ${widget.metaSemanal} pontos (folhas). '
            'A soma dos pontos de todas as tarefas deve ser exatamente essa meta — nem falta, nem sobra.',
            style: TextStyle(fontSize: 15, color: Colors.blueGrey[800], height: 1.35),
          ),
          const SizedBox(height: 16),
          Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(
                    diff == 0 ? Icons.check_circle : Icons.info_outline,
                    color: diff == 0 ? Colors.green : Colors.orange,
                    size: 28,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Total: $soma / ${widget.metaSemanal}'
                      '${diff == 0 ? ' — ok!' : (diff > 0 ? ' — faltam $diff pontos' : ' — passou ${-diff} pontos da meta')}',
                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              onPressed: _distribuirIgual,
              icon: const Icon(Icons.balance),
              label: const Text('Distribuir pontos igualmente entre as linhas'),
            ),
          ),
          const SizedBox(height: 8),
          ...List.generate(_linhas.length, (i) {
            final l = _linhas[i];
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 3,
                    child: TextField(
                      controller: l.titulo,
                      onChanged: (_) => setState(() {}),
                      decoration: InputDecoration(
                        labelText: 'Tarefa ${i + 1}',
                        hintText: 'Ex.: Arrumar a cama',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  SizedBox(
                    width: 72,
                    child: TextField(
                      controller: l.pontos,
                      onChanged: (_) => setState(() {}),
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Pts',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => _removeLinha(i),
                    icon: const Icon(Icons.remove_circle_outline, color: Colors.red),
                  ),
                ],
              ),
            );
          }),
          OutlinedButton.icon(
            onPressed: _addLinha,
            icon: const Icon(Icons.add),
            label: const Text('Adicionar tarefa'),
          ),
          const SizedBox(height: 28),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green[700],
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: _salvar,
              child: const Text('Salvar tarefas', style: TextStyle(fontSize: 16)),
            ),
          ),
        ],
      ),
    );
  }
}

class _LinhaTarefa {
  static int _nextId = 0;

  final String id;
  final TextEditingController titulo;
  final TextEditingController pontos;

  _LinhaTarefa({
    required this.id,
    required this.titulo,
    required this.pontos,
  });

  factory _LinhaTarefa.vazia() {
    _nextId++;
    return _LinhaTarefa(
      id: 't_${DateTime.now().microsecondsSinceEpoch}_$_nextId',
      titulo: TextEditingController(),
      pontos: TextEditingController(text: '1'),
    );
  }
}
