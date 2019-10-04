import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:todo/models/itens.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Todo APP',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  List<Item> itens = new List<Item>();
  HomePage() {
    // itens.add(Item(title: 'TESTE TITLE', done: true));
    // itens.add(Item(title: 'TESTE TITLE 2 ', done: true));
    // itens.add(Item(title: 'TESTE TITLE 2', done: false));
  }

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  var editcontrole = TextEditingController();
  void add() {
    if (editcontrole.text.isEmpty) {
      return;
    }
    setState(() {
      widget.itens.add(Item(title: editcontrole.text, done: false));
      editcontrole.text = "";
      save();
    });
  }

  void remove(int index) {
    setState(() {
      widget.itens.removeAt(index);
      save();
    });
  }

  _HomePageState() {
    load();
  }
  Future load() async {
    var preferences = await SharedPreferences.getInstance();
    var data = preferences.getString('data');
    if (data != null) {
      Iterable decod = jsonDecode(data);
      List<Item> result = decod.map((x) => Item.fromJson(x)).toList();
      setState(() {
        widget.itens = result;
      });
    }
  }

  save() async {
    var preferences = await SharedPreferences.getInstance();
    await preferences.setString('data', jsonEncode(widget.itens));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextFormField(
          keyboardType: TextInputType.text,
          style: TextStyle(color: Colors.white),
          decoration: InputDecoration(
              labelText: "Nova Tarefa",
              labelStyle: TextStyle(color: Colors.white)),
          controller: editcontrole,
        ),
        centerTitle: true,
      ),
      body: ListView.builder(
        itemCount: widget.itens.length,
        itemBuilder: (BuildContext context, int index) {
          final item = widget.itens[index];
          return Dismissible(
            child: CheckboxListTile(
              title: Text(item.title),
              value: item.done,
              onChanged: (value) {
                setState(() {
                  item.done = value;
                  save();
                });
              },
            ),
            key: Key(item.title),
            onDismissed: (direction) {
              remove(index);
            },
            background: Container(
              color: Colors.red[100],
            ),
            secondaryBackground: Container(
              color: Colors.red,
              child: Icon(Icons.add),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: add,
        child: Icon(Icons.add),
      ),
    );
  }
}
