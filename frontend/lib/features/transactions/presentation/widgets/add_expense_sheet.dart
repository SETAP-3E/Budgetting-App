import 'package:budgetting_frontend/features/transactions/data/datasources/mock_transactions_datasource.dart';
import 'package:budgetting_frontend/features/transactions/domain/models/transaction_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Bottom sheet modal for logging a new expense.
///
/// Presents fields for amount, location, and category.
/// When "Other" is selected as category, a custom name field is revealed.
/// On save, the expense is stored via [MockTransactionsDatasource].
class AddExpenseSheet extends StatefulWidget {
  /// Create an [AddExpenseSheet].
  const AddExpenseSheet({super.key});

  @override
  State<AddExpenseSheet> createState() => _AddExpenseSheetState();
}

class _AddExpenseSheetState extends State<AddExpenseSheet> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _locationController = TextEditingController();
  final _customCategoryController = TextEditingController();

  String? _selectedCategory;
  static const String _otherCategory = 'Other';

  bool get _isOtherSelected => _selectedCategory == _otherCategory;

  @override
  void dispose() {
    _amountController.dispose();
    _locationController.dispose();
    _customCategoryController.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;

    final categoryName = _isOtherSelected
        ? _customCategoryController.text.trim()
        : _selectedCategory!;

    MockTransactionsDatasource.addTransaction(
      TransactionModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        amount: double.parse(_amountController.text.trim()),
        location: _locationController.text.trim().isEmpty
            ? null
            : _locationController.text.trim(),
        categoryName: categoryName,
        date: DateTime.now(),
      ),
    );

    Navigator.of(context).pop();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Expense saved')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(16, 20, 16, 16 + bottomInset),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _SheetHandle(),
            const SizedBox(height: 12),
            Text(
              'Add Expense',
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 20),
            // Amount field
            TextFormField(
              controller: _amountController,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(
                  RegExp(r'^\d*\.?\d{0,2}'),
                ),
              ],
              decoration: const InputDecoration(
                labelText: 'Amount',
                prefixText: '£',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter an amount';
                }
                final parsed = double.tryParse(value.trim());
                if (parsed == null || parsed <= 0) {
                  return 'Amount must be greater than 0';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            // Location field (optional)
            TextFormField(
              controller: _locationController,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(
                labelText: 'Location (optional)',
                hintText: 'e.g. Tesco, High Street',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.location_on_outlined),
              ),
            ),
            const SizedBox(height: 16),
            // Category dropdown
            DropdownButtonFormField<String>(
              initialValue: _selectedCategory,
              decoration: const InputDecoration(
                labelText: 'Category',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.category_outlined),
              ),
              items: [
                ...MockTransactionsDatasource.predefinedCategories.map(
                  (cat) => DropdownMenuItem(value: cat, child: Text(cat)),
                ),
                const DropdownMenuItem(
                  value: _otherCategory,
                  child: Text('Other'),
                ),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedCategory = value;
                  if (!_isOtherSelected) {
                    _customCategoryController.clear();
                  }
                });
              },
              validator: (value) =>
                  value == null ? 'Please select a category' : null,
            ),
            // Custom category field — shown only when "Other" is selected
            if (_isOtherSelected) ...[
              const SizedBox(height: 16),
              TextFormField(
                controller: _customCategoryController,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  labelText: 'Custom category name',
                  hintText: 'e.g. Golf',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (_isOtherSelected &&
                      (value == null || value.trim().isEmpty)) {
                    return 'Please enter a category name';
                  }
                  return null;
                },
              ),
            ],
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _save,
              child: const Padding(
                padding: EdgeInsets.symmetric(vertical: 4),
                child: Text('Save Expense'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Decorative drag handle shown at the top of the sheet.
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
