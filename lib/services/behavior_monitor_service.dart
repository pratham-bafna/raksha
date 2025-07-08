import 'dart:async';
import '../models/raw_behavior_data.dart';
import '../models/behavior_data.dart';
import 'sensor_collector.dart';
import 'behavior_storage_service.dart';

class BehaviorMonitorService {
  static final BehaviorMonitorService _instance = BehaviorMonitorService._internal();
  factory BehaviorMonitorService() => _instance;
  BehaviorMonitorService._internal();

  final List<RawBehaviorData> _rawDataQueue = [];
  final List<BehaviorData> _normalizedDataQueue = [];
  Timer? _timer;
  bool _isRunning = false;
  int _sessionId = 0;

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

  void collectData() async {
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

    // Save to local storage
    await BehaviorStorageService.saveBehaviorData(normalizedData);
  }

  List<RawBehaviorData> get rawDataQueue => List.unmodifiable(_rawDataQueue);
  List<BehaviorData> get normalizedDataQueue => List.unmodifiable(_normalizedDataQueue);

  void clear() {
    _rawDataQueue.clear();
    _normalizedDataQueue.clear();
  }
} 