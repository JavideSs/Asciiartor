import "package:flutter/material.dart";

void showLoadingDialog(BuildContext context){
  showDialog(
    context: context,
    barrierDismissible: false,
    useSafeArea: true,
    builder: (_) => const Center(
      child: CircularProgressIndicator(),
    ),
  );
}