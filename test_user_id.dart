import 'lib/utils/user_id_generator.dart';

void main() {
  print('Testing User ID Generator:');
  print('');
  
  // Test examples
  print('Example user IDs:');
  final examples = UserIdGenerator.getExamples();
  examples.forEach((username, userId) {
    print('$username -> $userId');
  });
  
  print('');
  
  // Test validation
  print('Validation tests:');
  final testUserId = UserIdGenerator.generateUserId('testuser');
  print('Generated ID for "testuser": $testUserId');
  print('Is valid: ${UserIdGenerator.isValidUserId(testUserId)}');
  
  // Test edge cases
  print('');
  print('Edge case tests:');
  print('Empty username: ${UserIdGenerator.generateUserId('')}');
  print('Valid ID test: ${UserIdGenerator.isValidUserId('abcd1234efgh')}');
  print('Invalid ID test (too short): ${UserIdGenerator.isValidUserId('abc123')}');
  print('Invalid ID test (invalid chars): ${UserIdGenerator.isValidUserId('xyzthash1234')}');
}
