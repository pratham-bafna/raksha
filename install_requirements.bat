@echo off
echo Installing requirements for Raksha Behavioral Anomaly Detection Model...
echo.

REM Check if Python is installed
python --version >nul 2>&1
if %errorlevel% neq 0 (
    echo Python is not installed or not in PATH
    echo Please install Python from https://python.org
    pause
    exit /b 1
)

REM Install required packages
echo Installing TensorFlow...
pip install tensorflow>=2.12.0

echo Installing scikit-learn...
pip install scikit-learn>=1.3.0

echo Installing pandas...
pip install pandas>=2.0.0

echo Installing numpy...
pip install numpy>=1.24.0

echo Installing joblib...
pip install joblib>=1.3.0

echo.
echo Installation completed!
echo You can now run the behavioral_anomaly_autoencoder.py script.
echo.
pause
