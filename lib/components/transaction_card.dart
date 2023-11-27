import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:libra_sheet/data/int_dollar.dart';
import 'package:libra_sheet/data/objects/transaction.dart';

class TransactionCard extends StatelessWidget {
  const TransactionCard({
    super.key,
    required this.trans,
    this.maxRowsForName = 1,
    this.onSelect,
    this.margin,
  });

  final Transaction trans;
  final int? maxRowsForName;
  final Function(Transaction)? onSelect;
  final EdgeInsets? margin;

  static const double colorIndicatorWidth = 6;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: margin ?? const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: () => onSelect?.call(trans),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
          child: Stack(
            children: [
              Positioned(
                left: 0,
                width: colorIndicatorWidth,
                top: 0,
                bottom: 0,
                child: Container(color: trans.category?.color ?? Colors.transparent),
              ),
              Padding(
                padding: const EdgeInsets.only(left: colorIndicatorWidth + 10),
                child: Column(
                  children: [
                    _TextElements(
                      trans: trans,
                      maxRowsForName: maxRowsForName,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

final _dtFormat = DateFormat("M/d/yy");

class _TextElements extends StatelessWidget {
  const _TextElements({
    super.key,
    required this.trans,
    required this.maxRowsForName,
  });

  final Transaction trans;
  final int? maxRowsForName;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    var subText = '';
    if (trans.account != null) {
      subText += trans.account!.name;
    }
    if (trans.category != null) {
      if (subText.isNotEmpty) {
        subText += ', ';
      }
      subText += trans.category!.name;
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                trans.name,
                maxLines: maxRowsForName,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                subText,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.outline),
              ),
            ],
          ),
        ),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              trans.value.dollarString(),
              style: theme.textTheme.bodyMedium
                  ?.copyWith(color: (trans.value < 0) ? Colors.red : Colors.green),
            ),
            Text(
              _dtFormat.format(trans.date),
            ),
          ],
        ),
      ],
    );
  }
}
