// ignore_for_file: non_constant_identifier_names, use_build_context_synchronously

import 'package:app_dev_agil/view/add_conta.dart';
import 'package:flutter/material.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import '../model/db_helper.dart';
import 'add_saldo_modal.dart';

class Contas extends StatefulWidget {
  const Contas({super.key});

  @override
  State<Contas> createState() => _ContasState();
}

class _ContasState extends State<Contas> {
  List<Map<String, dynamic>> _allData = [];
  bool _isLoading = true;
  bool atualizou = false;

  double _total() {
    double valor_total = 0.0;
    for (var i in _allData) {
      valor_total = valor_total + double.parse(i['valor'].toString());
    }
    print(valor_total);
    return valor_total;
  }

  double _resultado = 0.0;
  //Pega todos os dados do banco
  void _refreshData() async {
    atualizou = false;
    final data = await SQLHelper.getAllData();
    setState(() {
      _allData = data;
      _isLoading = false;
    });
    if (atualizou == false) {
      _resultado = _total();
      atualizou = true;
    }
  }

  @override
  void initState() {
    super.initState();
    _refreshData();
  }

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
          backgroundColor: const Color.fromARGB(255, 250, 250, 92),
          toolbarHeight: 100,
          centerTitle: true,
          title: Text('Total: $_resultado'),
          actions: <Widget>[
            IconButton(
                onPressed: () {
                  Navigator.push(
                      context, MaterialPageRoute(builder: (_) => AddConta()));
                },
                icon: const Icon(Icons.add))
          ],
        ),
        floatingActionButton: Padding(
          padding: const EdgeInsets.only(left: 30, bottom: 20),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              FloatingActionButton(
                onPressed: () {},
                child: const Icon(Icons.remove),
              ),
              Expanded(child: Container()),
              FloatingActionButton(
                onPressed: () {
                  /*return showBarModalBottomSheet(
                      context: context,
                      builder: (context) => AdicionarSaldoModal());*/
                },
                child: const Icon(Icons.add),
              )
            ],
          ),
        ),
        body: Column(children: [
          ListView.builder(
              shrinkWrap: true,
              itemCount: _allData.length,
              itemBuilder: (context, index) => Card(
                  margin: const EdgeInsets.all(15),
                  child: ListTile(
                    title: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 5),
                      child: Text(
                        _allData[index]['valor'],
                        style: const TextStyle(
                          fontSize: 20,
                        ),
                      ),
                    ),
                    subtitle: Text(_allData[index]['desc_conta']),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                            onPressed: () {
                              _deleteData(_allData[index]['id']);
                            },
                            icon: const Icon(
                              Icons.check,
                              color: Colors.green,
                            ))
                      ],
                    ),
                  ))),
        ]));
  }
}
