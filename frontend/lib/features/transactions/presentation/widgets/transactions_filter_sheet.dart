import 'package:budgetting_frontend/features/transactions/presentation/bloc/transactions_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

/// Bottom sheet for configuring transaction list filters.
///
/// Provides date range pickers, amount min/max fields, and a category
/// substring search. Calls [onApply] with the resulting [TransactionFilter].
class TransactionsFilterSheet extends StatefulWidget {
  /// Create a [TransactionsFilterSheet].
  const TransactionsFilterSheet({
    required this.initialFilter,
    required this.onApply,
    super.key,
  });

  /// Pre-populated filter values shown when the sheet opens.
  final TransactionFilter initialFilter;

  /// Called with the new filter when the user taps "Apply".
  final ValueChanged<TransactionFilter> onApply;

  @override
  State<TransactionsFilterSheet> createState() =>
      _TransactionsFilterSheetState();
}

class _TransactionsFilterSheetState extends State<TransactionsFilterSheet> {
  late DateTime? _dateFrom;
  late DateTime? _dateTo;
  final _categoryController = TextEditingController();
  final _minController = TextEditingController();
  final _maxController = TextEditingController();

  final _fmt = DateFormat('dd MMM yyyy');

  @override
  void initState() {
    super.initState();
    final f = widget.initialFilter;
    _dateFrom = f.dateFrom;
    _dateTo = f.dateTo;
    _categoryController.text = f.categoryQuery ?? '';
    _minController.text = f.minAmount?.toStringAsFixed(2) ?? '';
    _maxController.text = f.maxAmount?.toStringAsFixed(2) ?? '';
  }

  @override
  void dispose() {
    _categoryController.dispose();
    _minController.dispose();
    _maxController.dispose();
    super.dispose();
  }

  Future<void> _pickDate({required bool isFrom}) async {
    final initial = isFrom
        ? (_dateFrom ?? DateTime.now())
        : (_dateTo ?? DateTime.now());
    final first = isFrom ? DateTime(2000) : (_dateFrom ?? DateTime(2000));
    final last = isFrom ? (_dateTo ?? DateTime(2100)) : DateTime(2100);

    final clamped = initial.isBefore(first)
        ? first
        : initial.isAfter(last)
            ? last
            : initial;
    final picked = await showDatePicker(
      context: context,
      initialDate: clamped,
      firstDate: first,
      lastDate: last,
    );
    if (picked == null) return;
    setState(() {
      if (isFrom) {
        _dateFrom = picked;
      } else {
        _dateTo = picked;
      }
    });
  }

  void _apply() {
    final min = double.tryParse(_minController.text.trim());
    final max = double.tryParse(_maxController.text.trim());
    final cat = _categoryController.text.trim();
    widget.onApply(
      TransactionFilter(
        dateFrom: _dateFrom,
        dateTo: _dateTo,
        categoryQuery: cat.isEmpty ? null : cat,
        minAmount: min,
        maxAmount: max,
      ),
    );
    Navigator.of(context).pop();
  }

  void _clearAll() {
    setState(() {
      _dateFrom = null;
      _dateTo = null;
      _categoryController.clear();
      _minController.clear();
      _maxController.clear();
    });
    widget.onApply(const TransactionFilter());
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(16, 20, 16, 16 + bottomInset),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _SheetHandle(),
          const SizedBox(height: 12),
          Text(
            'Filter Transactions',
            style: Theme.of(context)
                .textTheme
                .titleLarge
                ?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 20),
          // Date range
          Row(
            children: [
              Expanded(
                child: _DatePickerTile(
                  label: 'From',
                  value: _dateFrom != null ? _fmt.format(_dateFrom!) : null,
                  onTap: () => _pickDate(isFrom: true),
                  onClear: _dateFrom != null
                      ? () => setState(() => _dateFrom = null)
                      : null,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _DatePickerTile(
                  label: 'To',
                  value: _dateTo != null ? _fmt.format(_dateTo!) : null,
                  onTap: () => _pickDate(isFrom: false),
                  onClear: _dateTo != null
                      ? () => setState(() => _dateTo = null)
                      : null,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Category filter
          TextField(
            controller: _categoryController,
            decoration: const InputDecoration(
              labelText: 'Category contains',
              hintText: 'e.g. Groceries',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.category_outlined),
            ),
          ),
          const SizedBox(height: 16),
          // Amount range
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _minController,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(
                      RegExp(r'^\d*\.?\d{0,2}'),
                    ),
                  ],
                  decoration: const InputDecoration(
                    labelText: 'Min amount',
                    prefixText: '£',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: _maxController,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(
                      RegExp(r'^\d*\.?\d{0,2}'),
                    ),
                  ],
                  decoration: const InputDecoration(
                    labelText: 'Max amount',
                    prefixText: '£',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _clearAll,
                  child: const Text('Clear All'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton(
                  onPressed: _apply,
                  child: const Text('Apply Filters'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SheetHandle extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 40,
        height: 4,
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }
}

/// A tappable tile that shows a date label and optional clear button.
class _DatePickerTile extends StatelessWidget {
  const _DatePickerTile({
    required this.label,
    required this.onTap,
    this.value,
    this.onClear,
  });

  final String label;
  final String? value;
  final VoidCallback onTap;
  final VoidCallback? onClear;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(4),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          suffixIcon: onClear != null
              ? IconButton(
                  icon: const Icon(Icons.clear, size: 18),
                  onPressed: onClear,
                )
              : const Icon(Icons.calendar_today_outlined, size: 18),
        ),
        child: Text(
          value ?? 'Any',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: value == null
                    ? Theme.of(context).colorScheme.outline
                    : null,
              ),
        ),
      ),
    );
  }
}
