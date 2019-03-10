import 'package:flutter/material.dart';
import 'package:app_contatos/ui/listview_contato.dart';

void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Contatos App',
      home: ListViewContato(),
    );
  }
}
