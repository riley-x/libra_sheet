import 'package:flutter/material.dart';
import 'package:libra_sheet/components/transaction_filter_grid.dart';
import 'package:libra_sheet/data/account.dart';
import 'package:libra_sheet/data/test_state.dart';
import 'package:libra_sheet/tabs/transaction/transaction_tab_filters.dart';
import 'package:libra_sheet/tabs/transaction/transaction_tab_state.dart';
import 'package:provider/provider.dart';

class TransactionTab extends StatelessWidget {
  const TransactionTab({super.key});

  @override
  Widget build(BuildContext context) {
    final accounts = context.select<LibraAppState, List<Account>>((it) => it.accounts);

    return ChangeNotifierProvider(
      create: (context) => TransactionTabState(accounts),
      child: const _TransactionTab(),
    );
  }
}

class _TransactionTab extends StatelessWidget {
  const _TransactionTab({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<TransactionTabState>();
    return Row(
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 10, left: 10),
            child: Scaffold(
              body: TransactionGrid(
                state.transactions,
                maxRowsForName: 3,
                fixedColumns: 1,
              ),
              floatingActionButton: FloatingActionButton(
                onPressed: () {}, // TODO
                child: const Icon(Icons.add),
              ),
            ),
          ),
        ),

        ///
        const SizedBox(width: 10),
        Container(
          width: 1,
          color: Theme.of(context).colorScheme.outlineVariant,
        ),
        const SizedBox(width: 10),

        ///
        Expanded(child: TransactionTabFilters()),
        const SizedBox(width: 10),
      ],
    );
  }
}
