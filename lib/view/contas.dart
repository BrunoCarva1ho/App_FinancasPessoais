// ignore_for_file: non_constant_identifier_names, use_build_context_synchronously

//import 'package:app_dev_agil/view/add_conta.dart';
import 'package:app_dev_agil/model/db_user.dart';
import 'package:flutter/material.dart';
//import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import '../model/db_helper.dart';
//import 'add_saldo_modal.dart';

class Contas extends StatefulWidget {
  const Contas({super.key});

  @override
  State<Contas> createState() => _ContasState();
}

class _ContasState extends State<Contas> {
  List<Map<String, dynamic>> _allData = [];
  List<Map<String, dynamic>> _user = [];
  bool _isLoading = true;
  bool atualizou = false;

  var _resultado;
  //Pega todos os dados do banco
  void _refreshData() async {
    final data = await SQLHelper.getAllData();
    setState(() {
      _allData = data;
      _isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    _refreshData();
  }

  final TextEditingController _desc_conta = TextEditingController();
  final TextEditingController _valor_conta = TextEditingController();
  //final TextEditingController _saldo = TextEditingController();

  void _adicionarPagamento() async {
    await SQLHelper.adicionarPagamento(
        _desc_conta.text, _valor_conta.text, DateTime.now().toString());
    _refreshData();
  }

  void _adicionarRecebimento() async {}

  // void _adicionarSaldo() async {
  //   print('tam ' + _allData.length.toString());

  //   if (_allData.isEmpty) {
  //     await SQLHelper.criarSaldo(_valor_conta.text);
  //     await SQLHelper.adicionarSaldo(
  //         _desc_conta.text, _valor_conta.text, _valor_conta.text);
  //     _refreshData();
  //     print("criou o db");
  //     return;
  //   } else {
  //     double saldoAtual = 0.0;
  //     saldoAtual = double.parse(_allData[0]['saldo'].toString()) +
  //         double.parse(_valor_conta.text);
  //     await SQLHelper.adicionarSaldo(
  //         _desc_conta.text, _valor_conta.text, saldoAtual.toString());
  //     _refreshData();
  //     return;
  //   }
  // }

  void _deleteData(int id) async {
    await SQLHelper.deleteData(id);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        backgroundColor: Colors.green, content: Text("Conta paga! (imagino)")));
    _refreshData();
  }

  @override
  Widget build(BuildContext context) {
    //_refreshData();

    return Scaffold(
      appBar: AppBar(
          shadowColor: Colors.black,
          backgroundColor: const Color.fromARGB(255, 250, 250, 92),
          toolbarHeight: 100,
          centerTitle: true,
          title: Text(
            "Saldo " + _resultado.toString(),
            style: const TextStyle(fontSize: 27),
          )),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(left: 30, bottom: 20),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            FloatingActionButton(
              onPressed: () {
                showModalBottomSheet(
                    isScrollControlled: true,
                    context: context,
                    builder: (_) {
                      return Container(
                          height: MediaQuery.of(context).size.height * 0.8,
                          child: Padding(
                              padding: const EdgeInsets.all(20),
                              child: Form(
                                child: Column(children: [
                                  const Text(
                                    "Remover Saldo",
                                    style: TextStyle(
                                      fontSize: 22,
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 15,
                                  ),
                                  TextFormField(
                                    controller: _desc_conta,
                                    decoration: const InputDecoration(
                                        labelText: "Descrição",
                                        border: OutlineInputBorder()),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(
                                    height: 15,
                                  ),
                                  TextFormField(
                                    controller: _valor_conta,
                                    decoration: const InputDecoration(
                                        labelText: "Digite o valor",
                                        floatingLabelAlignment:
                                            FloatingLabelAlignment.center,
                                        border: OutlineInputBorder()),
                                    keyboardType: TextInputType.number,
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(
                                    height: 15,
                                  ),
                                  ElevatedButton(
                                      style: ButtonStyle(
                                          backgroundColor:
                                              MaterialStateProperty.all(
                                                  Colors.white)),
                                      onPressed: () {
                                        _adicionarPagamento();
                                        Navigator.pop(context);
                                      },
                                      child: const Text(
                                        "remover",
                                      ))
                                ]),
                              )));
                    });
              },
              child: const Icon(Icons.remove),
            ),
            Expanded(child: Container()),
            FloatingActionButton(
              onPressed: () {
                showModalBottomSheet(
                    isScrollControlled: true,
                    context: context,
                    builder: (_) {
                      return Container(
                          height: MediaQuery.of(context).size.height * 0.8,
                          child: Padding(
                              padding: const EdgeInsets.all(20),
                              child: Form(
                                child: Column(children: [
                                  const Text(
                                    "Adicionar Saldo",
                                    style: TextStyle(
                                      fontSize: 22,
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 15,
                                  ),
                                  TextFormField(
                                    controller: _desc_conta,
                                    decoration: const InputDecoration(
                                        labelText: "Descrição",
                                        border: OutlineInputBorder()),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(
                                    height: 15,
                                  ),
                                  TextFormField(
                                    controller: _valor_conta,
                                    decoration: const InputDecoration(
                                        labelText: "Digite o valor",
                                        floatingLabelAlignment:
                                            FloatingLabelAlignment.center,
                                        border: OutlineInputBorder()),
                                    keyboardType: TextInputType.number,
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(
                                    height: 15,
                                  ),
                                  ElevatedButton(
                                      style: ButtonStyle(
                                          backgroundColor:
                                              MaterialStateProperty.all(
                                                  Colors.white)),
                                      onPressed: () {
                                        //_adicionarSaldo();
                                        _adicionarPagamento();
                                        Navigator.pop(context);
                                      },
                                      child: const Text(
                                        "adicionar",
                                      ))
                                ]),
                              )));
                    });
              },
              child: const Icon(Icons.add),
            )
          ],
        ),
      ),
      body: ListView.builder(
          padding: const EdgeInsets.only(bottom: 100),
          shrinkWrap: true,
          itemCount: _allData.length,
          itemBuilder: (context, index) => Card(
              margin: const EdgeInsets.all(15),
              child: ListTile(
                title: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5),
                  child: Text(
                    _allData[index]['desc_conta'],
                    style: const TextStyle(
                      fontSize: 20,
                    ),
                  ),
                ),
                subtitle: Text(_allData[index]['valor']),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(_allData[index]['createdAt']),
                  ],
                ),
              ))),
    );
  }
}
