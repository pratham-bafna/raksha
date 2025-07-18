import 'dart:convert';
import 'package:http/http.dart' as http;

void main() async {
  print('🔍 Debugging EC2 server connectivity...');
  
  // Step 1: Test basic server connectivity
  print('\n1. Testing basic server connectivity...');
  try {
    final response = await http.get(
      Uri.parse('http://43.204.97.149'),
    ).timeout(Duration(seconds: 10));
    print('✅ Server is reachable - Status: ${response.statusCode}');
    print('📋 Response: ${response.body.substring(0, 100)}...');
  } catch (e) {
    print('❌ Server is not reachable: $e');
    return;
  }
  
  // Step 2: Test if predict endpoint exists (with known user)
  print('\n2. Testing predict endpoint structure...');
  try {
    final response = await http.post(
      Uri.parse('http://43.204.97.149/predict/e52baba8acbc'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({"test": "data"}),
    ).timeout(Duration(seconds: 10));
    print('📊 Predict endpoint response - Status: ${response.statusCode}');
    print('📋 Response: ${response.body}');
  } catch (e) {
    print('❌ Predict endpoint error: $e');
  }
  
  // Step 3: Test with minimal valid data
  print('\n3. Testing with minimal behavioral data...');
  final minimalData = {
    "tap_duration": 0.15,
    "swipe_velocity": 0.35,
    "touch_pressure": 0.6,
    "tap_interval_avg": 0.25,
    "accel_variance": 0.2,
    "gyro_variance": 0.15,
    "battery_level": 0.75,
    "brightness_level": 0.5,
    "screen_on_time": 0.1,
    "time_of_day_sin": 0.5,
    "time_of_day_cos": 0.5,
    "wifi_id_hash": 0.5,
    "gps_latitude": 0.55,
    "gps_longitude": 0.31,
    "accel_variance_missing": 0,
    "gyro_variance_missing": 0,
    "charging_state": 1,
    "wifi_info_missing": 0,
    "gps_location_missing": 0,
    "day_of_week_mon": 0,
    "day_of_week_tue": 1,
    "day_of_week_wed": 0,
    "day_of_week_thu": 0,
    "day_of_week_fri": 0,
    "day_of_week_sat": 0,
    "day_of_week_sun": 0,
    "device_orientation": 0.8,
    "touch_area": 0.3,
    "touch_event_count": 5,
    "app_usage_time": 0.05
  };
  
  try {
    final response = await http.post(
      Uri.parse('http://43.204.97.149/predict/e52baba8acbc'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode(minimalData),
    ).timeout(Duration(seconds: 10));
    
    print('✅ Full test - Status: ${response.statusCode}');
    print('📋 Response: ${response.body}');
    
    if (response.statusCode == 200) {
      final result = jsonDecode(response.body);
      print('🎯 Anomaly: ${result['anomaly']}');
      print('📈 Risk Score: ${result['risk_score']}');
    }
  } catch (e) {
    print('❌ Full test error: $e');
  }
}
