import "package:asciiartor/utils/theme.dart";

import "package:flutter/material.dart";

class MyScaffold extends StatelessWidget{
  final Widget body;

  const MyScaffold({
    super.key,
    required this.body,
  });

  @override
  Widget build(BuildContext context){
    final theme = Theme.of(context).extension<AppThemeExtension>()!;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          children: [
            SizedBox(height: theme.sizes.appBarSpacing),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(r"""
    _             _ _            _             
   / \   ___  ___(_|_) __ _ _ __| |_ ___  _ __ 
  / _ \ / __|/ __| | |/ _` | '__| __/ _ \| '__|
 / ___ \\__ \ (__| | | (_| | |  | || (_) | |   
/_/   \_\___/\___|_|_|\__,_|_|   \__\___/|_|   
                """,
                style: theme.textStyles["appBarTitle"],
              ),
            ),
            SizedBox(height: theme.sizes.appBarSpacing),
            Text("Convert your images to ASCII art",
              style: theme.textStyles["appBarSubtitle"],
            ),
          ],
        ),
        actions: [
          ValueListenableBuilder<AppColorsTheme>(
            valueListenable: AppTheme.modeNotifier,
            builder: (context, currentMode, _) {
              return PopupMenuButton<AppColorsTheme>(
                icon: Icon(
                  switch (currentMode) {
                    AppColorsTheme.original => Icons.palette,
                    AppColorsTheme.dark => Icons.dark_mode,
                    AppColorsTheme.light => Icons.light_mode,
                  },
                  color: theme.colorWidgets["colorsThemeIcon"]
                ),
                onSelected: (AppColorsTheme newMode) {
                  AppTheme.modeNotifier.value = newMode;
                },
                itemBuilder: (BuildContext context) => <PopupMenuEntry<AppColorsTheme>>[
                  PopupMenuItem<AppColorsTheme>(
                    value: AppColorsTheme.original,
                    child: Row(
                      children: [
                        Icon(Icons.palette, color: Colors.purple[900]!),
                        SizedBox(width: theme.sizes.colorsThemeSpacing),
                        const Text("Original"),
                      ],
                    ),
                  ),
                  PopupMenuItem<AppColorsTheme>(
                    value: AppColorsTheme.dark,
                    child: Row(
                      children: [
                        Icon(Icons.dark_mode, color: Colors.black),
                        SizedBox(width: theme.sizes.colorsThemeSpacing),
                        const Text("Dark"),
                      ],
                    ),
                  ),
                  PopupMenuItem<AppColorsTheme>(
                    value: AppColorsTheme.light,
                    child: Row(
                      children: [
                        Icon(Icons.light_mode, color: Colors.orange),
                        SizedBox(width: theme.sizes.colorsThemeSpacing),
                        const Text("Light"),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
      body: body,
      bottomNavigationBar: BottomAppBar(
        child: Center(
          child: Text("Developed by @JavideSs",
            textAlign: TextAlign.center,
            style: theme.textStyles["bottomAppBarText"],
          ),
        ),
      ),
    );
  }
}