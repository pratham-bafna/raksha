import 'dart:convert';
import 'package:crypto/crypto.dart';

void main() {
  // Test hash function
  String hashPassword(String password) {
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  // Test with sample passwords
  final testPasswords = ['password123', 'mySecurePassword', 'test123'];
  
  print('Testing hash function:');
  for (final password in testPasswords) {
    final hash1 = hashPassword(password);
    final hash2 = hashPassword(password);
    print('Password: $password');
    print('Hash 1:   $hash1');
    print('Hash 2:   $hash2');
    print('Match:    ${hash1 == hash2}');
    print('Length:   ${hash1.length} characters');
    print('');
  }
  
  // Test with different passwords
  print('Testing different passwords:');
  final hash1 = hashPassword('password123');
  final hash2 = hashPassword('password124');
  print('Hash 1: $hash1');
  print('Hash 2: $hash2');
  print('Different passwords produce different hashes: ${hash1 != hash2}');
}
