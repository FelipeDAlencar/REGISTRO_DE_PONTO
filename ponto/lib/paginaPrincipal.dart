import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ponto/mPonto.dart';
import 'package:ponto/banco.dart';

class PaginaPrincipal extends StatefulWidget {
  @override
  _PaginaPrincipal createState() => new _PaginaPrincipal();
}

class _PaginaPrincipal extends State<PaginaPrincipal> {
  final formatDate = DateFormat('EEEE, d MMM, yyyy - hh:ss', 'pt_Br');
  PageController _pageController = new PageController();
  int _page = 0;
  String _title = "Resumo";
  Color _appBarColor = Colors.indigo;
  final dbHelper = DatabaseHelper.dbHelper;
  List<ListTile> listTiles;
  List<Ponto> pontos;
  ListView listViewListTiles;

  @override
  Widget build(BuildContext context) {
    print("buid");
    listTiles.clear();
    BottomNavigationBar navegacao = BottomNavigationBar(
      items: [
        BottomNavigationBarItem(
          icon: Icon(Icons.subject),
          title: Text("Resumo"),
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.done_all),
          title: Text("Meu Ponto"),
        ),
      ],
      onTap: navigateToPage,
      currentIndex: _page,
    );

    print("Aqui ${pontos.length}");
    if (pontos.length > 0) {
      print("Entrou aqui 1");
      print("lengt 3 ${pontos.length}");

      for (int i = 0; i < pontos.length; i++) {
        print("lengt 4  ${pontos.length}");
        Ponto ponto = pontos[i];
        String dataHora = formatDate.format(ponto.dataHora);
        ListTile listTile = ListTile(
          leading: Icon(Icons.done),
          title: Text("Data: $dataHora"),
          subtitle: Text("Código: ${ponto.cod}"),
          onTap: () {
            print(ponto.dataHora);
          },
        );
        listTiles.add(listTile);
      }
    } else {
      ListTile listTile = ListTile(
        leading: Icon(Icons.done),
        title: Text("Não há pontos registrados."),
        subtitle: Text("Tente registrar seu ponto."),
        onTap: () {},
      );
      listTiles.add(listTile);
    }

    listViewListTiles = ListView.builder(
      itemBuilder: (context, position) {
        return listTiles[position];
      },
      itemCount: listTiles.length,
      scrollDirection: Axis.vertical,
      shrinkWrap: true,
    );

    //SingleChildScrollView  listViewListTiles = SingleChildScrollView ();

