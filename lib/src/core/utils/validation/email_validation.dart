import 'package:material_ui/material_ui.dart';

class EmailValidation {
  static String? validate(BuildContext context, String? value) {
    final emailRegex = RegExp(r'^[\w-\.]+(\+[\w-\.]+)?@([\w-]+\.)+[\w-]{2,4}$');

    if (value == null) return null;

    if (!emailRegex.hasMatch(value)) {
      return "$value is not a valid email address.";
    }

    return null;
  }
}
