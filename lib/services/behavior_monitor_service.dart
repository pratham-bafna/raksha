import 'dart:async';
import 'package:flutter/widgets.dart';
import '../models/raw_behavior_data.dart';

class BehaviorMonitorService {
  static final BehaviorMonitorService _instance = BehaviorMonitorService._internal();
  factory BehaviorMonitorService() => _instance;
  BehaviorMonitorService._internal();

  final List<RawBehaviorData> _dataQueue = [];
  Timer? _timer;
  bool _isRunning = false;

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
    // TODO: Implement actual sensor/context data collection
    RawBehaviorData data = await RawBehaviorData.collect();
    _dataQueue.add(data);
  }

  List<RawBehaviorData> get dataQueue => List.unmodifiable(_dataQueue);

  void clear() {
    _dataQueue.clear();
  }
} 