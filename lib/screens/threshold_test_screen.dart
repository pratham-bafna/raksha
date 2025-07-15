import 'package:flutter/material.dart';
import '../services/cloud_ml_service.dart';
import '../models/behavior_data.dart';

/// Demo screen to test the 95% threshold approach for risk scoring
class ThresholdTestScreen extends StatefulWidget {
  const ThresholdTestScreen({super.key});

  @override
  State<ThresholdTestScreen> createState() => _ThresholdTestScreenState();
}

class _ThresholdTestScreenState extends State<ThresholdTestScreen> {
  final CloudMLService _cloudML = CloudMLService();
  final List<Map<String, dynamic>> _testResults = [];
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('95% Threshold Test'),
        backgroundColor: const Color(0xFF667EEA),
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Info card
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.blue.withOpacity(0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '95% Threshold Approach',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Normal scores: ~0.05 (95% of users)\n'
                  'Medium risk: >0.06 (20% above normal)\n'
                  'High risk: >0.08 (60% above normal)',
                  style: TextStyle(fontSize: 14),
                ),
              ],
            ),
          ),
          
          // Test buttons
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : () => _testScenario('normal'),
                        child: const Text('Test Normal (0.05)'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : () => _testScenario('medium'),
                        child: const Text('Test Medium (0.07)'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : () => _testScenario('high'),
                        child: const Text('Test High (0.10)'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _clearResults,
                        child: const Text('Clear Results'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Results list
          Expanded(
            child: _testResults.isEmpty
                ? const Center(
                    child: Text(
                      'No test results yet.\nTry the test buttons above.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _testResults.length,
                    itemBuilder: (context, index) {
                      final result = _testResults[index];
                      return _buildResultCard(result);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultCard(Map<String, dynamic> result) {
    final riskLevel = result['riskLevel'] as RiskLevel;
    final rawScore = result['rawScore'] as double;
    final normalizedScore = result['normalizedScore'] as double;
    final anomaly = result['anomaly'] as int;
    final scenario = result['scenario'] as String;
    final timestamp = result['timestamp'] as DateTime;
    
    final color = _getRiskColor(riskLevel);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                _getRiskIcon(riskLevel),
                color: color,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                '$scenario Scenario',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              const Spacer(),
              Text(
                riskLevel.name.toUpperCase(),
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text('Raw Score: ${rawScore.toStringAsFixed(6)}'),
          Text('Normalized: ${(normalizedScore * 100).toStringAsFixed(1)}%'),
          Text('Anomaly Flag: $anomaly'),
          Text('Time: ${_formatTime(timestamp)}'),
        ],
      ),
    );
  }

  Future<void> _testScenario(String scenario) async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Create test behavior data with different risk levels
      final testData = _createTestBehaviorData(scenario);
      
      // Get risk assessment from cloud
      final riskAssessment = await _cloudML.calculateRiskScore(testData);
      
      // Extract details from cloud response
      final cloudResponse = riskAssessment.cloudResponse;
      final rawScore = cloudResponse?['risk_score'] ?? 0.0;
      final anomaly = cloudResponse?['anomaly'] ?? 0;
      
      setState(() {
        _testResults.insert(0, {
          'scenario': scenario,
          'riskLevel': riskAssessment.riskLevel,
          'rawScore': rawScore,
          'normalizedScore': riskAssessment.riskScore,
          'anomaly': anomaly,
          'timestamp': DateTime.now(),
        });
      });
      
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Test failed: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  BehaviorData _createTestBehaviorData(String scenario) {
    // Base normal behavior data
    final baseData = {
      'tapDuration': 0.15,
      'swipeVelocity': 0.35,
      'touchPressure': 0.6,
      'tapIntervalAvg': 0.25,
      'accelVariance': 0.2,
      'gyroVariance': 0.15,
      'batteryLevel': 0.75,
      'brightnessLevel': 0.5,
      'screenOnTime': 0.1,
      'timeOfDaySin': 0.5,
      'timeOfDayCos': 0.5,
      'wifiIdHash': 0.5,
      'gpsLatitude': 0.55,
      'gpsLongitude': 0.31,
      'deviceOrientation': 0.8,
      'touchArea': 0.3,
      'touchEventCount': 5.0,
      'appUsageTime': 0.05,
    };

    // Modify data based on scenario to trigger different risk levels
    switch (scenario) {
      case 'medium':
        // Make it slightly suspicious
        baseData['tapDuration'] = 0.25;  // Slower taps
        baseData['swipeVelocity'] = 0.15; // Slower swipes
        baseData['touchPressure'] = 0.85; // Higher pressure
        break;
      case 'high':
        // Make it very suspicious
        baseData['tapDuration'] = 0.9;   // Very slow taps
        baseData['swipeVelocity'] = 0.05; // Very slow swipes
        baseData['touchPressure'] = 0.95; // Very high pressure
        baseData['accelVariance'] = 0.8;  // High motion variance
        baseData['gyroVariance'] = 0.9;   // High rotation variance
        break;
      // 'normal' case uses base data as-is
    }

    return BehaviorData(
      tapDuration: baseData['tapDuration']!,
      swipeVelocity: baseData['swipeVelocity']!,
      touchPressure: baseData['touchPressure']!,
      tapIntervalAvg: baseData['tapIntervalAvg']!,
      accelVariance: baseData['accelVariance']!,
      accelVarianceMissing: 0,
      gyroVariance: baseData['gyroVariance']!,
      gyroVarianceMissing: 0,
      batteryLevel: baseData['batteryLevel']!,
      chargingState: 1,
      brightnessLevel: baseData['brightnessLevel']!,
      screenOnTime: baseData['screenOnTime']!,
      wifiIdHash: baseData['wifiIdHash']!,
      wifiInfoMissing: 0,
      gpsLatitude: baseData['gpsLatitude']!,
      gpsLongitude: baseData['gpsLongitude']!,
      gpsLocationMissing: 0,
      timeOfDaySin: baseData['timeOfDaySin']!,
      timeOfDayCos: baseData['timeOfDayCos']!,
      dayOfWeekMon: 0,
      dayOfWeekTue: 1,
      dayOfWeekWed: 0,
      dayOfWeekThu: 0,
      dayOfWeekFri: 0,
      dayOfWeekSat: 0,
      dayOfWeekSun: 0,
      deviceOrientation: baseData['deviceOrientation']!,
      touchArea: baseData['touchArea']!,
      touchEventCount: baseData['touchEventCount']!,
      appUsageTime: baseData['appUsageTime']!,
      timestamp: DateTime.now(),
      userId: 'threshold_test_user',
      sessionId: DateTime.now().millisecondsSinceEpoch,
    );
  }

  void _clearResults() {
    setState(() {
      _testResults.clear();
    });
  }

  IconData _getRiskIcon(RiskLevel riskLevel) {
    switch (riskLevel) {
      case RiskLevel.low:
        return Icons.security;
      case RiskLevel.medium:
        return Icons.warning;
      case RiskLevel.high:
        return Icons.error;
    }
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

  String _formatTime(DateTime dateTime) {
    return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}:${dateTime.second.toString().padLeft(2, '0')}';
  }
}
