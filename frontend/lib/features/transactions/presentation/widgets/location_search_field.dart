import 'dart:async';

import 'package:budgetting_frontend/features/transactions/data/datasources/transactions_api_client.dart';
import 'package:flutter/material.dart';

/// Called when the user selects a place from the autocomplete dropdown.
typedef OnPlaceSelected = void Function(
  String name,
  double latitude,
  double longitude,
);

/// A location search field backed by Google Places Autocomplete.
///
/// Debounces input (350 ms, minimum 3 chars) and shows a suggestions dropdown.
/// On selection, resolves coordinates via the Places Details proxy and fires
/// [onPlaceSelected]. Fires [onCleared] when the user edits after a selection.
class LocationSearchField extends StatefulWidget {
  /// Create a [LocationSearchField].
  const LocationSearchField({
    required this.onPlaceSelected,
    this.onCleared,
    super.key,
  });

  /// Called with the resolved place name and coordinates after selection.
  final OnPlaceSelected onPlaceSelected;

  /// Called when the user edits the field after a place was already selected.
  final VoidCallback? onCleared;

  @override
  State<LocationSearchField> createState() => _LocationSearchFieldState();
}

class _LocationSearchFieldState extends State<LocationSearchField> {
  final _controller = TextEditingController();
  final _apiClient = TransactionsApiClient();
  Timer? _debounce;

  List<Map<String, dynamic>> _suggestions = [];
  bool _loading = false;

  /// True while the field contains a resolved place name — suppresses search.
  bool _placeSelected = false;

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _onChanged(String value) {
    if (_placeSelected) {
      _placeSelected = false;
      widget.onCleared?.call();
    }

    _debounce?.cancel();

    if (value.trim().length < 3) {
      if (_suggestions.isNotEmpty) setState(() => _suggestions = []);
      return;
    }

    _debounce = Timer(const Duration(milliseconds: 350), () async {
      if (!mounted) return;
      setState(() => _loading = true);
      try {
        final results =
            await _apiClient.getPlaceSuggestions(value.trim());
        if (mounted) {
          setState(() {
            _suggestions = results;
            _loading = false;
          });
        }
      } catch (_) {
        if (mounted) setState(() { _suggestions = []; _loading = false; });
      }
    });
  }

  Future<void> _onSuggestionTapped(Map<String, dynamic> suggestion) async {
    final placeId = suggestion['place_id'] as String;
    final description = suggestion['description'] as String;

    setState(() { _loading = true; _suggestions = []; });

    try {
      final details = await _apiClient.getPlaceDetails(placeId);
      final name = (details['name'] as String?) ?? description;
      final lat = (details['latitude'] as num).toDouble();
      final lng = (details['longitude'] as num).toDouble();

      _controller.text = name;
      _placeSelected = true;
      widget.onPlaceSelected(name, lat, lng);
    } catch (_) {
      // Details call failed — surface description as name with no coords.
      _controller.text = description;
      _placeSelected = true;
      widget.onCleared?.call();
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        TextFormField(
          controller: _controller,
          onChanged: _onChanged,
          decoration: InputDecoration(
            labelText: 'Location (optional)',
            hintText: 'Search for a place…',
            border: const OutlineInputBorder(),
            prefixIcon: const Icon(Icons.location_on_outlined),
            suffixIcon: _loading
                ? const Padding(
                    padding: EdgeInsets.all(12),
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  )
                : null,
          ),
        ),
        if (_suggestions.isNotEmpty)
          ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 200),
            child: Material(
              elevation: 4,
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: _suggestions.length,
                itemBuilder: (context, index) {
                  final s = _suggestions[index];
                  return ListTile(
                    dense: true,
                    leading: const Icon(Icons.place_outlined, size: 18),
                    title: Text(
                      s['description'] as String,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    onTap: () => _onSuggestionTapped(s),
                  );
                },
              ),
            ),
          ),
      ],
    );
  }
}
