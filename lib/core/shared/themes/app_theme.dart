import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_text_styles.dart';

class AppTheme {
  // Update the brand seed to your new color
  static const _seed = Color(0xFF1B2A49); // new deep blue

  // ===== Dim Light (dark-leaning light) =====
  static ThemeData get lightTheme {
    final cs = ColorScheme.fromSeed(
      seedColor: _seed,
      brightness: Brightness.light,
    );

    // nudge the scheme to dimmer surfaces
    final dim = cs.copyWith(
      surface: const Color(0xFFF2F4F7), // soft off-white
      surfaceContainerHighest: const Color(0xFFE6EAF0),
      surfaceContainerHigh: const Color(0xFFEEF1F5),
      // No need to manually set 0xFF274472 or 0xFF1B2A49 here
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: dim,
      scaffoldBackgroundColor: dim.surface, // no bright white

      textTheme: const TextTheme(
        headlineLarge: AppTextStyles.heading1,
        headlineMedium: AppTextStyles.heading2,
        headlineSmall: AppTextStyles.heading3,
        bodyLarge: AppTextStyles.bodyText1,
        bodyMedium: AppTextStyles.bodyText2,
        bodySmall: AppTextStyles.caption,
      ),

      appBarTheme: AppBarTheme(
        backgroundColor: dim.surface,
        foregroundColor: dim.onSurface,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: AppTextStyles.heading3.copyWith(color: dim.onSurface),
        surfaceTintColor: dim.surfaceTint,
      ),

      tabBarTheme: TabBarThemeData(
        labelColor: dim.primary,
        unselectedLabelColor: dim.onSurfaceVariant,
        indicatorColor: dim.primary,
        indicatorSize: TabBarIndicatorSize.label,
        labelStyle: AppTextStyles.bodyText1.copyWith(
          fontWeight: FontWeight.w700,
        ),
        unselectedLabelStyle: AppTextStyles.bodyText1,
      ),

      filledButtonTheme: FilledButtonThemeData(
        style: ButtonStyle(
          padding: WidgetStateProperty.all(
            const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
          ),
          shape: WidgetStateProperty.all(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          ),
          textStyle: WidgetStateProperty.all(
            AppTextStyles.bodyText1.copyWith(fontWeight: FontWeight.w600),
          ),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: dim.primary,
          foregroundColor: dim.onPrimary,
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          textStyle: AppTextStyles.bodyText1.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: dim.primary,
          side: BorderSide(color: dim.outline),
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          textStyle: AppTextStyles.bodyText1.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: dim.primary,
          textStyle: AppTextStyles.bodyText1.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: dim.surfaceContainerHigh, // darker field bg
        hintStyle: TextStyle(color: dim.onSurfaceVariant),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: dim.outlineVariant),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: dim.outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: dim.primary, width: 2),
        ),
      ),

      cardTheme: CardThemeData(
        color: dim.surfaceContainerHigh, // dim card, not white
        elevation: 1,
        margin: const EdgeInsets.all(12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        shadowColor: dim.shadow,
      ),
      listTileTheme: ListTileThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        iconColor: dim.onSurfaceVariant,
        textColor: dim.onSurface,
        titleTextStyle: AppTextStyles.bodyText1.copyWith(
          fontWeight: FontWeight.w600,
        ),
        subtitleTextStyle: AppTextStyles.bodyText2.copyWith(
          color: dim.onSurfaceVariant,
        ),
      ),
      dividerTheme: DividerThemeData(color: dim.outlineVariant, thickness: 1),

