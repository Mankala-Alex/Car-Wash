import 'package:flutter/material.dart';

class AppColors {
  // Light Mode Colors
  static const Color primaryLight = Color(0xFFE7E1CF); // Color(0xFFA32C2C);
  static const Color secondaryLight = Color(0xFFC4DBD4);
  static const Color blue = Color(0xFF0C8CE9);

  static const Color bgLight = Color(0xFFFFFFFF);
  static const Color bgBlackLight = Color(0xFF000000);
  static const Color bgLightBlueLight = Color(0xFFEAF4FF);
  static const Color bgBtnDisableLight = Color(0xFFCFD1DF);
  static const Color bgLightSecondaryLight = Color(0xFFFFF5F1);
  static const Color bgLightSecondaryDark = Color(0xFFF7E9E3);
  static const Color bgLightblue = Color(0xFFEAF4FF);
  //static
  //

  static const Color borderLightBlueLight = Color(0xFFD0DCEC);
  static const Color borderLightGrayLight = Color(0xFFDDE0E6);
  static const Color borderGray = Color(0xFFBEBEC0); //newly added

  // static const Color textPrimaryLight = Color(0xFFA32C2C); // primary color
  // static const Color textSecondaryLight = Color(0xFFF66834); // secondary color
  static const Color textDefaultLight = Color(0xFF000000); // black
  static const Color textWhiteLight = Color(0xFFFFFFFF); // black
  static const Color textLightBlueLight = Color(0xFF343645);
  static const Color textLightGrayLight = Color(0xFF6E6F71);
  static const Color textGreenLight = Color(0xFF269E82);

  static const Color errorLight = Color(0xFFF44336);
  static const Color successLight = Color(0xFF4CAF50);
  static const Color warningLight = Color(0xFFFFC107);

  // Dark Mode Colors
  // static const Color primaryDark = Color(0xFFA32C2C);
  // static const Color secondaryDark = Color(0xFFF66834);
  // static const Color bgDark = Color(0xFF121212);
  // static const Color errorDark = Color(0xFFF44336);
  // static const Color successDark = Color(0xFF4CAF50);
  // static const Color warningDark = Color(0xFFFFC107);
}

class AppTheme {
  /*  Font size Theme */
  // Define a base font size similar to 16px in CSS
  static double baseFontSize = 18.0;

  // Define the text theme
  static final TextTheme themeFont = TextTheme(
    displayLarge: TextStyle(fontSize: baseFontSize * 3.5), // 56px
    displayMedium: TextStyle(fontSize: baseFontSize * 3), // 48px
    displaySmall: TextStyle(fontSize: baseFontSize * 2.5), // 40px
    headlineLarge: TextStyle(fontSize: baseFontSize * 2), // 32px
    headlineMedium: TextStyle(fontSize: baseFontSize * 1.75), // 28px
    headlineSmall: TextStyle(fontSize: baseFontSize * 1.5), // 24px
    titleLarge: TextStyle(fontSize: baseFontSize * 1.25), // 20px
    titleMedium: TextStyle(fontSize: baseFontSize * 1.125), // 18px
    titleSmall: TextStyle(fontSize: baseFontSize), // 16px (Base)
    bodyLarge: TextStyle(fontSize: baseFontSize), // 16px
    bodyMedium: TextStyle(fontSize: baseFontSize * 0.875), // 14px
    bodySmall: TextStyle(fontSize: baseFontSize * 0.75), // 12px
    labelLarge: TextStyle(fontSize: baseFontSize * 0.875), // 14px
    labelMedium: TextStyle(fontSize: baseFontSize * 0.75), // 12px
    labelSmall: TextStyle(fontSize: baseFontSize * 0.625), // 10px
  );

