import 'package:flutter/material.dart';
import 'package:teste_dev/Components/button.dart';
import 'package:teste_dev/Components/colors.dart';
import 'package:teste_dev/Components/input.dart';
import 'package:teste_dev/Json/account_json.dart';
import 'package:teste_dev/SQLite/database.dart';
import 'package:teste_dev/Error_handling/tratamento_erro.dart';

class Accounts extends StatefulWidget {
  const Accounts({super.key});

  @override
  State<Accounts> createState() => _AccountsState();
}

class _AccountsState extends State<Accounts> {
  late DataBase handler;
  late Future<List<AccountsJson>> accounts;
  final db = DataBase();

  @override
  void initState() {
    super.initState();
    handler = db;
    accounts = handler.getAccounts();
    handler.init().whenComplete(() {
      accounts = getAllRecords();
    });
  }

  Future<List<AccountsJson>> getAllRecords() async {
    return await handler.getAccounts();
  }

  Future<void> _onRefresh() async {
    setState(() {
      accounts = getAllRecords();
    });
  }

  Future<List<AccountsJson>> filter() async {
    return await handler.filter(searchController.text);
  }

  final nome = TextEditingController();
  final telefone = TextEditingController();
  final searchController = TextEditingController();
  bool isSearchOn = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          addDialog();
          nome.clear();
          telefone.clear();
        },
        child: const Icon(Icons.add),
      ),
      appBar: AppBar(
        toolbarHeight: 65,
        title: isSearchOn
            ? Container(
                margin:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                padding: const EdgeInsets.symmetric(horizontal: 10),
                width: MediaQuery.of(context).size.width * .4,
                height: 45,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(.5),
                      blurRadius: 1,
                      spreadRadius: 0,
                    ),
                  ],
                ),
                child: TextFormField(
                  onChanged: (value) {
                    setState(() {
                      accounts = filter();
                    });
                  },
                  controller: searchController,
                  decoration: InputDecoration(
                    suffixIcon: searchController.text.isNotEmpty
                        ? IconButton(
                            onPressed: () {
                              setState(() {
                                searchController.clear();
                                _onRefresh();
                              });
                            },
                            icon: const Icon(Icons.clear, size: 17),
                          )
                        : const SizedBox(),
                    border: InputBorder.none,
                    hintText: "Procurar contato",
                    icon: const Icon(Icons.search),
                  ),
                ),
              )
            : const Text("Lista telefônica"),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            child: IconButton(
              onPressed: () {
                setState(() {
                  isSearchOn = !isSearchOn;
                });
              },
              icon: const Icon(Icons.search),
            ),
          ),
        ],
      ),
      body: FutureBuilder(
        future: accounts,
        builder:
            (BuildContext context, AsyncSnapshot<List<AccountsJson>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasData && snapshot.data!.isEmpty) {
            return const Center(child: Text("Contato não encontrado"));
          } else if (snapshot.hasError) {
            return Text(snapshot.error.toString());
          } else {
            final items = snapshot.data ?? <AccountsJson>[];
            return ListView.builder(
              itemCount: items.length,
              itemBuilder: (context, index) {
                return ListTile(
                  leading: CircleAvatar(
                    radius: 20,
                    child: Text(items[index].nome[0]),
                  ),
                  title: Text(items[index].nome),
                  subtitle: Text(items[index].telefone.toString()),
                  trailing: IconButton(
                    onPressed: () {
                      setState(() {
                        deleteAccount(items[index].id!);
                      });
                    },
                    icon: const Icon(Icons.delete,
                        color: Color.fromARGB(255, 179, 28, 28)),
                  ),
                  onTap: () {
                    setState(() {
                      // Para abrir a caixa de diálogo de atualização
                      updateDialog(items[index].id!);

                      // Para mostrar a conta selecionada no campo de texto para o método de atualização
                      nome.text = items[index].nome;
                      telefone.text = items[index].telefone.toString();
                    });
                  },
                  tileColor: index % 2 == 1
                      ? primaryColor.withOpacity(0.1)
                      : Colors.transparent,
                );
              },
            );
          }
        },
      ),
    );
  }

  // Adicionando
  void addDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Adicionar contato"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              InputCampo(hint: "Nome", icon: Icons.person, controller: nome),
              InputCampo(
                  hint: "Telefone", icon: Icons.phone, controller: telefone),
            ],
          ),
          actions: [
            Button(
              label: "Adicionar",
              press: () {
                Navigator.pop(context);
                addAccount(context);
              },
            ),
          ],
        );
      },
    );
  }

  // Editando
  void updateDialog(int id) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Editar contato"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              InputCampo(hint: "Nome", icon: Icons.person, controller: nome),
              InputCampo(
                  hint: "Telefone", icon: Icons.phone, controller: telefone),
            ],
          ),
          actions: [
            Button(
              label: "Editar",
              press: () {
                Navigator.pop(context);
                updateAccount(id);
              },
            ),
          ],
        );
      },
    );
  }

  // Métodos

  //Adicionando conta
  void addAccount(BuildContext context) async {
    final telefoneStr = telefone.text;
    bool telefoneValido =
        await validarTelefone(context, telefoneStr); //usa a função de validação
    if (!telefoneValido) {
      return;
    }

    final int telefoneInt = int.parse(telefone.text);
    bool isDuplicado = await handler.telefoneDuplicado(
        telefoneInt); // usa a função de verificação no banco de dados

    if (isDuplicado) {
      final falha =
          TelefoneDuplicadoFalha(); // Usa a classe de falha para telefone duplicado
      await mostrarAlertaErro(
          context, falha.mensagem); // Mostra a mensagem de erro
      return;
    }
    var res = await handler.insertAccount(
      context,
      AccountsJson(
        nome: nome.text,
        telefone: telefoneInt,
        createAt: DateTime.now(),
      ),
    );
    if (res > 0) {
      setState(() {
        _onRefresh();
      });
    }
  }

  //Editando conta
  void updateAccount(int id) async {
    final telefoneStr = telefone.text;
    bool telefoneValido = await validarTelefone(
        context, telefoneStr); // Usa a função de validação
    if (!telefoneValido) {
      return;
    }
    final telefoneAtual = await handler
        .getTelefoneById(id); // Obtem o telefone atual do banco de dados
    final int telefoneInt = int.parse(telefoneStr);

    bool telefoneMudou =
        telefoneAtual != telefoneInt; // Verifica se o telefone mudou
    if (telefoneMudou) {
      bool isDuplicado = await handler.telefoneDuplicado(
          telefoneInt); // Se o telefone mudou ele verifica se é duplicado

      if (isDuplicado) {
        final falha =
            TelefoneDuplicadoFalha(); // Usa a classe de falha para telefone duplicado
        await mostrarAlertaErro(
            context, falha.mensagem); // Mostra a mensagem de erro
        return;
      }
    }
    var res = await handler.updateAccount(nome.text, telefoneInt, id);
    if (res > 0) {
      setState(() {
        _onRefresh();
      });
    }
  }

  // Deletando conta
  void deleteAccount(int id) async {
    var res = await handler.deleteAccount(id);
    if (res > 0) {
      setState(() {
        _onRefresh();
      });
    }
  }

  //Caixa de dialogo
  Future<void> mostrarAlertaErro(BuildContext context, String mensagem) async {
    if (!context.mounted) return;

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Atenção'),
          content: Text(mensagem),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              style: TextButton.styleFrom(
                foregroundColor: Colors.white, // Cor do texto
                backgroundColor: const Color.fromARGB(255, 177, 157, 92),
              ),
              child: const Text('Confirmar'),
            ),
          ],
        );
      },
    );
  }

  //validando celular para somente aceite numeros inteiros
  Future<bool> validarTelefone(BuildContext context, String telefoneStr) async {
    final telefoneInt = int.tryParse(telefoneStr);

    if (telefoneInt == null || telefoneInt <= 0) {
      final falha =
          CaracterInvalidoFalha(); // Usa a classe de falha para telefone inválido
      await mostrarAlertaErro(
          context, falha.mensagem); // Mostra a mensagem de erro
      return false;
    }
    return true;
  }
}
