import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:financrr_frontend/modules/auth/pages/login_page.dart';
import 'package:financrr_frontend/shared/ui/auth_page_template.dart';
import 'package:financrr_frontend/modules/auth/providers/authentication.provider.dart';
import 'package:financrr_frontend/modules/auth/models/authentication.state.dart';
import 'package:financrr_frontend/modules/dashboard/views/dashboard_page.dart';
import 'package:financrr_frontend/routing/router_extensions.dart';
import 'package:financrr_frontend/utils/extensions.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../shared/ui/adaptive_scaffold.dart';
import '../../../routing/page_path.dart';

class RegisterPage extends StatefulHookConsumerWidget {
  static const PagePathBuilder pagePath = PagePathBuilder('/register');

  final Uri hostUri;

  const RegisterPage({super.key, required this.hostUri});

  @override
  ConsumerState<RegisterPage> createState() => RegisterPageState();
}

class RegisterPageState extends ConsumerState<RegisterPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _passwordRepeatController = TextEditingController();

  bool _obscureText = true;
  bool _obscureRepeatText = true;

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
        registerWelcomeMessages: true,
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
                        autofillHints: const [AutofillHints.newUsername],
                        validator: (value) => value!.isEmpty ? 'common_username_required'.tr() : null,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 20),
                      child: TextFormField(
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
                        autofillHints: const [AutofillHints.newPassword],
                        validator: (value) => value!.isEmpty ? 'common_password_required'.tr() : null,
                      ),
                    ),
                    TextFormField(
                      controller: _passwordRepeatController,
                      decoration: InputDecoration(
                          labelText: 'common_repeat_password'.tr(),
                          suffixIcon: Padding(
                            padding: const EdgeInsets.only(right: 10),
                            child: IconButton(
                                icon: Icon(_obscureRepeatText ? Icons.visibility : Icons.visibility_off),
                                onPressed: () => setState(() => _obscureRepeatText = !_obscureRepeatText)),
                          )),
                      obscureText: _obscureRepeatText,
                      autofillHints: const [AutofillHints.newPassword],
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
                    onPressed: _handleRegistration,
                    child: const Text('common_register').tr(),
                  ),
                )),
            Padding(
                padding: const EdgeInsets.only(top: 10),
                child: SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: TextButton(
                    onPressed: () => context.goPath(LoginPage.pagePath.build(), extra: widget.hostUri),
                    child: const Text('Already have an account?'),
                  ),
                )),
          ],
        ));
  }

  Future<void> _handleRegistration() async {
    final String username = _usernameController.text;
    if (username.isEmpty) {
      context.showSnackBar('common_username_required'.tr());
      return;
    }
    final String password = _passwordController.text;
    if (password.isEmpty) {
      context.showSnackBar('common_password_required'.tr());
      return;
    }
    if (password != _passwordRepeatController.text) {
      context.showSnackBar('common_passwords_do_not_match'.tr());
      return;
    }
    final AuthenticationState state = await ref.read(authProvider.notifier).register(username, password, widget.hostUri);
    if (!mounted) return;
    if (state.status == AuthenticationStatus.authenticated) {
      context.goPath(DashboardPage.pagePath.build());
    } else {
      context.showSnackBar('common_registration_failed'.tr());
    }
  }
}
