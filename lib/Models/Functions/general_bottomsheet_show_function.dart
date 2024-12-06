import 'package:bottom_sheet/bottom_sheet.dart';
import 'package:flutter/material.dart';

class GeneralBottomsheetShowFunction {
  static Future<void> showScrollableGeneralBottomsheet({
    required Widget Function(BuildContext, ScrollController) widgetBuilder,
    required BuildContext context,
    required double initHeight,
    Color color = Colors.white,
  }) async {
    await showFlexibleBottomSheet(
      minHeight: 0,
      initHeight: initHeight,
      maxHeight: 1,
      context: context,
      builder: (context, scrollController, bottomSheet) =>
          widgetBuilder(context, scrollController),
      duration: const Duration(milliseconds: 500),
      bottomSheetColor: color,
      bottomSheetBorderRadius: const BorderRadius.only(
        topLeft: Radius.circular(20),
        topRight: Radius.circular(20),
      ),
      isSafeArea: true,
    );
  }
}
