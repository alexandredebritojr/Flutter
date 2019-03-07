import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:flutter/material.dart';
import 'package:teste_list_form/service/firebase_firestore_service.dart';

import 'package:teste_list_form/model/contato.dart';
import 'package:teste_list_form/ui/contato_screen.dart';

class ListViewContato extends StatefulWidget {
  @override
  _ListViewContatoState createState() => new _ListViewContatoState();
}

class _ListViewContatoState extends State<ListViewContato> {
  List<Contato> items;
  FirebaseFirestoreService db = new FirebaseFirestoreService();

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

      setState(() {
        this.items = contatos;
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
        body: Center(
          child: ListView.builder(
              itemCount: items.length,
              padding: const EdgeInsets.all(16.0),
              itemBuilder: (context, position) {
                return Column(
                  children: <Widget>[
                    ListTile(
                      title: Text(
                        '${items[position].nome}',
                        style: TextStyle(
                          fontSize: 22.0,
                          color: Colors.black
                        ),
                      ),
                      subtitle: Text(
                        '${items[position].telefone}',
                        style: new TextStyle(
                          fontSize: 18.0,
                          fontStyle: FontStyle.italic,
                          color: Colors.grey
                        ),
                      ),
                      trailing: new IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () => _deleteContato(
                              context, items[position], position)),
                      leading: Column(
                        children: <Widget>[
                          CircleAvatar(
                            backgroundColor: Colors.blueAccent,
                            radius: 25.0,
                            child: new Container(
                                width: 50.0,
                                height: 190.0,
                                decoration: new BoxDecoration(
                                    shape: BoxShape.circle,
                                    image: new DecorationImage(
                                      fit: BoxFit.fill,
                                      image: new AssetImage(
                                          'assets/icone-contato.png'),
                                    ))),
                          ),
                        ],
                      ),
                      onTap: () => _navigateToContato(context, items[position]),
                    ),
                    Divider(height: 5.0),
                  ],
                );
              }),
        ),
        floatingActionButton: FloatingActionButton(
          child: Icon(Icons.add),
          onPressed: () => _createNewContato(context),
        ),
      ),
    );
  }

  void _deleteContato(
      BuildContext context, Contato contato, int position) async {
    db.deleteContato(contato.id).then((contatos) {
      setState(() {
        items.removeAt(position);
      });
    });
  }

  void _navigateToContato(BuildContext context, Contato contato) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ContatoScreen(contato)),
    );
  }

  void _createNewContato(BuildContext context) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => ContatoScreen(Contato(null, '', '', '', ''))),
    );
  }
}
