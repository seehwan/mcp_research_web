import 'package:flutter/material.dart';

class AppStyles {
  // Spacing
  static const double spacingSmall = 8.0;
  static const double spacingMedium = 16.0;
  static const double spacingLarge = 24.0;
  static const double spacingXLarge = 32.0;

  // Border Radius
  static const double cardBorderRadius = 12.0;
  static const double inputBorderRadius = 8.0;
  static const double buttonBorderRadius = 8.0;

  // Padding
  static const double cardPadding = 16.0;
  static const double inputPadding = 12.0;
  static const double buttonPadding = 12.0;

  // Input Decoration
  static InputDecoration getInputDecoration({
    required BuildContext context,
    String? labelText,
    String? hintText,
    String? errorText,
    Widget? prefixIcon,
    Widget? suffixIcon,
  }) {
    final theme = Theme.of(context);

    return InputDecoration(
      labelText: labelText,
      hintText: hintText,
      errorText: errorText,
      prefixIcon: prefixIcon,
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: theme.brightness == Brightness.dark ? Colors.blueGrey[900] : Colors.grey[100],
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(inputBorderRadius),
        borderSide: BorderSide(
          color: theme.brightness == Brightness.dark ? Colors.blueGrey[700]! : Colors.grey[300]!,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(inputBorderRadius),
        borderSide: BorderSide(
          color: theme.brightness == Brightness.dark ? Colors.blueGrey[700]! : Colors.grey[300]!,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(inputBorderRadius),
        borderSide: BorderSide(
          color: theme.colorScheme.primary,
          width: 2,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(inputBorderRadius),
        borderSide: BorderSide(
          color: theme.colorScheme.error,
        ),
      ),
      contentPadding: EdgeInsets.all(inputPadding),
    );
  }

  // Button Style
  static ButtonStyle getButtonStyle({
    required BuildContext context,
    bool isPrimary = true,
    bool isOutlined = false,
  }) {
    final theme = Theme.of(context);

    if (isOutlined) {
      return OutlinedButton.styleFrom(
        padding: EdgeInsets.all(buttonPadding),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(buttonBorderRadius),
        ),
        side: BorderSide(
          color: isPrimary ? theme.colorScheme.primary : theme.colorScheme.secondary,
        ),
      );
    }

    return ElevatedButton.styleFrom(
      padding: EdgeInsets.all(buttonPadding),
      backgroundColor: isPrimary ? theme.colorScheme.primary : theme.colorScheme.secondary,
      foregroundColor: isPrimary ? theme.colorScheme.onPrimary : theme.colorScheme.onSecondary,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(buttonBorderRadius),
      ),
    );
  }
} 