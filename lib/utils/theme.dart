import "package:asciiartor/utils/responsive.dart";

import "package:flutter/material.dart";
import "package:dotted_border/dotted_border.dart";

class AppSizes{
  final double appBarTitle;
  final double appBarSubtitle;
  final double appBarSpacing;
  late double appBarHeight;

  final double bottomAppBarText;
  late double bottomAppBarHeight;

  final double colorsThemeSpacing;
  final double dropAreaPadding;
  final double dropAreaSpacing;

  final double asciiArtConfigPadding;
  final double asciiArtConfigWidth;

  final double asciiArtSavePadding;

  final double dropAreaDashPattern;
  final double dropAreaStrokeWidth;
  final double dropAreaBorder;
  final double dropAreaChoose;
  final double dropAreaButtonPadding;
  final double dropAreaText;

  AppSizes(Responsive responsive) :
    appBarTitle = responsive.sr(10),
    appBarSubtitle = responsive.sr(15),
    appBarSpacing = responsive.sr(5),

    bottomAppBarText = responsive.sr(10),

    colorsThemeSpacing = responsive.sr(5),

    dropAreaPadding = responsive.sr(30),
    dropAreaSpacing = responsive.sr(10),

    asciiArtConfigPadding = responsive.sr(20),
    asciiArtConfigWidth = responsive.sr(150),

    asciiArtSavePadding = responsive.sr(10),

    dropAreaDashPattern = responsive.sr(20),
    dropAreaStrokeWidth = responsive.sr(10),
    dropAreaBorder = responsive.sr(50),
    dropAreaChoose = responsive.sr(15),
    dropAreaButtonPadding = responsive.sr(25),
    dropAreaText = responsive.sr(15)
  {
    final lineHeightFactorFiraMono = (TextPainter(
      text: TextSpan(text: "X", style: TextStyle(fontSize: 100, fontFamily: "FiraMono", fontWeight: FontWeight.bold)),
      textDirection: TextDirection.ltr,
    )..layout()).height / 100;
    final lineHeightFactor = (TextPainter(
      text: TextSpan(text: "X", style: TextStyle(fontSize: 100, fontWeight: FontWeight.normal)),
      textDirection: TextDirection.ltr,
    )..layout()).height / 100;
    final textScale = MediaQuery.textScalerOf(responsive.context).scale(1.0);

    final titleHeight = appBarTitle * 6 * lineHeightFactorFiraMono * textScale;
    final subtitleHeight = appBarSubtitle * lineHeightFactor * textScale;
    final footnoteHeight = bottomAppBarText * lineHeightFactor * textScale;

    appBarHeight = titleHeight + subtitleHeight + (appBarSpacing * 4);
    bottomAppBarHeight = footnoteHeight + responsive.sr(10);
  }
}

enum AppColorsTheme{
  original,
  dark,
  light,
}

class AppColors{
  final Color primary;
  final Color secondary;
  final Color accent;
  final Color complementary;

  const AppColors({
    required this.primary,
    required this.secondary,
    required this.accent,
    required this.complementary,
  });
}

class AppTheme{
  final AppSizes sizes;
  final AppColors colors;

  static final ValueNotifier<AppColorsTheme> modeNotifier = ValueNotifier<AppColorsTheme>(AppColorsTheme.original);

  AppTheme(BuildContext context, {
    required this.colors,
  }) :
    sizes = AppSizes(Responsive(context));

