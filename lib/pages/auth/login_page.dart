import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:financrr_frontend/layout/templates/auth_page_template.dart';
import 'package:financrr_frontend/pages/core/dashboard_page.dart';
import 'package:financrr_frontend/util/extensions.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:restrr/restrr.dart';

import '../../layout/adaptive_scaffold.dart';
import '../../router.dart';

class LoginPage extends StatefulWidget {
  final Uri hostUri;

  const LoginPage({super.key, required this.hostUri});

  @override
  State<StatefulWidget> createState() => LoginPageState();
}

class LoginPageState extends State<LoginPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    return AdaptiveScaffold(
      resizeToAvoidBottomInset: false,
      verticalBuilder: (_, __, size) => SafeArea(child: _buildVerticalLayout(size)),
    );
  }

  Widget _buildVerticalLayout(Size size) {
    return AuthPageTemplate(
        showBackButton: true,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 5),
              child: Text(widget.hostUri.host),
            ),
            Form(
                autovalidateMode: AutovalidateMode.onUserInteraction,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      child: TextFormField(
                        controller: _usernameController,
                        decoration: const InputDecoration(labelText: 'Username'),
                        autofillHints: const [AutofillHints.username],
                        validator: (value) => value!.isEmpty ? 'Username may not be empty' : null,
                      ),
                    ),
                    TextFormField(
                      controller: _passwordController,
                      decoration: InputDecoration(
                          labelText: 'common.password'.tr(),
                          suffixIcon: Padding(
                            padding: const EdgeInsets.only(right: 10),
                            child: IconButton(
                                icon: Icon(_obscureText ? Icons.visibility : Icons.visibility_off),
                                onPressed: () => setState(() => _obscureText = !_obscureText)),
                          )),
                      obscureText: _obscureText,
                      autofillHints: const [AutofillHints.password, AutofillHints.newPassword],
                      validator: (value) => value!.isEmpty ? 'Password may not be empty' : null,
                    ),
                  ],
                )),
            Padding(
                padding: const EdgeInsets.only(top: 20),
                child: SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _handleLogin,
                    child: const Text('common.sign_in').tr(),
                  ),
                )),
          ],
        ));
  }

  Future<void> _handleLogin() async {
    final String username = _usernameController.text;
    final String password = _passwordController.text;
    if (username.isEmpty || password.isEmpty) {
      context.showSnackBar('Username and password may not be empty');
      return;
    }
    final RestResponse<Restrr> response =
        await (RestrrBuilder.login(uri: widget.hostUri, username: username, password: password)
              ..options = const RestrrOptions(isWeb: kIsWeb))
            .create();
    if (!mounted) return;
    if (response.hasData) {
      context.authNotifier.setApi(response.data!);
      context.pushPath(DashboardPage.pagePath.build());
    } else {
      context.showSnackBar(response.error!.name);
    }
  }
}
