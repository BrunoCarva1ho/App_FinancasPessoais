// ignore_for_file: non_constant_identifier_names, use_build_context_synchronously, sized_box_for_whitespace

//import 'package:app_dev_agil/view/add_conta.dart';
import 'dart:ui';

import 'package:app_dev_agil/view/contas_debito.dart';
import 'package:flutter/material.dart';
//import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:flutter_holo_date_picker/flutter_holo_date_picker.dart';
import '../model/db_helper.dart';
import 'package:intl/intl.dart';
//import 'add_saldo_modal.dart';

class ContasCarteira extends StatefulWidget {
  const ContasCarteira({super.key});

  @override
  State<ContasCarteira> createState() => _ContasCarteiraState();
}

class _ContasCarteiraState extends State<ContasCarteira> {
  List<Map<String, dynamic>> _allData = [];
  bool atualizou = false;

  double conta = 0;
  void _refreshData() async {
    final data = await SQLHelper.getCarteira();
    conta = 0;
    setState(() {
      _allData = data;
    });

    for (int i = 0; i < _allData.length; i++) {
      if (_allData[i]['tipo'] == 'recebimento') {
        conta = conta + double.parse(_allData[i]['valor']);
      } else {
        conta = conta - double.parse(_allData[i]['valor']);
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _refreshData();
  }

  final TextEditingController _desc_conta = TextEditingController();
  final TextEditingController _valor_conta = TextEditingController();
  final TextEditingController _data_do_valor = TextEditingController();

  final TextEditingController _edit_desc_conta = TextEditingController();
  final TextEditingController _edit_valor_conta = TextEditingController();
  final TextEditingController _edit_data_do_valor = TextEditingController();

  void _adicionarPagamento() async {
    await SQLHelper.adicionarPagamento(_desc_conta.text, _valor_conta.text,
        DateTime.now().toString(), _data_do_valor.text, "Dinheiro");
    _desc_conta.text = '';
    _valor_conta.text = '';
    _refreshData();
  }

  void _adicionarRecebimento() async {
    await SQLHelper.adicionarRecebimento(_desc_conta.text, _valor_conta.text,
        DateTime.now().toString(), _data_do_valor.text, "Dinheiro");
    _desc_conta.text = '';
    _valor_conta.text = '';
    _refreshData();
  }

  void _editCarteira(int id) async {
    await SQLHelper.editData(id, _edit_desc_conta.text,
        _edit_data_do_valor.text, _edit_data_do_valor.text);
    _refreshData();
    _valor_conta.text = '';
    _desc_conta.text = '';
  }

  void _deleteData(int id) async {
    await SQLHelper.deleteData(id);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        backgroundColor: Color.fromARGB(255, 255, 47, 47),
        content: Text("Item deletado!")));
    _refreshData();
  }

