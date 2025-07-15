import requests

url = "http://your-env-name.eba-iq74dxhs.us-west-2.elasticbeanstalk.com/predict"
data = {
    "tap_duration": 1, "swipe_velocity": 2, "touch_pressure": 3, "tap_interval_avg": 4,
    "accel_variance": 5, "gyro_variance": 6, "battery_level": 7, "brightness_level": 8,
    "screen_on_time": 9, "time_of_day_sin": 0.5, "time_of_day_cos": 0.5,
    "wifi_id_hash": 123, "gps_latitude": 12.34, "gps_longitude": 56.78,
    "accel_variance_missing": 0, "gyro_variance_missing": 0, "charging_state": 1,
    "wifi_info_missing": 0, "gps_location_missing": 0,
    "day_of_week_mon": 0, "day_of_week_tue": 1, "day_of_week_wed": 0,
    "day_of_week_thu": 0, "day_of_week_fri": 0, "day_of_week_sat": 0, "day_of_week_sun": 0
}
response = requests.post(url, json=data)
print(response.json())