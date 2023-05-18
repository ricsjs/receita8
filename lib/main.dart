import 'dart:convert';
import 'package:flutter/material.dart';
//flutter pub add flutter_hooks
import 'package:flutter_hooks/flutter_hooks.dart';
//flutter pub add http
import 'package:http/http.dart' as http;

enum TableStatus { idle, loading, ready, error }

class DataService {
  final ValueNotifier<Map<String, dynamic>> tableStateNotifier =
      ValueNotifier({'status': TableStatus.idle, 'dataObjects': []});

  void carregar(index) {
    final List<void Function()> funcoes = [
      carregarCafe,
      carregarCervejas,
      carregarNacoes,
      carregarPessoas
    ];

    tableStateNotifier.value = {
      'status': TableStatus.loading,
      'dataObjects': []
    };

    funcoes[index]();
  }

  void carregarCafe() {
    var coffeeUri = Uri(
      scheme: 'https',
      host: 'random-data-api.com',
      path: 'api/coffee/random_coffee',
      queryParameters: {'size': '5'},
    );

    http.read(coffeeUri).then((jsonSting) {
      var coffeeJson = jsonDecode(jsonSting);

      tableStateNotifier.value = {
        'status': TableStatus.ready,
        'dataObjects': coffeeJson,
        'propertyNames': ["blend_name", "origin", "intensifier"],
        'columnNames': ["Nome", "Nacionalidade", "Intensidade"]
      };
    }).catchError((error) {
      tableStateNotifier.value = {'status': TableStatus.error};
    }, test: (error) => error is Exception);
  }

  void carregarCervejas() {
    var beersUri = Uri(
      scheme: 'https',
      host: 'random-data-api.com',
      path: 'api/beer/random_beer',
      queryParameters: {'size': '5'},
    );

    http.read(beersUri).then((jsonString) {
      var beersJson = jsonDecode(jsonString);

      tableStateNotifier.value = {
        'status': TableStatus.ready,
        'dataObjects': beersJson,
        'propertyNames': ["name", "style", "ibu"],
        'columnNames': ["Nome", "Estilo", "IBU"]
      };
    }).catchError((error) {
      tableStateNotifier.value = {'status': TableStatus.error};
    }, test: (error) => error is Exception);
  }

  void carregarNacoes() {
    var nationUri = Uri(
      scheme: 'https',
      host: 'random-data-api.com',
      path: 'api/nation/random_nation',
      queryParameters: {'size': '5'},
    );

    http.read(nationUri).then((jsonString) {
      var nationJson = jsonDecode(jsonString);

      tableStateNotifier.value = {
        'status': TableStatus.ready,
        'dataObjects': nationJson,
        'propertyNames': ["nationality", "language", "capital"],
        'columnNames': ["Nacionalidade", "Idioma", "Capital"]
      };
    }).catchError((error) {
      tableStateNotifier.value = {'status': TableStatus.error};
    }, test: (error) => error is Exception);
  }

  void carregarPessoas() {
    var peopleUri = Uri(
        scheme: 'https',
        host: 'random-data-api.com',
        path: 'api/users/random_user',
        queryParameters: {'size': '5'});

    http.read(peopleUri).then((jsonString) {
      var peopleJson = jsonDecode(jsonString);

      tableStateNotifier.value = {
        'status': TableStatus.ready,
        'dataObjects': peopleJson,
        'propertyNames': ["first_name", "last_name", "username"],
        'columnNames': ["Primeiro nome", "Último nome", "Usuário"]
      };
    }).catchError((error) {
      tableStateNotifier.value = {'status': TableStatus.error};
    }, test: (error) => error is Exception);
  }
}

final dataService = DataService();

void main() {
  MyApp app = MyApp();

  runApp(app);
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(primarySwatch: Colors.deepPurple),
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: const Text("Dicas"),
        ),
        body: Container(
          width: double.infinity,
          height: double.infinity,
          child: ValueListenableBuilder(
            valueListenable: dataService.tableStateNotifier,
            builder: (_, value, __) {
              switch (value['status']) {
                case TableStatus.idle:
                  return Center(
                    child: Text(
                      "Seja bem-vindo!\nPara ver as dicas, toque em algum botão!",
                      style: TextStyle(
                        fontSize: 20,
                        color: Colors.purple,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  );

                case TableStatus.loading:
                  return Center(
                    child: SizedBox(
                      width: 40,
                      height: 40,
                      child: CircularProgressIndicator(),
                    ),
                  );

                case TableStatus.ready:
                  return DataTableWidget(
                    jsonObjects: value['dataObjects'],
                    propertyNames: value['propertyNames'],
                    columnNames: value['columnNames'],
                  );

                case TableStatus.error:
                  return Center(
                    child: Text(
                      "Ops! Ocorreu um erro ao carregar os dados.",
                      style: TextStyle(
                        fontSize: 20,
                        color: Colors.red,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  );
              }

              return Text("...");
            },
          ),
        ),
        bottomNavigationBar:
            NewNavBar(itemSelectedCallback: dataService.carregar),
      ),
    );
  }
}

class NewNavBar extends HookWidget {
  var itemSelectedCallback; // esse atributo será uma função

  NewNavBar({this.itemSelectedCallback}) {
    itemSelectedCallback ??= (_) {};
  }

  @override
  Widget build(BuildContext context) {
    var state = useState(0);
    return BottomNavigationBar(
        onTap: (index) {
          state.value = index;
          print(state.value);
          itemSelectedCallback(index);
        },
        currentIndex: state.value,
        selectedItemColor:
            Colors.purple, // Definindo a cor dos ícones selecionados como roxo
        unselectedItemColor: Colors
            .purple, // Definindo a cor dos ícones não selecionados como roxo
        items: const [
          BottomNavigationBarItem(
              label: "Cafés", icon: Icon(Icons.coffee_outlined)),
          BottomNavigationBarItem(
              label: "Cervejas", icon: Icon(Icons.local_drink_outlined)),
          BottomNavigationBarItem(
              label: "Nações", icon: Icon(Icons.flag_outlined)),
          BottomNavigationBarItem(
              label: "Pessoas", icon: Icon(Icons.people_outlined))
        ]);
  }
}

class DataTableWidget extends StatelessWidget {
  final List jsonObjects;

  final List<String> columnNames;

  final List<String> propertyNames;

  DataTableWidget(
      {this.jsonObjects = const [],
      this.columnNames = const ["Coluna", "Coluna", "Coluna"],
      this.propertyNames = const ["name", "style", "ibu"]});

  @override
  @override
  Widget build(BuildContext context) {
    return DataTable(
      columns: columnNames
          .map(
            (name) => DataColumn(
              label: Expanded(
                child: Text(
                  name,
                  style: TextStyle(fontStyle: FontStyle.italic),
                ),
              ),
            ),
          )
          .toList(),
      rows: jsonObjects
          .map(
            (obj) => DataRow(
              cells: propertyNames
                  .map(
                    (propName) => DataCell(
                      Text(obj[propName] ??
                          'Conteúdo vazio'), // Verificar e fornecer valor padrão para propriedades nulas
                    ),
                  )
                  .toList(),
            ),
          )
          .toList(),
    );
  }
}
