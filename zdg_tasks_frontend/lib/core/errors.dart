/// Shared error types surfaced by the repository layer. Widgets render
/// these through AsyncValue error states; they never inspect raw dio
/// exceptions.
sealed class AppException implements Exception {
  const AppException(this.message);

  final String message;

  @override
  String toString() => message;
}

/// The server answered with a non-success status code.
class ApiException extends AppException {
  const ApiException(super.message, {required this.statusCode});

  final int statusCode;
}

/// The request never reached the server (offline, DNS, timeout). The
/// standard-request flow auto-drafts on this failure class.
class NetworkException extends AppException {
  const NetworkException(super.message);
}

/// The token was missing or rejected; the router redirects to login.
class UnauthenticatedException extends AppException {
  const UnauthenticatedException(super.message);
}
