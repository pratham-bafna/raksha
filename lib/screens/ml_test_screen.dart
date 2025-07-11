import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../models/behavior_data.dart';
import '../services/ml_model_service.dart';

class MLTestScreen extends StatefulWidget {
  const MLTestScreen({super.key});

  @override
  State<MLTestScreen> createState() => _MLTestScreenState();
}

class _MLTestScreenState extends State<MLTestScreen> {
  final MLModelService _mlService = MLModelService();
  final TextEditingController _csvController = TextEditingController();
  List<BehaviorData> _testSessions = [];
  List<RiskAssessment> _riskResults = [];
  bool _isLoading = false;
  bool _modelInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeModel();
  }

  Future<void> _initializeModel() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await _mlService.initializeModel();
      setState(() {
        _modelInitialized = true;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error initializing model: $e')),
      );
    }
  }

  Future<void> _loadCsvFromFile() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/behavior_data.csv');
      
      if (await file.exists()) {
        final content = await file.readAsString();
        _csvController.text = content;
        await _parseCsvAndTest(content);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No CSV file found. Export data first from Behavior Dashboard.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading CSV: $e')),
      );
    }
  }

  Future<void> _parseCsvAndTest(String csvContent) async {
    if (!_modelInitialized) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Model not initialized yet')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _testSessions.clear();
      _riskResults.clear();
    });

    try {
      final lines = csvContent.split('\n');
      if (lines.length < 2) {
        throw Exception('CSV must have header and at least one data row');
      }

      // Skip header row
      final dataLines = lines.skip(1).where((line) => line.trim().isNotEmpty);
      
      for (final line in dataLines) {
        final values = line.split(',');
        if (values.length >= BehaviorData.csvHeaders.length) {
          final behaviorData = _parseLineToeBehaviorData(values);
          if (behaviorData != null) {
            _testSessions.add(behaviorData);
          }
        }
      }

      // Test each session
      for (final session in _testSessions) {
        final riskAssessment = await _mlService.calculateRiskScore(session);
        _riskResults.add(riskAssessment);
        
        // Update UI progressively
        setState(() {});
      }

      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Analyzed ${_testSessions.length} sessions from CSV')),
      );

    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error parsing CSV: $e')),
      );
    }
  }

  BehaviorData? _parseLineToeBehaviorData(List<String> values) {
    try {
      return BehaviorData(
        tapDuration: double.parse(values[0]),
        swipeVelocity: double.parse(values[1]),
        touchPressure: double.parse(values[2]),
        tapIntervalAvg: double.parse(values[3]),
        accelVariance: double.parse(values[4]),
        accelVarianceMissing: int.parse(values[5]),
        gyroVariance: double.parse(values[6]),
        gyroVarianceMissing: int.parse(values[7]),
        batteryLevel: double.parse(values[8]),
        chargingState: int.parse(values[9]),
        brightnessLevel: double.parse(values[10]),
        screenOnTime: double.parse(values[11]),
        wifiIdHash: double.parse(values[12]),
        wifiInfoMissing: int.parse(values[13]),
        gpsLatitude: double.parse(values[14]),
        gpsLongitude: double.parse(values[15]),
        gpsLocationMissing: int.parse(values[16]),
        timeOfDaySin: double.parse(values[17]),
        timeOfDayCos: double.parse(values[18]),
        dayOfWeekMon: int.parse(values[19]),
        dayOfWeekTue: int.parse(values[20]),
        dayOfWeekWed: int.parse(values[21]),
        dayOfWeekThu: int.parse(values[22]),
        dayOfWeekFri: int.parse(values[23]),
        dayOfWeekSat: int.parse(values[24]),
        dayOfWeekSun: int.parse(values[25]),
        deviceOrientation: double.parse(values[26]),
        touchArea: double.parse(values[27]),
        touchEventCount: double.parse(values[28]),
        appUsageTime: double.parse(values[29]),
        timestamp: DateTime.now(),
        userId: 'csv_test_user',
        sessionId: null,
      );
    } catch (e) {
      print('Error parsing CSV line: $e');
      return null;
    }
  }

  Future<void> _generateSyntheticTest() async {
    if (!_modelInitialized) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Model not initialized yet')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _testSessions.clear();
      _riskResults.clear();
    });

    try {
      // Generate synthetic normal sessions
      for (int i = 0; i < 5; i++) {
        final normalSession = _generateNormalSyntheticSession();
        _testSessions.add(normalSession);
        final riskAssessment = await _mlService.calculateRiskScore(normalSession);
        _riskResults.add(riskAssessment);
      }

      // Generate synthetic anomalous sessions
      for (int i = 0; i < 3; i++) {
        final anomalousSession = _generateAnomalousSyntheticSession();
        _testSessions.add(anomalousSession);
        final riskAssessment = await _mlService.calculateRiskScore(anomalousSession);
        _riskResults.add(riskAssessment);
      }

      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Generated and analyzed 8 synthetic sessions')),
      );

    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error generating synthetic test: $e')),
      );
    }
  }

  BehaviorData _generateNormalSyntheticSession() {
    return BehaviorData(
      tapDuration: 0.15,
      swipeVelocity: 0.35,
      touchPressure: 0.6,
      tapIntervalAvg: 0.25,
      accelVariance: 0.2,
      accelVarianceMissing: 0,
      gyroVariance: 0.15,
      gyroVarianceMissing: 0,
      batteryLevel: 0.6,
      chargingState: 1,
      brightnessLevel: 0.4,
      screenOnTime: 0.1,
      wifiIdHash: 0.5,
      wifiInfoMissing: 0,
      gpsLatitude: 0.55,
      gpsLongitude: 0.31,
      gpsLocationMissing: 0,
      timeOfDaySin: 0.5,
      timeOfDayCos: 0.5,
      dayOfWeekMon: 1,
      dayOfWeekTue: 0,
      dayOfWeekWed: 0,
      dayOfWeekThu: 0,
      dayOfWeekFri: 0,
      dayOfWeekSat: 0,
      dayOfWeekSun: 0,
      deviceOrientation: 0.8,
      touchArea: 0.3,
      touchEventCount: 0.4,
      appUsageTime: 0.05,
      timestamp: DateTime.now(),
      userId: 'synthetic_normal',
      sessionId: null,
    );
  }

  BehaviorData _generateAnomalousSyntheticSession() {
    return BehaviorData(
      tapDuration: 0.95, // Very slow taps
      swipeVelocity: 0.05, // Very slow swipes
      touchPressure: 0.95, // Very high pressure
      tapIntervalAvg: 0.95, // Very long intervals
      accelVariance: 0.9, // High motion variance
      accelVarianceMissing: 0,
      gyroVariance: 0.9, // High gyro variance
      gyroVarianceMissing: 0,
      batteryLevel: 0.05, // Very low battery
      chargingState: 0,
      brightnessLevel: 0.95, // Very bright
      screenOnTime: 0.95, // Long screen time
      wifiIdHash: 0.1, // Different WiFi
      wifiInfoMissing: 0,
      gpsLatitude: 0.9, // Different location
      gpsLongitude: 0.9,
      gpsLocationMissing: 0,
      timeOfDaySin: -0.9, // Unusual time
      timeOfDayCos: -0.9,
      dayOfWeekMon: 0,
      dayOfWeekTue: 0,
      dayOfWeekWed: 0,
      dayOfWeekThu: 0,
      dayOfWeekFri: 0,
      dayOfWeekSat: 1, // Weekend usage
      dayOfWeekSun: 0,
      deviceOrientation: 0.1, // Different orientation
      touchArea: 0.9, // Very large touch area
      touchEventCount: 0.95, // Very high activity
      appUsageTime: 0.95, // Very long usage
      timestamp: DateTime.now(),
      userId: 'synthetic_anomalous',
      sessionId: null,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ML Model Test'),
        backgroundColor: const Color(0xFF667EEA),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Model status
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _modelInitialized ? Colors.green.withOpacity(0.1) : Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: _modelInitialized ? Colors.green : Colors.orange,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    _modelInitialized ? Icons.check_circle : Icons.pending,
                    color: _modelInitialized ? Colors.green : Colors.orange,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _modelInitialized ? 'ML Model: Ready' : 'ML Model: Initializing...',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Test buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isLoading ? null : _loadCsvFromFile,
                    icon: const Icon(Icons.file_open),
                    label: const Text('Test CSV Data'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF667EEA),
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isLoading ? null : _generateSyntheticTest,
                    icon: const Icon(Icons.science),
                    label: const Text('Synthetic Test'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purple,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Results summary
            if (_riskResults.isNotEmpty) ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Test Results Summary:',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildSummaryCard(
                          'Total Tested',
                          '${_riskResults.length}',
                          Colors.blue,
                        ),
                        _buildSummaryCard(
                          'Low Risk',
                          '${_riskResults.where((r) => r.riskLevel == RiskLevel.low).length}',
                          Colors.green,
                        ),
                        _buildSummaryCard(
                          'Medium Risk',
                          '${_riskResults.where((r) => r.riskLevel == RiskLevel.medium).length}',
                          Colors.orange,
                        ),
                        _buildSummaryCard(
                          'High Risk',
                          '${_riskResults.where((r) => r.riskLevel == RiskLevel.high).length}',
                          Colors.red,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Loading indicator
            if (_isLoading) ...[
              const Center(child: CircularProgressIndicator()),
              const SizedBox(height: 8),
              const Center(child: Text('Processing...')),
              const SizedBox(height: 16),
            ],

            // Results list
            Expanded(
              child: _riskResults.isEmpty
                  ? const Center(
                      child: Text(
                        'Run a test to see results',
                        style: TextStyle(color: Colors.grey),
                      ),
                    )
                  : ListView.builder(
                      itemCount: _riskResults.length,
                      itemBuilder: (context, index) {
                        final result = _riskResults[index];
                        final session = _testSessions[index];
                        return _buildResultCard(result, session, index);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard(String title, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            title,
            style: TextStyle(
              fontSize: 10,
              color: color.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultCard(RiskAssessment result, BehaviorData session, int index) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Test Session ${index + 1}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getRiskColor(result.riskLevel),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${result.riskLevel.name.toUpperCase()} RISK',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text('User ID: ${session.userId}'),
            Text('Risk Score: ${result.riskPercentage}'),
            Text(result.riskDescription),
            const SizedBox(height: 8),
            ExpansionTile(
              title: const Text('Detailed Breakdown'),
              children: [
                _buildRiskBreakdown('Touch Patterns', result.touchAnomalyScore),
                _buildRiskBreakdown('Motion Patterns', result.motionAnomalyScore),
                _buildRiskBreakdown('Device Context', result.contextAnomalyScore),
                _buildRiskBreakdown('Location', result.locationAnomalyScore),
                _buildRiskBreakdown('Time Patterns', result.timeAnomalyScore),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRiskBreakdown(String label, double score) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text('${(score * 100).toStringAsFixed(1)}%'),
        ],
      ),
    );
  }

  Color _getRiskColor(RiskLevel riskLevel) {
    switch (riskLevel) {
      case RiskLevel.low:
        return Colors.green;
      case RiskLevel.medium:
        return Colors.orange;
      case RiskLevel.high:
        return Colors.red;
    }
  }
}
