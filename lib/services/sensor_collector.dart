import 'dart:math';
import '../models/raw_behavior_data.dart';
import '../models/behavior_data.dart';

class SensorCollector {
  // GPS bounding box for normalization (example: India)
  static const double _minLat = 6.0;
  static const double _maxLat = 37.0;
  static const double _minLon = 68.0;
  static const double _maxLon = 97.0;

  static BehaviorData normalize(RawBehaviorData raw, {String? userId, int? sessionId}) {
    final now = DateTime.now();
    final hour = now.hour;
    final weekday = now.weekday; // 1 = Monday, 7 = Sunday

    // Time encoding
    final timeOfDaySin = sin(2 * pi * hour / 24);
    final timeOfDayCos = cos(2 * pi * hour / 24);

    // Day of week one-hot encoding
    final dayOfWeekMon = weekday == 1 ? 1 : 0;
    final dayOfWeekTue = weekday == 2 ? 1 : 0;
    final dayOfWeekWed = weekday == 3 ? 1 : 0;
    final dayOfWeekThu = weekday == 4 ? 1 : 0;
    final dayOfWeekFri = weekday == 5 ? 1 : 0;
    final dayOfWeekSat = weekday == 6 ? 1 : 0;
    final dayOfWeekSun = weekday == 7 ? 1 : 0;

    // Touch metrics normalization
    final tapDuration = _normalizeRange(raw.rawTapDuration, 0.05, 0.3);
    final swipeVelocity = _normalizeRange(raw.rawSwipeVelocity, 0.7, 1.0);
    final touchPressure = _normalizeRange(raw.rawTouchPressure, 0.1, 1.0);
    final tapIntervalAvg = _normalizeRange(raw.rawTapIntervalAvg, 0.1, 0.4);

    // Motion sensor variance calculation and normalization
    double accelVariance = 0.0;
    int accelVarianceMissing = raw.accelMissing ? 1 : 0;
    if (!raw.accelMissing && raw.rawAccelReadings != null) {
      accelVariance = _calculateVariance(raw.rawAccelReadings!);
      accelVariance = _normalizeRange(accelVariance, 0.0, 3.5);
    }

    double gyroVariance = 0.0;
    int gyroVarianceMissing = raw.gyroMissing ? 1 : 0;
    if (!raw.gyroMissing && raw.rawGyroReadings != null) {
      gyroVariance = _calculateVariance(raw.rawGyroReadings!);
      gyroVariance = _normalizeRange(gyroVariance, 0.0, 3.5);
    }

    // Device context normalization
    final batteryLevel = raw.rawBatteryLevel ?? 0.0; // Already 0-1 from collection
    final chargingState = raw.rawChargingState == true ? 1 : 0;
    final brightnessLevel = _normalizeRange(raw.rawBrightnessLevel, 0.0, 255.0);
    final screenOnTime = _normalizeRange(raw.rawScreenOnTime, 0.0, 600.0); // 10 minutes max

    // Network/Location normalization
    double wifiIdHash = 0.0;
    int wifiInfoMissing = raw.wifiInfoMissing ? 1 : 0;
    if (!raw.wifiInfoMissing && raw.rawWifiSsidHash != null) {
      final hash = int.tryParse(raw.rawWifiSsidHash!) ?? 0;
      wifiIdHash = _normalizeHash(hash);
    }

    double gpsLatitude = 0.0;
    double gpsLongitude = 0.0;
    int gpsLocationMissing = raw.gpsLocationMissing ? 1 : 0;
    if (!raw.gpsLocationMissing && raw.rawGpsLatitude != null && raw.rawGpsLongitude != null) {
      gpsLatitude = _normalizeLatitude(raw.rawGpsLatitude!);
      gpsLongitude = _normalizeLongitude(raw.rawGpsLongitude!);
    }

    return BehaviorData(
      tapDuration: tapDuration,
      swipeVelocity: swipeVelocity,
      touchPressure: touchPressure,
      tapIntervalAvg: tapIntervalAvg,
      accelVariance: accelVariance,
      accelVarianceMissing: accelVarianceMissing,
      gyroVariance: gyroVariance,
      gyroVarianceMissing: gyroVarianceMissing,
      batteryLevel: batteryLevel,
      chargingState: chargingState,
      brightnessLevel: brightnessLevel,
      screenOnTime: screenOnTime,
      wifiIdHash: wifiIdHash,
      wifiInfoMissing: wifiInfoMissing,
      gpsLatitude: gpsLatitude,
      gpsLongitude: gpsLongitude,
      gpsLocationMissing: gpsLocationMissing,
      timeOfDaySin: timeOfDaySin,
      timeOfDayCos: timeOfDayCos,
      dayOfWeekMon: dayOfWeekMon,
      dayOfWeekTue: dayOfWeekTue,
      dayOfWeekWed: dayOfWeekWed,
      dayOfWeekThu: dayOfWeekThu,
      dayOfWeekFri: dayOfWeekFri,
      dayOfWeekSat: dayOfWeekSat,
      dayOfWeekSun: dayOfWeekSun,
      deviceOrientation: _normalizeRange(raw.rawDeviceOrientation, -180.0, 180.0),
      touchArea: _normalizeRange(raw.rawTouchArea, 0.0, 10.0),
      touchEventCount: _normalizeRange(raw.rawTouchEventCount?.toDouble(), 0.0, 100.0),
      appUsageTime: _normalizeRange(raw.rawAppUsageTime, 0.0, 60.0),
      timestamp: raw.collectionTimestamp,
      userId: userId,
      sessionId: sessionId,
    );
  }

  static double _normalizeRange(double? value, double min, double max) {
    if (value == null) return 0.0;
    return ((value - min) / (max - min)).clamp(0.0, 1.0);
  }

  static double _calculateVariance(List<double> values) {
    if (values.isEmpty) return 0.0;
    final mean = values.reduce((a, b) => a + b) / values.length;
    final squaredDiffs = values.map((x) => pow(x - mean, 2));
    return squaredDiffs.reduce((a, b) => a + b) / values.length;
  }

  static double _normalizeHash(int hash) {
    // Normalize hash to 0-1 range
    return (hash % 1000000) / 1000000.0;
  }

  static double _normalizeLatitude(double lat) {
    return _normalizeRange(lat, _minLat, _maxLat);
  }

  static double _normalizeLongitude(double lon) {
    return _normalizeRange(lon, _minLon, _maxLon);
  }
} 