  /// Light Theme
  static const _lightTheme = CustomTheme(
    primaryColor: AppColors.primaryLight,
    secondaryColor: AppColors.secondaryLight,
    blue: AppColors.blue,
    errorColor: AppColors.errorLight,
    successColor: AppColors.successLight,
    warningColor: AppColors.warningLight,
    bgColor: AppColors.bgLight,
    bgBlack: AppColors.bgBlackLight,
    bgLightBlue: AppColors.bgLightBlueLight,
    bgBtnDisable: AppColors.bgBtnDisableLight,
    bgLightSecondary: AppColors.bgLightSecondaryLight,
    bgLightSecondaryDark: AppColors.bgLightSecondaryDark,
    borderLightBlue: AppColors.borderLightBlueLight,
    borderLightGray: AppColors.borderLightGrayLight,
    borderGray: AppColors.borderGray,
    textDefault: AppColors.textDefaultLight,
    textWhiteLight: AppColors.textWhiteLight,
    textLightBlue: AppColors.textLightBlueLight,
    textLightGray: AppColors.textLightGrayLight,
    textGreen: AppColors.textGreenLight,
  );

  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    fontFamily: 'Montserrat',
    extensions: const [_lightTheme],
    textTheme: themeFont,
    // scaffoldBackgroundColor: Colors.white,
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 15),
        backgroundColor: AppColors.primaryLight,
        foregroundColor: Colors.white,
        minimumSize: const Size(100, 45),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0),
        ),
        // textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    ),
    // colorScheme: ColorScheme.fromSwatch().copyWith(
    //   primary: const Color(0xFFA32C2C),
    //   secondary: const Color(0xFFF66834),
    // ),
  );

  /// Dark Theme

  // static const _darkTheme = CustomTheme(
  //   primaryColor: AppColors.primaryLight, // Add dark colors here if available
  //   secondaryColor: AppColors.secondaryLight,
  //   errorColor: AppColors.errorLight,
  //   successColor: AppColors.successLight,
  //   warningColor: AppColors.warningLight,
  //   bgColor: Colors.black, // Example dark color
  //   bgBlack: Colors.black,
  //   bgLightBlue: Colors.grey.shade800,
  //   bgBtnDisable: Colors.grey.shade800,
  //   bgLightSecondary: Colors.grey.shade700,
  //   borderLightBlue: Colors.grey.shade600,
  //   borderLightGray: Colors.grey.shade500,
  //   textDefault: Colors.grey.shade200,
  //   textLightBlue: Colors.grey.shade400,
  //   textLightGray: Colors.grey.shade500,
  //   textGreen: Colors.green.shade300,
  // );

  // static ThemeData darkTheme = ThemeData(
  //   useMaterial3: true,
  //   extensions: [
  //     CustomTheme(
  //       primaryColor: AppColors.primaryDark,
  //       secondaryColor: AppColors.secondaryDark,
  //       errorColor: AppColors.errorDark,
  //       successColor: AppColors.successDark,
  //       warningColor: AppColors.warningDark,
  //     ),
  //   ],
  //   textTheme: themeFont,
  // );
}

class CustomTheme extends ThemeExtension<CustomTheme> {
  final Color primaryColor;
  final Color secondaryColor;
  final Color blue;
  final Color errorColor;
  final Color successColor;
  final Color warningColor;

  // Background Colors
  final Color bgColor;
  final Color bgBlack;
  final Color bgLightBlue;
  final Color bgBtnDisable;
  final Color bgLightSecondary;
  final Color bgLightSecondaryDark;

  // Border Colors
  final Color borderLightBlue;
  final Color borderLightGray;
  final Color borderGray;

  // Text Colors
  final Color textDefault;
  final Color textWhiteLight;
  final Color textLightBlue;
  final Color textLightGray;
  final Color textGreen;

  const CustomTheme({
    required this.primaryColor,
    required this.secondaryColor,
    required this.blue,
    required this.errorColor,
    required this.successColor,
    required this.warningColor,
    required this.bgColor,
    required this.bgBlack,
    required this.bgLightBlue,
    required this.bgBtnDisable,
    required this.bgLightSecondary,
    required this.bgLightSecondaryDark,
    required this.borderLightBlue,
    required this.borderLightGray,
    required this.borderGray,
    required this.textDefault,
    required this.textWhiteLight,
    required this.textLightBlue,
    required this.textLightGray,
    required this.textGreen,
  });

