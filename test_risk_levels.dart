// Test the new risk level logic
void testRiskLevels() {
  print('Testing new risk level thresholds:');
  
  // Test cases
  List<double> testScores = [0.0, 0.2, 0.4, 0.49, 0.5, 0.6, 0.74, 0.75, 0.8, 1.0];
  
  for (double score in testScores) {
    String level;
    if (score < 0.5) {
      level = 'LOW';
    } else if (score < 0.75) {
      level = 'MEDIUM';
    } else {
      level = 'HIGH';
    }
    print('Score: ${score.toStringAsFixed(2)} -> Risk Level: $level');
  }
}

void main() {
  testRiskLevels();
}
