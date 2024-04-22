import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:financrr_frontend/layout/templates/auth_page_template.dart';
import 'package:financrr_frontend/pages/authentication/state/authentication_provider.dart';
import 'package:financrr_frontend/pages/authentication/state/authentication_state.dart';
import 'package:financrr_frontend/pages/core/dashboard_page.dart';
import 'package:financrr_frontend/routing/router_extensions.dart';
import 'package:financrr_frontend/util/extensions.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../layout/adaptive_scaffold.dart';
import '../../routing/page_path.dart';

class LoginPage extends StatefulHookConsumerWidget {
  static const PagePathBuilder pagePath = PagePathBuilder('/login');

  final Uri hostUri;

  const LoginPage({super.key, required this.hostUri});

  @override
  ConsumerState<LoginPage> createState() => LoginPageState();
}

class LoginPageState extends ConsumerState<LoginPage> {
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
                        decoration: InputDecoration(labelText: 'common_username'.tr()),
                        autofillHints: const [AutofillHints.username],
                        validator: (value) => value!.isEmpty ? 'common_username_required'.tr() : null,
                      ),
                    ),
                    TextFormField(
                      controller: _passwordController,
                      decoration: InputDecoration(
                          labelText: 'common_password'.tr(),
                          suffixIcon: Padding(
                            padding: const EdgeInsets.only(right: 10),
                            child: IconButton(
                                icon: Icon(_obscureText ? Icons.visibility : Icons.visibility_off),
                                onPressed: () => setState(() => _obscureText = !_obscureText)),
                          )),
                      obscureText: _obscureText,
                      autofillHints: const [AutofillHints.password, AutofillHints.newPassword],
                      validator: (value) => value!.isEmpty ? 'common_password_required'.tr() : null,
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
                    child: const Text('common_login').tr(),
                  ),
                )),
          ],
        ));
  }

  Future<void> _handleLogin() async {
    final String username = _usernameController.text;
    if (username.isEmpty) {
      context.showSnackBar('common_username_required'.tr());
      return;
    }
    final String password = _passwordController.text;
    if (username.isEmpty) {
      context.showSnackBar('common_password_required'.tr());
      return;
    }
    final AuthenticationState state = await ref.read(authProvider.notifier).login(username, password, widget.hostUri);
    if (!mounted) return;
    if (state.status == AuthenticationStatus.authenticated) {
      context.replacePath(DashboardPage.pagePath.build());
    } else {
      context.showSnackBar('common_login_failed'.tr());
    }
  }
}
