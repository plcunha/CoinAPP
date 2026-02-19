/// Exceções customizadas da aplicação
abstract class AppException implements Exception {
  final String message;
  final String? code;
  final StackTrace? stackTrace;

  const AppException(this.message, {this.code, this.stackTrace});

  @override
  String toString() => '[$runtimeType] $message${code != null ? ' (Code: $code)' : ''}';
}

/// Exceção de validação de carteira
class WalletValidationException extends AppException {
  const WalletValidationException(
    String message, {
    String? code,
    StackTrace? stackTrace,
  }) : super(message, code: code, stackTrace: stackTrace);
}

/// Exceção de rede/API
class NetworkException extends AppException {
  final int? statusCode;

  const NetworkException(
    String message, {
    this.statusCode,
    String? code,
    StackTrace? stackTrace,
  }) : super(message, code: code, stackTrace: stackTrace);

  factory NetworkException.fromStatusCode(int code, {String? message}) {
    switch (code) {
      case 400:
        return NetworkException(
          message ?? 'Requisição inválida',
          statusCode: code,
          code: 'BAD_REQUEST',
        );
      case 401:
        return NetworkException(
          message ?? 'Não autorizado',
          statusCode: code,
          code: 'UNAUTHORIZED',
        );
      case 403:
        return NetworkException(
          message ?? 'Acesso negado',
          statusCode: code,
          code: 'FORBIDDEN',
        );
      case 404:
        return NetworkException(
          message ?? 'Recurso não encontrado',
          statusCode: code,
          code: 'NOT_FOUND',
        );
      case 429:
        return NetworkException(
          message ?? 'Muitas requisições',
          statusCode: code,
          code: 'RATE_LIMIT',
        );
      case 500:
      case 502:
      case 503:
      case 504:
        return NetworkException(
          message ?? 'Erro no servidor',
          statusCode: code,
          code: 'SERVER_ERROR',
        );
      default:
        return NetworkException(
          message ?? 'Erro de rede desconhecido',
          statusCode: code,
          code: 'UNKNOWN_ERROR',
        );
    }
  }
}

/// Exceção de blockchain
class BlockchainException extends AppException {
  const BlockchainException(
    String message, {
    String? code,
    StackTrace? stackTrace,
  }) : super(message, code: code, stackTrace: stackTrace);
}

/// Exceção de cache/armazenamento
class CacheException extends AppException {
  const CacheException(
    String message, {
    String? code,
    StackTrace? stackTrace,
  }) : super(message, code: code, stackTrace: stackTrace);
}

/// Exceção de autenticação
class AuthException extends AppException {
  const AuthException(
    String message, {
    String? code,
    StackTrace? stackTrace,
  }) : super(message, code: code, stackTrace: stackTrace);
}

/// Falha genérica para camada de domínio
abstract class Failure {
  final String message;
  final String? code;

  const Failure(this.message, {this.code});

  @override
  String toString() => '[$runtimeType] $message';
}

class ValidationFailure extends Failure {
  const ValidationFailure(String message, {String? code}) : super(message, code: code);
}

class ServerFailure extends Failure {
  const ServerFailure(String message, {String? code}) : super(message, code: code);
}

class NetworkFailure extends Failure {
  const NetworkFailure(String message, {String? code}) : super(message, code: code);
}

class CacheFailure extends Failure {
  const CacheFailure(String message, {String? code}) : super(message, code: code);
}