    PageView paginas = PageView(
      children: <Widget>[
        Column(
          children: <Widget>[
            Card(
              elevation: 5,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  const ListTile(
                    leading: Icon(Icons.alarm),
                    title: Text(
                      "Banco de horas",
                      style: TextStyle(color: Colors.indigo),
                    ),
                    subtitle: Text("*Horas extras acumuladas."),
                  ),
                  Text(
                    "+ 20:00",
                    style: TextStyle(color: Colors.indigo, fontSize: 80),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                ],
              ),
            ),
            Card(
              elevation: 5,
              child: Column(
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  const ListTile(
                    leading: Icon(Icons.assignment),
                    title: Text(
                      "Pontos Recentes",
                      style: TextStyle(fontSize: 20.0, color: Colors.indigo),
                    ),
                  ),
                  Divider(
                    height: 30,
                  ),
                  listTiles[0],
                ],
              ),
            ),
          ],
        ),
        Column(
          children: <Widget>[
            Expanded(
              child: listViewListTiles,
            ),
            Wrap(
              spacing: 20,
              runSpacing: 10,
              children: <Widget>[
                RaisedButton(
                  onPressed: () {
                    DateTime dataAtual = DateTime.now();
                    String dataAtualString = formatDate.format(dataAtual);
                    _showDialogRegistrar(
                      context,
                      "CÓDIGO: 000\nDATA/HORA: $dataAtualString.",
                      "PONTO A SER REGISTRADO",
                    );
                  },
                  color: Colors.deepPurple,
                  textColor: Colors.white,
                  child: Text("REGISTRAR"),
                  elevation: 10,
                  hoverElevation: 10,
                  splashColor: Colors.deepOrange,
                ),
                RaisedButton(
                  onPressed: () {
                    _showDialogDeletarRegistro(context, "TEM CERTEZA QUE DESEJA DELETAR?", "DELETAR REGISTROS");
                  },
                  color: Colors.red,
                  textColor: Colors.white,
                  child: Text("DELETAR REGISTROS"),
                )
              ],
            )
          ],
        ),
      ],
      controller: _pageController,
      onPageChanged: onPageChanged,
    );

    Scaffold scaffold = Scaffold(
      appBar: new AppBar(
        title: new Text(_title),
        backgroundColor: _appBarColor,
      ),
      body: paginas,
      bottomNavigationBar: navegacao,
    );

    return scaffold;
  }

  void navigateToPage(int page) {
    _pageController.animateToPage(page,
        duration: Duration(milliseconds: 300), curve: Curves.ease);
  }

  void onPageChanged(int page) {
    String _temptitle = "";
    Color _tempColor;
    switch (page) {
      case 0:
        _temptitle = "Resumo";
        _tempColor = Colors.indigo;
        break;
      case 1:
        _temptitle = "Meu ponto";
        _tempColor = Colors.deepPurple;
        break;
    }
    setState(() {
      this._page = page;
      this._title = _temptitle;
      this._appBarColor = _tempColor;
    });
  }

  @override
  void initState() {
    super.initState();
    listTiles = List();
    pontos = List();
    _query();
  }

  @override
  void dispose() {
    super.dispose();
    _pageController.dispose();
  }

  void _showDialogRegistrar(contexto, data, titulo) {
    showDialog(
        context: contexto,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(titulo),
            content: Text(data),
            actions: <Widget>[
              FlatButton(
                child: Text("FINALIZAR"),
                onPressed: () {
                  Ponto ponto = Ponto();
                  ponto.dataHora = DateTime.now();
                  ponto.cod = 0;
                  ponto.diaDaSemana = ponto.dataHora.weekday;
                  print(
                      "${ponto.diaDaSemana} - ${ponto.dataHora} - ${ponto.cod}");
                  _insert(ponto);
                  pontos.clear();
                  _query();
                  Navigator.of(context).pop();
                },
              )
            ],
          );
        });
  }

  void _showDialogDeletarRegistro(contexto, data, titulo) {
    showDialog(
        context: contexto,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(titulo),
            content: Text(data),
            actions: <Widget>[
              FlatButton(
                child: Text("SIM"),
                onPressed: () {
                  setState(() {
                    pontos.clear();
                    listTiles.clear();
                    dbHelper.limparDados();
                  });
                  Navigator.of(context).pop();
                },
              ),
              FlatButton(
                child: Text("NÃO"),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              )
            ],
          );
        });
  }

  _insert(Ponto ponto) async {
    Map<String, dynamic> linha = {
      DatabaseHelper.colunaCod: 000,
      DatabaseHelper.colunaDataHora: ponto.dataHora.toIso8601String(),
      DatabaseHelper.colunaDiaDaSemana: ponto.diaDaSemana
    };
    final id = await dbHelper.insert(linha);
    print("id $id");
  }

  _query() async {
    final allRows = await dbHelper.queryAllRows();
    allRows.forEach((row) => print(row));
    for (int i = 0; i < allRows.length; i++) {
      Ponto ponto = Ponto();
      ponto.cod = allRows[i]["cod"];
      ponto.dataHora = DateTime.parse(allRows[i]["data_hora"]);
      ponto.diaDaSemana = allRows[i]["dia_da_semana"];
      pontos.add(ponto);
      print(pontos.length);
      //print(ponto.dataHora);
    }
  }
}
