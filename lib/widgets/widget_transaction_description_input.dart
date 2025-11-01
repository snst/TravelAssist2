import 'package:flutter/material.dart';

import '../transaction_list/transaction_item_page.dart';
import '../utils/globals.dart';

class WidgetTransactionDescriptionInput extends StatelessWidget {
  const WidgetTransactionDescriptionInput({
    super.key,
    required this.widget,
    required this.hintText,
  });

  final TransactionItemPage widget;
  final String hintText;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: TextEditingController()..text = widget.modifiedItem.name,
      decoration: InputDecoration(
        hintText: hintText,
        border: BorderStyles.input,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 10,
            vertical: 10,
        ),
      ),
      onChanged: (value) => widget.modifiedItem.name = value,
      autofocus: false,
    );
  }
}
