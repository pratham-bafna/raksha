#!/usr/bin/env python3
"""
Test script for Cloud ML API with 95% threshold approach.
This script tests various risk score values and shows how they map to risk levels.
"""
import requests
import json

# Cloud ML API endpoint (replace with actual URL)
CLOUD_ML_URL = "https://your-cloud-ml-api.com/predict"

def normalize_risk_score(raw_score, max_expected=0.1):
    """
    Normalize risk score for 95% threshold approach.
    Since typical scores are around 0.05, we use 0.1 as the max.
    """
    normalized = min(raw_score / max_expected, 1.0)
    return normalized

def determine_risk_level(normalized_score):
    """
    Determine risk level using 95% threshold approach.
    Most scores will be low, with higher thresholds for medium/high.
    """
    if normalized_score >= 0.8:  # >= 0.08 raw score
        return "HIGH"
    elif normalized_score >= 0.6:  # >= 0.06 raw score  
        return "MEDIUM"
    else:
        return "LOW"

def test_risk_scoring():
    """Test various risk score scenarios"""
    test_scores = [
        0.01,  # Very low
        0.03,  # Normal low
        0.05,  # Typical normal
        0.06,  # Medium threshold
        0.07,  # Medium-high
        0.08,  # High threshold
        0.09,  # High
        0.10,  # Very high
    ]
    
    print("Testing 95% Threshold Risk Scoring:")
    print("=" * 50)
    print(f"{'Raw Score':<12} {'Normalized':<12} {'Risk Level':<12}")
    print("-" * 50)
    
    for raw_score in test_scores:
        normalized = normalize_risk_score(raw_score)
        risk_level = determine_risk_level(normalized)
        print(f"{raw_score:<12.3f} {normalized:<12.3f} {risk_level:<12}")
    
    print("\nRisk Level Distribution (95% threshold):")
    print("- LOW:    < 0.06 raw score (< 60% normalized)")
    print("- MEDIUM: 0.06-0.08 raw score (60-80% normalized)")  
    print("- HIGH:   >= 0.08 raw score (>= 80% normalized)")

def test_api_call():
    """Test actual API call (if endpoint is available)"""
    sample_data = {
        "touch_pressure": [0.5, 0.6, 0.4],
        "touch_area": [10.2, 11.1, 9.8],
        "swipe_velocity": [150.0, 160.0, 140.0],
        "accelerometer": [[0.1, 0.2, 9.8], [0.15, 0.18, 9.85]],
        "gyroscope": [[0.01, 0.02, 0.01], [0.015, 0.018, 0.012]]
    }
    
    try:
        response = requests.post(CLOUD_ML_URL, json=sample_data, timeout=5)
        if response.status_code == 200:
            result = response.json()
            raw_score = result.get('risk_score', 0.05)
            anomaly = result.get('anomaly', 0)
            
            normalized = normalize_risk_score(raw_score)
            risk_level = determine_risk_level(normalized)
            
            print(f"\nAPI Response:")
            print(f"Raw Score: {raw_score:.3f}")
            print(f"Anomaly: {anomaly}")
            print(f"Normalized: {normalized:.3f}")
            print(f"Risk Level: {risk_level}")
        else:
            print(f"API Error: {response.status_code}")
    except requests.RequestException as e:
        print(f"API Connection Error: {e}")
        print("Using simulated response for testing...")
        
        # Simulate typical cloud ML response
        simulated_score = 0.05  # Typical response
        normalized = normalize_risk_score(simulated_score)
        risk_level = determine_risk_level(normalized)
        
        print(f"\nSimulated Response:")
        print(f"Raw Score: {simulated_score:.3f}")
        print(f"Normalized: {normalized:.3f}")
        print(f"Risk Level: {risk_level}")

if __name__ == "__main__":
    test_risk_scoring()
    test_api_call()
