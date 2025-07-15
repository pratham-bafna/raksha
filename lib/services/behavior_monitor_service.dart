import 'dart:async';
import '../models/raw_behavior_data.dart';
import '../models/behavior_data.dart';
import 'sensor_collector.dart';
import 'behavior_storage_service.dart';
import 'real_time_cloud_risk_service.dart';
import 'cloud_ml_service.dart';

class BehaviorMonitorService {
  static final BehaviorMonitorService _instance = BehaviorMonitorService._internal();
  factory BehaviorMonitorService() => _instance;
  BehaviorMonitorService._internal();

  final List<RawBehaviorData> _rawDataQueue = [];
  final List<BehaviorData> _normalizedDataQueue = [];
  final RealTimeCloudRiskService _cloudRiskService = RealTimeCloudRiskService();
  
  Timer? _timer;
  bool _isRunning = false;
  int _sessionId = 0;

  /// Stream of real-time risk assessments
  Stream<RiskAssessment> get riskStream => _cloudRiskService.riskStream;

  /// Initialize the service
  Future<void> initialize() async {
    await _cloudRiskService.initialize();
  }

  void start() {
    if (_isRunning) return;
    _isRunning = true;
    _timer = Timer.periodic(const Duration(minutes: 1), (_) => collectData());
    collectData(); // Collect immediately on start
  }

  void stop() {
    _timer?.cancel();
    _isRunning = false;
  }

  Future<void> collectData() async {
    print('🔄 Collecting new behavior data...');
    
    // Collect raw data
    RawBehaviorData rawData = await RawBehaviorData.collect();
    _rawDataQueue.add(rawData);

    // Normalize and store with session tracking
    _sessionId++;
    BehaviorData normalizedData = SensorCollector.normalize(
      rawData, 
      userId: 'current_user', // You can get from AuthService if needed
      sessionId: _sessionId,
    );
    _normalizedDataQueue.add(normalizedData);

    // Save to local storage AND trigger cloud-based risk assessment
    await BehaviorStorageService.saveBehaviorData(normalizedData);
    
    // Process with cloud ML service in real-time
    final riskAssessment = await _cloudRiskService.processNewBehaviorData(normalizedData);
    
    print('✅ Behavior data collected and risk assessed: ${riskAssessment.riskLevel.name}');
  }

  /// Manually trigger risk assessment for existing session
  Future<RiskAssessment> assessRisk(BehaviorData behaviorData) async {
    return await _cloudRiskService.processNewBehaviorData(behaviorData);
  }

  /// Check if cloud service is available
  bool get isCloudServiceAvailable => _cloudRiskService.isCloudServiceAvailable;

  List<RawBehaviorData> get rawDataQueue => List.unmodifiable(_rawDataQueue);
  List<BehaviorData> get normalizedDataQueue => List.unmodifiable(_normalizedDataQueue);

  void clear() {
    _rawDataQueue.clear();
    _normalizedDataQueue.clear();
  }
} 