  ThemeData toThemeData() => ThemeData(
    scaffoldBackgroundColor: colors.primary,

    appBarTheme: AppBarTheme(
      centerTitle: true,
      backgroundColor: colors.primary,
      foregroundColor: colors.secondary,
      toolbarHeight: sizes.appBarHeight,
    ),

    bottomAppBarTheme: BottomAppBarThemeData(
      padding: EdgeInsets.zero,
      color: colors.accent,
      height: sizes.bottomAppBarHeight,
    ),

    extensions: [
      AppThemeExtension(
        sizes: sizes,
        colors: colors,

        textStyles: {
          "appBarTitle": TextStyle(
            color: colors.secondary,
            fontSize: sizes.appBarTitle,
            fontFamily: "FiraMono",
            fontWeight: FontWeight.bold,
          ),
          "appBarSubtitle": TextStyle(
            color: colors.secondary,
            fontSize: sizes.appBarSubtitle,
            fontWeight: FontWeight.normal,
          ),
          "bottomAppBarText": TextStyle(
            color: colors.secondary,
            fontSize: sizes.bottomAppBarText,
          ),
          "dropAreaText": TextStyle(
            color: colors.accent,
            fontSize: sizes.dropAreaText,
          ),
          "configAsciiartText": TextStyle(
            color: colors.secondary,
          ),
        },
        buttonStyles: {
          "dropAreaChooseButton": FilledButton.styleFrom(
            backgroundColor: colors.primary,
            foregroundColor: colors.secondary,
            padding: EdgeInsets.all(sizes.dropAreaButtonPadding),
            textStyle: TextStyle(
              fontSize: sizes.dropAreaChoose,
            ),

          ),
          "asciiArtSaveButton": FilledButton.styleFrom(
            backgroundColor: colors.complementary,
            foregroundColor: colors.primary,
          ),
        },
        colorWidgets: {
          "bottomAppBar": colors.accent,
          "colorsThemeIcon": colors.secondary,
          "dropAreaHovering": colors.complementary,
        },

        dottedBorderOptions: RoundedRectDottedBorderOptions(
          color: colors.accent,
          radius: Radius.circular(sizes.dropAreaBorder),
          dashPattern: [sizes.dropAreaDashPattern],
          strokeWidth: sizes.dropAreaStrokeWidth,
        ),
        sliderThemeData: SliderThemeData(
          activeTrackColor: colors.secondary,
          inactiveTrackColor: colors.secondary.withValues(alpha: 0.3),
          thumbColor: colors.complementary,
          overlayColor: colors.complementary.withValues(alpha: 0.2),
          trackHeight: 4,
          thumbShape: RoundSliderThumbShape(
            enabledThumbRadius: 5,
          ),
          overlayShape: RoundSliderOverlayShape(
            overlayRadius: 6,
          ),
        ),
      ),
    ],
  );

  static AppTheme original(BuildContext context) => AppTheme(
    context,
    colors: AppColors(
      primary: Colors.purple[900]!,
      secondary: Colors.white,
      accent: Colors.black,
      complementary: Colors.white,
    ),
  );

  static AppTheme dark(BuildContext context) => AppTheme(
    context,
    colors: AppColors(
      primary: Color(0xFF121212),
      secondary: Colors.white,
      accent: Color(0xFF2C2C2C),
      complementary: Color(0xFF585858),
    ),
  );

  static AppTheme light(BuildContext context) => AppTheme(
    context,
    colors: AppColors(
      primary: Color(0xFFFFFFFF),
      secondary: Colors.black,
      accent: Color(0xFFE0E0E0),
      complementary: Color(0xFFA8A8A8),
    ),
  );

  static ThemeData getThemeData(BuildContext context){
    switch (modeNotifier.value){
      case AppColorsTheme.original:
        return AppTheme.original(context).toThemeData();
      case AppColorsTheme.dark:
        return AppTheme.dark(context).toThemeData();
      case AppColorsTheme.light:
        return AppTheme.light(context).toThemeData();
    }
  }
}

@immutable
class AppThemeExtension extends ThemeExtension<AppThemeExtension> {
  final AppSizes sizes;
  final AppColors colors;

  final Map<String, TextStyle> textStyles;
  final Map<String, ButtonStyle> buttonStyles;
  final Map<String, Color> colorWidgets;

  final RoundedRectDottedBorderOptions dottedBorderOptions;
  final SliderThemeData sliderThemeData;

  const AppThemeExtension({
    required this.sizes,
    required this.colors,

    required this.textStyles,
    required this.buttonStyles,
    required this.colorWidgets,

    required this.dottedBorderOptions,
    required this.sliderThemeData,
  });

  @override
  AppThemeExtension copyWith({
    AppSizes? sizes,
    AppColors? colors,

    Map<String, TextStyle>? textStyles,
    Map<String, ButtonStyle>? buttonStyles,
    Map<String, Color>? colorWidgets,

    RoundedRectDottedBorderOptions? dottedBorderOptions,
    SliderThemeData? sliderThemeData,
  }){
    return AppThemeExtension(
      sizes: sizes ?? this.sizes,
      colors: colors ?? this.colors,
      textStyles: textStyles ?? this.textStyles,
      buttonStyles: buttonStyles ?? this.buttonStyles,
      colorWidgets: colorWidgets ?? this.colorWidgets,
      dottedBorderOptions: dottedBorderOptions ?? this.dottedBorderOptions,
      sliderThemeData: sliderThemeData ?? this.sliderThemeData,
    );
  }

  @override
  AppThemeExtension lerp(ThemeExtension<AppThemeExtension>? other, double t){
    if (other is! AppThemeExtension) return this;
    return t < 0.5 ? this : other;
  }
}