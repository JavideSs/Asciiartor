import "package:Asciiartor/utils/theme.dart";

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
            const Text("Asciiartor"),
            SizedBox(height: theme.sizes.appBarSpacing),
            Text("Convert your images to ASCII art",
              style: theme.textStyles["appBarSubtitle"],
            ),
          ],
        ),
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