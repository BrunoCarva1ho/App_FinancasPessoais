import 'package:app_dev_agil/view/contas.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: const Color.fromARGB(255, 250, 250, 92),
          title: const Text('Bem vindo(a)!'),
          centerTitle: true,
          actions: const <Widget>[
            /*
          IconButton(onPressed:(){
            Navigator.(context);
          }, icon: Icon(Icons.logout))
        */
          ],
        ),
        body: Center(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
              const Padding(
                padding: EdgeInsets.only(bottom: 0, top: 30),
              ),
              SizedBox(
                width: 200,
                height: 40,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 250, 250, 92),
                  ),
                  child: const Text('Visualizar contas'),
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const Contas(),
                        ));
                  },
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              SizedBox(
                width: 200,
                height: 40,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 250, 250, 92),
                  ),
                  child: const Text('Visualizar categorias'),
                  onPressed: () {},
                ),
              ),
            ])));
  }
}
