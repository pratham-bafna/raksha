import 'dart:collection';
import 'dart:ui';
import 'package:flutter/gestures.dart';

class TouchEventService {
  static final TouchEventService instance = TouchEventService._internal();
  TouchEventService._internal();

  // Store events for the last minute
  final List<_TouchEvent> _events = [];
  double? _lastTapUpTime;

  void recordTap({required double duration, required double pressure}) {
    final now = DateTime.now().millisecondsSinceEpoch / 1000.0;
    double? interval;
    if (_lastTapUpTime != null) {
      interval = now - _lastTapUpTime!;
    }
    _lastTapUpTime = now;
    _events.add(_TouchEvent(
      type: _TouchType.tap,
      timestamp: now,
      duration: duration,
      pressure: pressure,
      interval: interval,
    ));
    _pruneOldEvents();
  }

  void recordSwipe({required double velocity, required double pressure}) {
    final now = DateTime.now().millisecondsSinceEpoch / 1000.0;
    _events.add(_TouchEvent(
      type: _TouchType.swipe,
      timestamp: now,
      velocity: velocity,
      pressure: pressure,
    ));
    _pruneOldEvents();
  }

  void _pruneOldEvents() {
    final cutoff = DateTime.now().millisecondsSinceEpoch / 1000.0 - 60.0;
    _events.removeWhere((e) => e.timestamp < cutoff);
  }

  Map<String, double?> getAndResetStats() {
    _pruneOldEvents();
    final taps = _events.where((e) => e.type == _TouchType.tap).toList();
    final swipes = _events.where((e) => e.type == _TouchType.swipe).toList();
    double? tapDuration = taps.isNotEmpty ? taps.map((e) => e.duration ?? 0).reduce((a, b) => a + b) / taps.length : null;
    double? tapIntervalAvg = taps.isNotEmpty ? taps.where((e) => e.interval != null).map((e) => e.interval!).fold(0.0, (a, b) => a + b) / (taps.where((e) => e.interval != null).length == 0 ? 1 : taps.where((e) => e.interval != null).length) : null;
    double? tapPressure = taps.isNotEmpty ? taps.map((e) => e.pressure ?? 0).reduce((a, b) => a + b) / taps.length : null;
    double? swipeVelocity = swipes.isNotEmpty ? swipes.map((e) => e.velocity ?? 0).reduce((a, b) => a + b) / swipes.length : null;
    double? swipePressure = swipes.isNotEmpty ? swipes.map((e) => e.pressure ?? 0).reduce((a, b) => a + b) / swipes.length : null;
    // For now, only tapPressure is used for touchPressure
    _events.clear();
    return {
      'tapDuration': tapDuration,
      'tapIntervalAvg': tapIntervalAvg,
      'touchPressure': tapPressure,
      'swipeVelocity': swipeVelocity,
      'screenOnTime': null, // To be implemented if needed
    };
  }
}

enum _TouchType { tap, swipe }

class _TouchEvent {
  final _TouchType type;
  final double timestamp;
  final double? duration;
  final double? pressure;
  final double? interval;
  final double? velocity;

  _TouchEvent({
    required this.type,
    required this.timestamp,
    this.duration,
    this.pressure,
    this.interval,
    this.velocity,
  });
}

class TouchEventTracker {
  static final TouchEventTracker instance = TouchEventTracker._internal();
  TouchEventTracker._internal();

  Offset? _lastPointerDownPos;
  int? _lastPointerDownTime;
  double? _lastPointerPressure;

  void onPointerDown(PointerDownEvent event) {
    _lastPointerDownPos = event.position;
    _lastPointerDownTime = event.timeStamp.inMilliseconds;
    _lastPointerPressure = event.pressure;
  }

  void onPointerUp(PointerUpEvent event) {
    if (_lastPointerDownTime != null) {
      final duration = (event.timeStamp.inMilliseconds - _lastPointerDownTime!) / 1000.0;
      final pressure = _lastPointerPressure ?? 1.0;
      TouchEventService.instance.recordTap(duration: duration, pressure: pressure);
    }
    _lastPointerDownPos = null;
    _lastPointerDownTime = null;
    _lastPointerPressure = null;
  }

  void onPointerMove(PointerMoveEvent event) {
    if (_lastPointerDownPos != null && _lastPointerDownTime != null) {
      final distance = (event.position - _lastPointerDownPos!).distance;
      final duration = (event.timeStamp.inMilliseconds - _lastPointerDownTime!) / 1000.0;
      if (duration > 0.05 && distance > 10) {
        final velocity = distance / duration;
        final pressure = event.pressure;
        TouchEventService.instance.recordSwipe(velocity: velocity, pressure: pressure);
        _lastPointerDownPos = event.position;
        _lastPointerDownTime = event.timeStamp.inMilliseconds;
        _lastPointerPressure = event.pressure;
      }
    }
  }
} 