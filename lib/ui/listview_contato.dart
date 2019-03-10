import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:flutter/material.dart';
import 'package:app_contatos/service/firebase_firestore_service.dart';

import 'package:app_contatos/model/contato.dart';
import 'package:app_contatos/ui/contato_screen.dart';

class ListViewContato extends StatefulWidget {
  @override
  _ListViewContatoState createState() => new _ListViewContatoState();
}

class _ListViewContatoState extends State<ListViewContato> {
  List<Contato> items;
  List<Contato> _searchResult = [];
  FirebaseFirestoreService db = new FirebaseFirestoreService();
  TextEditingController controller = new TextEditingController();
  StreamSubscription<QuerySnapshot> contatoSub;

  @override
  void initState() {
    super.initState();

    items = new List();

    contatoSub?.cancel();
    contatoSub = db.getContatoList().listen((QuerySnapshot snapshot) {
      final List<Contato> contatos = snapshot.documents
          .map((documentSnapshot) => Contato.fromMap(documentSnapshot.data))
          .toList();

      //Rotina onde ordena de forma alfabética a lista de contatos
      contatos.sort((a, b) {
        return a.nome.toLowerCase().compareTo(b.nome.toLowerCase());
      });

      setState(() {
        this.items = contatos;
        controller.text = '';
        this._searchResult.clear();
      });
    });
  }

  @override
  void dispose() {
    contatoSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Contatos',
      home: Scaffold(
        appBar: AppBar(
          title: Text('Contatos'),
          centerTitle: true,
          backgroundColor: Colors.blue,
        ),
        body: new Column(
          children: <Widget>[
            new Container(
              child: new Padding(
                padding: const EdgeInsets.all(8.0),
                child: new Card(
                  child: new ListTile(
                    leading: new Icon(Icons.search),
                    title: new TextField(
                      controller: controller,
                      decoration: new InputDecoration(
                          hintText: 'Pesquisar', border: InputBorder.none),
                      onChanged: onSearchTextChanged,
                    ),
                    trailing: new IconButton(
                      icon: new Icon(Icons.cancel),
                      onPressed: () {
                        controller.clear();
                        onSearchTextChanged('');
                      },
                    ),
                  ),
                ),
              ),
            ),
            new Expanded(
              child: _searchResult.length != 0 || controller.text.isNotEmpty
                  ? ListView.builder(
                      itemCount: _searchResult.length,
                      padding: const EdgeInsets.all(16.0),
                      itemBuilder: (context, position) {
                        return Column(
                          children: <Widget>[
                            Divider(height: 5.0),
                            ListTile(
                              title: Text(
                                '${_searchResult[position].nome}',
                                style: TextStyle(
                                    fontSize: 22.0, color: Colors.black),
                              ),
                              subtitle: Text(
                                '${_searchResult[position].telefone}',
                                style: new TextStyle(
                                    fontSize: 18.0,
                                    fontStyle: FontStyle.italic,
                                    color: Colors.grey),
                              ),
                              trailing: new IconButton(
                                  icon: const Icon(Icons.delete),
                                  onPressed: () => _showDialog(context,
                                      _searchResult[position], position)),
                              leading: Column(
                                children: <Widget>[
                                  CircleAvatar(
                                      backgroundColor: Colors.blueAccent,
                                      radius: 25.0,
                                      child: new Text(
                                        '${_searchResult[position].primeiraLetra}',
                                        style: new TextStyle(
                                          fontSize: 30.0,
                                          color: Colors.white,
                                        ),
                                      )),
                                ],
                              ),
                              onTap: () => _navigateToContato(
                                  context, _searchResult[position]),
                            ),
                          ],
                        );
                      })
                  : new ListView.builder(
                      itemCount: items.length,
                      padding: const EdgeInsets.all(16.0),
                      itemBuilder: (context, position) {
                        return Column(
                          children: <Widget>[
                            Divider(height: 5.0),
                            ListTile(
                              title: Text(
                                '${items[position].nome}',
                                style: TextStyle(
                                    fontSize: 22.0, color: Colors.black),
                              ),
                              subtitle: Text(
                                '${items[position].telefone}',
                                style: new TextStyle(
                                    fontSize: 18.0,
                                    fontStyle: FontStyle.italic,
                                    color: Colors.grey),
                              ),
                              trailing: new IconButton(
                                  icon: const Icon(Icons.delete),
                                  onPressed: () => _showDialog(
                                      context, items[position], position)),
                              leading: Column(
                                children: <Widget>[
                                  CircleAvatar(
                                      backgroundColor: Colors.blueAccent,
                                      radius: 25.0,
                                      child: new Text(
                                        '${items[position].primeiraLetra}',
                                        style: new TextStyle(
                                          fontSize: 30.0,
                                          color: Colors.white,
                                        ),
                                      )),
                                ],
                              ),
                              onTap: () =>
                                  _navigateToContato(context, items[position]),
                            ),
                          ],
                        );
                      }),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          child: Icon(Icons.add),
          onPressed: () => _createNewContato(context),
        ),
      ),
    );
  }

//Evento onde filtra contatos
  onSearchTextChanged(String text) async {
    _searchResult.clear();
    if (text.isEmpty) {
      setState(() {});
      return;
    }

    this.items.forEach((userDetail) {
      if (userDetail.nome.toUpperCase().contains(text.toUpperCase()))
        _searchResult.add(userDetail);
    });

    setState(() {});
  }

//Evento onde deleta contato selecionado
  void _deleteContato(
      BuildContext context, Contato contato, int position) async {
    db.deleteContato(contato.id).then((contatos) {
      setState(() {
        items.removeAt(position);
      });
    });
  }

//Evento onde confirma com o usuário a exclusão do contato selecionado
  void _showDialog(BuildContext context, Contato item, int position) {    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: new Text(
            "Um Contato será excluido.",
          ),
          actions: <Widget>[
            new FlatButton(
              child: new Text("CANCELAR"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            new FlatButton(
              child: new Text("EXCLUIR"),
              onPressed: () {
                _deleteContato(context, item, position);
                Navigator.of(context).pop();
              },
            )
          ],
        );
      },
    );
  }

//Evento onde navega para a pagina de cadastro de contato
  void _navigateToContato(BuildContext context, Contato contato) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ContatoScreen(contato)),
    );
  }

//Evento onde navega para a pagina de cadastro de contato
  void _createNewContato(BuildContext context) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => ContatoScreen(Contato(null, '', '', '', ''))),
    );
  }
}
