import 'package:budgetting_frontend/features/dashboard/presentation/bloc/dashboard_event.dart';
import 'package:budgetting_frontend/features/dashboard/presentation/bloc/dashboard_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// BLoC for managing Dashboard feature state and events.
class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  /// Create a [DashboardBloc].
  DashboardBloc() : super(const DashboardLoading()) {
    on<FetchDashboard>(_onFetchDashboard);
    on<ChangePeriod>(_onChangePeriod);
    on<ToggleViewMode>(_onToggleViewMode);
  }

  /// Handle [FetchDashboard] event.
  Future<void> _onFetchDashboard(
    FetchDashboard event,
    Emitter<DashboardState> emit,
  ) async {
    emit(const DashboardLoading());
    // TODO(dev): Implement data fetching from MockDashboardDataService
  }

  /// Handle [ChangePeriod] event.
  Future<void> _onChangePeriod(
    ChangePeriod event,
    Emitter<DashboardState> emit,
  ) async {
    // TODO(dev): Update state with new period data
  }

  /// Handle [ToggleViewMode] event.
  Future<void> _onToggleViewMode(
    ToggleViewMode event,
    Emitter<DashboardState> emit,
  ) async {
    // TODO(dev): Toggle isSimpleView and persist to SharedPreferences
  }
}
