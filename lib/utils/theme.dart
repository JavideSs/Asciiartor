import "package:Asciiartor/utils/responsive.dart";

import "package:flutter/material.dart";

class AppSizes{
  final double appBarTitle;
  final double appBarSubtitle;
  final double appBarSpacing;
  late double appBarHeight;

  final double bottomAppBarText;
  late double bottomAppBarHeight;

  final double dropAreaPadding;
  final double dropAreaDashPattern;
  final double dropAreaStrokeWidth;
  final double dropAreaBorder;
  final double dropAreaChoose;
  final double dropAreaButtonPadding;
  final double dropAreaText;
  final double dropAreaSpacing;

  final double asciiArtButtonPadding;

  AppSizes(Responsive responsive) :
    appBarTitle = responsive.sr(30),
    appBarSubtitle = responsive.sr(15),
    appBarSpacing = responsive.sr(5),

    bottomAppBarText = responsive.sr(10),

    dropAreaPadding = responsive.sr(30),
    dropAreaDashPattern = responsive.sr(20),
    dropAreaStrokeWidth = responsive.sr(10),
    dropAreaBorder = responsive.sr(50),
    dropAreaChoose = responsive.sr(15),
    dropAreaButtonPadding = responsive.sr(25),
    dropAreaText = responsive.sr(15),
    dropAreaSpacing = responsive.sr(10),

    asciiArtButtonPadding = responsive.sr(10)
  {
    appBarHeight = appBarTitle + appBarSubtitle + appBarSpacing + responsive.sr(50);

    bottomAppBarHeight = bottomAppBarText + 30;
  }
}

class AppTheme{
  final AppSizes sizes;
  final Color primaryColor;
  final Color secondaryColor;
  final Color accentColor;

  AppTheme(context, {
    required this.primaryColor,
    required this.secondaryColor,
    required this.accentColor
  }) :
    sizes = AppSizes(Responsive(context));

  ThemeData toThemeData() => ThemeData(
    scaffoldBackgroundColor: primaryColor,

    appBarTheme: AppBarTheme(
      backgroundColor: primaryColor,
      foregroundColor: secondaryColor,
      toolbarHeight: sizes.appBarHeight,
      centerTitle: true,
      titleTextStyle: TextStyle(
        color: secondaryColor,
        fontSize: sizes.appBarTitle,
        fontWeight: FontWeight.bold,
      ),
    ),

    bottomAppBarTheme: BottomAppBarTheme(
      color: accentColor,
      height: sizes.bottomAppBarHeight,
    ),

    extensions: [
      AppThemeExtension(
        sizes: sizes,
        textStyles: {
          "appBarSubtitle": TextStyle(
            fontSize: sizes.appBarSubtitle,
            fontWeight: FontWeight.normal,
          ),
          "bottomAppBarText": TextStyle(
            color: secondaryColor,
            fontSize: sizes.bottomAppBarText,
          ),
          "dropAreaText": TextStyle(
            color: accentColor,
            fontSize: sizes.dropAreaText,
          ),
        },
        buttonStyles: {
          "dropAreaChooseButton": FilledButton.styleFrom(
            textStyle: TextStyle(
              color: secondaryColor,
              fontSize: sizes.dropAreaChoose,
            ),
            padding: EdgeInsets.symmetric(
              horizontal: sizes.dropAreaButtonPadding,
              vertical: sizes.dropAreaButtonPadding,
            ),
          ),
        },
      ),
    ],
  );

  static AppTheme original(BuildContext context) => AppTheme(
    context,
    primaryColor: Colors.purple[900]!,
    secondaryColor: Colors.white,
    accentColor: Colors.black,
  );
}

@immutable
class AppThemeExtension extends ThemeExtension<AppThemeExtension>{
  final AppSizes sizes;
  final Map<String, TextStyle> textStyles;
  final Map<String, ButtonStyle> buttonStyles;

  const AppThemeExtension({
      required this.sizes,
      required this.textStyles,
      required this.buttonStyles,
    });

  @override
  AppThemeExtension copyWith({
    AppSizes? sizes,
    Map<String, TextStyle>? textStyles,
    Map<String, ButtonStyle>? buttonStyles,
  }){
    return AppThemeExtension(
      sizes: sizes ?? this.sizes,
      textStyles: textStyles ?? this.textStyles,
      buttonStyles: buttonStyles ?? this.buttonStyles,
    );
  }

  @override
  AppThemeExtension lerp(ThemeExtension<AppThemeExtension>? other, double t){
    if (other is! AppThemeExtension) return this;
    return t < 0.5 ? this : other;
  }
}