  @override
  CustomTheme copyWith({
    Color? primaryColor,
    Color? secondaryColor,
    Color? blue,
    Color? errorColor,
    Color? successColor,
    Color? warningColor,
    Color? bgColor,
    Color? bgBlack,
    Color? bgLightBlue,
    Color? bgBtnDisable,
    Color? bgLightSecondary,
    Color? bgLightSecondaryDark,
    Color? borderLightBlue,
    Color? borderLightGray,
    Color? borderGray,
    Color? textDefault,
    Color? textWhiteLight,
    Color? textLightBlue,
    Color? textLightGray,
    Color? textGreen,
  }) {
    return CustomTheme(
      primaryColor: primaryColor ?? this.primaryColor,
      secondaryColor: secondaryColor ?? this.secondaryColor,
      blue: blue ?? this.blue,
      errorColor: errorColor ?? this.errorColor,
      successColor: successColor ?? this.successColor,
      warningColor: warningColor ?? this.warningColor,
      bgColor: bgColor ?? this.bgColor,
      bgBlack: bgBlack ?? this.bgBlack,
      bgLightBlue: bgLightBlue ?? this.bgLightBlue,
      bgBtnDisable: bgBtnDisable ?? this.bgBtnDisable,
      bgLightSecondary: bgLightSecondary ?? this.bgLightSecondary,
      bgLightSecondaryDark: bgLightSecondary ?? this.bgLightSecondaryDark,
      borderLightBlue: borderLightBlue ?? this.borderLightBlue,
      borderLightGray: borderLightGray ?? this.borderLightGray,
      borderGray: borderGray ?? this.borderGray,
      textDefault: textDefault ?? this.textDefault,
      textWhiteLight: textWhiteLight ?? this.textWhiteLight,
      textLightBlue: textLightBlue ?? this.textLightBlue,
      textLightGray: textLightGray ?? this.textLightGray,
      textGreen: textGreen ?? this.textGreen,
    );
  }

  @override
  CustomTheme lerp(ThemeExtension<CustomTheme>? other, double t) {
    if (other is! CustomTheme) return this;
    return CustomTheme(
      primaryColor: Color.lerp(primaryColor, other.primaryColor, t)!,
      secondaryColor: Color.lerp(secondaryColor, other.secondaryColor, t)!,
      blue: Color.lerp(blue, other.blue, t)!,
      errorColor: Color.lerp(errorColor, other.errorColor, t)!,
      successColor: Color.lerp(successColor, other.successColor, t)!,
      warningColor: Color.lerp(warningColor, other.warningColor, t)!,
      bgColor: Color.lerp(bgColor, other.bgColor, t)!,
      bgBlack: Color.lerp(bgBlack, other.bgBlack, t)!,
      bgLightBlue: Color.lerp(bgLightBlue, other.bgLightBlue, t)!,
      bgBtnDisable: Color.lerp(bgBtnDisable, other.bgBtnDisable, t)!,
      bgLightSecondary:
          Color.lerp(bgLightSecondary, other.bgLightSecondary, t)!,
      bgLightSecondaryDark:
          Color.lerp(bgLightSecondary, other.bgLightSecondaryDark, t)!,
      borderLightBlue: Color.lerp(borderLightBlue, other.borderLightBlue, t)!,
      borderLightGray: Color.lerp(borderLightGray, other.borderLightGray, t)!,
      borderGray: Color.lerp(borderGray, other.borderGray, t)!,
      // textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      // textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      textDefault: Color.lerp(textDefault, other.textDefault, t)!,
      textWhiteLight: Color.lerp(textWhiteLight, other.textWhiteLight, t)!,
      textLightBlue: Color.lerp(textLightBlue, other.textLightBlue, t)!,
      textLightGray: Color.lerp(textLightGray, other.textLightGray, t)!,
      textGreen: Color.lerp(textGreen, other.textGreen, t)!,
    );
  }

  // Helper method for easy access
  static CustomTheme of(BuildContext context) {
    final customTheme = Theme.of(context).extension<CustomTheme>();
    if (customTheme == null) {
      // Fallback to light theme if extension not found
      return AppTheme._lightTheme;
    }
    return customTheme;
    // // return Theme.of(context).extension<CustomTheme>()!;
    // final customTheme = Theme.of(context).extension<CustomTheme>();
    // assert(
    //   customTheme != null,
    //   'CustomTheme not found in ThemeData.extensions',
    // );
    // return customTheme ?? AppTheme._lightTheme;
    // // return customTheme ??
    // //     (Theme.of(context).brightness == Brightness.light ? AppTheme._lightTheme : AppTheme._darkTheme);
  }
}
