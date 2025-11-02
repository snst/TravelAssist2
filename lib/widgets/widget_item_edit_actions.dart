import 'package:flutter/material.dart';

import '../widgets/widget_confirm_dialog.dart';

class WidgetItemEditActions extends StatelessWidget {
  const WidgetItemEditActions({super.key, required this.onSave, this.onDelete, this.prependWidget});

  final Function onSave;
  final Function? onDelete;
  final Widget? prependWidget;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (prependWidget != null) prependWidget!,
        const Spacer(),
        ElevatedButton(
          child: const Text('Cancel'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),

        if (onDelete != null)
          ElevatedButton(
            child: const Text('Delete'),
            onPressed: () {
              showConfirmationDialog(
                context: context,
                title: 'Confirm Delete',
                text: 'Are you sure you want to delete this item?',
                onConfirm: () {
                  onDelete!();
                  //getPackingList(context).delete(widget.item!);
                  Navigator.of(context).pop();
                  //Navigator.of(context).popUntil((route) => route.isFirst);
                },
              );
            },
          ),

        ElevatedButton(
          child: const Text('Save'),
          onPressed: () {
            if (onSave()) {
              Navigator.of(context).pop();
            }
          },
        ),

      ],
    );
  }
}
