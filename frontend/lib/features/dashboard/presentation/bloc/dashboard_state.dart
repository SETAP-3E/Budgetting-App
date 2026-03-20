import 'package:equatable/equatable.dart';

/// Base state for Dashboard feature.
abstract class DashboardState extends Equatable {
  /// Create a [DashboardState].
  const DashboardState();

  @override
  List<Object?> get props => [];
}

/// Loading state while fetching dashboard data.
class DashboardLoading extends DashboardState {
  /// Create a [DashboardLoading] state.
  const DashboardLoading();
}

/// Successfully loaded dashboard data.
class DashboardLoaded extends DashboardState {
  /// Create a [DashboardLoaded] state.
  const DashboardLoaded({
    required this.totalSpending,
    required this.month,
    required this.year,
    required this.topCategory,
    required this.categories,
    required this.isSimpleView,
    required this.selectedPeriod,
    this.goalAmount,
  });

  /// Total spending amount for the period.
  final double totalSpending;

  /// Month name.
  final String month;

  /// Year number.
  final int year;

  /// Top category with its amount and comparison.
  final Map<String, dynamic> topCategory;

  /// List of all categories with spending details.
  final List<Map<String, dynamic>> categories;

  /// Optional goal amount for the period.
  final double? goalAmount;

  /// Whether viewing Simple (top 3) or Advanced (all) mode.
  final bool isSimpleView;

  /// Currently selected time period.
  final String selectedPeriod;

  @override
  List<Object?> get props => [
    totalSpending,
    month,
    year,
    topCategory,
    categories,
    goalAmount,
    isSimpleView,
    selectedPeriod,
  ];
}

/// Error state when dashboard data fetch fails.
class DashboardError extends DashboardState {
  /// Create a [DashboardError] state.
  const DashboardError(this.message);

  /// Error message to display to user.
  final String message;

  @override
  List<Object?> get props => [message];
}
