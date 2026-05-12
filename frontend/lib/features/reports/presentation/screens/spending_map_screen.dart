import 'dart:math' show max, min;
import 'dart:ui' as ui;

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

  // Pre-built PNG marker icons keyed by category name.
  Map<String, BitmapDescriptor> _markerIcons = {};

  // Geolocated transactions, optionally filtered by selected category.
  List<TransactionModel> get _visible => _transactions
      .where((t) => t.latitude != null && t.longitude != null)
      .where(
        (t) =>
            _selectedCategory == null || t.categoryName == _selectedCategory,
      )
      .toList();

  // Sorted list of unique categories that have at least one geolocated tx.
  List<String> get _categories => _transactions
      .where((t) => t.latitude != null && t.longitude != null)
      .map((t) => t.categoryName)
      .toSet()
      .toList()
    ..sort();

  // Evenly-spaced hues across 360° — one per category in sorted order.
  Map<String, double> get _categoryHues {
    final cats = _categories;
    if (cats.isEmpty) return {};
    final step = 360.0 / cats.length;
    return {for (var i = 0; i < cats.length; i++) cats[i]: i * step};
  }

  @override
  void initState() {
    super.initState();
    _loadTransactions();
  }

  Future<void> _loadTransactions() async {
    setState(() => _loading = true);
    try {
      final data = await _apiClient.getTransactions();
      if (!mounted) return;
      setState(() => _transactions = data);

      // Build PNG icons for every category before showing markers.
      final icons = await _buildMarkerIcons(_categoryHues);
      if (!mounted) return;
      setState(() {
        _markerIcons = icons;
        _loading = false;
      });
      if (_mapController != null) _fitBounds();
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  // Generates a coloured teardrop PNG for each category using dart:ui canvas.
  Future<Map<String, BitmapDescriptor>> _buildMarkerIcons(
    Map<String, double> hues,
  ) async {
    final result = <String, BitmapDescriptor>{};
    for (final entry in hues.entries) {
      final color = HSVColor.fromAHSV(1, entry.value, 0.85, 0.85).toColor();
      result[entry.key] = await _renderPinIcon(color);
    }
    return result;
  }

  Future<BitmapDescriptor> _renderPinIcon(Color color) async {
    const w = 28.0;
    const h = 40.0;
    final recorder = ui.PictureRecorder();
    final canvas = ui.Canvas(
      recorder,
      const ui.Rect.fromLTWH(0, 0, w, h),
    );

    final fill = ui.Paint()..color = color;
    final tail = ui.Path()
      ..moveTo(w / 2 - 7, w - 6)
      ..lineTo(w / 2 + 7, w - 6)
      ..lineTo(w / 2, h)
      ..close();

    canvas
      ..drawCircle(const ui.Offset(w / 2, w / 2), w / 2, fill)
      ..drawPath(tail, fill)
      ..drawCircle(
        const ui.Offset(w / 2, w / 2),
        w / 5,
        ui.Paint()..color = const ui.Color(0xCCFFFFFF),
      );

    final picture = recorder.endRecording();
    final img = await picture.toImage(w.toInt(), h.toInt());
    final bytes = await img.toByteData(format: ui.ImageByteFormat.png);
    return BitmapDescriptor.bytes(bytes!.buffer.asUint8List());
  }

  void _fitBounds() {
    final pts = _visible
        .map((t) => LatLng(t.latitude!, t.longitude!))
        .toList();
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

  Set<Marker> _buildMarkers() {
    return _visible
        .map(
          (t) => Marker(
            markerId: MarkerId(t.id),
            position: LatLng(t.latitude!, t.longitude!),
            icon: _markerIcons[t.categoryName] ??
                BitmapDescriptor.defaultMarker,
            infoWindow: InfoWindow(
              title: t.location ?? t.categoryName,
              snippet: '£${t.amount.toStringAsFixed(2)}'
                  ' · ${DateFormat('d MMM y').format(t.date)}',
            ),
          ),
        )
        .toSet();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hues = _categoryHues;
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
                    // Category filter chips — right-side reserved for legend.
                    if (_categories.isNotEmpty)
                      Positioned(
                        top: 8,
                        left: 8,
                        right: 120,
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              _MapChip(
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
                                  child: _MapChip(
                                    label: cat,
                                    selected: _selectedCategory == cat,
                                    onTap: () => setState(() {
                                      _selectedCategory =
                                          _selectedCategory == cat
                                              ? null
                                              : cat;
                                      _fitBounds();
                                    }),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    // Colour legend — top-right.
                    if (hues.isNotEmpty)
                      Positioned(
                        top: 8,
                        right: 8,
                        child: _Legend(categoryHues: hues),
                      ),
                    // Stats card — bottom centre.
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

// ── Colour legend ────────────────────────────────────────────────────────────

class _Legend extends StatelessWidget {
  const _Legend({required this.categoryHues});

  final Map<String, double> categoryHues;

  Color _hueToColor(double hue) =>
      HSVColor.fromAHSV(1, hue, 0.85, 0.85).toColor();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: categoryHues.entries.map((e) {
            final color = _hueToColor(e.value);
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 3),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(e.key, style: theme.textTheme.labelSmall),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

// ── Filter chip ──────────────────────────────────────────────────────────────

class _MapChip extends StatelessWidget {
  const _MapChip({
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

// ── Empty state ──────────────────────────────────────────────────────────────

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
            Text('No locations saved yet', style: theme.textTheme.titleMedium),
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
