part of 'budgets_bloc.dart';

/// Which view panel is active on the budgets screen.
enum BudgetViewMode {
  /// Pie chart overview.
  overview,

  /// Per-category detail list.
  details,
}

/// Loading status for the budgets screen.
enum BudgetsStatus {
  /// No data has been requested yet.
  initial,

  /// A network request is in flight.
  loading,

  /// Data loaded successfully.
  loaded,

  /// The request failed.
  failure,
}

/// Immutable state for [BudgetsBloc].
final class BudgetsState extends Equatable {
  /// Create a [BudgetsState].
  const BudgetsState({
    required this.selectedYear,
    required this.selectedMonth,
    this.status = BudgetsStatus.initial,
    this.summary,
    this.errorMessage,
    this.viewMode = BudgetViewMode.overview,
  });

  /// Current load status.
  final BudgetsStatus status;

  /// Loaded budget summary, or null while loading / on error.
  final BudgetSummaryModel? summary;

  /// Error message when [status] is [BudgetsStatus.failure].
  final String? errorMessage;

  /// The year currently displayed.
  final int selectedYear;

  /// The month currently displayed (1–12).
  final int selectedMonth;

  /// Which view panel is visible.
  final BudgetViewMode viewMode;

  /// Return a copy with selected fields replaced.
  BudgetsState copyWith({
    BudgetsStatus? status,
    BudgetSummaryModel? summary,
    String? errorMessage,
    int? selectedYear,
    int? selectedMonth,
    BudgetViewMode? viewMode,
  }) =>
      BudgetsState(
        status: status ?? this.status,
        summary: summary ?? this.summary,
        errorMessage: errorMessage ?? this.errorMessage,
        selectedYear: selectedYear ?? this.selectedYear,
        selectedMonth: selectedMonth ?? this.selectedMonth,
        viewMode: viewMode ?? this.viewMode,
      );

  @override
  List<Object?> get props => [
        status,
        summary,
        errorMessage,
        selectedYear,
        selectedMonth,
        viewMode,
      ];
}
