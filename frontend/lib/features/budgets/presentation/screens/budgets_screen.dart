import 'package:budgetting_frontend/core/utils/colour_utils.dart';
import 'package:budgetting_frontend/features/budgets/domain/models/budget_models.dart';
import 'package:budgetting_frontend/features/budgets/presentation/bloc/budgets_bloc.dart';
import 'package:budgetting_frontend/features/budgets/presentation/widgets/budget_alert_card.dart';
import 'package:budgetting_frontend/features/budgets/presentation/widgets/budget_card.dart';
import 'package:budgetting_frontend/features/budgets/presentation/widgets/budget_chart.dart';
import 'package:budgetting_frontend/features/budgets/presentation/widgets/budget_summary_card.dart';
import 'package:budgetting_frontend/features/budgets/presentation/widgets/set_budget_sheet.dart';
import 'package:budgetting_frontend/features/budgets/presentation/widgets/weekly_budget_chart.dart';
import 'package:budgetting_frontend/features/dashboard/presentation/widgets/app_footer.dart';
import 'package:budgetting_frontend/features/dashboard/presentation/widgets/app_header.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Budgets screen — monthly overview with weekly breakdown chart.
class BudgetsScreen extends StatelessWidget {
  /// Create a [BudgetsScreen].
  const BudgetsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    return BlocProvider(
      create: (_) => BudgetsBloc(year: now.year, month: now.month)
        ..add(BudgetsLoadRequested(year: now.year, month: now.month)),
      child: const _BudgetsView(),
    );
  }
}

class _BudgetsView extends StatefulWidget {
  const _BudgetsView();

  @override
  State<_BudgetsView> createState() => _BudgetsViewState();
}

class _BudgetsViewState extends State<_BudgetsView> {
  Future<void> _openSetBudgetSheet(
    BuildContext context,
    int year,
    int month,
  ) async {
    final saved = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SetBudgetSheet(year: year, month: month),
    );
    if ((saved ?? false) && context.mounted) {
      context
          .read<BudgetsBloc>()
          .add(BudgetsLoadRequested(year: year, month: month));
    }
  }

  Future<void> _openEditBudgetSheet(
    BuildContext context,
    int year,
    int month,
    BudgetItemModel budget,
  ) async {
    final saved = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SetBudgetSheet(
        year: year,
        month: month,
        initialCategoryId: budget.categoryId,
        initialAmount: budget.goalAmount,
      ),
    );
    if ((saved ?? false) && context.mounted) {
      context
          .read<BudgetsBloc>()
          .add(BudgetsLoadRequested(year: year, month: month));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BudgetsBloc, BudgetsState>(
      builder: (context, state) {
        return Scaffold(
          appBar: AppHeader(title: 'Budgets', onMenuPressed: () {}),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => _openSetBudgetSheet(
              context,
              state.selectedYear,
              state.selectedMonth,
            ),
            icon: const Icon(Icons.add),
            label: const Text('Add Budget'),
          ),
          body: _buildBody(context, state),
          bottomNavigationBar: const AppFooter(activeIndex: 2),
        );
      },
    );
  }

  Widget _buildBody(BuildContext context, BudgetsState state) {
    if ((state.status == BudgetsStatus.loading ||
            state.status == BudgetsStatus.initial) &&
        state.summary == null) {
      return const Center(child: CircularProgressIndicator());
    }
    if (state.status == BudgetsStatus.failure && state.summary == null) {
      return _ErrorView(
        message: state.errorMessage ?? 'Something went wrong.',
        onRetry: () => context.read<BudgetsBloc>().add(
              BudgetsLoadRequested(
                year: state.selectedYear,
                month: state.selectedMonth,
              ),
            ),
      );
    }
    return RefreshIndicator(
      onRefresh: () async => context.read<BudgetsBloc>().add(
            BudgetsLoadRequested(
              year: state.selectedYear,
              month: state.selectedMonth,
            ),
          ),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _MonthNavigator(
              year: state.selectedYear,
              month: state.selectedMonth,
            ),
            const SizedBox(height: 12),
            if (state.summary != null) ...[
              _SummarySection(summary: state.summary!),
              const SizedBox(height: 16),
              _AlertSection(summary: state.summary!),
              const SizedBox(height: 16),
              _WeeklySection(
                summary: state.summary!,
                year: state.selectedYear,
                month: state.selectedMonth,
              ),
              const SizedBox(height: 16),
              if (state.summary!.budgets.isEmpty)
                const _EmptyState()
              else
                _CategorySection(
                  summary: state.summary!,
                  onEdit: (BudgetItemModel b) => _openEditBudgetSheet(
                    context,
                    state.selectedYear,
                    state.selectedMonth,
                    b,
                  ),
                ),
            ] else if (state.status == BudgetsStatus.loaded) ...[
              const _EmptyState(),
            ],
          ],
        ),
      ),
    );
  }
}

// ── Month navigator ────────────────────────────────────────────────────────

class _MonthNavigator extends StatelessWidget {
  const _MonthNavigator({required this.year, required this.month});
  final int year;
  final int month;

