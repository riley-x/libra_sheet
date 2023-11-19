import 'package:flutter/material.dart';
import 'package:libra_sheet/data/int_dollar.dart';
import 'package:libra_sheet/graphing/line.dart';
import 'package:libra_sheet/tabs/home/chart_with_title.dart';
import 'package:libra_sheet/tabs/home/home_tab.dart';

class HomeCharts extends StatelessWidget {
  const HomeCharts({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      const minChartHeight = 400.0;
      final pieChartsAligned = constraints.maxWidth > 2 * minChartHeight + 16;
      if (pieChartsAligned && constraints.maxHeight > 2 * minChartHeight + 16) {
        return const _ExpandedCharts();
      } else {
        return _ListCharts(
          chartHeight: minChartHeight,
          pieChartsAligned: pieChartsAligned,
        );
      }
    });
  }
}

/// Expands the line chart to maximum height
class _ExpandedCharts extends StatelessWidget {
  const _ExpandedCharts({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(child: _NetWorthGraph(null)),
        Container(
          height: 1,
          color: Theme.of(context).colorScheme.outlineVariant,
        ),
        Expanded(
          child: _alignedPies(null, context)[0],
        ),
      ],
    );
  }
}

/// Gives each chart a fixed height inside a list view. Used when the height of the window is not
/// sufficient to display all of the adequately.
class _ListCharts extends StatelessWidget {
  final double chartHeight;
  final bool pieChartsAligned;

  const _ListCharts({
    super.key,
    required this.chartHeight,
    required this.pieChartsAligned,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        _NetWorthGraph(chartHeight),
        const SizedBox(height: 5),
        Container(
          height: 1,
          color: Theme.of(context).colorScheme.outlineVariant,
        ),

        /// Don't add padding here or else the vertical grid lines won't be tight
        if (pieChartsAligned) ..._alignedPies(chartHeight, context),
        if (!pieChartsAligned) ..._verticalPies(chartHeight, context),
      ],
    );
  }
}

List<Widget> _alignedPies(double? height, BuildContext context) {
  return [
    Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        Expanded(child: _AssetsPie(height)),
        Container(
          width: 1,
          height: height,
          color: Theme.of(context).colorScheme.outlineVariant,
        ),
        const SizedBox(height: 10),
        Expanded(child: _LiabilitiesPie(height)),
      ],
    ),
  ];
}

List<Widget> _verticalPies(double height, BuildContext context) {
  return [
    Center(child: _AssetsPie(height)),
    Container(
      height: 1,
      color: Theme.of(context).colorScheme.outlineVariant,
    ),
    Center(child: _LiabilitiesPie(height)),
  ];
}

class _NetWorthGraph extends StatelessWidget {
  const _NetWorthGraph(
    this.height, {
    super.key,
  });

  final double? height;

  @override
  Widget build(BuildContext context) {
    return ChartWithTitle(
      height: height,
      textLeft: 'Net Worth',
      textRight: 13413418374.dollarString(),
      textStyle: Theme.of(context).textTheme.headlineMedium,
      padding: const EdgeInsets.only(top: 10),
      child: TestGraph(),
    );
  }
}

class _AssetsPie extends StatelessWidget {
  final double? height;
  const _AssetsPie(this.height, {super.key});

  @override
  Widget build(BuildContext context) {
    return ChartWithTitle(
      height: height,
      textLeft: 'Assets',
      textRight: '\$123.00',
      textStyle: Theme.of(context).textTheme.headlineMedium,
      padding: const EdgeInsets.only(top: 10),
      child: TestPie(),
    );
  }
}

class _LiabilitiesPie extends StatelessWidget {
  final double? height;
  const _LiabilitiesPie(this.height, {super.key});

  @override
  Widget build(BuildContext context) {
    return ChartWithTitle(
      height: height,
      textLeft: 'Liabilities',
      textRight: '\$123.00',
      textStyle: Theme.of(context).textTheme.headlineMedium,
      padding: const EdgeInsets.only(top: 10),
      child: TestPie(),
    );
  }
}
