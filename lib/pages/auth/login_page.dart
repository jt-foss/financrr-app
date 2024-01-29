import 'package:financrr_frontend/util/text_utils.dart';
import 'package:flutter/cupertino.dart';

import '../../layout/adaptive_scaffold.dart';
import '../../router.dart';

class LoginPage extends StatefulWidget {
  static const PagePathBuilder pagePath = PagePathBuilder('/login');

  final String? redirectTo;

  const LoginPage({super.key, this.redirectTo});

  @override
  State<StatefulWidget> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  late final AppTextStyles textStyles = AppTextStyles.of(context);

  @override
  Widget build(BuildContext context) {
    return AdaptiveScaffold(
      resizeToAvoidBottomInset: false,
      verticalBuilder: (_, __, size) => SafeArea(child: _buildPageVertical(size)),
    );
  }

  Widget _buildPageVertical(Size size) {
    return SingleChildScrollView(
        child: Center(child: Column(children: [textStyles.bodyLarge.text('TODO: Implement Login Page')])));
  }
}
