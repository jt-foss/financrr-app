import 'package:financrr_frontend/utils/l10n_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:package_info_plus/package_info_plus.dart';

class FallbackErrorApp extends StatelessWidget {
  static const String githubIssueUrl =
      'https://github.com/financrr/financrr-app/issues/new?labels=fix&template=bug_report.md&title=bug(frontend): ';

  final String error;
  final String? stackTrace;

  const FallbackErrorApp({super.key, required this.error, this.stackTrace});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: SafeArea(
          child: GestureDetector(
            onTap: () => Clipboard.setData(ClipboardData(text: error)),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: ListView(
                children: [
                  const Icon(Icons.error_outline_rounded),
                  const SizedBox(height: 10),
                  L10nKey.startupErrorTitle.toText(
                    textAlign: TextAlign.center,
                    baseStyle: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  // TODO: parse URL & email to clickable links
                  L10nKey.startupErrorSubtitle.toText(textAlign: TextAlign.center),
                  const SizedBox(height: 20),
                  FutureBuilder(
                    future: PackageInfo.fromPlatform(),
                    builder: (context, snap) {
                      if (!snap.hasData) return const SizedBox();
                      final PackageInfo info = snap.data!;
                      return Align(
                        alignment: Alignment.centerRight,
                        child: Text('v${info.version}+${info.buildNumber}', textAlign: TextAlign.center),
                      );
                    },
                  ),
                  Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text('${error.trim()}${stackTrace != null ? '\n\n${stackTrace!.trim()}' : ''}'))
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
