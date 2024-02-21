import 'package:restrr/restrr.dart';
import 'package:test/expect.dart';
import 'package:test/scaffolding.dart';

final Uri _invalidUri = Uri.parse('https://financrr-stage.jasonlessenich.dev');
final Uri _validUri = Uri.parse('https://financrr-stage.denux.dev');

void main() {
  group('[RestrrBuilder] ', () {
    test('.login (invalid URL)', () async {
      final RestResponse<Restrr> loginResponse =
          await RestrrBuilder.login(uri: _invalidUri, username: '', password: '').create();
      expect(loginResponse.hasData, false);
      expect(loginResponse.error!.type, RestrrError.invalidUri);
    });

    test('.login (invalid credentials)', () async {
      final RestResponse<Restrr> loginResponse =
          await RestrrBuilder.login(uri: _validUri, username: 'abc', password: 'abc').create();
      expect(loginResponse.hasData, false);
      expect(loginResponse.error!.type, RestrrError.invalidCredentials);
    });

    test('.login (valid)', () async {
      final RestResponse<Restrr> loginResponse =
      await RestrrBuilder.login(uri: _validUri, username: 'admin', password: 'Financrr123').create();
      expect(loginResponse.hasData, true);
    });
  });
}
