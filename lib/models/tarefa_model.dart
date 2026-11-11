class Tarefa {
  final int? id;
  final String titulo;
  final String descricao;
  final bool concluido;

  Tarefa({
    this.id,
    required this.titulo,
    required this.descricao,
    required this.concluido,
  });

  factory Tarefa.fronJson(Map<String, dynamic> json) {
    return Tarefa(
      id: json['id'],
      titulo: json['titulo'],
      descricao: json['descricao'],
      concluido: json['concluido'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'titulo': titulo,
      'descricao': descricao,
      'concluido': concluido,
    };
  }
}
