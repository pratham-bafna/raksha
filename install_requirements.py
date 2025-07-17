#!/usr/bin/env python3
"""
Installation script for Raksha Behavioral Anomaly Detection Model
Run this script first to install required dependencies
"""

import subprocess
import sys
import os

def install_package(package):
    """Install a package using pip"""
    try:
        subprocess.check_call([sys.executable, "-m", "pip", "install", package])
        print(f"✅ Successfully installed {package}")
        return True
    except subprocess.CalledProcessError:
        print(f"❌ Failed to install {package}")
        return False

def main():
    print("🔧 Installing dependencies for Raksha Behavioral Anomaly Detection Model...")
    print("=" * 60)
    
    # Required packages
    packages = [
        "tensorflow>=2.12.0",
        "scikit-learn>=1.3.0", 
        "pandas>=2.0.0",
        "numpy>=1.24.0",
        "joblib>=1.3.0"
    ]
    
    failed_packages = []
    
    for package in packages:
        print(f"\nInstalling {package}...")
        if not install_package(package):
            failed_packages.append(package)
    
    print("\n" + "=" * 60)
    if failed_packages:
        print(f"❌ Failed to install: {', '.join(failed_packages)}")
        print("Please install these packages manually using:")
        for package in failed_packages:
            print(f"  pip install {package}")
    else:
        print("✅ All packages installed successfully!")
        print("\nYou can now run the behavioral_anomaly_autoencoder.py script.")
        
        # Check if training data file exists
        data_file = r"C:\Users\Dell\Downloads\behavioral_training_data_6000_correlated.csv"
        if os.path.exists(data_file):
            print(f"✅ Training data file found: {data_file}")
        else:
            print(f"⚠️  Training data file not found: {data_file}")
            print("Please ensure the training data file is in the correct location.")

if __name__ == "__main__":
    main()
