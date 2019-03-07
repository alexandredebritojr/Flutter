import 'package:flutter/material.dart';
import 'package:teste_list_form/model/contato.dart';
import 'package:teste_list_form/service/firebase_firestore_service.dart';
import 'package:validate/validate.dart';
import 'package:auro_avatar/auro_avatar.dart';

class ContatoScreen extends StatefulWidget {
  final Contato contato;
  ContatoScreen(this.contato);

  @override
  State<StatefulWidget> createState() => new _ContatoScreenState();
}

class _ContatoScreenState extends State<ContatoScreen> {
  FirebaseFirestoreService db = new FirebaseFirestoreService();

  TextEditingController _nomeController;
  TextEditingController _enderecoController;
  TextEditingController _telefoneController;
  TextEditingController _emailController;
  bool _validateNome = false;
  bool _validateTelefone = false;
  bool _validateEmail = false;

  @override
  void initState() {
    super.initState();

    _nomeController = new TextEditingController(text: widget.contato.nome);
    _enderecoController =
        new TextEditingController(text: widget.contato.endereco);
    _telefoneController =
        new TextEditingController(text: widget.contato.telefone);
    _emailController = new TextEditingController(text: widget.contato.email);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Adicionar Contato')),
      body: new Container(
          padding: new EdgeInsets.all(20.0),
          child: new Form(
            child: new ListView(
              children: <Widget>[
//                 new InitialNameAvatar(
//     'John Doe',
//     circleAvatar: true,
//     borderColor: Colors.grey,
//     borderSize: 4.0,
//     backgroundColor: Colors.blue,
//     foregroundColor: Colors.white,
//     padding: 20.0,
//     textSize: 30.0,
// ),
                new Container(
                    width: 50.0,
                    height: 190.0,
                    decoration: new BoxDecoration(
                        shape: BoxShape.circle,
                        image: new DecorationImage(
                          fit: BoxFit.fill,
                          image: new AssetImage('assets/icone-contato.png'),
                        ))),
                TextField(
                    controller: _nomeController,
                    decoration: InputDecoration(
                        labelText: 'Nome',
                        errorText:
                            _validateNome ? 'O Nome é obrigatório.' : null),
                    keyboardType: TextInputType.text),
                Padding(padding: new EdgeInsets.all(5.0)),
                TextField(
                    controller: _emailController,
                    decoration: InputDecoration(
                        labelText: 'Email',
                        errorText:
                            _validateEmail ? 'O Email é inválido.' : null),
                    keyboardType: TextInputType.emailAddress),
                Padding(padding: new EdgeInsets.all(5.0)),
                TextField(
                    controller: _enderecoController,
                    decoration: InputDecoration(labelText: 'Endereco'),
                    keyboardType: TextInputType.text),
                Padding(padding: new EdgeInsets.all(5.0)),
                TextField(
                    controller: _telefoneController,
                    decoration: InputDecoration(
                        labelText: 'Telefone',
                        errorText: _validateTelefone
                            ? 'O Telefone é obrigatório.'
                            : null),
                    keyboardType: TextInputType.phone),
                Padding(padding: new EdgeInsets.all(5.0)),
                RaisedButton(
                  child: (widget.contato.id != null)
                      ? Text('Atualizar')
                      : Text('Adicionar'),
                  onPressed: () {
                    setState(() {
                      _nomeController.text.isEmpty
                          ? _validateNome = true
                          : _validateNome = false;
                      _telefoneController.text.isEmpty
                          ? _validateTelefone = true
                          : _validateTelefone = false;

                      if (_emailController.text.isNotEmpty) {
                        try {
                          Validate.isEmail(_emailController.text);
                          _validateEmail = false;
                        } catch (e) {
                          return _validateEmail = true;
                        }
                      } else if (_emailController.text.isEmpty) {
                        _validateEmail = false;
                      }
                    });
                    if (!_validateNome &&
                        !_validateTelefone &&
                        !_validateEmail) {
                      if (widget.contato.id != null) {
                        db
                            .updateContato(Contato(
                                widget.contato.id,
                                _nomeController.text,
                                _enderecoController.text,
                                _telefoneController.text,
                                _emailController.text))
                            .then((_) {
                          Navigator.pop(context);
                        });
                      } else {
                        db
                            .createContato(
                                _nomeController.text,
                                _enderecoController.text,
                                _telefoneController.text,
                                _emailController.text)
                            .then((_) {
                          Navigator.pop(context);
                        });
                      }
                    }
                  },
                ),
              ],
            ),
          )),
    );
  }
}
