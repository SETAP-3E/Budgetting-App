import 'package:budgetting_frontend/features/accounts/data/accounts_api_client.dart';
import 'package:budgetting_frontend/features/accounts/domain/models/account_model.dart';
import 'package:budgetting_frontend/features/transactions/data/datasources/transactions_api_client.dart';
import 'package:budgetting_frontend/features/transactions/domain/models/transaction_model.dart';
import 'package:budgetting_frontend/features/transactions/presentation/widgets/location_search_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Bottom sheet for editing or deleting an existing expense.
class EditExpenseSheet extends StatefulWidget {
  /// Create an [EditExpenseSheet] for [transaction].
  const EditExpenseSheet({
    required this.transaction,
    super.key,
    this.accountsOverride,
  });

  /// The transaction to edit.
  final TransactionModel transaction;

  /// Pre-loaded accounts — pass in tests to skip the network call.
  final List<AccountModel>? accountsOverride;

  @override
  State<EditExpenseSheet> createState() => _EditExpenseSheetState();
}

class _EditExpenseSheetState extends State<EditExpenseSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _amountController;
  final _customCategoryController = TextEditingController();

  final _apiClient = TransactionsApiClient();
  final _accountsClient = AccountsApiClient();

  List<AccountModel> _accounts = [];
  bool _loadingAccounts = true;
  String? _accountError;
  AccountModel? _selectedAccount;

  List<Map<String, dynamic>> _categories = [];
  bool _loadingCategories = true;
  String? _categoryError;

  Map<String, dynamic>? _selectedCategory;
  static const String _otherId = '__other__';

  late DateTime _selectedDate;
  String? _selectedPlaceName;
  double? _selectedLat;
  double? _selectedLng;

  bool get _isOtherSelected => _selectedCategory?['id'] == _otherId;

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController(
      text: widget.transaction.amount.toStringAsFixed(2),
    );
    _selectedDate = widget.transaction.date;
    _selectedPlaceName = widget.transaction.location;
    _selectedLat = widget.transaction.latitude;
    _selectedLng = widget.transaction.longitude;

    _loadCategories();
    if (widget.accountsOverride != null) {
      _accounts = widget.accountsOverride!;
      _selectedAccount = _accounts
          .where((a) => a.id == widget.transaction.accountId)
          .firstOrNull;
      _loadingAccounts = false;
    } else {
      _loadAccounts();
    }
  }

  Future<void> _loadAccounts() async {
    try {
      final accounts = await _accountsClient.getAccounts();
      if (mounted) {
        setState(() {
          _accounts = accounts;
          _selectedAccount = accounts
              .where((a) => a.id == widget.transaction.accountId)
              .firstOrNull;
          _loadingAccounts = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _accountError = 'Could not load accounts. Is the server running?';
          _loadingAccounts = false;
        });
      }
    }
  }

  Future<void> _loadCategories() async {
    try {
      final cats = await _apiClient.getCategories();
      if (mounted) {
        setState(() {
          _categories = cats;
          _selectedCategory = cats
              .where((c) => c['id'] == widget.transaction.categoryId)
              .firstOrNull;
          _loadingCategories = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _categoryError =
              'Could not load categories. Is the server running?';
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

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final amount = double.parse(_amountController.text.trim());
    final dateStr =
        '${_selectedDate.year}-'
        '${_selectedDate.month.toString().padLeft(2, '0')}-'
        '${_selectedDate.day.toString().padLeft(2, '0')}';

    try {
      await _apiClient.updateTransaction(
        id: widget.transaction.id,
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
        Navigator.of(context).pop(true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Expense updated')),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to update expense')),
        );
      }
    }
  }

  Future<void> _confirmDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete transaction?'),
        content: const Text('This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(ctx).colorScheme.error,
            ),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    try {
      await _apiClient.deleteTransaction(widget.transaction.id);
      if (mounted) {
        Navigator.of(context).pop(true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Transaction deleted')),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to delete transaction')),
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
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Edit Expense',
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge
                        ?.copyWith(fontWeight: FontWeight.w600),
                  ),
                ),
                IconButton(
                  icon: Icon(
                    Icons.delete_outline,
                    color: Theme.of(context).colorScheme.error,
                  ),
                  tooltip: 'Delete transaction',
                  onPressed: _confirmDelete,
                ),
              ],
            ),
            const SizedBox(height: 20),
            // Amount
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
            if (_loadingAccounts)
              const Center(child: CircularProgressIndicator())
            else if (_accountError != null)
              Text(
                _accountError!,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              )
            else
              DropdownButtonFormField<String>(
                initialValue: _selectedAccount?.id,
                autovalidateMode: AutovalidateMode.onUserInteraction,
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
                            Icon(acc.type.icon,
                                color: acc.accentColor, size: 18,),
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
            // Date picker
            InkWell(
              onTap: _pickDate,
              borderRadius: BorderRadius.circular(4),
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Date',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.calendar_today_outlined),
                ),
                child: Text(
                  '${_selectedDate.day.toString().padLeft(2, '0')}/'
                  '${_selectedDate.month.toString().padLeft(2, '0')}/'
                  '${_selectedDate.year}',
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Location search
            LocationSearchField(
              initialValue: _selectedPlaceName,
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
            // Category selector
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
                        : _categories.firstWhere((c) => c['id'] == value);
                    if (!_isOtherSelected) _customCategoryController.clear();
                  });
                },
                validator: (value) =>
                    value == null ? 'Please select a category' : null,
              ),
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
              onPressed: _loadingCategories || _loadingAccounts ? null : _save,
              child: const Padding(
                padding: EdgeInsets.symmetric(vertical: 4),
                child: Text('Save Changes'),
              ),
            ),
          ],
        ),
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
