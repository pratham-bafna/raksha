import 'lib/utils/user_id_generator.dart';

void main() {
  print('User ID for deepam_goyal: ${UserIdGenerator.generateUserId('deepam_goyal')}');
  print('User ID for deepam: ${UserIdGenerator.generateUserId('deepam')}');
  print('User ID for goyal: ${UserIdGenerator.generateUserId('goyal')}');
  
  // Test validation
  final deepamGoyalId = UserIdGenerator.generateUserId('deepam_goyal');
  print('Is valid: ${UserIdGenerator.isValidUserId(deepamGoyalId)}');
}
