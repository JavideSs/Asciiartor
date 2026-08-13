import "package:asciiartor/utils/theme.dart";
import "package:asciiartor/widgets/scaffold.dart";
import "package:asciiartor/controllers/controller.dart";
import "package:asciiartor/models/image.dart";

import "package:flutter/material.dart";
import "package:provider/provider.dart";

class AsciiartView extends StatelessWidget{
  AsciiartView({super.key});

  final showAsciiart = ValueNotifier<bool>(true);

  @override
  Widget build(BuildContext context){
    final theme = Theme.of(context).extension<AppThemeExtension>()!;
    final controller = context.read<Controller>();

    final args = ModalRoute.of(context)?.settings.arguments;
    final image = args is AsciiImage ? args : AsciiImage.error();

    return MyScaffold(
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: InkWell(
                onTap: () => showAsciiart.value = !showAsciiart.value,
                child: ValueListenableBuilder<bool>(
                  valueListenable: showAsciiart,
                  builder: (_, showAsciiart, __) => InteractiveViewer(
                    maxScale: 5.0,
                    child: RawImage(
                      image: showAsciiart ? image.image : image.original,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(theme.sizes.asciiArtButtonPadding),
            child: Wrap(
              spacing: theme.sizes.asciiArtButtonPadding,
              children: [
                ElevatedButton.icon(
                  onPressed: () => copyImage(context, controller, image),
                  icon: const Icon(Icons.copy),
                  label: const Text("Copy"),
                ),
                ElevatedButton.icon(
                  onPressed: () => saveImage(context, controller, image),
                  icon: const Icon(Icons.save),
                  label: const Text("Save"),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void copyImage(BuildContext context, Controller controller, AsciiImage image){
    controller.copyImage(image).then((saved){
      if (!context.mounted) return;
      final result = saved ? "ASCII art copied to clipboard" : "Error :(";
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result),
          duration: const Duration(seconds: 1),
        ),
      );
    });
  }

  void saveImage(BuildContext context, Controller controller, AsciiImage image){
    controller.saveImage(image).then((saved){
      if (!context.mounted) return;
      final result = saved ? "ASCII art image saved" : "Error :(";
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result),
          duration: const Duration(seconds: 1),
        ),
      );
    });
  }
}