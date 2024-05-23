import 'dart:async';

import 'package:financrr_frontend/modules/auth/views/register_page.dart';
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
import '../../../shared/ui/custom_replacements/custom_button.dart';
import '../../../shared/ui/custom_replacements/custom_text_button.dart';
import '../../../shared/ui/custom_replacements/custom_text_field.dart';
import '../../settings/providers/theme.provider.dart';

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
    var theme = ref.watch(themeProvider);

    buildVerticalLayout(Size size) {
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
                          prefixIcon: const Icon(Icons.person_outline),
                          autofillHints: const [AutofillHints.username, AutofillHints.newUsername],
                          validator: (value) => value!.isEmpty ? L10nKey.commonUsernameRequired.toString() : null,
                        ),
                      ),
                      FinancrrTextField(
                        controller: _passwordController,
                        label: L10nKey.commonPassword,
                        hint: L10nKey.commonPassword, // TODO: implement L10nKey ("Password")
                        prefixIcon: const Icon(Icons.lock_outline),
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
                  child: FinancrrButton(
                    onPressed: _handleLogin,
                    isLoading: _isLoading,
                    text: L10nKey.commonLogin.toString(),
                  )),
              Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: FinancrrTextButton(
                    onPressed: () {
                      if (_isLoading) {
                        return;
                      }
                      context.goPath(RegisterPage.pagePath.build(), extra: widget.hostUri);
                    },
                    label: L10nKey.authLoginNoAccount.toText(),
                  )),
            ],
          ));
    }

    return AdaptiveScaffold(
      resizeToAvoidBottomInset: false,
      verticalBuilder: (_, __, size) => SafeArea(child: buildVerticalLayout(size)),
    );
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
