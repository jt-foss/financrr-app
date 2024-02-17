import 'package:restrr/restrr.dart';
import 'package:test/expect.dart';
import 'package:test/scaffolding.dart';

void main() async {
  group('Restrr#checkUri: ', () {
    test('Invalid hosts return no data', () async {
      final Uri uri = Uri.parse('https://jasonlessenich.dev');
      final RestResponse<HealthResponse> response = await Restrr.checkUri(uri);
      expect(response.hasData, equals(false));
    });

    test('Valid hosts return a HealthResponse', () async {
      final Uri uri = Uri.parse('https://financrr-stage.denux.dev');
      final RestResponse<HealthResponse> response = await Restrr.checkUri(uri);
      expect(response.hasData, equals(true));
      expect(response.data!.apiVersion, equals(1));
      expect(response.data!.healthy, equals(true));
    });
  });
}