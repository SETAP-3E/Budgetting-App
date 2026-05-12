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
  DateTimeRange? _dateRange;

  // Pre-built PNG marker icons keyed by category name.
  Map<String, BitmapDescriptor> _markerIcons = {};

  // Geolocated transactions, optionally filtered by category and date range.
  List<TransactionModel> get _visible => _transactions
      .where((t) => t.latitude != null && t.longitude != null)
      .where(
        (t) =>
            _selectedCategory == null || t.categoryName == _selectedCategory,
      )
      .where((t) {
        if (_dateRange == null) return true;
        return !t.date.isBefore(_dateRange!.start) &&
            !t.date.isAfter(
              _dateRange!.end.add(const Duration(days: 1)),
            );
      })
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

  Future<void> _pickDateRange() async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => _DateRangeSheet(
        initial: _dateRange,
        onApply: (range) {
          if (!mounted) return;
          setState(() => _dateRange = range);
          _fitBounds();
        },
        onClear: () {
          if (!mounted) return;
          setState(() => _dateRange = null);
          _fitBounds();
        },
      ),
    );
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
                    // Category filter chips — left side.
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
                    // Date range button + colour legend — top-right row.
                    if (hues.isNotEmpty)
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _DateRangeButton(
                              dateRange: _dateRange,
                              onPick: _pickDateRange,
                              onClear: () {
                                setState(() => _dateRange = null);
                                _fitBounds();
                              },
                            ),
                            const SizedBox(width: 6),
                            _Legend(categoryHues: hues),
                          ],
                        ),
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

// ── Date range button ────────────────────────────────────────────────────────

class _DateRangeButton extends StatelessWidget {
  const _DateRangeButton({
    required this.dateRange,
    required this.onPick,
    required this.onClear,
  });

  final DateTimeRange? dateRange;
  final VoidCallback onPick;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final active = dateRange != null;
    final fmt = DateFormat('d MMM');

    return GestureDetector(
      onTap: onPick,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.fromLTRB(10, 6, 6, 6),
        decoration: BoxDecoration(
          color: active
              ? theme.colorScheme.primaryContainer
              : theme.colorScheme.surface.withValues(alpha: 0.95),
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.12),
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.calendar_today_outlined,
              size: 13,
              color: active
                  ? theme.colorScheme.onPrimaryContainer
                  : theme.colorScheme.onSurface,
            ),
            const SizedBox(width: 5),
            Text(
              active
                  ? '${fmt.format(dateRange!.start)}'
                    ' – ${fmt.format(dateRange!.end)}'
                  : 'Date',
              style: theme.textTheme.labelSmall?.copyWith(
                color: active
                    ? theme.colorScheme.onPrimaryContainer
                    : theme.colorScheme.onSurface,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (active) ...[
              const SizedBox(width: 4),
              GestureDetector(
                onTap: onClear,
                child: Icon(
                  Icons.close,
                  size: 13,
                  color: theme.colorScheme.onPrimaryContainer,
                ),
              ),
            ] else
              const SizedBox(width: 4),
          ],
        ),
      ),
    );
  }
}

// ── Date range bottom sheet ──────────────────────────────────────────────────

class _DateRangeSheet extends StatefulWidget {
  const _DateRangeSheet({
    required this.onApply,
    required this.onClear,
    this.initial,
  });

  final DateTimeRange? initial;
  final ValueChanged<DateTimeRange> onApply;
  final VoidCallback onClear;

  @override
  State<_DateRangeSheet> createState() => _DateRangeSheetState();
}

class _DateRangeSheetState extends State<_DateRangeSheet> {
  static final _fmt = DateFormat('dd/MM/yyyy');

  late final TextEditingController _startCtrl;
  late final TextEditingController _endCtrl;
  String? _startError;
  String? _endError;

