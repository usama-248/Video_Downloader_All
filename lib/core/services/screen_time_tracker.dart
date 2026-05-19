// lib/core/services/screen_time_tracker.dart
import 'package:firebase_analytics/firebase_analytics.dart';
import 'dart:async';
import 'dart:developer' as developer;

class ScreenTimeTracker {
  static final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;
  static final Map<String, DateTime> _screenStartTimes = {};
  static final Map<String, Timer> _screenTimers = {};
  
  // Start tracking screen time
  static void startTracking(String screenName) {
    // Stop any existing tracking for this screen
    stopTracking(screenName);
    
    // Start new tracking
    _screenStartTimes[screenName] = DateTime.now();
    developer.log('⏱️ Started tracking: $screenName', name: 'ScreenTime');
    
    // Auto-log every 30 seconds (heartbeat)
    _screenTimers[screenName] = Timer.periodic(
      const Duration(seconds: 30),
      (timer) async {
        if (_screenStartTimes.containsKey(screenName)) {
          final currentTime = DateTime.now();
          final timeSpent = currentTime.difference(_screenStartTimes[screenName]!);
          await _logHeartbeat(screenName, timeSpent.inSeconds);
        }
      },
    );
  }
  
  // Stop tracking and log final time
  static Future<void> stopTracking(String screenName) async {
    if (_screenStartTimes.containsKey(screenName)) {
      final endTime = DateTime.now();
      final timeSpent = endTime.difference(_screenStartTimes[screenName]!);
      final secondsSpent = timeSpent.inSeconds;
      
      // Cancel timer
      if (_screenTimers.containsKey(screenName)) {
        _screenTimers[screenName]!.cancel();
        _screenTimers.remove(screenName);
      }
      
      // Only log if user spent at least 1 second
      if (secondsSpent > 0) {
        await _logScreenTime(screenName, secondsSpent);
      }
      
      // Remove tracking
      _screenStartTimes.remove(screenName);
      
      developer.log('⏱️ Stopped tracking: $screenName (${secondsSpent}s)', name: 'ScreenTime');
    }
  }
  
  // Get current time spent (without logging)
  static int getCurrentTimeSpent(String screenName) {
    if (_screenStartTimes.containsKey(screenName)) {
      final currentTime = DateTime.now();
      final timeSpent = currentTime.difference(_screenStartTimes[screenName]!);
      return timeSpent.inSeconds;
    }
    return 0;
  }
  
  // Log final screen time to Firebase
  static Future<void> _logScreenTime(String screenName, int secondsSpent) async {
    try {
      await _analytics.logEvent(
        name: 'screen_duration',
        parameters: {
          'screen_name': screenName,
          'duration_seconds': secondsSpent,
          'duration_minutes': (secondsSpent / 60).round(),
          'duration_formatted': _formatDuration(secondsSpent),
          'timestamp': DateTime.now().toIso8601String(),
        },
      );
      developer.log('✓ Screen time logged: $screenName - ${secondsSpent}s', name: 'Analytics');
    } catch (e) {
      developer.log('Error logging screen time: $e', name: 'Analytics');
    }
  }
  
  // Log heartbeat every 30 seconds
  static Future<void> _logHeartbeat(String screenName, int secondsSoFar) async {
    try {
      await _analytics.logEvent(
        name: 'screen_heartbeat',
        parameters: {
          'screen_name': screenName,
          'active_seconds': secondsSoFar,
          'active_minutes': (secondsSoFar / 60).round(),
          'timestamp': DateTime.now().toIso8601String(),
        },
      );
      developer.log('❤️ Heartbeat: $screenName - ${secondsSoFar}s', name: 'ScreenTime');
    } catch (e) {
      // Silent fail for heartbeat to avoid console spam
    }
  }
  
  // Format duration as MM:SS or HH:MM:SS
  static String _formatDuration(int seconds) {
    final Duration duration = Duration(seconds: seconds);
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final secs = duration.inSeconds.remainder(60);
    
    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
    } else {
      return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
    }
  }
  
  // Dispose all trackers (call when app closes)
  static void disposeAll() {
    for (var timer in _screenTimers.values) {
      timer.cancel();
    }
    _screenTimers.clear();
    _screenStartTimes.clear();
    developer.log('All screen timers disposed', name: 'ScreenTime');
  }
}