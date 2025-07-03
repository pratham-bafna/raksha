import 'dart:math';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:battery_plus/battery_plus.dart';
import 'package:screen_brightness/screen_brightness.dart';
import 'package:location/location.dart' as loc;
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/services.dart';
import '../services/touch_event_service.dart';

class RawBehaviorData {
  // Touch
  final double? rawTapDuration;
  final double? rawSwipeVelocity;
  final double? rawTouchPressure;
  final double? rawTapIntervalAvg;

  // Motion sensors
  final List<double>? rawAccelReadings; // e.g., [x, y, z] samples
  final bool accelMissing;
  final List<double>? rawGyroReadings; // e.g., [x, y, z] samples
  final bool gyroMissing;

  // Device context
  final double? rawBatteryLevel;
  final bool? rawChargingState;
  final double? rawBrightnessLevel;
  final double? rawScreenOnTime;

  // Network/Location
  final String? rawWifiSsidHash;
  final bool wifiInfoMissing;
  final double? rawGpsLatitude;
  final double? rawGpsLongitude;
  final bool gpsLocationMissing;

  static const MethodChannel _wifiChannel = MethodChannel('behavior/wifi');

  RawBehaviorData({
    this.rawTapDuration,
    this.rawSwipeVelocity,
    this.rawTouchPressure,
    this.rawTapIntervalAvg,
    this.rawAccelReadings,
    this.accelMissing = false,
    this.rawGyroReadings,
    this.gyroMissing = false,
    this.rawBatteryLevel,
    this.rawChargingState,
    this.rawBrightnessLevel,
    this.rawScreenOnTime,
    this.rawWifiSsidHash,
    this.wifiInfoMissing = false,
    this.rawGpsLatitude,
    this.rawGpsLongitude,
    this.gpsLocationMissing = false,
  });

  static Future<RawBehaviorData> collect() async {
    // Touch metrics
    final touchStats = TouchEventService.instance.getAndResetStats();

    // Accelerometer/Gyroscope
    List<double>? accel;
    bool accelMissing = false;
    List<double>? gyro;
    bool gyroMissing = false;
    try {
      final accelEvent = await accelerometerEvents.first.timeout(const Duration(milliseconds: 500));
      accel = [accelEvent.x, accelEvent.y, accelEvent.z];
    } catch (_) {
      accelMissing = true;
    }
    try {
      final gyroEvent = await gyroscopeEvents.first.timeout(const Duration(milliseconds: 500));
      gyro = [gyroEvent.x, gyroEvent.y, gyroEvent.z];
    } catch (_) {
      gyroMissing = true;
    }

    // Battery/Charging
    double? batteryLevel;
    bool? chargingState;
    try {
      final battery = Battery();
      batteryLevel = (await battery.batteryLevel) / 100.0;
      final state = await battery.batteryState;
      chargingState = state == BatteryState.charging || state == BatteryState.full;
    } catch (_) {}

    // Brightness
    double? brightnessLevel;
    try {
      brightnessLevel = await ScreenBrightness().current;
    } catch (_) {}

    // GPS
    double? gpsLat;
    double? gpsLong;
    bool gpsMissing = false;
    try {
      final location = loc.Location();
      final hasPerm = await location.hasPermission();
      if (hasPerm == loc.PermissionStatus.granted) {
        final pos = await location.getLocation();
        gpsLat = pos.latitude;
        gpsLong = pos.longitude;
      } else {
        gpsMissing = true;
      }
    } catch (_) {
      gpsMissing = true;
    }

    // Wi-Fi SSID hash
    String? wifiSsidHash;
    bool wifiMissing = false;
    try {
      final connectivity = Connectivity();
      final result = await connectivity.checkConnectivity();
      if (result == ConnectivityResult.wifi) {
        final ssid = await _wifiChannel.invokeMethod<String>('getWifiSsid');
        if (ssid != null) {
          wifiSsidHash = ssid.hashCode.toString();
        } else {
          wifiMissing = true;
        }
      } else {
        wifiMissing = true;
      }
    } catch (_) {
      wifiMissing = true;
    }

    return RawBehaviorData(
      rawTapDuration: touchStats['tapDuration'],
      rawSwipeVelocity: touchStats['swipeVelocity'],
      rawTouchPressure: touchStats['touchPressure'],
      rawTapIntervalAvg: touchStats['tapIntervalAvg'],
      rawAccelReadings: accel,
      accelMissing: accelMissing,
      rawGyroReadings: gyro,
      gyroMissing: gyroMissing,
      rawBatteryLevel: batteryLevel,
      rawChargingState: chargingState,
      rawBrightnessLevel: brightnessLevel,
      rawScreenOnTime: touchStats['screenOnTime'],
      rawWifiSsidHash: wifiSsidHash,
      wifiInfoMissing: wifiMissing,
      rawGpsLatitude: gpsLat,
      rawGpsLongitude: gpsLong,
      gpsLocationMissing: gpsMissing,
    );
  }
} 