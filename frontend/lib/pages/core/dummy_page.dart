import 'package:flutter/material.dart';

class DummyPage extends StatefulWidget {
  final String text;

  const DummyPage({super.key, required this.text});

  @override
  State<StatefulWidget> createState() => _DummyPageState();
}

class _DummyPageState extends State<DummyPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Card(child: ListTile(title: Text(widget.text), subtitle: const Text('This a a dummy page'))),
      ),
    );
  }
}
