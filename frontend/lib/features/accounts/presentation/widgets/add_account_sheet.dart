import 'package:budgetting_frontend/features/accounts/data/accounts_api_client.dart';
import 'package:budgetting_frontend/features/accounts/domain/models/account_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Colour options available when creating a new account.
const List<Color> kAccountAccentColours = [
  Color(0xFF4DB6AC),
  Color(0xFF66BB6A),
  Color(0xFFFFC107),
  Color(0xFFFF9800),
  Color(0xFF42A5F5),
  Color(0xFFAB47BC),
  Color(0xFFEF5350),
  Color(0xFF78909C),
];

/// Bottom sheet form for adding a new account.
///
/// Posts directly to the backend via [AccountsApiClient] and pops on success.
/// The parent screen should refresh the accounts list after the sheet closes.
class AddAccountSheet extends StatefulWidget {
  /// Create an [AddAccountSheet].
  ///
  /// [apiClientOverride] is injected in tests to avoid real HTTP calls.
  const AddAccountSheet({super.key, this.apiClientOverride});

  /// Replaces the default [AccountsApiClient] — used in tests only.
  final AccountsApiClient? apiClientOverride;

  @override
  State<AddAccountSheet> createState() => _AddAccountSheetState();
}

class _AddAccountSheetState extends State<AddAccountSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _balanceController = TextEditingController();
  final _budgetController = TextEditingController();

  late final AccountsApiClient _apiClient;
  AccountType? _selectedType;
  Color _selectedColour = kAccountAccentColours.first;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _apiClient = widget.apiClientOverride ?? AccountsApiClient();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _balanceController.dispose();
    _budgetController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);

    try {
      await _apiClient.createAccount(
        name: _nameController.text.trim(),
        type: _selectedType!,
        balance: double.parse(_balanceController.text.trim()),
        monthlyBudget: double.parse(_budgetController.text.trim()),
        accentColor: _selectedColour,
      );

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Account saved')),
        );
      }
    } catch (_) {
      if (mounted) {
        setState(() => _saving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to save account')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const _SheetHandle(),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Add Account', style: theme.textTheme.titleLarge),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Account Name',
                        border: OutlineInputBorder(),
                      ),
                      validator: (v) =>
                          (v == null || v.trim().isEmpty) ? 'Required' : null,
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<AccountType>(
                      initialValue: _selectedType,
                      decoration: const InputDecoration(
                        labelText: 'Account Type',
                        border: OutlineInputBorder(),
                      ),
                      items: AccountType.values
                          .map(
                            (t) => DropdownMenuItem(
                              value: t,
                              child: Text(t.label),
                            ),
                          )
                          .toList(),
                      onChanged: (t) => setState(() => _selectedType = t),
                      validator: (v) => v == null ? 'Required' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _balanceController,
                      decoration: const InputDecoration(
                        labelText: 'Opening Balance',
                        prefixText: '£',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                          RegExp(r'^\d*\.?\d{0,2}'),
                        ),
                      ],
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) return 'Required';
                        final n = double.tryParse(v.trim());
                        if (n == null || n < 0) return 'Enter a valid amount';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _budgetController,
                      decoration: const InputDecoration(
                        labelText: 'Monthly Budget',
                        prefixText: '£',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                          RegExp(r'^\d*\.?\d{0,2}'),
                        ),
                      ],
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) return 'Required';
                        final n = double.tryParse(v.trim());
                        if (n == null || n <= 0) {
                          return 'Enter an amount greater than 0';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    Text('Accent Colour', style: theme.textTheme.labelLarge),
                    const SizedBox(height: 8),
                    _ColourPicker(
                      selected: _selectedColour,
                      onChanged: (c) => setState(() => _selectedColour = c),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: _saving ? null : _save,
                        child: _saving
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text('Save Account'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SheetHandle extends StatelessWidget {
  const _SheetHandle();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Center(
        child: Container(
          width: 40,
          height: 4,
          decoration: BoxDecoration(
            color: Theme.of(context)
                .colorScheme
                .onSurface
                .withAlpha((0.2 * 255).round()),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ),
    );
  }
}

class _ColourPicker extends StatelessWidget {
  const _ColourPicker({required this.selected, required this.onChanged});

  final Color selected;
  final void Function(Color) onChanged;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: kAccountAccentColours.map((colour) {
        final isSelected = colour.toARGB32() == selected.toARGB32();
        return GestureDetector(
          onTap: () => onChanged(colour),
          child: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: colour,
              shape: BoxShape.circle,
              border: isSelected
                  ? Border.all(color: Colors.white, width: 3)
                  : null,
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: colour.withAlpha((0.6 * 255).round()),
                        blurRadius: 6,
                      ),
                    ]
                  : null,
            ),
          ),
        );
      }).toList(),
    );
  }
}
