import "package:asciiartor/utils/theme.dart";
import "package:asciiartor/widgets/scaffold.dart";
import "package:asciiartor/widgets/loading_dialog.dart";
import "package:asciiartor/controllers/controller.dart";
import "package:asciiartor/models/image.dart";

import "package:flutter/material.dart";
import "package:provider/provider.dart";

class AsciiartView extends StatefulWidget{
  const AsciiartView({super.key});

  @override
  State<AsciiartView> createState() => _AsciiartViewState();
}

class _AsciiartViewState extends State<AsciiartView>{
  final showAsciiart = ValueNotifier<bool>(true);

  AsciiImageStyle selectedStyle = AsciiImageStyle.classic;
  int? selectedResolution;

  @override
  void dispose(){
    showAsciiart.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context){
    final theme = Theme.of(context).extension<AppThemeExtension>()!;
    final controller = context.read<Controller>();

    final args = ModalRoute.of(context)?.settings.arguments;
    final image = args is AsciiImage ? args : AsciiImage.error();

    return MyScaffold(
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(theme.sizes.asciiArtConfigPadding),
            child: Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: theme.sizes.asciiArtConfigPadding,
              children: [
                SizedBox(
                  width: theme.sizes.asciiArtConfigWidth,
                  child: DropdownButton<AsciiImageStyle>(
                    onChanged: (newStyle) => configAsciiart(context, image, newStyle:newStyle),
                    value: selectedStyle,
                    items: AsciiImageStyle.values.map((style){
                      return DropdownMenuItem<AsciiImageStyle>(
                        value: style,
                        child: Text(style.name),
                      );
                    }).toList(),
                    isExpanded: true,
                    dropdownColor: Colors.transparent,
                    focusColor: Colors.transparent,
                    style: theme.textStyles["configAsciiartText"],
                  ),
                ),
                SizedBox(
                  width: theme.sizes.asciiArtConfigWidth,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Transform.translate(
                        offset: const Offset(20, 0),
                        child: Text("Resolution ${selectedResolution ?? image.resolution}%",
                          style: theme.textStyles["configAsciiartText"]
                        ),
                      ),
                      SliderTheme(
                        data: theme.sliderThemeData,
                        child: Slider(
                          onChanged: (newResolution) {setState((){selectedResolution = newResolution.round();});},
                          onChangeEnd: (newResolution) => configAsciiart(context, image, newResolution:newResolution.round()),
                          value: (selectedResolution ?? image.resolution).toDouble(),
                          min: 3.0,
                          max: 30.0,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Center(
              child: InkWell(
                onTap: () => showAsciiart.value = !showAsciiart.value,
                onLongPress: (){
                  showGeneralDialog(
                    context: context,
                    barrierLabel: "Asciiart",
                    barrierDismissible: true,
                    pageBuilder: (_, _, _) => Stack(
                      children: [
                        SafeArea(
                          child: Align(
                            alignment: Alignment.topRight,
                            child: IconButton(
                              onPressed: () => Navigator.of(context).pop(),
                              icon: Icon(Icons.close, color: Colors.white)
                            ),
                          ),
                        ),
                        Center(
                          child: InteractiveViewer(
                            maxScale: 5.0,
                            child: ValueListenableBuilder<bool>(
                              valueListenable: showAsciiart,
                              builder: (_, showAsciiart, _) => RawImage(
                                image: showAsciiart ? image.image : image.original,
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
                child: ValueListenableBuilder<bool>(
                  valueListenable: showAsciiart,
                  builder: (_, showAsciiart, _) => InteractiveViewer(
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
            padding: EdgeInsets.all(theme.sizes.asciiArtSavePadding),
            child: Wrap(
              spacing: theme.sizes.asciiArtSavePadding,
              children: [
                ElevatedButton.icon(
                  onPressed: () => copyImage(context, controller, image),
                  icon: const Icon(Icons.copy),
                  label: const Text("Copy"),
                  style: theme.buttonStyles["asciiArtSaveButton"],
                ),
                ElevatedButton.icon(
                  onPressed: () => saveImage(context, controller, image),
                  icon: const Icon(Icons.save),
                  label: const Text("Save"),
                  style: theme.buttonStyles["asciiArtSaveButton"],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> configAsciiart(BuildContext context, AsciiImage image, {AsciiImageStyle? newStyle, int? newResolution}) async{
    if ((newStyle == null || newStyle == image.style) && (newResolution == null || newResolution == image.resolution)) return;

    showLoadingDialog(context);
    await image.config(style: newStyle, resolution:newResolution);
    if (!context.mounted) return;
    Navigator.pop(context);

    setState(()
      {
        selectedStyle = image.style;
        selectedResolution = image.resolution;
      }
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