  static const _names = [
    '',
    'January', 'February', 'March', 'April',
    'May', 'June', 'July', 'August',
    'September', 'October', 'November', 'December',
  ];

  void _navigate(BuildContext context, int newYear, int newMonth) =>
      context.read<BudgetsBloc>().add(
            BudgetsLoadRequested(year: newYear, month: newMonth),
          );

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final canGoNext = !(year == now.year && month == now.month);

    var prevMonth = month - 1;
    var prevYear = year;
    if (prevMonth < 1) {
      prevMonth = 12;
      prevYear--;
    }
    var nextMonth = month + 1;
    var nextYear = year;
    if (nextMonth > 12) {
      nextMonth = 1;
      nextYear++;
    }

    return Row(
      children: [
        IconButton(
          icon: const Icon(Icons.chevron_left),
          tooltip: '${_names[prevMonth]} $prevYear',
          onPressed: () => _navigate(context, prevYear, prevMonth),
        ),
        Expanded(
          child: Text(
            '${_names[month]} $year',
            textAlign: TextAlign.center,
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(fontWeight: FontWeight.w600),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.chevron_right),
          tooltip: canGoNext ? '${_names[nextMonth]} $nextYear' : null,
          onPressed: canGoNext
              ? () => _navigate(context, nextYear, nextMonth)
              : null,
        ),
      ],
    );
  }
}

// ── Summary section ────────────────────────────────────────────────────────

class _SummarySection extends StatelessWidget {
  const _SummarySection({required this.summary});
  final BudgetSummaryModel summary;

  @override
  Widget build(BuildContext context) => BudgetSummaryCard(
        totalBudget: summary.totalGoal,
        totalSpent: summary.totalSpent,
        monthName: summary.monthName,
        year: summary.year,
        month: summary.month ?? DateTime.now().month,
      );
}

// ── Weekly chart section ───────────────────────────────────────────────────

class _WeeklySection extends StatelessWidget {
  const _WeeklySection({
    required this.summary,
    required this.year,
    required this.month,
  });
  final BudgetSummaryModel summary;
  final int year;
  final int month;

  @override
  Widget build(BuildContext context) {
    final weeks = summary.weeklyBreakdown;
    final hasSpending = weeks?.any((w) => w.spent > 0) ?? false;
    if (weeks == null || weeks.isEmpty || !hasSpending) {
      return const SizedBox.shrink();
    }
    return WeeklyBudgetChart(
      weeks: weeks,
      totalGoal: summary.totalGoal,
      year: year,
      month: month,
    );
  }
}

// ── Alert section ──────────────────────────────────────────────────────────

class _AlertSection extends StatelessWidget {
  const _AlertSection({required this.summary});
  final BudgetSummaryModel summary;

  @override
  Widget build(BuildContext context) {
    if (summary.budgets.isEmpty) return const SizedBox.shrink();

    // Find the category with the highest usage percentage
    final alert = summary.budgets.reduce(
      (a, b) => b.percentage > a.percentage ? b : a,
    );
    // Only show if close to or over limit (>= 75 %)
    if (alert.percentage < 75) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Budget Alert',
          style: Theme.of(context)
              .textTheme
              .titleSmall
              ?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        BudgetAlertCard(
          categoryName: alert.name,
          allocatedAmount: alert.goalAmount,
          currentAmount: alert.spentAmount,
          percentage: alert.percentage,
          categoryColour: alert.colourValue,
        ),
      ],
    );
  }
}

// ── Category section ───────────────────────────────────────────────────────

class _CategorySection extends StatelessWidget {
  const _CategorySection({
    required this.summary,
    this.onEdit,
  });
  final BudgetSummaryModel summary;
  final void Function(BudgetItemModel)? onEdit;

  @override
  Widget build(BuildContext context) {
    if (summary.budgets.isEmpty) return const SizedBox.shrink();

    final chartCategories = ensureUniqueColours(
      summary.budgets
          .map(
            (b) => <String, dynamic>{
              'name': b.name,
              'allocated': b.goalAmount,
              'spent': b.spentAmount,
              'colour': b.colourValue,
            },
          )
          .toList(),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Categories',
                style: Theme.of(context)
                    .textTheme
                    .titleSmall
                    ?.copyWith(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        BudgetChart(
          categories: chartCategories,
          isSimpleView: true,
        ),
        const SizedBox(height: 12),
        ...summary.budgets.map(
          (b) => BudgetCard(
            rank: b.rank,
            categoryName: b.name,
            allocatedAmount: b.goalAmount,
            spentAmount: b.spentAmount,
            percentage: b.percentage,
            categoryColour: b.colourValue,
            onEditLimit: onEdit != null ? () => onEdit!(b) : null,
          ),
        ),
      ],
    );
  }
}

// ── Empty / error states ───────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.pie_chart_outline,
                size: 56,
                color: Theme.of(context).colorScheme.outline,
              ),
              const SizedBox(height: 16),
              Text(
                'No budgets set for this month.',
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});
  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                message,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: onRetry,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
}
