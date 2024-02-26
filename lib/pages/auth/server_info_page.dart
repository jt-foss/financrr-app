import 'dart:async';

import 'package:financrr_frontend/data/host_repository.dart';
import 'package:financrr_frontend/layout/templates/auth_page_template.dart';
import 'package:financrr_frontend/pages/auth/login_page.dart';
import 'package:financrr_frontend/util/extensions.dart';
import 'package:financrr_frontend/util/input_utils.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:restrr/restrr.dart';

import '../../layout/adaptive_scaffold.dart';
import '../../router.dart';

class ServerInfoPage extends StatefulWidget {
  static const PagePathBuilder pagePath = PagePathBuilder('/login');

  final String? redirectTo;

  const ServerInfoPage({super.key, this.redirectTo});

  @override
  State<StatefulWidget> createState() => ServerInfoPageState();
}

class ServerInfoPageState extends State<ServerInfoPage> {
  final TextEditingController _urlController = TextEditingController();

  bool _isLoading = false;
  bool _isValid = false;
  Uri? _hostUri;
  int? _apiVersion;

  @override
  void initState() {
    super.initState();
    final String hostUrl = HostService.get().hostUrl;
    if (hostUrl.isNotEmpty && InputValidators.url(context, hostUrl) == null) {
      _urlController.text = hostUrl;
      _handleUrlCheck();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AdaptiveScaffold(
      resizeToAvoidBottomInset: false,
      verticalBuilder: (_, __, size) => SafeArea(child: _buildVerticalLayout(size)),
    );
  }

  Widget _buildVerticalLayout(Size size) {
    return AuthPageTemplate(
        child: Column(
      children: [
        Form(
            autovalidateMode: AutovalidateMode.onUserInteraction,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 20),
                  child: TextFormField(
                    controller: _urlController,
                    decoration: const InputDecoration(labelText: 'Server URL'),
                    autofillHints: const [AutofillHints.username],
                    validator: (value) => InputValidators.url(context, value),
                    onChanged: (_) => setState(() {
                      _isValid = false;
                      _apiVersion = null;
                    }),
                  ),
                ),
                if (_isValid && _apiVersion != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 5),
                    child: Text('Status: Healthy, v$_apiVersion',
                        style: context.textTheme.labelMedium?.copyWith(color: context.theme.primaryColor)),
                  )
              ],
            )),
        Padding(
            padding: const EdgeInsets.only(top: 20, bottom: 20),
            child: _isLoading
                ? const CircularProgressIndicator()
                : TextButton.icon(
                    onPressed: () {
                      if (_isValid) {
                        Navigator.push(context, MaterialPageRoute(builder: (ctx) => LoginPage(hostUri: _hostUri!)));
                      } else {
                        _handleUrlCheck();
                      }
                    },
                    label: const Icon(Icons.arrow_forward, size: 18),
                    icon: Text(_isValid ? 'Next' : 'Check URL'),
                  )),
      ],
    ));
  }

  Future<void> _handleUrlCheck() async {
    final String url = _urlController.text;
    if (InputValidators.url(context, url) != null) {
      context.showSnackBar('Please provide a valid URL');
      return;
    }
    setState(() {
      _isLoading = true;
      _isValid = false;
    });
    final RestResponse<HealthResponse> response = await Restrr.checkUri(Uri.parse(url), isWeb: kIsWeb);
    setState(() => _isLoading = false);
    if (!mounted) return;
    if (response.hasData) {
      setState(() {
        _isValid = true;
        _apiVersion = response.data!.apiVersion;
      });
      _hostUri = Uri.parse(url);
      HostService.setHostPreferences(url);
    } else {
      context.showSnackBar('Invalid URL');
    }
  }
}
