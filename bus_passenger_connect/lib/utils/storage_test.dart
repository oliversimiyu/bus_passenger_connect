import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class StorageTest {
  static Future<void> testStorage() async {
    if (kDebugMode) {
      print('=== STORAGE TEST START ===');

      try {
        final prefs = await SharedPreferences.getInstance();

        // Test simple string storage
        const testKey = 'test_key';
        const testValue = 'test_value';

        print('1. Testing simple string storage...');
        await prefs.setString(testKey, testValue);
        final retrievedValue = prefs.getString(testKey);
        print('   Stored: $testValue');
        print('   Retrieved: $retrievedValue');
        print('   Match: ${testValue == retrievedValue}');

        // Test JSON storage (like users database)
        const usersTestKey = 'users_test';
        final testUsers = {
          'test@example.com': {
            'id': 'user_123',
            'name': 'Test User',
            'email': 'test@example.com',
            'password': 'testpass',
          },
        };

        print('2. Testing JSON storage...');
        final jsonString = jsonEncode(testUsers);
        print('   JSON to store: $jsonString');

        await prefs.setString(usersTestKey, jsonString);
        final retrievedJson = prefs.getString(usersTestKey);
        print('   Retrieved JSON: $retrievedJson');

        if (retrievedJson != null) {
          final decoded = jsonDecode(retrievedJson);
          print('   Decoded successfully: ${decoded.runtimeType}');
          print(
            '   Contains test user: ${decoded.containsKey('test@example.com')}',
          );
        }

        // List all keys
        print('3. All stored keys:');
        final allKeys = prefs.getKeys();
        for (final key in allKeys) {
          print('   - $key');
        }

        // Clean up
        await prefs.remove(testKey);
        await prefs.remove(usersTestKey);

        print('=== STORAGE TEST END ===');
      } catch (e) {
        print('STORAGE TEST ERROR: $e');
      }
    }
  }
}
