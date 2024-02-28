import 'package:restrr/restrr.dart';

class RequestEvent extends RestrrEvent {
  final String route;
  final int? statusCode;

  const RequestEvent({required super.api, required this.route, this.statusCode});
}
