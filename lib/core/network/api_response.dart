/// Normalised result of every API call. The network layer never throws:
/// callers check [success] and show [message].
///
/// The backend answers with `{status|success, message, data}`; both key
/// names are handled. Laravel validation errors (`errors: {field: [msg]}`)
/// are exposed through [fieldError].
class ApiResponse<T> {
  const ApiResponse({
    required this.success,
    required this.message,
    this.data,
    this.statusCode,
    this.errors,
    this.body,
  });

  final bool success;
  final String message;
  final T? data;
  final int? statusCode;
  final Map<String, dynamic>? errors;

  /// Whole JSON body, for top-level keys besides `data` (e.g. `current`).
  final Map<String, dynamic>? body;

  /// Backend answered `Subscription required` (open the Subscription page).
  bool get isSubscriptionRequired =>
      !success &&
      (statusCode == 402 || message.toLowerCase().contains('subscription'));

  /// First validation message for [field], if the server sent one.
  String? fieldError(String field) {
    final value = errors?[field];
    if (value is List && value.isNotEmpty) return value.first.toString();
    if (value is String && value.isNotEmpty) return value;
    return null;
  }

  /// Same response with the payload converted (failures stay failures).
  ApiResponse<R> map<R>(R? Function(T? data) convert) => ApiResponse<R>(
    success: success,
    message: message,
    data: success ? convert(data) : null,
    statusCode: statusCode,
    errors: errors,
    body: body,
  );
}
