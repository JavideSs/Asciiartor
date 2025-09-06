import "package:Asciiartor/utils/theme.dart";
import "package:Asciiartor/views/drop_view.dart";
import "package:Asciiartor/views/asciiart_view.dart";
import "package:Asciiartor/controllers/controller.dart";

import "package:flutter/material.dart";
import "package:provider/provider.dart";

void main(){
  runApp(
    ChangeNotifierProvider(
      create: (_) => Controller(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget{
  const MyApp({super.key});

  @override
  Widget build(BuildContext context){
    return MaterialApp(
      title: "Asciiartor",
      theme: AppTheme.original(context).toThemeData(),
      initialRoute: "/",
      routes: {
        "/": (context) => DropArea(),
        "/ascii": (context) => AsciiartView(),
      },
    );
  }
}