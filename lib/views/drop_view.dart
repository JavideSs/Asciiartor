import "package:asciiartor/utils/theme.dart";
import "package:asciiartor/widgets/scaffold.dart";
import "package:asciiartor/widgets/loading_dialog.dart";
import "package:asciiartor/controllers/controller.dart";

import "package:flutter/material.dart";
import "package:provider/provider.dart";
import "package:desktop_drop/desktop_drop.dart";
import "package:dotted_border/dotted_border.dart";

class DropArea extends StatelessWidget{
  DropArea({super.key});

  final isDropHovering = ValueNotifier<bool>(false);

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
            onDragEntered: (_) => isDropHovering.value = true,
            onDragExited: (_) => isDropHovering.value = false,
            child: DottedBorder(
              options: theme.dottedBorderOptions,
              child: ValueListenableBuilder<bool>(
                valueListenable: isDropHovering,
                builder: (_, isDropHovering, _) => AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  decoration: BoxDecoration(
                    color: !isDropHovering ? theme.colorWidgets["dropAreaHovering"] : theme.colorWidgets["dropAreaHovering"]!.withValues(alpha: 0.7),
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

  void pickAndNavigate(BuildContext context, Controller controller){
    controller.pickImageFile().then((imageFile){
      if (!context.mounted) return;
      loadAndNavigate(context, controller, imageFile);
    });
  }

  void loadAndNavigate(BuildContext context, Controller controller, imageFile){
    if (imageFile == null) return;
    showLoadingDialog(context);
    controller.loadImage(imageFile).then((image){
      if (!context.mounted) return;
      Navigator.popAndPushNamed(context, "/ascii", arguments: image);
    }).catchError((error){
      if (!context.mounted) return;
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