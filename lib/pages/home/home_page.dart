import 'package:flutter/material.dart';
import 'package:todo_api_consumer/models/tarefa_model.dart';
import 'package:todo_api_consumer/services/tarefa_service.dart';

class HomePage extends StatefulWidget {
  const new({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TarefaService _service = TarefaService();
  late Future<List<Tarefa>> _futureTarefas;

  @override
  void initState() {
    super.initState();
    _futureTarefas = _service.buscarTarefas();
  }

  // Atualiza o estado da tela recarregando os dados da API
  void _atualizarLista() {
    setState(() {
      _futureTarefas = _service.buscarTarefas();
    });
  }

  void _exibirFormularioCriar() {
    final tituloController = TextEditingController();
    final descricaoController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          top: 20,
          left: 20,
          right: 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: tituloController,
              decoration: const InputDecoration(labelText: 'Título'),
            ),
            TextField(
              controller: descricaoController,
              decoration: const InputDecoration(labelText: 'Descrição'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                if (tituloController.text.isNotEmpty) {
                  await _service.criarTarefa(
                    tituloController.text,
                    descricaoController.text,
                  );
                  Navigator.pop(context);
                  _atualizarLista(); // Recarrega o app com o novo dado inserido no PostgreSQL
                }
              },
              child: const Text('Adicionar Tarefa'),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: SafeArea(
        child: Scaffold(
          appBar: AppBar(title: Text("Consumo de api"), centerTitle: true),
          body: FutureBuilder(
            future: _futureTarefas,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return Center(child: Text('Erro: ${snapshot.error}'));
              }

              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(child: Text('Nenhuma tarefa encontrada.'));
              }

              final tarefas = snapshot.data!;
              return ListView.builder(
                itemCount: tarefas.length,
                itemBuilder: (context, index) {
                  final tarefa = tarefas[index];
                  return ListTile(
                    title: Text(tarefa.titulo),
                    subtitle: Text(tarefa.descricao),
                    leading: IconButton(
                      onPressed: () async {
                        await _service.alterarStatus(tarefa);
                        _atualizarLista();
                      },
                      icon: Icon(
                        tarefa.concluido
                            ? Icons.check_circle
                            : Icons.radio_button_unchecked,
                        color: tarefa.concluido ? Colors.green : null,
                      ),
                    ),
                    trailing: IconButton(
                      onPressed: () async {
                        if (tarefa.id != null) {
                          await _service.deletarTarefa(tarefa.id!);
                          _atualizarLista();
                        }
                      },
                      icon: const Icon(Icons.delete, color: Colors.red),
                    ),
                  );
                },
              );
            },
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: _exibirFormularioCriar,
            label: Row(
              spacing: 5,
              children: [Icon(Icons.add), Text("Adicionar Tarefas")],
            ),
          ),
        ),
      ),
    );
  }
}
