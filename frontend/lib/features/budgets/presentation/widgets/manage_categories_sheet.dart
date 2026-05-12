import 'package:budgetting_frontend/features/accounts/presentation/widgets/add_account_sheet.dart';
import 'package:budgetting_frontend/features/budgets/data/budgets_api_client.dart';
import 'package:budgetting_frontend/features/budgets/domain/models/budget_models.dart';
import 'package:flutter/material.dart';

/// Bottom sheet listing all custom categories.
///
/// Each row has an edit action to rename the category or change its colour.
class ManageCategoriesSheet extends StatefulWidget {
  /// Create a [ManageCategoriesSheet].
  const ManageCategoriesSheet({super.key});

  @override
  State<ManageCategoriesSheet> createState() => _ManageCategoriesSheetState();
}

class _ManageCategoriesSheetState extends State<ManageCategoriesSheet> {
  late final _client = BudgetsApiClient();
  List<CategoryItem>? _categories;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final all = await _client.getCategories();
      if (mounted) {
        setState(() {
          _categories = all.where((c) => !c.isPredefined).toList();
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _error = 'Could not load categories.';
          _loading = false;
        });
      }
    }
  }

  Future<void> _edit(CategoryItem cat) async {
    final controller = TextEditingController(text: cat.name);
    var selectedColour = Color(cat.colourValue);

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('Edit category'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: controller,
                autofocus: true,
                decoration: const InputDecoration(labelText: 'Name'),
              ),
              const SizedBox(height: 16),
              Text(
                'Colour',
                style: Theme.of(ctx).textTheme.labelSmall,
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: kAccountAccentColours.map((colour) {
                  final isSelected =
                      colour.toARGB32() == selectedColour.toARGB32();
                  return GestureDetector(
                    onTap: () =>
                        setDialogState(() => selectedColour = colour),
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
                                  color: colour
                                      .withAlpha((0.6 * 255).round()),
                                  blurRadius: 6,
                                ),
                              ]
                            : null,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );

    if (confirmed != true) return;
    final newName = controller.text.trim();
    final nameToSave = newName.isEmpty ? cat.name : newName;
    try {
      await _client.updateCategory(
        cat.id,
        nameToSave,
        selectedColour.toARGB32(),
      );
      await _load();
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to update category.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 8,
        bottom: MediaQuery.viewInsetsOf(context).bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: theme.colorScheme.outlineVariant,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Text(
            'Manage custom categories',
            style: theme.textTheme.titleMedium
                ?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 16),
          if (_loading)
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 32),
                child: CircularProgressIndicator(),
              ),
            )
          else if (_error != null)
            Text(_error!, style: const TextStyle(color: Colors.red))
          else if (_categories!.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Text(
                'No custom categories yet.',
                style: theme.textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _categories!.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (_, i) {
                final cat = _categories![i];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Color(cat.colourValue),
                    radius: 14,
                  ),
                  title: Text(cat.name),
                  trailing: IconButton(
                    icon: const Icon(Icons.edit_outlined, size: 20),
                    tooltip: 'Edit',
                    onPressed: () => _edit(cat),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}
