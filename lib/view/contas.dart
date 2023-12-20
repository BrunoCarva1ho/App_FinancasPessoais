// ignore_for_file: non_constant_identifier_names, use_build_context_synchronously

import 'package:app_dev_agil/view/add_conta.dart';
import 'package:flutter/material.dart';

import '../model/db_helper.dart';

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

  //Pega todos os dados do banco
  void _refreshData() async {
    final data = await SQLHelper.getAllData();
    setState(() {
      _allData = data;
      _isLoading = false;
    });
    _total();
    atualizou = true;
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
    _refreshData();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 250, 250, 92),
        centerTitle: true,
        title: Text('Total: ${_total().toString()}'),
        actions: <Widget>[
          IconButton(
              onPressed: () {
                Navigator.push(
                    context, MaterialPageRoute(builder: (_) => AddConta()));
              },
              icon: const Icon(Icons.add))
        ],
      ),
      body: ListView.builder(
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
    );
  }
}
