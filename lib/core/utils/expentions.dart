class ServerException implements Exception {
  final String message;
  ServerException({this.message = 'Server Exception'});
}

class CacheException implements Exception {
  final String message;
  CacheException({this.message = 'Cache Exception'});
}


class FireBaseException implements Exception {
  final String message;

  FireBaseException({required this.message});

  @override
  String toString() => 'FireBaseException: $message';
}


class FireStoreException implements Exception {
  final String message;
  FireStoreException({this.message = 'Cache Exception'});
}
