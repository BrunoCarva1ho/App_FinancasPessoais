// ignore_for_file: non_constant_identifier_names, use_build_context_synchronously, sized_box_for_whitespace

//import 'package:app_dev_agil/view/add_conta.dart';
import 'package:app_dev_agil/view/contas_carteira.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
//import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import '../model/db_helper.dart';
//import 'add_saldo_modal.dart';

class ContasDebito extends StatefulWidget {
  const ContasDebito({super.key});

  @override
  State<ContasDebito> createState() => _ContasDebitoState();
}

class _ContasDebitoState extends State<ContasDebito> {
  List<Map<String, dynamic>> _allData = [];
  bool _isLoading = true;
  bool atualizou = false;

  String _resultado = "0";
  //Pega todos os dados do banco
  void _refreshData() async {
    final data = await SQLHelper.getDebito();
    final saldo = await SQLHelper.getSaldoDebito();

    setState(() {
      _allData = data;
      if (saldo.isNotEmpty) {
        _resultado = saldo[saldo.length - 1]['saldo'];
      }
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
  final TextEditingController _data_do_valor = TextEditingController();

  void _adicionarPagamento() async {
    var conta = _resultado.toString();

    final r = double.parse(conta) - double.parse(_valor_conta.text);
    await SQLHelper.adicionarPagamento(
        _desc_conta.text,
        _valor_conta.text,
        DateTime.now().toString(),
        r.toString(),
        _data_do_valor.text,
        "Cartão de Débito");
    _desc_conta.text = '';
    _valor_conta.text = '';
    _refreshData();
  }

  void _adicionarRecebimento() async {
    final saldo = double.parse(_resultado) + double.parse(_valor_conta.text);

    await SQLHelper.adicionarRecebimento(
        _desc_conta.text,
        _valor_conta.text,
        DateTime.now().toString(),
        saldo.toString(),
        _data_do_valor.text,
        "Cartão de Débito");
    _desc_conta.text = '';
    _valor_conta.text = '';
    _refreshData();
  }

  void _deleteData(int id) async {
    await SQLHelper.deleteData(id);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        backgroundColor: Colors.green, content: Text("Conta paga! (imagino)")));
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

  /*
  String _dropdownConfig = 'Não Realizado';
  var configs = ['Editar', 'Remover'];

  Widget buildDropdownButton(List<String> variaveis, String dropdownValue) {
    return DropdownButton<String>(
        value: dropdownValue,
        onChanged: (String? newValue) {
          setState(() {
            dropdownValue = newValue!;
          });
        },
        items: variaveis.map((String item) {
          return DropdownMenuItem(value: item, child: Text(item));
        }).toList(),
        borderRadius: BorderRadius.circular(10));
  }
  */
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        shadowColor: Colors.black,
        backgroundColor: Colors.blueAccent,
        toolbarHeight: 100,
        centerTitle: false,
        title: Text(
          "Saldo Débito: ${_formatarDinheiro(double.parse(_resultado))}",
          style: const TextStyle(fontSize: 25, color: Colors.white),
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
                                    height: 15,
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
                                    height: 15,
                                  ),
                                  /*MaterialButton(
                                      onPressed: () async {
                                        await showDatePicker(
                                          context: context,
                                          initialDate: DateTime.now(),
                                          firstDate: DateTime(1900),
                                          lastDate: DateTime.now(),
                                          locale: const Locale('pt',
                                              'BR'), // Define o idioma do DatePicker
                                        ).then((value) {
                                          final dataformatada =
                                              "${value!.day}/${value.month}/${value.year}";

                                          setState(() {
                                            _data_do_valor.text = dataformatada;
                                          });
                                        });
                                      },
                                      padding: const EdgeInsets.all(20),
                                      color: Colors.red,
                                      child: Text(
                                        _data_do_valor.text,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 15,
                                        ),
                                      )),*/
                                  ElevatedButton(
                                      style: ButtonStyle(
                                          backgroundColor:
                                              MaterialStateProperty.all(
                                                  Colors.blueAccent)),
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
                    style: const TextStyle(fontSize: 20),
                  ),
                ),
                subtitle: Text(
                    _formatarDinheiro(double.parse(_allData[index]['valor'])),
                    style: const TextStyle(fontSize: 14)),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                        onPressed: () {
                          _deleteData(_allData[index]['id']);
                        },
                        icon: const Icon(Icons.delete))
                  ],
                ),
              ))),
    );
  }
}
