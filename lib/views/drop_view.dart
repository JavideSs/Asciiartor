import "package:Asciiartor/utils/theme.dart";
import "package:Asciiartor/widgets/scaffold.dart";
import "package:Asciiartor/controllers/controller.dart";

import "package:flutter/material.dart";
import "package:provider/provider.dart";
import "package:desktop_drop/desktop_drop.dart";
import "package:dotted_border/dotted_border.dart";

class DropArea extends StatelessWidget{
  DropArea({super.key});

  final dropHoverColor = ValueNotifier<Color>(Colors.white);

  @override
  Widget build(BuildContext context){
    final theme = Theme.of(context).extension<AppThemeExtension>()!;
    final controller = context.read<Controller>();

    return MyScaffold(
      body: Padding(
        padding: EdgeInsets.all(theme.sizes.dropAreaPadding),
        child: GestureDetector(
          onTap: () => pickAndNavigate(context, controller),
          child: DropTarget(
            onDragDone: (detail) => loadAndNavigate(context, controller, detail.files.firstOrNull),
            onDragEntered: (_) => dropHoverColor.value = Colors.white70,
            onDragExited: (_) => dropHoverColor.value = Colors.white,
            child: DottedBorder(
              borderType: BorderType.RRect,
              radius: Radius.circular(theme.sizes.dropAreaBorder),
              dashPattern: [theme.sizes.dropAreaDashPattern],
              strokeWidth: theme.sizes.dropAreaStrokeWidth,
              child: ValueListenableBuilder<Color>(
                valueListenable: dropHoverColor,
                builder: (_, dropHoverColor, __) => AnimatedContainer(
                  duration: const Duration(milliseconds: 500),
                  decoration: BoxDecoration(
                    color: dropHoverColor,
                    borderRadius: BorderRadius.circular(theme.sizes.dropAreaBorder),
                  ),
                  child: Center(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Column(
                        children: <Widget>[
                          FilledButton.icon(
                            onPressed: () => pickAndNavigate(context, controller),
                            icon: const Icon(Icons.add_photo_alternate_outlined),
                            label: const Text("CHOOSE IMAGE"),
                            style: theme.buttonStyles["dropAreaChooseButton"],
                          ),
                          SizedBox(height: theme.sizes.dropAreaSpacing),
                          Text("or drop image here",
                            style: theme.textStyles["dropAreaText"],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void showLoadingDialog(BuildContext context){
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  void pickAndNavigate(BuildContext context, Controller controller){
    controller.pickImageFile().then((imageFile){
      loadAndNavigate(context, controller, imageFile);
    });
  }

  void loadAndNavigate(BuildContext context, Controller controller, imageFile){
    if (imageFile == null) return;
    showLoadingDialog(context);
    controller.loadImage(imageFile).then((image){
      Navigator.popAndPushNamed(context, "/ascii", arguments: image);
    }).catchError((error) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Failed to load image"),
          duration: Duration(seconds: 1),
        ),
      );
    });
  }
}