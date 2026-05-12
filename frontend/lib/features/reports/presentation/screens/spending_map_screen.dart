import 'dart:math' show max, min;

import 'package:budgetting_frontend/core/utils/currency_formatter.dart';
import 'package:budgetting_frontend/features/dashboard/presentation/widgets/app_footer.dart';
import 'package:budgetting_frontend/features/dashboard/presentation/widgets/app_header.dart';
import 'package:budgetting_frontend/features/transactions/data/datasources/transactions_api_client.dart';
import 'package:budgetting_frontend/features/transactions/domain/models/transaction_model.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';

/// Displays all geolocated transactions as colour-coded pins on a Google Map.
class SpendingMapScreen extends StatefulWidget {
  /// Create a [SpendingMapScreen].
  const SpendingMapScreen({super.key});

  @override
  State<SpendingMapScreen> createState() => _SpendingMapScreenState();
}

class _SpendingMapScreenState extends State<SpendingMapScreen> {
  final _apiClient = TransactionsApiClient();

  List<TransactionModel> _transactions = [];
  bool _loading = true;
  GoogleMapController? _mapController;
  String? _selectedCategory;

  // Geolocated transactions, filtered by selected category.
  List<TransactionModel> get _visible => _transactions
      .where((t) => t.latitude != null && t.longitude != null)
      .where(
        (t) => _selectedCategory == null || t.categoryName == _selectedCategory,
      )
      .toList();

  List<String> get _categories => _transactions
      .where((t) => t.latitude != null && t.longitude != null)
      .map((t) => t.categoryName)
      .toSet()
      .toList()
    ..sort();

  @override
  void initState() {
    super.initState();
    _loadTransactions();
  }

  Future<void> _loadTransactions() async {
    setState(() => _loading = true);
    try {
      final data = await _apiClient.getTransactions();
      if (mounted) {
        setState(() {
          _transactions = data;
          _loading = false;
        });
        if (_mapController != null) _fitBounds();
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _fitBounds() {
    final pts = _visible.map((t) => LatLng(t.latitude!, t.longitude!)).toList();
    if (pts.isEmpty) return;
    if (pts.length == 1) {
      _mapController?.animateCamera(
        CameraUpdate.newLatLngZoom(pts.first, 14),
      );
      return;
    }
    final sw = LatLng(
      pts.map((p) => p.latitude).reduce(min),
      pts.map((p) => p.longitude).reduce(min),
    );
    final ne = LatLng(
      pts.map((p) => p.latitude).reduce(max),
      pts.map((p) => p.longitude).reduce(max),
    );
    _mapController?.animateCamera(
      CameraUpdate.newLatLngBounds(
        LatLngBounds(southwest: sw, northeast: ne),
        60,
      ),
    );
  }

  // Deterministic hue in [0, 360) derived from the category name.
  double _categoryHue(String category) =>
      (category.codeUnits.fold(0, (a, b) => a + b) % 360).toDouble();

  Set<Marker> _buildMarkers() {
    return _visible
        .map(
          (t) => Marker(
            markerId: MarkerId(t.id),
            position: LatLng(t.latitude!, t.longitude!),
            icon: BitmapDescriptor.defaultMarkerWithHue(
              _categoryHue(t.categoryName),
            ),
            infoWindow: InfoWindow(
              title: t.location ?? t.categoryName,
              snippet:
                  '£${t.amount.toStringAsFixed(2)}'
                  ' · ${DateFormat('d MMM y').format(t.date)}',
            ),
          ),
        )
        .toSet();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final markers = _buildMarkers();
    final totalSpend = _visible.fold<double>(0, (s, t) => s + t.amount);

    return Scaffold(
      appBar: AppHeader(
        title: 'Expense Map',
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadTransactions,
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _transactions.where((t) => t.latitude != null).isEmpty
              ? _EmptyState(theme: theme)
              : Stack(
                  children: [
                    GoogleMap(
                      initialCameraPosition: const CameraPosition(
                        target: LatLng(52.2, -1.5),
                        zoom: 6,
                      ),
                      markers: markers,
                      onMapCreated: (ctrl) {
                        _mapController = ctrl;
                        _fitBounds();
                      },
                    ),
                    // Category filter chips
                    if (_categories.isNotEmpty)
                      Positioned(
                        top: 8,
                        left: 8,
                        right: 8,
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              _FilterChip(
                                label: 'All',
                                selected: _selectedCategory == null,
                                onTap: () => setState(() {
                                  _selectedCategory = null;
                                  _fitBounds();
                                }),
                              ),
                              ..._categories.map(
                                (cat) => Padding(
                                  padding: const EdgeInsets.only(left: 6),
                                  child: _FilterChip(
                                    label: cat,
                                    selected: _selectedCategory == cat,
                                    onTap: () => setState(() {
                                      _selectedCategory =
                                          _selectedCategory == cat ? null : cat;
                                      _fitBounds();
                                    }),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    // Stats card
                    if (markers.isNotEmpty)
                      Positioned(
                        bottom: 16,
                        left: 16,
                        right: 16,
                        child: Center(
                          child: Card(
                            elevation: 4,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 10,
                              ),
                              child: Text(
                                '${markers.length} '
                                '${markers.length == 1
                                    ? 'location'
                                    : 'locations'}'
                                ' · ${formatCurrency(totalSpend)}',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
      bottomNavigationBar: const AppFooter(activeIndex: 4),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: selected
              ? theme.colorScheme.primary
              : theme.colorScheme.surface.withValues(alpha: 0.92),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.12),
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            color: selected
                ? theme.colorScheme.onPrimary
                : theme.colorScheme.onSurface,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.theme});

  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.location_off_outlined,
              size: 64,
              color: theme.colorScheme.outline,
            ),
            const SizedBox(height: 16),
            Text(
              'No locations saved yet',
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Add a place when recording an expense to see it here',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
