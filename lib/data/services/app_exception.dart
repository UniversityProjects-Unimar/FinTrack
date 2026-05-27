abstract class AppException implements Exception {
  const AppException(this.mensagem);

  final String mensagem;

  @override
  String toString() => mensagem;
}

class NetworkException extends AppException {
  const NetworkException([String m = 'Sem conexão com a internet.']) : super(m);
}

class TimeoutApiException extends AppException {
  const TimeoutApiException([
    String m = 'O servidor demorou para responder. Tente novamente.',
  ]) : super(m);
}

class ParseException extends AppException {
  const ParseException([
    String m = 'Resposta do servidor em formato inesperado.',
  ]) : super(m);
}

class ApiException extends AppException {
  const ApiException({required this.codigo, required String mensagem})
    : super(mensagem);

  final int codigo;
}

class UnauthorizedException extends ApiException {
  const UnauthorizedException()
    : super(codigo: 401, mensagem: 'Sessão expirada. Faça login novamente.');
}

class ForbiddenException extends ApiException {
  const ForbiddenException()
    : super(
        codigo: 403,
        mensagem: 'Sem permissão para realizar esta operação.',
      );
}

class NotFoundException extends ApiException {
  const NotFoundException([String m = 'Recurso não encontrado.'])
    : super(codigo: 404, mensagem: m);
}

class UnprocessableException extends ApiException {
  const UnprocessableException([
    String m = 'Dados inválidos para esta operação.',
  ]) : super(codigo: 422, mensagem: m);
}

class ServerException extends ApiException {
  const ServerException()
    : super(
        codigo: 500,
        mensagem: 'Erro interno do servidor. Tente mais tarde.',
      );
}
