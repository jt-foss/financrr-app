import 'package:flutter/material.dart';

import '../../layout/adaptive_scaffold.dart';

class DummyPage extends StatefulWidget {
  final String text;

  const DummyPage({super.key, required this.text});

  @override
  State<StatefulWidget> createState() => _DummyPageState();
}

class _DummyPageState extends State<DummyPage> {
  @override
  Widget build(BuildContext context) {
    return AdaptiveScaffold(verticalBuilder: (_, __, size) => SafeArea(child: _buildVerticalLayout(size)));
  }

  Widget _buildVerticalLayout(Size size) {
    return Padding(
      padding: const EdgeInsets.only(top: 10, bottom: 20),
      child: Center(
        child: SizedBox(
          width: size.width / 1.1,
          child: ListView(
            children: [Card(child: ListTile(title: Text(widget.text)))],
          ),
        ),
      ),
    );
  }
}
