import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'tokens/app_colors.dart';

class AppTheme {
  // Construtor privado para evitar instanciação
  AppTheme._();

  static ThemeData light() => _base(Brightness.light);

  static ThemeData dark() => _base(Brightness.dark);

  static ThemeData _base(Brightness brightness) {
    const seed = Color(0xFF2F9E41);
    final base = ColorScheme.fromSeed(seedColor: seed, brightness: brightness);

    final scheme = base.copyWith(
      primary: base.primary,
      secondary: base.secondary,
      tertiary: base.tertiary,

      // onPrimary: brightness == Brightness.light ? Colors.white : Colors.black,
      // onSecondary: brightness == Brightness.light ? Colors.white : Colors.black,
      // onTertiary: brightness == Brightness.light ? Colors.white : Colors.black,
      // surface: brightness == Brightness.light ? Colors.white : const Color(0xFF121212),
      onSurface: brightness == Brightness.light
          ? const Color(0xFF003C25)
          : Colors.white,
    );
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      brightness: brightness,
      filledButtonTheme: FilledButtonThemeData(
          style: ButtonStyle(
              minimumSize: const WidgetStatePropertyAll(Size(48, 48)),
              padding: const WidgetStatePropertyAll(
                  EdgeInsets.symmetric(horizontal: 20)),
              shape: WidgetStatePropertyAll(RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12))),
              backgroundColor: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.disabled)) {
                  return scheme.onSurface.withOpacity(0.12);
                }
                if (states.contains(WidgetState.pressed)) {
                  return scheme.primaryContainer;
                }
                return scheme.primary;
              }),
              foregroundColor: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.disabled)) {
                  return scheme.onSurface.withOpacity(0.38);
                }
                return scheme.onPrimary;
              }))),
      outlinedButtonTheme: OutlinedButtonThemeData(
          style: ButtonStyle(
        minimumSize: const WidgetStatePropertyAll(Size(48, 48)),
        padding:
            const WidgetStatePropertyAll(EdgeInsets.symmetric(horizontal: 20)),
        shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
        side: WidgetStatePropertyAll(BorderSide(color: scheme.outline)),
        foregroundColor: WidgetStatePropertyAll(scheme.primary),
      )),
      textButtonTheme: TextButtonThemeData(
          style: ButtonStyle(
        foregroundColor: WidgetStatePropertyAll(scheme.primary),
        padding:
            const WidgetStatePropertyAll(EdgeInsets.symmetric(horizontal: 20)),
        shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
      )),
      appBarTheme: AppBarTheme(
        backgroundColor: scheme.surface,
        foregroundColor: scheme.onSurface,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: scheme.onSurface,
          fontWeight: FontWeight.w600,
          fontSize: 20,
        ),
        iconTheme: IconThemeData(color: scheme.onSurface),
        actionsIconTheme: IconThemeData(color: scheme.onSurface),
        // Ícones da status bar legíveis em light/dark
        systemOverlayStyle: (brightness == Brightness.light)
            ? SystemUiOverlayStyle.dark
            : SystemUiOverlayStyle.light,
      ),
      inputDecorationTheme: InputDecorationTheme(
        isDense: true,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        filled: true,
        fillColor: (brightness == Brightness.light)
            ? scheme.surfaceVariant.withOpacity(0.20)
            : scheme.surfaceVariant.withOpacity(0.15),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: scheme.outlineVariant),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: scheme.outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: scheme.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: scheme.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: scheme.error, width: 2),
        ),
        labelStyle: TextStyle(color: scheme.onSurface.withOpacity(0.7)),
        hintStyle: TextStyle(color: scheme.onSurfaceVariant),
        prefixIconColor: scheme.onSurfaceVariant,
        suffixIconColor: scheme.onSurfaceVariant,
      ),

      extensions: const [
        AppColors(
          success: Color(0xFF4CAF50),
          warning: Color(0xFFFFC107),
          info: Color(0xFF2196F3),
          gradient: LinearGradient(
            colors: [Color(0xFF6750A4), Color(0xFF6200EE)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
      ],
    );
  }
}
