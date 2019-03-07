class Contato {
  String _id;
  String _nome;
  String _telefone;
  String _endereco;
  String _email;

  Contato(this._id, this._nome, this._endereco, this._telefone, this._email);

  Contato.map(dynamic obj) {
    this._id = obj['id'];
    this._nome = obj['nome'];
    this._telefone = obj['telefone'];
    this._endereco = obj['endereco'];
    this._email = obj['email'];
  }

  String get id => _id;
  String get nome => _nome;  
  String get telefone => _telefone;   
  String get endereco => _endereco;   
  String get email   => _email;   

  Map<String, dynamic> toMap() {
    var map = new Map<String, dynamic>();
    if (id != null) {
      map['id'] = id;
    }
    map['nome'] = nome;
    map['telefone'] = telefone;
    map['endereco'] = endereco;
    map['email'] = email;

    return map;
  }

  Contato.fromMap(Map<String, dynamic> map) {
    this._id = map['id'];
    this._endereco = map['endereco'];
    this._nome = map['nome'];
    this._telefone = map['telefone'];
    this._email = map['email'];
  }
}
