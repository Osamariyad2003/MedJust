// lib/core/error/failures.dart

abstract class Failure {
  final String message;
  const Failure(this.message);
}

// Common failures
class ServerFailure extends Failure {
  const ServerFailure(String message) : super(message);
}

class CacheFailure extends Failure {
  const CacheFailure(String message) : super(message);
}

class FirebaseAuthFailure extends Failure {
  const FirebaseAuthFailure({required String message}) : super(message);
}

class FireStoreFailure extends Failure {
  const FireStoreFailure(String message) : super(message);
}
