abstract final class Validators {
  static final RegExp _email = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

  static bool isEmail(String value) => _email.hasMatch(value.trim());

  /// Returns `The <name> field is required.` for blank input, else `null`.
  static String? requiredField(String value, String name) =>
      value.trim().isEmpty ? 'The $name field is required.' : null;
}
