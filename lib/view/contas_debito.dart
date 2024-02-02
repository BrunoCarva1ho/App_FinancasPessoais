// ignore_for_file: non_constant_identifier_names, use_build_context_synchronously, sized_box_for_whitespace

//import 'package:app_dev_agil/view/add_conta.dart';
import 'package:app_dev_agil/view/contas_carteira.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_holo_date_picker/flutter_holo_date_picker.dart';
import '../model/db_helper.dart';

class ContasDebito extends StatefulWidget {
  const ContasDebito({super.key});

  @override
  State<ContasDebito> createState() => _ContasDebitoState();
}

class _ContasDebitoState extends State<ContasDebito> {
  List<Map<String, dynamic>> _allData = [];
  bool atualizou = false;

  int tamanho = 0;
  double conta = 0;
  void _refreshData() async {
    final data = await SQLHelper.getDebito();
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
        DateTime.now().toString(), _data_do_valor.text, "Cartão de Débito");
    _desc_conta.text = '';
    _valor_conta.text = '';
    _refreshData();
  }

  void _adicionarRecebimento() async {
    await SQLHelper.adicionarRecebimento(_desc_conta.text, _valor_conta.text,
        DateTime.now().toString(), _data_do_valor.text, "Cartão de Débito");
    _desc_conta.text = '';
    _valor_conta.text = '';
    _refreshData();
  }

  void _deleteData(int id) async {
    await SQLHelper.deleteData(id);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        backgroundColor: Color.fromARGB(255, 255, 47, 47),
        content: Text("Item deletado!")));
    _refreshData();
  }

  void _editDebito(int id) async {
    await SQLHelper.editData(id, _edit_desc_conta.text, _edit_valor_conta.text,
        _edit_data_do_valor.text);
    _refreshData();
    _valor_conta.text = '';
    _desc_conta.text = '';
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
          backgroundColor: const Color.fromARGB(255, 198, 225, 247),
          title: const Text('Confirmar Exclusão'),
          content: const Text('Tem certeza de que deseja excluir?'),
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
        backgroundColor: Colors.blueAccent,
        toolbarHeight: 100,
        centerTitle: false,
        title: Text(
          "Débito: ${_formatarDinheiro(conta)}",
          style: const TextStyle(
              fontSize: 29, color: Colors.white, fontFamily: 'NotoSans'),
        ),
        actions: <Widget>[
          IconButton(
            onPressed: () {
              Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (_) => const ContasCarteira()));
            },
            icon: const Icon(Icons.wallet),
            iconSize: 32,
            color: Colors.white,
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
                                    "Adicionar Despesa para Débito",
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
                                    child: Text(_data_do_valor.text.isEmpty
                                        ? "Selecione a Data"
                                        : _data_do_valor.text),
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

                                      setState(() {
                                        _data_do_valor.text =
                                            "${datePicked!.day}/${datePicked.month}/${datePicked.year}";
                                      });
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
                size: 27,
                color: Colors.white,
              ),
            ),
            Expanded(child: Container()),
            FloatingActionButton(
              backgroundColor: Colors.blueAccent,
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
                                    "Adicionar Saldo para Débito",
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
                                                  Colors.blueAccent)),
                                      onPressed: () {
                                        //_adicionarSaldo();
                                        if (_valor_conta.text != "" &&
                                            _desc_conta.text != "") {
                                          if (_data_do_valor.text.isEmpty) {
                                            _data_do_valor.text =
                                                "${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}";
                                          }
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
                size: 27,
                color: Colors.white,
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
                subtitle: Text(
                    _formatarDinheiro(double.parse(_allData[index]['valor'])),
                    style: const TextStyle(fontSize: 14)),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(_allData[index]['data_do_valor']),
                    IconButton(
                        onPressed: () {
                          _edit_valor_conta.text = _allData[index]['valor'];
                          _edit_desc_conta.text = _allData[index]['desc_conta'];
                          _edit_data_do_valor.text =
                              _allData[index]['data_do_valor'];
                          _editarDebito(context, _allData[index]['id']);
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

  void _editarDebito(BuildContext context, int id) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // Retorna o widget do conteúdo da tela modal
        return AlertDialog(
          backgroundColor: const Color.fromARGB(255, 198, 225, 247),
          title: const Text('Editar Item do Débito'),
          actions: [
            TextFormField(
              controller: _edit_desc_conta,
              decoration: const InputDecoration(
                  labelText: "Descrição",
                  floatingLabelAlignment: FloatingLabelAlignment.center,
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

                setState(() {
                  _edit_data_do_valor.text =
                      "${datePicked!.day}/${datePicked.month}/${datePicked.year}";
                });
              },
            ),
            const SizedBox(
              height: 5,
            ),
            TextButton(
              onPressed: () {
                _editDebito(id);
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
