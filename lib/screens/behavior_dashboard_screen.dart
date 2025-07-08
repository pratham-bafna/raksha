import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:io';
import 'dart:convert';
import '../models/behavior_data.dart';
import '../services/behavior_storage_service.dart';

class BehaviorDashboardScreen extends StatefulWidget {
  const BehaviorDashboardScreen({super.key});

  @override
  State<BehaviorDashboardScreen> createState() => _BehaviorDashboardScreenState();
}

class _BehaviorDashboardScreenState extends State<BehaviorDashboardScreen> {
  List<BehaviorData> _behaviorDataList = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final data = await BehaviorStorageService.getAllBehaviorData();
      setState(() {
        _behaviorDataList = data.reversed.toList(); // Show newest first
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading data: $e')),
      );
    }
  }

  Future<void> _exportJson() async {
    try {
      final data = await BehaviorStorageService.getAllBehaviorData();
      final jsonData = data.map((item) => item.toJson()).toList();
      final jsonString = jsonEncode(jsonData);

      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/behavior_data.json');
      await file.writeAsString(jsonString);

      await Share.shareXFiles(
        [XFile(file.path)],
        text: 'Behavior Biometrics Data (JSON)',
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error exporting JSON: $e')),
      );
    }
  }

  Future<void> _exportCsv() async {
    try {
      final data = await BehaviorStorageService.getAllBehaviorData();
      if (data.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No data to export')),
        );
        return;
      }

      final csvBuffer = StringBuffer();
      
      // Add headers
      csvBuffer.writeln(BehaviorData.csvHeaders.join(','));

      // Add data rows
      for (final item in data) {
        csvBuffer.writeln(item.toCsvRow().join(','));
      }

      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/behavior_data.csv');
      await file.writeAsString(csvBuffer.toString());

      await Share.shareXFiles(
        [XFile(file.path)],
        text: 'Behavior Biometrics Data (CSV)',
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error exporting CSV: $e')),
      );
    }
  }

  Future<void> _clearData() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear All Data'),
        content: const Text('Are you sure you want to clear all behavior data? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Clear'),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await BehaviorStorageService.clearAllData();
        setState(() {
          _behaviorDataList.clear();
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('All data cleared')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error clearing data: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Behavior Dashboard'),
        backgroundColor: const Color(0xFF667EEA),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
          ),
        ],
      ),
      body: Column(
        children: [
          // Action buttons
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _exportJson,
                    icon: const Icon(Icons.file_download),
                    label: const Text('Export JSON'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF667EEA),
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _exportCsv,
                    icon: const Icon(Icons.table_chart),
                    label: const Text('Export CSV'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF667EEA),
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _clearData,
                    icon: const Icon(Icons.delete_forever),
                    label: const Text('Clear Data'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Data count
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Text(
                  'Total Sessions: ${_behaviorDataList.length}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 8),
          
          // Data list
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _behaviorDataList.isEmpty
                    ? const Center(
                        child: Text(
                          'No behavior data available',
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                      )
                    : ListView.builder(
                        itemCount: _behaviorDataList.length,
                        itemBuilder: (context, index) {
                          final data = _behaviorDataList[index];
                          return _buildDataCard(data, index);
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildDataCard(BehaviorData data, int index) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Session ${_behaviorDataList.length - index}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF667EEA),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'Behavior Data',
                    style: TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            
            // Touch metrics
            _buildMetricRow('Tap Duration', '${(data.tapDuration * 100).toStringAsFixed(1)}%'),
            _buildMetricRow('Swipe Velocity', '${(data.swipeVelocity * 100).toStringAsFixed(1)}%'),
            _buildMetricRow('Touch Pressure', '${(data.touchPressure * 100).toStringAsFixed(1)}%'),
            _buildMetricRow('Tap Interval Avg', '${(data.tapIntervalAvg * 100).toStringAsFixed(1)}%'),
            _buildMetricRow('Touch Area', '${(data.touchArea * 100).toStringAsFixed(1)}%'),
            _buildMetricRow('Touch Events', '${data.touchEventCount.toStringAsFixed(0)}'),
            
            const Divider(),
            
            // Motion & Orientation
            _buildMetricRow('Accel Variance', '${(data.accelVariance * 100).toStringAsFixed(1)}%'),
            _buildMetricRow('Gyro Variance', '${(data.gyroVariance * 100).toStringAsFixed(1)}%'),
            _buildMetricRow('Device Orientation', '${(data.deviceOrientation * 180).toStringAsFixed(1)}°'),
            
            const Divider(),
            
            // Device context
            _buildMetricRow('Battery Level', '${(data.batteryLevel * 100).toStringAsFixed(1)}%'),
            _buildMetricRow('Charging', data.chargingState == 1 ? 'Yes' : 'No'),
            _buildMetricRow('Brightness', '${(data.brightnessLevel * 100).toStringAsFixed(1)}%'),
            _buildMetricRow('Screen On Time', '${data.screenOnTime.toStringAsFixed(1)}s'),
            _buildMetricRow('App Usage Time', '${data.appUsageTime.toStringAsFixed(1)}s'),
            
            const Divider(),
            
            // Network & Location
            _buildMetricRow('Wi-Fi Available', data.wifiInfoMissing == 0 ? 'Yes' : 'No'),
            _buildMetricRow('GPS Available', data.gpsLocationMissing == 0 ? 'Yes' : 'No'),
            if (data.gpsLocationMissing == 0) ...[
              _buildMetricRow('Latitude', '${(data.gpsLatitude * 100).toStringAsFixed(1)}%'),
              _buildMetricRow('Longitude', '${(data.gpsLongitude * 100).toStringAsFixed(1)}%'),
            ],
            
            const Divider(),
            
            // Time context
            _buildMetricRow('Time of Day (Sin)', '${data.timeOfDaySin.toStringAsFixed(3)}'),
            _buildMetricRow('Time of Day (Cos)', '${data.timeOfDayCos.toStringAsFixed(3)}'),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 14,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
} 