      chipTheme: ChipThemeData(
        shape: const StadiumBorder(),
        labelStyle: AppTextStyles.bodyText2.copyWith(
          fontWeight: FontWeight.w600,
        ),
        selectedColor: dim.secondaryContainer,
        secondarySelectedColor: dim.secondaryContainer,
        backgroundColor: dim.surfaceContainerHighest,
      ),

      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: dim.surface,
        indicatorColor: dim.secondaryContainer,
        elevation: 1,
        labelTextStyle: WidgetStateProperty.all(
          AppTextStyles.caption.copyWith(fontWeight: FontWeight.w700),
        ),
      ),

      snackBarTheme: SnackBarThemeData(
        backgroundColor: dim.inverseSurface,
        contentTextStyle: TextStyle(color: dim.onInverseSurface),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: dim.surface,
        surfaceTintColor: dim.surfaceTint,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: dim.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: dim.primaryContainer,
        foregroundColor: dim.onPrimaryContainer,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      visualDensity: VisualDensity.standard,
    );
  }

  // ===== Full Dark =====
  static ThemeData get darkTheme {
    final cs = ColorScheme.fromSeed(
      seedColor: _seed,
      brightness: Brightness.dark,
    );

    final deep = cs.copyWith(
      surface: const Color(0xFF0E141A),
      surfaceContainerHigh: const Color(0xFF1B2A49),
      surfaceContainerHighest: const Color(0xFF274472),
      // No need to manually set 0xFF274472 or 0xFF1B2A49 here
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: deep,
      scaffoldBackgroundColor: deep.surface,

      textTheme: TextTheme(
        headlineLarge: AppTextStyles.heading1.copyWith(color: deep.onSurface),
        headlineMedium: AppTextStyles.heading2.copyWith(color: deep.onSurface),
        headlineSmall: AppTextStyles.heading3.copyWith(color: deep.onSurface),
        bodyLarge: AppTextStyles.bodyText1.copyWith(color: deep.onSurface),
        bodyMedium: AppTextStyles.bodyText2.copyWith(
          color: deep.onSurfaceVariant,
        ),
        bodySmall: AppTextStyles.caption.copyWith(color: deep.onSurfaceVariant),
      ),

      appBarTheme: AppBarTheme(
        backgroundColor: deep.surface,
        foregroundColor: deep.onSurface,
        centerTitle: true,
        elevation: 0,
        titleTextStyle: AppTextStyles.heading3.copyWith(color: deep.onSurface),
        surfaceTintColor: deep.surfaceTint,
      ),

      // buttons (reuse)
      filledButtonTheme: FilledButtonThemeData(
        style: ButtonStyle(
          padding: WidgetStateProperty.all(
            const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
          ),
          shape: WidgetStateProperty.all(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          ),
          textStyle: WidgetStateProperty.all(
            AppTextStyles.bodyText1.copyWith(fontWeight: FontWeight.w600),
          ),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: deep.primary,
          foregroundColor: deep.onPrimary,
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          textStyle: AppTextStyles.bodyText1.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: deep.primary,
          side: BorderSide(color: deep.outline),
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          textStyle: AppTextStyles.bodyText1.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: deep.secondary,
          textStyle: AppTextStyles.bodyText1.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: deep.surfaceContainerHigh,
        hintStyle: TextStyle(color: deep.onSurfaceVariant),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: deep.outlineVariant),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: deep.outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: deep.primary, width: 2),
        ),
      ),

      cardTheme: CardThemeData(
        color: deep.surfaceContainerHigh,
        elevation: 1,
        margin: const EdgeInsets.all(12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        shadowColor: deep.shadow,
      ),
      listTileTheme: ListTileThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        iconColor: deep.onSurfaceVariant,
        textColor: deep.onSurface,
        titleTextStyle: AppTextStyles.bodyText1.copyWith(
          fontWeight: FontWeight.w600,
          color: deep.onSurface,
        ),
        subtitleTextStyle: AppTextStyles.bodyText2.copyWith(
          color: deep.onSurfaceVariant,
        ),
      ),
      dividerTheme: DividerThemeData(color: deep.outlineVariant, thickness: 1),

      chipTheme: ChipThemeData(
        shape: const StadiumBorder(),
        labelStyle: AppTextStyles.bodyText2.copyWith(
          fontWeight: FontWeight.w600,
          color: deep.onSecondaryContainer,
        ),
        selectedColor: deep.secondaryContainer,
        secondarySelectedColor: deep.secondaryContainer,
        backgroundColor: deep.surfaceContainerHighest,
      ),

      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: deep.surface,
        indicatorColor: deep.secondaryContainer,
        elevation: 1,
        labelTextStyle: WidgetStateProperty.all(
          AppTextStyles.caption.copyWith(
            fontWeight: FontWeight.w700,
            color: deep.onSurface,
          ),
        ),
      ),

      snackBarTheme: SnackBarThemeData(
        backgroundColor: deep.inverseSurface,
        contentTextStyle: TextStyle(color: deep.onInverseSurface),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: deep.surface,
        surfaceTintColor: deep.surfaceTint,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: deep.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: deep.primaryContainer,
        foregroundColor: deep.onPrimaryContainer,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      visualDensity: VisualDensity.standard,
    );
  }

  // ===== Optional: AMOLED true black =====
  static ThemeData get amoledTheme {
    final cs = ColorScheme.fromSeed(
      seedColor: _seed,
      brightness: Brightness.dark,
    );
    final black = cs.copyWith(
      surface: Colors.black,
      surfaceContainerHigh: const Color(0xFF0A0A0A),
      surfaceContainerHighest: Colors.black,
    );

    return darkTheme.copyWith(
      colorScheme: black,
      scaffoldBackgroundColor: Colors.black,
      appBarTheme: darkTheme.appBarTheme.copyWith(
        backgroundColor: Colors.black,
      ),
      cardTheme: darkTheme.cardTheme.copyWith(
        color: black.surfaceContainerHigh,
      ),
    );
  }
}
