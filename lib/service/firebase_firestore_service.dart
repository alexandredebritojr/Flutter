import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:teste_list_form/model/contato.dart';
 
final CollectionReference contatoCollection = Firestore.instance.collection('contatos');
 
class FirebaseFirestoreService {
 
  static final FirebaseFirestoreService _instance = new FirebaseFirestoreService.internal();
 
  factory FirebaseFirestoreService() => _instance;
 
  FirebaseFirestoreService.internal();
 
  Future<Contato> createContato(String nome, String endereco, String telefone, String email)  async {
    final TransactionHandler createTransaction = (Transaction tx) async {
      final DocumentSnapshot ds = await tx.get(contatoCollection.document());
 
      final Contato contato = new Contato(ds.documentID, nome, endereco, telefone,email);
      final Map<String, dynamic> data = contato.toMap();
 
      await tx.set(ds.reference, data);
 
      return data;
    };
 
    return Firestore.instance.runTransaction(createTransaction).then((mapData) {
      return Contato.fromMap(mapData);
    }).catchError((error) {
      print('error: $error');
      return null;
    });
  }
 
  Stream<QuerySnapshot> getContatoList({int offset, int limit}) {
    Stream<QuerySnapshot> snapshots = contatoCollection.snapshots();
 
    if (offset != null) {
      snapshots = snapshots.skip(offset);
    }
 
    if (limit != null) {
      snapshots = snapshots.take(limit);
    }
 
    return snapshots;
  }
 
  Future<dynamic> updateContato(Contato contato) async {
    final TransactionHandler updateTransaction = (Transaction tx) async {
      final DocumentSnapshot ds = await tx.get(contatoCollection.document(contato.id));
 
      await tx.update(ds.reference, contato.toMap());
      return {'updated': true};
    };
 
    return Firestore.instance
        .runTransaction(updateTransaction)
        .then((result) => result['updated'])
        .catchError((error) {
      print('error: $error');
      return false;
    });
  }
 
  Future<dynamic> deleteContato(String id) async {
    final TransactionHandler deleteTransaction = (Transaction tx) async {
      final DocumentSnapshot ds = await tx.get(contatoCollection.document(id));
 
      await tx.delete(ds.reference);
      return {'deleted': true};
    };
 
    return Firestore.instance
        .runTransaction(deleteTransaction)
        .then((result) => result['deleted'])
        .catchError((error) {
      print('error: $error');
      return false;
    });
  }
}