  Future<String> _showDatePicker() async {
    String dataformatada = "";
    await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      locale: const Locale('pt', 'BR'), // Define o idioma do DatePicker
    ).then((value) {
      dataformatada = "${value!.day}/${value.month}/${value.year}";

      setState(() {
        _data_do_valor.text = dataformatada;
      });
    });
    return dataformatada.toString();
  }

  String _formatarDinheiro(double valor) {
    final formatoMoeda = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
    return formatoMoeda.format(valor);
  }

  void _mostrarDialogoDeConfirmacao(BuildContext context, int id) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color.fromARGB(255, 204, 241, 206),
          title: const Text('Confirmar Exclusão'),
          content: const Text('Tem certeza de que deseja excluir o item?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                _deleteData(id);
                Navigator.of(context).pop();
              },
              child: const Text('Confirmar'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        shadowColor: Colors.black,
        backgroundColor: Colors.green,
        toolbarHeight: 100,
        centerTitle: false,
        title: Text(
          "Carteira: ${_formatarDinheiro(conta)}",
          style: const TextStyle(
              fontSize: 29, color: Colors.white, fontFamily: 'NotoSans'),
        ),
        actions: <Widget>[
          IconButton(
            onPressed: () {
              Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (_) => const ContasDebito()));
            },
            icon: const Icon(
              Icons.credit_card_sharp,
              color: Colors.white,
            ),
            iconSize: 32,
          ),
        ],
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(left: 30, bottom: 20),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            FloatingActionButton(
              backgroundColor: Colors.red,
              onPressed: () {
                showModalBottomSheet(
                    isScrollControlled: true,
                    context: context,
                    builder: (_) {
                      return Container(
                          height: MediaQuery.of(context).size.height * 0.8,
                          child: Padding(
                              padding: const EdgeInsets.all(30),
                              child: Form(
                                child: Column(children: [
                                  const Text(
                                    "Adicionar Despesa para Carteira",
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
                                    validator: (text) {
                                      if (_valor_conta.text == "") {
                                        return "Informe uma descrição";
                                      } else {
                                        return null;
                                      }
                                    },
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
                                    validator: (text) {
                                      if (text == null) {
                                        return "Informe o Valor";
                                      } else {
                                        return null;
                                      }
                                    },
                                  ),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  ElevatedButton(
                                    child: const Text("Selecione a Data"),
                                    onPressed: () async {
                                      var datePicked =
                                          await DatePicker.showSimpleDatePicker(
                                        context,
                                        initialDate: DateTime.now(),
                                        firstDate: DateTime(2000),
                                        lastDate: DateTime(2090),
                                        titleText: "Selecione a data",
                                        dateFormat: "dd-MMMM-yyyy",
                                        locale: DateTimePickerLocale.pt_br,
                                        looping: true,
                                      );

                                      _data_do_valor.text =
                                          "${datePicked!.day}/${datePicked.month}/${datePicked.year}";
                                    },
                                  ),
                                  const SizedBox(
                                    height: 5,
                                  ),
                                  ElevatedButton(
                                      style: ButtonStyle(
                                          backgroundColor:
                                              MaterialStateProperty.all(
                                                  Colors.red)),
                                      onPressed: () {
                                        if (_valor_conta.text != "" &&
                                            _desc_conta.text != "") {
                                          _adicionarPagamento();
                                          Navigator.pop(context);
                                        }
                                      },
                                      child: const Text(
                                        "adicionar",
                                        style: TextStyle(color: Colors.white),
                                      ))
                                ]),
                              )));
                    });
              },
              child: const Icon(
                Icons.remove,
                color: Colors.white,
                size: 27,
              ),
            ),
            Expanded(child: Container()),
            FloatingActionButton(
              backgroundColor: Colors.green,
              onPressed: () {
                showModalBottomSheet(
                    isScrollControlled: true,
                    context: context,
                    builder: (_) {
                      return SizedBox(
                          height: MediaQuery.of(context).size.height * 0.8,
                          child: Padding(
                              padding: const EdgeInsets.all(30),
                              child: Form(
                                child: Column(children: [
                                  const Text(
                                    "Adicionar Saldo para Carteira",
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
                                    validator: (text) {
                                      if (_valor_conta.text == "") {
                                        return "Informe uma descrição";
                                      } else {
                                        return null;
                                      }
                                    },
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
                                    validator: (text) {
                                      if (_valor_conta.text == "") {
                                        return "Informe o Valor";
                                      } else {
                                        return null;
                                      }
                                    },
                                  ),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  ElevatedButton(
                                    child: const Text("Selecione a Data"),
                                    onPressed: () async {
                                      var datePicked =
                                          await DatePicker.showSimpleDatePicker(
                                        context,
                                        initialDate: DateTime.now(),
                                        firstDate: DateTime(2000),
                                        lastDate: DateTime.now(),
                                        titleText: "Selecione a data",
                                        dateFormat: "dd-MMMM-yyyy",
                                        locale: DateTimePickerLocale.pt_br,
                                        looping: true,
                                      );

                                      _data_do_valor.text =
                                          "${datePicked!.day}/${datePicked.month}/${datePicked.year}";
                                    },
                                  ),
                                  const SizedBox(
                                    height: 5,
                                  ),
                                  ElevatedButton(
                                      style: ButtonStyle(
                                          backgroundColor:
                                              MaterialStateProperty.all(
                                                  Colors.green)),
                                      onPressed: () {
                                        //_adicionarSaldo();
                                        if (_valor_conta.text != "" &&
                                            _desc_conta.text != "") {
                                          _adicionarRecebimento();
                                          Navigator.pop(context);
                                        }
                                      },
                                      child: const Text(
                                        "adicionar",
                                        style: TextStyle(color: Colors.white),
                                      ))
                                ]),
                              )));
                    });
              },
              child: const Icon(
                Icons.add,
                color: Colors.white,
                size: 27,
              ),
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
                textColor: (_allData[index]['tipo'] == 'pagamento')
                    ? const Color.fromARGB(255, 196, 54, 44)
                    : const Color.fromARGB(255, 67, 116, 69),
                title: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5),
                  child: Text(
                    _allData[index]['desc_conta'],
                    style: const TextStyle(fontSize: 17),
                  ),
                ),
                // ignore: prefer_interpolation_to_compose_strings
                subtitle: Text("R\$ " + _allData[index]['valor'],
                    style: const TextStyle(fontSize: 14)),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _allData[index]['data_do_valor'],
                    ),
                    IconButton(
                        onPressed: () {
                          _edit_valor_conta.text = _allData[index]['valor'];
                          _edit_desc_conta.text = _allData[index]['desc_conta'];
                          _edit_data_do_valor.text =
                              _allData[index]['data_do_valor'];
                          _editarCarteira(context, _allData[index]['id']);
                        },
                        icon: const Icon(Icons.edit)),
                    IconButton(
                        onPressed: () {
                          _mostrarDialogoDeConfirmacao(
                              context, _allData[index]['id']);
                        },
                        icon: const Icon(Icons.delete))
                  ],
                ),
              ))),
    );
  }

  void _editarCarteira(BuildContext context, int id) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // Retorna o widget do conteúdo da tela modal
        return AlertDialog(
          backgroundColor: const Color.fromARGB(255, 204, 241, 206),
          title: const Text('Editar Item da Carteira'),
          actions: [
            TextFormField(
              controller: _edit_desc_conta,
              decoration: const InputDecoration(
                  floatingLabelAlignment: FloatingLabelAlignment.center,
                  labelText: "Descrição",
                  border: OutlineInputBorder()),
              textAlign: TextAlign.center,
              validator: (text) {
                if (_valor_conta.text == "") {
                  return "Informe uma descrição";
                } else {
                  return null;
                }
              },
            ),
            const SizedBox(
              height: 15,
            ),
            TextFormField(
              controller: _edit_valor_conta,
              decoration: const InputDecoration(
                  labelText: "Digite o valor",
                  floatingLabelAlignment: FloatingLabelAlignment.center,
                  border: OutlineInputBorder()),
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              validator: (text) {
                if (_valor_conta.text == "") {
                  return "Informe o Valor";
                } else {
                  return null;
                }
              },
            ),
            ElevatedButton(
              child: Text(_edit_data_do_valor.text),
              onPressed: () async {
                var datePicked = await DatePicker.showSimpleDatePicker(
                  context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime(2000),
                  lastDate: DateTime.now(),
                  titleText: "Selecione a data",
                  dateFormat: "dd-MMMM-yyyy",
                  locale: DateTimePickerLocale.pt_br,
                  looping: true,
                );

                _data_do_valor.text =
                    "${datePicked!.day}/${datePicked.month}/${datePicked.year}";
              },
            ),
            const SizedBox(
              height: 5,
            ),
            TextButton(
              onPressed: () {
                _editCarteira(id);
                Navigator.of(context).pop();
              },
              child: const Text('Salvar'),
            ),
            TextButton(
              onPressed: () {
                _valor_conta.text = '';
                _desc_conta.text = '';
                Navigator.of(context).pop();
              },
              child: const Text('Fechar'),
            ),
          ],
        );
      },
    );
  }
}
