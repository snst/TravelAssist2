import 'package:flutter/material.dart';

import '../utils/globals.dart';
import '../widgets/widget_confirm_dialog.dart';
import '../widgets/widget_icon_button.dart';
import '../widgets/widget_layout.dart';

class WidgetItemEditActions extends StatelessWidget {
  const WidgetItemEditActions({
    super.key,
    required this.onSave,
    this.onDelete,
    this.leftWidget = const [],
    this.rightWidget = const [],
    this.cancel = false,
    this.createReplacementPage,
  });

  final Function onSave;
  final Function? onDelete;
  final List<Widget> leftWidget;
  final List<Widget> rightWidget;
  final bool cancel;
  final Function? createReplacementPage;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: Row(
        children:
            leftWidget +
            [
              Spacer(),
              if (cancel)
                WidgetIconButton(
                  icon: MyIcons.cancel,
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              HSpace(),

              if (onDelete != null)
                WidgetIconButton(
                  icon: MyIcons.delete,
                  onPressed: () {
                    showConfirmationDialog(
                      context: context,
                      title: 'Confirm Delete',
                      text: 'Are you sure you want to delete this item?',
                      onConfirm: () {
                        onDelete!();
                        Navigator.of(context).pop();
                      },
                    );
                  },
                ),
              HSpace(),
              WidgetIconButton(
                icon: MyIcons.save,
                onPressed: () {
                  if (onSave()) {
                    if (createReplacementPage != null) {
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder: (context) => createReplacementPage!(),
                        ),
                      );
                    } else {
                      Navigator.of(context).pop();
                    }
                  }
                },
              ),
            ] +
            rightWidget,
      ),
    );
  }
}
