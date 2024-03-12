import '../../restrr.dart';
import 'api_service.dart';

class UserService extends ApiService {
  const UserService({required super.api});

  Future<RestResponse<User>> login(String username, String password) async {
    return request(
        route: UserRoutes.login.compile(),
        body: {
          'username': username,
          'password': password,
        },
        mapper: (json) => api.entityBuilder.buildUser(json),
        errorMap: {
          404: RestrrError.invalidCredentials,
          401: RestrrError.invalidCredentials,
        });
  }

  Future<RestResponse<bool>> logout() async {
    return noResponseRequest(route: UserRoutes.logout.compile(), errorMap: {
      401: RestrrError.notSignedIn,
    });
  }

  Future<RestResponse<User>> register(String username, String password, {String? email, String? displayName}) async {
    return request(
        route: UserRoutes.register.compile(),
        body: {
          'username': username,
          'password': password,
          if (email != null) 'email': email,
          if (displayName != null) 'display_name': displayName,
        },
        mapper: (json) => api.entityBuilder.buildUser(json),
        errorMap: {
          409: RestrrError.alreadySignedIn,
        });
  }

  Future<RestResponse<User>> getSelf() async {
    return request(route: UserRoutes.me.compile(), mapper: (json) => api.entityBuilder.buildUser(json), errorMap: {
      401: RestrrError.notSignedIn,
    });
  }
}
