import 'package:app_dev_agil/model/db_helper.dart';
import 'package:flutter/material.dart';

class AddConta extends StatefulWidget {
  const AddConta({super.key});

  @override
  State<AddConta> createState() => _AddConta();
}

class _AddConta extends State<AddConta> {
  List<Map<String, dynamic>> _allData = [];
  bool _isLoading = true;

  final TextEditingController _desc_conta = TextEditingController();
  final TextEditingController _valor = TextEditingController();

  void _refreshData() async {
    final data = await SQLHelper.getAllData();
    setState(() {
      _allData = data;
      _isLoading = false;
    });
  }

  Future<void> _addData() async {
    await SQLHelper.adicionarPagamento(
        _desc_conta.text, _valor.text, DateTime.now().toString(), 'a');
    _refreshData();

    // ignore: use_build_context_synchronously
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 250, 250, 92),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 250, 250, 92),
        title: const Text("Adicionar Conta"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
            child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CustomTextField(
              label: 'Descrição da Conta',
              controller: _desc_conta,
            ),
            const SizedBox(
              height: 30,
            ),
            CustomTextField(
              label: 'Valor',
              controller: _valor,
              keyboardType: TextInputType.number,
            ),
            const SizedBox(
              height: 30,
            ),
            Builder(builder: (context) {
              return SizedBox(
                  width: 200,
                  height: 50,
                  child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white),
                      onPressed: () {
                        if (Form.of(context).validate()) {
                          _addData();
                        }
                      },
                      child: const Text("Adicionar")));
            })
          ],
        )),
      ),
    );
  }
}

class CustomTextField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final TextInputType? keyboardType;

  const CustomTextField({
    Key? key,
    required this.label,
    required this.controller,
    this.keyboardType,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      validator: (text) {
        if ((text == null || text.isEmpty)) {
          return 'Preencha este campo!';
        } else {
          return null;
        }
      },
      decoration:
          InputDecoration(labelText: label, border: const OutlineInputBorder()),
      controller: controller,
      keyboardType: keyboardType,
    );
  }
}
