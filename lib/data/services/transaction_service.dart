import 'dart:convert';

import 'package:fin_track/data/services/api_uris.dart';
import 'package:fin_track/data/services/cabecalhos.dart';
import 'package:fin_track/data/services/http_utils.dart';
import 'package:fin_track/features/autenticacao/domain/models/transaction.dart';
import 'package:http/http.dart' as http;

class TransactionService {
  TransactionService({required http.Client client}) : _client = client;

  final http.Client _client;

  Future<List<Transaction>> listByUser({
    required int userId,
    String? token,
  }) async {
    final response = await executar(
      () => _client
          .get(
            ApiUris.transactions(userId: userId),
            headers: Cabecalhos.leitura(token),
          )
          .timeout(const Duration(seconds: 10)),
    );

    if (response.statusCode == 204 || response.statusCode == 404) {
      return const [];
    }

    verificarStatus(response);

    final jsonList = decodeJsonList(response);
    return jsonList.map(Transaction.fromJson).toList();
  }

  Future<Transaction> upsert({
    required int userId,
    required Transaction tx,
    String? token,
  }) async {
    final response = await executar(
      () => _client
          .put(
            ApiUris.transaction(userId: userId, id: tx.id),
            headers: Cabecalhos.escrita(token),
            body: jsonEncode(tx.toJson()),
          )
          .timeout(const Duration(seconds: 15)),
    );

    verificarStatus(response);

    final json = decodeJsonMap(response);
    return Transaction.fromJson(json);
  }

  Future<void> delete({
    required int userId,
    required String id,
    String? token,
  }) async {
    final response = await executar(
      () => _client
          .delete(
            ApiUris.transaction(userId: userId, id: id),
            headers: Cabecalhos.leitura(token),
          )
          .timeout(const Duration(seconds: 10)),
    );

    if (response.statusCode == 200 || response.statusCode == 204) {
      return;
    }

    verificarStatus(response);
  }
}
