import 'package:budgetting_frontend/features/dashboard/presentation/widgets/app_footer.dart';
import 'package:budgetting_frontend/features/dashboard/presentation/widgets/app_header.dart';
import 'package:budgetting_frontend/features/transactions/data/datasources/transactions_api_client.dart';
import 'package:budgetting_frontend/features/transactions/domain/models/transaction_model.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

/// Displays all geolocated transactions as pins on an interactive Google Map.
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

  @override
  void initState() {
    super.initState();
    _loadTransactions();
  }

  Future<void> _loadTransactions() async {
    try {
      final data = await _apiClient.getTransactions();
      if (mounted) {
        setState(() {
          _transactions = data;
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Set<Marker> _buildMarkers() {
    return _transactions
        .where((t) => t.latitude != null && t.longitude != null)
        .map(
          (t) => Marker(
            markerId: MarkerId(t.id),
            position: LatLng(t.latitude!, t.longitude!),
            infoWindow: InfoWindow(
              title: t.location ?? t.categoryName,
              snippet: '£${t.amount.toStringAsFixed(2)}',
            ),
          ),
        )
        .toSet();
  }

  @override
  Widget build(BuildContext context) {
    final markers = _buildMarkers();

    return Scaffold(
      appBar: const AppHeader(title: 'Expense Map'),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : markers.isEmpty
              ? const Center(
                  child: Text(
                    'No locations saved yet.\n'
                    'Search for a place when adding an expense.',
                    textAlign: TextAlign.center,
                  ),
                )
              : GoogleMap(
                  initialCameraPosition: const CameraPosition(
                    // Centre of England — sensible default for a UK app.
                    target: LatLng(52.2, -1.5),
                    zoom: 6,
                  ),
                  markers: markers,
                ),
      bottomNavigationBar: const AppFooter(activeIndex: 4),
    );
  }
}
