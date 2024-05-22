import 'dart:async';

import 'package:financrr_frontend/modules/auth/pages/register_page.dart';
import 'package:financrr_frontend/shared/ui/auth_page_template.dart';
import 'package:financrr_frontend/modules/auth/providers/authentication.provider.dart';
import 'package:financrr_frontend/modules/auth/models/authentication.state.dart';
import 'package:financrr_frontend/modules/dashboard/views/dashboard_page.dart';
import 'package:financrr_frontend/routing/router_extensions.dart';
import 'package:financrr_frontend/utils/l10n_utils.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../shared/ui/adaptive_scaffold.dart';
import '../../../routing/page_path.dart';
import '../../../shared/ui/custom_replacements/custom_text_field.dart';

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
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return AdaptiveScaffold(
      resizeToAvoidBottomInset: false,
      verticalBuilder: (_, __, size) => _buildVerticalLayout(size),
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
                      child: FinancrrTextField(
                        controller: _usernameController,
                        label: L10nKey.commonUsername,
                        hint: L10nKey.commonUsername, // TODO: implement L10nKey ("John Doe")
                        autofillHints: const [AutofillHints.username, AutofillHints.newUsername],
                        validator: (value) => value!.isEmpty ? L10nKey.commonUsernameRequired.toString() : null,
                      ),
                    ),
                    FinancrrTextField(
                      controller: _passwordController,
                      label: L10nKey.commonPassword,
                      suffixIcon: Padding(
                        padding: const EdgeInsets.only(right: 10),
                        child: IconButton(
                            icon: Icon(_obscureText ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                            onPressed: () => setState(() => _obscureText = !_obscureText)),
                      ),
                      obscureText: _obscureText,
                      autofillHints: const [AutofillHints.password, AutofillHints.newPassword],
                      validator: (value) => value!.isEmpty ? L10nKey.commonPasswordRequired.toString() : null,
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
                    child: _isLoading ? const CircularProgressIndicator() : L10nKey.commonLogin.toText(),
                  ),
                )),
            Padding(
                padding: const EdgeInsets.only(top: 10),
                child: SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: TextButton(
                    onPressed: () {
                      if (_isLoading) {
                        return;
                      }
                      context.goPath(RegisterPage.pagePath.build(), extra: widget.hostUri);
                    },
                    child: L10nKey.authLoginNoAccount.toText(),
                  ),
                )),
          ],
        ));
  }

  Future<void> _handleLogin() async {
    if (_isLoading) {
      return;
    }
    // check if username is empty
    final String username = _usernameController.text;
    if (username.isEmpty) {
      L10nKey.commonUsernameRequired.showSnack(context);
      return;
    }
    // check if password is empty
    final String password = _passwordController.text;
    if (password.isEmpty) {
      L10nKey.commonPasswordRequired.showSnack(context);
      return;
    }
    setState(() => _isLoading = true);
    final AuthenticationState state = await ref.read(authProvider.notifier).login(username, password, widget.hostUri);
    setState(() => _isLoading = false);
    if (!mounted) return;
    if (state.status == AuthenticationStatus.authenticated) {
      context.goPath(DashboardPage.pagePath.build());
    } else {
      L10nKey.authLoginFailed.showSnack(context);
    }
  }
}
