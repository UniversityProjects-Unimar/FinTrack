import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:fin_track/data/services/app_exception.dart';
import 'package:http/http.dart' as http;

Future<http.Response> executar(Future<http.Response> Function() fn) async {
  try {
    return await fn();
  } on SocketException {
    throw const NetworkException();
  } on TimeoutException {
    throw const TimeoutApiException();
  }
}

void verificarStatus(http.Response response) {
  if (response.statusCode >= 200 && response.statusCode < 300) {
    return;
  }

  switch (response.statusCode) {
    case 401:
      throw const UnauthorizedException();
    case 403:
      throw const ForbiddenException();
    case 404:
      throw const NotFoundException();
    case 422:
      throw const UnprocessableException();
    case 500:
      throw const ServerException();
    default:
      throw ApiException(codigo: response.statusCode, mensagem: response.body);
  }
}

String decodeBodyUtf8(http.Response response) {
  return utf8.decode(response.bodyBytes);
}

List<Map<String, dynamic>> decodeJsonList(http.Response response) {
  try {
    final body = decodeBodyUtf8(response);
    final list = jsonDecode(body) as List<dynamic>;
    return list.cast<Map<String, dynamic>>();
  } on FormatException {
    throw const ParseException();
  } on TypeError {
    throw const ParseException();
  }
}

Map<String, dynamic> decodeJsonMap(http.Response response) {
  try {
    final body = decodeBodyUtf8(response);
    final map = jsonDecode(body) as Map<String, dynamic>;
    return map;
  } on FormatException {
    throw const ParseException();
  } on TypeError {
    throw const ParseException();
  }
}
