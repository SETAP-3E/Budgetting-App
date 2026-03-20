import 'package:equatable/equatable.dart';

/// Base event for Dashboard feature.
abstract class DashboardEvent extends Equatable {
  /// Create a [DashboardEvent].
  const DashboardEvent();

  @override
  List<Object?> get props => [];
}

/// Fetch dashboard data on initial load or refresh.
class FetchDashboard extends DashboardEvent {
  /// Create a [FetchDashboard] event.
  const FetchDashboard();
}

/// Change the active time period.
///
/// Supports: 'this_month', 'last_month', 'this_year', or custom date range.
class ChangePeriod extends DashboardEvent {
  /// Create a [ChangePeriod] event.
  const ChangePeriod(this.period);

  /// The period identifier.
  final String period;

  @override
  List<Object?> get props => [period];
}

/// Toggle between Simple and Advanced view modes.
///
/// Simple: top 3 categories + Other
/// Advanced: all categories
class ToggleViewMode extends DashboardEvent {
  /// Create a [ToggleViewMode] event.
  const ToggleViewMode();
}
