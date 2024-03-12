import 'package:flutter/material.dart';
import 'package:restrr/restrr.dart';

import '../../router.dart';

class DashboardPage extends StatefulWidget {
  static const PagePathBuilder pagePath = PagePathBuilder('/@me/dashboard');

  const DashboardPage({super.key});

  @override
  State<StatefulWidget> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  late final Restrr _api = context.api!;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text('Hello, ${_api.selfUser.username}!'),
      ),
    );
  }
}
