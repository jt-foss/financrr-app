import 'package:flutter/material.dart';

import '../../router.dart';

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
        child: Text(widget.text),
      ),
    );
  }
}
