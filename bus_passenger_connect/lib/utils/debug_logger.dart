// Debug logging utility for Bus Passenger Connect
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

class DebugLogger {
  static const String _fileName = 'bus_app_debug.log';
  static final List<String> _logBuffer = [];
  static const int maxLogEntries = 1000;

  static void log(String component, String message, {String level = 'INFO'}) {
    final timestamp = DateTime.now().toIso8601String();
    final logEntry = '[$timestamp] [$level] [$component] $message';

    // Print to console in debug mode
    if (kDebugMode) {
      String emoji = '🟢';
      switch (level) {
        case 'ERROR':
          emoji = '🔴';
          break;
        case 'WARN':
          emoji = '🟡';
          break;
        case 'DEBUG':
          emoji = '🔵';
          break;
      }
      print('$emoji $logEntry');
    }

    // Add to buffer
    _logBuffer.add(logEntry);

    // Keep buffer size manageable
    if (_logBuffer.length > maxLogEntries) {
      _logBuffer.removeAt(0);
    }

    // Write to file (async, don't await to avoid blocking)
    _writeToFile(logEntry);
  }

  static void error(
    String component,
    String message, [
    dynamic error,
    StackTrace? stackTrace,
  ]) {
    String fullMessage = message;
    if (error != null) {
      fullMessage += ' - Error: $error';
    }
    if (stackTrace != null) {
      fullMessage += '\nStackTrace: $stackTrace';
    }
    log(component, fullMessage, level: 'ERROR');
  }

  static void warn(String component, String message) {
    log(component, message, level: 'WARN');
  }

  static void debug(String component, String message) {
    log(component, message, level: 'DEBUG');
  }

  static void info(String component, String message) {
    log(component, message, level: 'INFO');
  }

  static Future<void> _writeToFile(String logEntry) async {
    try {
      // Don't attempt to write to file on web platform
      if (kIsWeb) {
        return;
      }

      if (Platform.isAndroid || Platform.isIOS) {
        final directory = await getApplicationDocumentsDirectory();
        final file = File('${directory.path}/$_fileName');
        await file.writeAsString('$logEntry\n', mode: FileMode.append);
      }
    } catch (e) {
      // Silently fail to avoid recursive logging
      if (kDebugMode) {
        print('Failed to write log to file: $e');
      }
    }
  }

  static Future<String> getLogsAsString() async {
    return _logBuffer.join('\n');
  }

  static Future<File?> getLogFile() async {
    try {
      // Don't attempt to access file system on web platform
      if (kIsWeb) {
        return null;
      }

      if (Platform.isAndroid || Platform.isIOS) {
        final directory = await getApplicationDocumentsDirectory();
        final file = File('${directory.path}/$_fileName');
        if (await file.exists()) {
          return file;
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Failed to get log file: $e');
      }
    }
    return null;
  }

  static Future<void> clearLogs() async {
    _logBuffer.clear();
    try {
      if (Platform.isAndroid || Platform.isIOS) {
        final directory = await getApplicationDocumentsDirectory();
        final file = File('${directory.path}/$_fileName');
        if (await file.exists()) {
          await file.delete();
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Failed to clear log file: $e');
      }
    }
  }

  static void logSystemInfo() {
    try {
      if (kIsWeb) {
        info('SYSTEM', 'Platform: Web');
        info('SYSTEM', 'Running in browser');
      } else {
        info('SYSTEM', 'Platform: ${Platform.operatingSystem}');
        info('SYSTEM', 'Platform version: ${Platform.operatingSystemVersion}');
        info('SYSTEM', 'Dart version: ${Platform.version}');
      }
    } catch (e) {
      info('SYSTEM', 'Could not determine platform info: $e');
    }
    info('SYSTEM', 'Debug mode: $kDebugMode');
    info('SYSTEM', 'Release mode: $kReleaseMode');
    info('SYSTEM', 'Profile mode: $kProfileMode');
  }

  static void logMapInitialization() {
    info('MAP_INIT', 'Starting map initialization');
    info('MAP_INIT', 'Google Maps Flutter version check');
    info('MAP_INIT', 'Checking for API key');
    info('MAP_INIT', 'Checking permissions');
  }

  static void logLocationStatus(
    bool hasPermission,
    bool serviceEnabled,
    dynamic location,
  ) {
    info('LOCATION', 'Permission granted: $hasPermission');
    info('LOCATION', 'Service enabled: $serviceEnabled');
    if (location != null) {
      info('LOCATION', 'Current location: ${location.toString()}');
    } else {
      warn('LOCATION', 'No location available');
    }
  }

  static void logNetworkStatus(
    String url,
    bool isConnected, [
    String? response,
  ]) {
    info('NETWORK', 'Testing connection to: $url');
    info('NETWORK', 'Connected: $isConnected');
    if (response != null) {
      info(
        'NETWORK',
        'Response: ${response.length > 200 ? "${response.substring(0, 200)}..." : response}',
      );
    }
  }
}
