import 'package:flutter/material.dart';
import 'package:libra_sheet/components/common_back_bar.dart';
import 'package:libra_sheet/components/transaction_filters/transaction_filter_grid.dart';
import 'package:libra_sheet/data/app_state/libra_app_state.dart';
import 'package:libra_sheet/data/objects/category.dart';
import 'package:libra_sheet/data/time_value.dart';
import 'package:libra_sheet/graphing/category_heat_map.dart';
import 'package:libra_sheet/graphing/date_time_graph.dart';
import 'package:libra_sheet/tabs/category/category_tab_state.dart';
import 'package:libra_sheet/tabs/home/chart_with_title.dart';
import 'package:libra_sheet/data/int_dollar.dart';
import 'package:libra_sheet/components/transaction_filters/transaction_filter_state.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class CategoryFocusScreen extends StatelessWidget {
  const CategoryFocusScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<CategoryTabState>();
    final category = state.categoriesFocused.lastOrNull;
    if (category == null) return const Placeholder();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 5),
        CommonBackBar(
          leftText: category.name,
          rightText: state.aggregateValues[category.key]?.abs().dollarString() ?? '',
          onBack: () {
            context.read<CategoryTabState>().clearFocus();
          },
        ),
        Expanded(child: _Body(category: category)),
      ],
    );
  }
}

class _Body extends StatelessWidget {
  const _Body({
    super.key,
    required this.category,
  });

  final Category category;

  @override
  Widget build(BuildContext context) {
    final state = context.watch<CategoryTabState>();
    return Row(
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(left: 10), // this offsets the title
            child: TransactionFilterGrid(
              padding: const EdgeInsets.only(right: 10),
              initialFilters: TransactionFilters(
                categories: CategoryTristateMap({category}),
                accounts: state.accounts,
              ),
              fixedColumns: 1,
              maxRowsForName: 3,
              onSelect: context.read<LibraAppState>().focusTransaction,
            ),
          ),
        ),
        Container(
          width: 1,
          color: Theme.of(context).colorScheme.outlineVariant,
        ),
        Expanded(
          child: Column(
            children: [
              /// this empircally matches the extra height caused by the icon button in the transaction filter grid
              const SizedBox(height: 7),
              Expanded(
                child: ChartWithTitle(
                  textLeft: 'Category History',
                  textStyle: Theme.of(context).textTheme.headlineSmall,
                  child: DateTimeGraph([
                    LineSeries<TimeIntValue, DateTime>(
                      animationDuration: 300,
                      dataSource: state.categoryFocusedHistory,
                      xValueMapper: (TimeIntValue sales, _) => sales.time,
                      yValueMapper: (TimeIntValue sales, _) => sales.value.asDollarDouble(),
                    ),
                  ]),
                ),
              ),
              if (state.aggregateValues[category.key] != state.individualValues[category.key]) ...[
                const SizedBox(height: 5),
                Container(
                  height: 1,
                  color: Theme.of(context).colorScheme.outlineVariant,
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: CategoryHeatMap(
                      categories: category.subCats + [category],
                      individualValues: state.individualValues,
                      aggregateValues: state.individualValues,
                      // individual here because the focus screen is always nested categories
                      onSelect: (it) {
                        if (it != category) context.read<CategoryTabState>().focusCategory(it);
                      },
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
