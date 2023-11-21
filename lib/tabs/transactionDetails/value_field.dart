import 'package:flutter/material.dart';
import 'package:libra_sheet/components/libra_text_field.dart';
import 'package:libra_sheet/data/int_dollar.dart';

/// Text field for
class ValueField extends StatelessWidget {
  const ValueField({
    super.key,
    this.formFieldKey,
    this.initial,
    this.onSave,
    this.onChanged,
  });

  final int? initial;
  final Function(int)? onSave;
  final Function(int?)? onChanged;
  final Key? formFieldKey;

  @override
  Widget build(BuildContext context) {
    return LibraTextFormField(
      formFieldKey: formFieldKey,
      initial: initial?.dollarString(dollarSign: false),
      validator: (String? text) {
        if (text == null || text.isEmpty) return ''; // No message to not take up space
        final val = text.toIntDollar();
        if (val == null) return ''; // No message to not take up space
        return null;
      },
      onChanged: (onChanged == null) ? null : (it) => onChanged!.call(it?.toIntDollar()),
      onSave: (it) => onSave?.call(it?.toIntDollar() ?? 0),
    );
  }
}
