part of 'budgets_bloc.dart';

sealed class BudgetsEvent {
  const BudgetsEvent();
}

/// Load (or reload) budgets for the given [year] and [month].
final class BudgetsLoadRequested extends BudgetsEvent {
  const BudgetsLoadRequested({required this.year, required this.month});
  final int year;
  final int month;
}

/// Toggle between overview and details view.
final class BudgetsViewModeChanged extends BudgetsEvent {
  const BudgetsViewModeChanged(this.mode);
  final BudgetViewMode mode;
}
