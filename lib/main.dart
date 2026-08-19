import "package:asciiartor/utils/theme.dart";
import "package:asciiartor/views/drop_view.dart";
import "package:asciiartor/views/asciiart_view.dart";
import "package:asciiartor/controllers/controller.dart";

import "package:flutter/material.dart";
import "package:provider/provider.dart";

void main(){
  runApp(
    Provider(
      create: (_) => Controller(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget{
  const MyApp({super.key});

  @override
  Widget build(BuildContext context){
    return ValueListenableBuilder<AppColorsTheme>(
      valueListenable: AppTheme.modeNotifier,
      builder: (context, mode, _){
        return MaterialApp(
          title: "Asciiartor",
          theme: AppTheme.getThemeData(context),
          initialRoute: "/",
          routes: {
            "/": (context) => DropArea(),
            "/ascii": (context) => AsciiartView(),
          },
        );
      },
    );
  }
}