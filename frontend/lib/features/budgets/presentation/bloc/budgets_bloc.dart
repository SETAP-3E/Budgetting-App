import 'package:budgetting_frontend/features/budgets/data/budgets_api_client.dart';
import 'package:budgetting_frontend/features/budgets/domain/models/budget_models.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'budgets_event.dart';
part 'budgets_state.dart';

/// Manages data fetching and UI state for the budgets screen.
class BudgetsBloc extends Bloc<BudgetsEvent, BudgetsState> {
  /// Create a [BudgetsBloc] for the given [year] and [month].
  BudgetsBloc({required int year, required int month})
      : _client = BudgetsApiClient(),
        super(BudgetsState(selectedYear: year, selectedMonth: month)) {
    on<BudgetsLoadRequested>(_onLoadRequested);
    on<BudgetsViewModeChanged>(_onViewModeChanged);
  }

  final BudgetsApiClient _client;

  Future<void> _onLoadRequested(
    BudgetsLoadRequested event,
    Emitter<BudgetsState> emit,
  ) async {
    emit(
      state.copyWith(
        status: BudgetsStatus.loading,
        selectedYear: event.year,
        selectedMonth: event.month,
      ),
    );
    try {
      final summary = await _client.getBudgets(
        year: event.year,
        month: event.month,
      );
      emit(state.copyWith(status: BudgetsStatus.loaded, summary: summary));
    } catch (e) {
      emit(
        state.copyWith(
          status: BudgetsStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  void _onViewModeChanged(
    BudgetsViewModeChanged event,
    Emitter<BudgetsState> emit,
  ) =>
      emit(state.copyWith(viewMode: event.mode));
}