  @override
  void initState() {
    super.initState();
    _startCtrl = TextEditingController(
      text: widget.initial != null ? _fmt.format(widget.initial!.start) : '',
    );
    _endCtrl = TextEditingController(
      text: widget.initial != null ? _fmt.format(widget.initial!.end) : '',
    );
  }

  @override
  void dispose() {
    _startCtrl.dispose();
    _endCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate({required bool isStart}) async {
    final now = DateTime.now();
    final ctrl = isStart ? _startCtrl : _endCtrl;
    DateTime? current;
    try {
      current = _fmt.parseStrict(ctrl.text.trim());
    } catch (_) {}
    final picked = await showDialog<DateTime>(
      context: context,
      builder: (_) => _CalendarDialog(
        initialDate: current ?? now,
        firstDate: DateTime(2020),
        lastDate: now,
      ),
    );
    if (picked == null || !mounted) return;
    setState(() {
      ctrl.text = _fmt.format(picked);
      if (isStart) {
        _startError = null;
      } else {
        _endError = null;
      }
    });
  }

  void _apply() {
    DateTime? start;
    DateTime? end;
    String? startErr;
    String? endErr;
    try {
      start = _fmt.parseStrict(_startCtrl.text.trim());
    } catch (_) {
      startErr =
          _startCtrl.text.trim().isEmpty ? 'Required' : 'Use dd/mm/yyyy';
    }
    try {
      end = _fmt.parseStrict(_endCtrl.text.trim());
    } catch (_) {
      endErr = _endCtrl.text.trim().isEmpty ? 'Required' : 'Use dd/mm/yyyy';
    }
    if (start != null && end != null && start.isAfter(end)) {
      startErr = 'Must be before end';
    }
    if (startErr != null || endErr != null) {
      setState(() {
        _startError = startErr;
        _endError = endErr;
      });
      return;
    }
    Navigator.pop(context);
    widget.onApply(DateTimeRange(start: start!, end: end!));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 32,
              height: 4,
              decoration: BoxDecoration(
                color: theme.colorScheme.outline.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text('Filter by date', style: theme.textTheme.titleMedium),
          const SizedBox(height: 20),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: TextField(
                  controller: _startCtrl,
                  keyboardType: TextInputType.datetime,
                  decoration: InputDecoration(
                    labelText: 'From',
                    hintText: 'dd/mm/yyyy',
                    errorText: _startError,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    suffixIcon: IconButton(
                      icon: const Icon(
                        Icons.calendar_month_outlined,
                        size: 18,
                      ),
                      onPressed: () => _pickDate(isStart: true),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 14,
                    ),
                  ),
                  onChanged: (_) {
                    if (_startError != null) {
                      setState(() => _startError = null);
                    }
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: _endCtrl,
                  keyboardType: TextInputType.datetime,
                  decoration: InputDecoration(
                    labelText: 'To',
                    hintText: 'dd/mm/yyyy',
                    errorText: _endError,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    suffixIcon: IconButton(
                      icon: const Icon(
                        Icons.calendar_month_outlined,
                        size: 18,
                      ),
                      onPressed: () => _pickDate(isStart: false),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 14,
                    ),
                  ),
                  onChanged: (_) {
                    if (_endError != null) {
                      setState(() => _endError = null);
                    }
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    widget.onClear();
                  },
                  child: const Text('Clear'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton(
                  onPressed: _apply,
                  child: const Text('Apply'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Calendar picker dialog ───────────────────────────────────────────────────

class _CalendarDialog extends StatelessWidget {
  const _CalendarDialog({
    required this.initialDate,
    required this.firstDate,
    required this.lastDate,
  });

  final DateTime initialDate;
  final DateTime firstDate;
  final DateTime lastDate;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: SizedBox(
        width: 300,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: CalendarDatePicker(
            initialDate: initialDate,
            firstDate: firstDate,
            lastDate: lastDate,
            onDateChanged: (date) => Navigator.pop(context, date),
          ),
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
