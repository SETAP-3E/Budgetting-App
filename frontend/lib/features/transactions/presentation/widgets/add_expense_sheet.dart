import 'package:budgetting_frontend/features/accounts/data/mock_accounts_datasource.dart';
import 'package:budgetting_frontend/features/accounts/domain/models/account_model.dart';
import 'package:budgetting_frontend/features/transactions/data/datasources/transactions_api_client.dart';
import 'package:budgetting_frontend/features/transactions/presentation/widgets/location_search_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Bottom sheet modal for logging a new expense.
///
/// Loads categories from the API on open. Selecting "Other" reveals a
/// free-text field for a custom category name. Location is picked via
/// [LocationSearchField] (Google Places Autocomplete). Saves via
/// [TransactionsApiClient].
class AddExpenseSheet extends StatefulWidget {
  /// Create an [AddExpenseSheet].
  const AddExpenseSheet({super.key});

  @override
  State<AddExpenseSheet> createState() => _AddExpenseSheetState();
}

class _AddExpenseSheetState extends State<AddExpenseSheet> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _customCategoryController = TextEditingController();

  final _apiClient = TransactionsApiClient();

  final List<AccountModel> _accounts = MockAccountsDatasource.getAccounts();
  late AccountModel? _selectedAccount;

  List<Map<String, dynamic>> _categories = [];
  bool _loadingCategories = true;
  String? _categoryError;

  // Selected category map from API: {id, name, ...} or null for 'Other'.
  Map<String, dynamic>? _selectedCategory;
  static const String _otherId = '__other__';

  // Selected place from Places Autocomplete.
  String? _selectedPlaceName;
  double? _selectedLat;
  double? _selectedLng;

  bool get _isOtherSelected => _selectedCategory?['id'] == _otherId;

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    try {
      final cats = await _apiClient.getCategories();
      if (mounted) {
        setState(() {
          _categories = cats;
          _loadingCategories = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _categoryError = 'Could not load categories. Is the server running?';
          _loadingCategories = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _customCategoryController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final amount = double.parse(_amountController.text.trim());
    final today = DateTime.now();
    final dateStr =
        '${today.year}-${today.month.toString().padLeft(2, '0')}'
        '-${today.day.toString().padLeft(2, '0')}';

    try {
      await _apiClient.createTransaction(
        amount: amount,
        transactionDate: dateStr,
        accountId: _selectedAccount!.id,
        categoryId: _isOtherSelected
            ? null
            : _selectedCategory!['id'] as String,
        newCategoryName:
            _isOtherSelected ? _customCategoryController.text.trim() : null,
        description: _selectedPlaceName,
        latitude: _selectedLat,
        longitude: _selectedLng,
      );

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Expense saved')),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to save expense')),
        );
      }
    }
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
            // Account selector
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: 'Account',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.account_balance_wallet_outlined),
              ),
              items: _accounts
                  .map(
                    (acc) => DropdownMenuItem(
                      value: acc.id,
                      child: Row(
                        children: [
                          Icon(acc.type.icon, color: acc.accentColor, size: 18),
                          const SizedBox(width: 8),
                          Text(acc.name),
                        ],
                      ),
                    ),
                  )
                  .toList(),
              onChanged: (id) => setState(
                () => _selectedAccount =
                    _accounts.firstWhere((a) => a.id == id),
              ),
              validator: (v) =>
                  v == null ? 'Please select an account' : null,
            ),
            const SizedBox(height: 16),
            // Location search field (Places Autocomplete)
            LocationSearchField(
              onPlaceSelected: (name, lat, lng) {
                setState(() {
                  _selectedPlaceName = name;
                  _selectedLat = lat;
                  _selectedLng = lng;
                });
              },
              onCleared: () {
                setState(() {
                  _selectedPlaceName = null;
                  _selectedLat = null;
                  _selectedLng = null;
                });
              },
            ),
            const SizedBox(height: 16),
            // Category dropdown
            if (_loadingCategories)
              const Center(child: CircularProgressIndicator())
            else if (_categoryError != null)
              Text(
                _categoryError!,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              )
            else
              DropdownButtonFormField<String>(
                initialValue: _selectedCategory?['id'] as String?,
                decoration: const InputDecoration(
                  labelText: 'Category',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.category_outlined),
                ),
                items: [
                  ..._categories.map(
                    (cat) => DropdownMenuItem(
                      value: cat['id'] as String,
                      child: Text(cat['name'] as String),
                    ),
                  ),
                  const DropdownMenuItem(
                    value: _otherId,
                    child: Text('Other'),
                  ),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedCategory = value == _otherId
                        ? {'id': _otherId}
                        : _categories.firstWhere(
                            (c) => c['id'] == value,
                          );
                    if (!_isOtherSelected) {
                      _customCategoryController.clear();
                    }
                  });
                },
                validator: (value) =>
                    value == null ? 'Please select a category' : null,
              ),
            // Custom category field — visible only when 'Other' selected
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
              onPressed: _loadingCategories ? null : _save,
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
