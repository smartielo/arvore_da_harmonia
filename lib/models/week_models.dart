class TarefaSemana {
  final String id;
  final String titulo;
  final int pontos;

  const TarefaSemana({
    required this.id,
    required this.titulo,
    required this.pontos,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'titulo': titulo,
        'pontos': pontos,
      };

  factory TarefaSemana.fromJson(Map<String, dynamic> json) {
    return TarefaSemana(
      id: json['id'] as String,
      titulo: json['titulo'] as String,
      pontos: (json['pontos'] as num).toInt(),
    );
  }
}

class HistoricoPeriodo {
  final DateTime inicio;
  final DateTime fim;
  final int meta;
  final int pontos;
  final bool metaCumprida;
  final String premio;

  const HistoricoPeriodo({
    required this.inicio,
    required this.fim,
    required this.meta,
    required this.pontos,
    required this.metaCumprida,
    required this.premio,
  });

  Map<String, dynamic> toJson() => {
        'inicio': inicio.toIso8601String(),
        'fim': fim.toIso8601String(),
        'meta': meta,
        'pontos': pontos,
        'metaCumprida': metaCumprida,
        'premio': premio,
      };

  factory HistoricoPeriodo.fromJson(Map<String, dynamic> json) {
    return HistoricoPeriodo(
      inicio: DateTime.parse(json['inicio'] as String),
      fim: DateTime.parse(json['fim'] as String),
      meta: (json['meta'] as num).toInt(),
      pontos: (json['pontos'] as num).toInt(),
      metaCumprida: json['metaCumprida'] as bool,
      premio: json['premio'] as String? ?? '',
    );
  }
}
