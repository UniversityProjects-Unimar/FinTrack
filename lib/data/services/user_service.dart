import 'dart:convert';

import 'package:fin_track/data/services/api_uris.dart';
import 'package:fin_track/data/services/cabecalhos.dart';
import 'package:fin_track/data/services/http_utils.dart';
import 'package:fin_track/features/autenticacao/domain/models/user.dart';
import 'package:http/http.dart' as http;

class UserService {
  UserService({required http.Client client}) : _client = client;

  final http.Client _client;

  Future<User?> getByEmail({required String email, String? token}) async {
    final response = await executar(
      () => _client
          .get(
            ApiUris.usersByEmail(email: email),
            headers: Cabecalhos.leitura(token),
          )
          .timeout(const Duration(seconds: 10)),
    );

    if (response.statusCode == 404) return null;

    verificarStatus(response);

    final json = decodeJsonMap(response);
    return User.fromJson(json);
  }

  Future<User> getById({required int userId, String? token}) async {
    final response = await executar(
      () => _client
          .get(ApiUris.user(userId: userId), headers: Cabecalhos.leitura(token))
          .timeout(const Duration(seconds: 10)),
    );

    verificarStatus(response);

    final json = decodeJsonMap(response);
    return User.fromJson(json);
  }

  Future<User> upsert({required User user, String? token}) async {
    final response = await executar(
      () => _client
          .put(
            ApiUris.user(userId: user.id),
            headers: Cabecalhos.escrita(token),
            body: jsonEncode(user.toJson()),
          )
          .timeout(const Duration(seconds: 15)),
    );

    verificarStatus(response);

    final json = decodeJsonMap(response);
    return User.fromJson(json);
  }
}
