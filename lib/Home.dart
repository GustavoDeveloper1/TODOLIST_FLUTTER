import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'dart:async';
import 'dart:convert';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final TextEditingController _taskController = TextEditingController();
  List<dynamic> _tasks = [];
  Map<String, dynamic> _lastRemoveTask = Map();

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _readArchive().then((data) {
        setState(() {
          _tasks = json.decode(data);
        });
      });
      // _saveArchive();
    });
    super.initState();
  }

  Future<File> _getFile() async {
    final diretorio = await getApplicationDocumentsDirectory();

    return File("${diretorio.path}/dados.json");
  }

  _saveArchive() async {
    var arquivo = await _getFile();

    String dados = json.encode(_tasks);

    arquivo.writeAsString(dados);
  }

  _saveTask() {
    String titleTake = _taskController.text;
    Map<String, dynamic> task = Map();

    task["title"] = titleTake;
    task["completed"] = false;

    setState(() {
      _tasks.add(task);
    });

    _saveArchive();

    _taskController.text = "";
  }

  _readArchive() async {
    try {
      var arquivo = await _getFile();
      return arquivo.readAsString();
    } catch (e) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    print("items: ${_tasks.toString()}");
    return Scaffold(
      appBar: AppBar(
        title: const Text('TodoList'),
        backgroundColor: Colors.purple,
      ),
      body: Column(children: [
        Expanded(
            child: ListView.builder(
                itemCount: _tasks.length,
                itemBuilder: (context, index) {
                  return Dismissible(
                    key: Key(DateTime.now().millisecondsSinceEpoch.toString()),
                    // direction: DismissDirection.endToStart,
                    secondaryBackground: Container(
                      color: Colors.red,
                      padding: const EdgeInsets.all(16),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [Icon(Icons.delete, color: Colors.white)],
                      ),
                    ),
                    background: Container(
                      color: Colors.green,
                      padding: const EdgeInsets.all(16),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Icon(Icons.edit, color: Colors.white),
                        ],
                      ),
                    ),

                    onDismissed: (direction) {
                      if (direction == DismissDirection.endToStart) {
                        _lastRemoveTask = _tasks[index];
                        setState(() {
                          _tasks.removeAt(index);
                        });
                        _saveArchive();

                        //snackbar
                        final snackbar = SnackBar(
                            backgroundColor: Colors.green,
                            duration: const Duration(seconds: 5),
                            action: SnackBarAction(
                                label: "Desfazer",
                                onPressed: () {
                                  setState(() {
                                    _tasks.insert(index, _lastRemoveTask);
                                  });

                                  _saveArchive();
                                }),
                            content: const Text(
                              "Tarefa Removida!",
                              style: TextStyle(color: Colors.white),
                            ));
                        ScaffoldMessenger.of(context).showSnackBar(snackbar);
                      } else if (direction == DismissDirection.startToEnd) {
                        print("endToStart");
                      }
                    },
                    child: CheckboxListTile(
                      value: _tasks[index]['completed'],
                      onChanged: (value) {
                        setState(() {
                          _tasks[index]['completed'] = value;
                        });
                        _saveArchive();
                      },
                      title: Text(_tasks[index]['title']),
                    ),
                  );

                  // return ListTile(
                  //   title: Text(_tasks[index]['title']),
                  //   leading: Checkbox(
                  //     value: _tasks[index][
                  //         'completed'], // Access the 'checked' property of the map
                  //     onChanged: (value) {
                  //       setState(() {
                  //         _tasks[index]['completed'] =
                  //             value; // Update the 'checked' property in the map
                  //       });
                  //     },
                  //   ),
                  // );
                }))
      ]),
      floatingActionButton: FloatingActionButton(
          onPressed: () {
            showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: const Text("Adicionar Tarefa"),
                    content: TextFormField(
                      controller: _taskController,
                      decoration: const InputDecoration(
                        label: Text('Digite aqui!'),
                      ),
                    ),
                    actions: [
                      ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: const Text('Cancelar')),
                      ElevatedButton(
                          onPressed: () {
                            _saveTask();
                            Navigator.pop(context);
                          },
                          child: const Text('Criar')),
                    ],
                  );
                });
          },
          backgroundColor: Colors.purple[400],
          child: const Icon(
            Icons.add,
            color: Colors.white,
          )),
    );
  }
}
