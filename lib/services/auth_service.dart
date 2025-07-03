import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:raksha/models/user.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final LocalAuthentication _localAuth = LocalAuthentication();
  static const String _userKey = 'current_user';
  static const String _tokenKey = 'auth_token';

  User? _currentUser;
  String? _authToken;

  User? get currentUser => _currentUser;
  String? get authToken => _authToken;
  bool get isLoggedIn => _currentUser != null && _authToken != null;

  Future<void> initialize() async {
    await _loadUserFromStorage();
  }

  Future<bool> login(String username, String password) async {
    try {
      if (username.isEmpty || password.isEmpty) {
        return false;
      }

      final userProfiles = {
        'deepam': {
          'password': 'deepam123',
          'name': 'Deepam Goyal',
          'email': 'deepam.goyal@example.com',
          'phone': '+91 98765 43210',
          'accountNumber': '1234567890123456',
          'balance': 45000.00,
          'branch': 'Mumbai Main Branch',
          'ifsc': 'SBI0001234',
        },
        'pratham': {
          'password': 'pratham123',
          'name': 'Pratham Sharma',
          'email': 'pratham.sharma@example.com',
          'phone': '+91 98765 43211',
          'accountNumber': '2345678901234567',
          'balance': 32000.00,
          'branch': 'Delhi Central Branch',
          'ifsc': 'HDFC0005678',
        },
        'atharva': {
          'password': 'atharva123',
          'name': 'Atharva Patel',
          'email': 'atharva.patel@example.com',
          'phone': '+91 98765 43212',
          'accountNumber': '3456789012345678',
          'balance': 78000.00,
          'branch': 'Bangalore Tech Branch',
          'ifsc': 'ICICI0009012',
        },
        'ashit': {
          'password': 'ashit123',
          'name': 'Ashit Kumar',
          'email': 'ashit.kumar@example.com',
          'phone': '+91 98765 43213',
          'accountNumber': '4567890123456789',
          'balance': 156000.00,
          'branch': 'Chennai South Branch',
          'ifsc': 'AXIS0003456',
        },
        'arijit': {
          'password': 'arijit123',
          'name': 'Arijit Singh',
          'email': 'arijit.singh@example.com',
          'phone': '+91 98765 43214',
          'accountNumber': '5678901234567890',
          'balance': 92000.00,
          'branch': 'Kolkata East Branch',
          'ifsc': 'PNB0007890',
        },
      };

      if (!userProfiles.containsKey(username)) {
        return false;
      }
      final userData = userProfiles[username]!;
      if (userData['password'] != password) {
        return false;
      }

      await Future.delayed(const Duration(seconds: 1));

      final user = User(
        id: 'user_${username}_${DateTime.now().millisecondsSinceEpoch}',
        username: username,
        name: userData['name'] as String,
        email: userData['email'] as String,
        phoneNumber: userData['phone'] as String,
        lastLogin: DateTime.now(),
        isBiometricEnabled: false,
      );

      final token = _generateToken(user.id);

      await _saveUserToStorage(user, token);
      _currentUser = user;
      _authToken = token;

      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> loginWithBiometrics() async {
    try {
      final isAvailable = await _localAuth.canCheckBiometrics;
      if (!isAvailable) return false;

      final isAuthenticated = await _localAuth.authenticate(
        localizedReason: 'Please authenticate to login',
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
        ),
      );

      if (isAuthenticated) {
        // Load saved user data
        await _loadUserFromStorage();
        return _currentUser != null;
      }

      return false;
    } catch (e) {
      print('Biometric authentication error: $e');
      return false;
    }
  }

  Future<bool> enableBiometrics() async {
    try {
      final isAvailable = await _localAuth.canCheckBiometrics;
      if (!isAvailable) return false;

      final isAuthenticated = await _localAuth.authenticate(
        localizedReason: 'Please authenticate to enable biometric login',
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
        ),
      );

      if (isAuthenticated && _currentUser != null) {
        final updatedUser = _currentUser!.copyWith(isBiometricEnabled: true);
        await _saveUserToStorage(updatedUser, _authToken!);
        _currentUser = updatedUser;
        return true;
      }

      return false;
    } catch (e) {
      print('Enable biometrics error: $e');
      return false;
    }
  }

  Future<void> logout() async {
    _currentUser = null;
    _authToken = null;
    await _clearStorage();
  }

  Future<void> _saveUserToStorage(User user, String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userKey, jsonEncode(user.toJson()));
    await prefs.setString(_tokenKey, token);
  }

  Future<void> _loadUserFromStorage() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString(_userKey);
    final token = prefs.getString(_tokenKey);

    if (userJson != null && token != null) {
      try {
        final userMap = jsonDecode(userJson) as Map<String, dynamic>;
        _currentUser = User.fromJson(userMap);
        _authToken = token;
      } catch (e) {
        print('Error loading user from storage: $e');
        await _clearStorage();
      }
    }
  }

  Future<void> _clearStorage() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userKey);
    await prefs.remove(_tokenKey);
  }

  String _generateToken(String userId) {
    final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    final data = '$userId:$timestamp';
    final bytes = utf8.encode(data);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  String _hashPassword(String password) {
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }
} 