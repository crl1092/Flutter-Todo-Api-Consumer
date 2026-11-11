import 'dart:convert';

import 'package:todo_api_consumer/models/tarefa_model.dart';
import 'package:http/http.dart' as http;

class TarefaService {
  static const String baseUrl = String.fromEnvironment(
    "BASE_URL",
    defaultValue: "http://localhost:8080",
  );

  //Read
  Future<List<Tarefa>> buscarTarefas() async {
    final res = await http.get(Uri.parse('$baseUrl/tarefas'));

    if (res.statusCode == 200) {
      List<dynamic> body = jsonDecode(utf8.decode(res.bodyBytes));
      return body.map((item) => Tarefa.fronJson(item)).toList();
    } else {
      throw Exception("Erro ao carregar as tarefas");
    }
  }

  //Create
  Future<Tarefa> criarTarefa(String titulo, String descricao) async {
    final res = await http.post(
      Uri.parse('$baseUrl/tarefas'),
      headers: {'Content-Type': "application/json"},
      body: jsonEncode({
        'titulo': titulo,
        'descricao': descricao,
        "concluido": false,
      }),
    );

    if (res.statusCode == 200 || res.statusCode == 201) {
      return Tarefa.fronJson(jsonDecode(utf8.decode(res.bodyBytes)));
    } else {
      throw Exception("Falha ao criar a tarefa");
    }
  }

  //Update
  Future<Tarefa> alterarStatus(Tarefa tarefa) async {
    final response = await http.put(
      Uri.parse('$baseUrl/tarefas/${tarefa.id}'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'titulo': tarefa.titulo,
        'descricao': tarefa.descricao,
        'concluido': !tarefa.concluido, // Inverte o estado atual
      }),
    );
    if (response.statusCode == 200) {
      return Tarefa.fronJson(jsonDecode(utf8.decode(response.bodyBytes)));
    } else {
      throw Exception('Falha ao atualizar tarefa');
    }
  }

  // DELETE (Excluir tarefa)
  Future<void> deletarTarefa(int id) async {
    final response = await http.delete(Uri.parse('$baseUrl/tarefas/$id'));
    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Falha ao deletar tarefa');
    }
  }
}
