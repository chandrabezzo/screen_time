import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:screen_time/src/model/screen_time_permission_status.dart';

import 'screen_time_method_channel.dart';
import 'src/model/app_usage.dart';
import 'src/model/installed_app.dart';
import 'src/model/monitoring_app_usage.dart';
import 'src/model/request_permission_model.dart';
import 'src/model/screen_time_permission_type.dart';
import 'src/model/usage_interval.dart';

abstract class ScreenTimePlatform extends PlatformInterface {
  /// Constructs a ScreenTimePlatform.
  ScreenTimePlatform() : super(token: _token);

  static final Object _token = Object();

  static ScreenTimePlatform _instance = MethodChannelScreenTime();

  /// The default instance of [ScreenTimePlatform] to use.
  ///
  /// Defaults to [MethodChannelScreenTime].
  static ScreenTimePlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [ScreenTimePlatform] when
  /// they register themselves.
  static set instance(ScreenTimePlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<List<InstalledApp>> installedApps({
    bool ignoreSystemApps = true,
  }) {
    throw UnimplementedError('installedApps() has not been implemented.');
  }

  Future<Map<String, dynamic>> showFamilyActivityPicker() {
    throw UnimplementedError(
        'showFamilyActivityPicker() has not been implemented.');
  }

  /// Returns a [RequestPermissionModel] with the following keys:
  /// - `status`: The current authorization status `true` is requested `false`: failed to request.
  /// - `error`: Error message if failed to request.
  /// appUsage: Request permission to access app usage data.
  /// accessibilitySettings: Opens the system accessibility settings screen. This allows users to enable the app monitoring service
  ///
  /// Returns `true` if the settings screen was opened successfully,
  /// `false` otherwise
  Future<bool> requestPermission({
    UsageInterval interval = UsageInterval.daily,
    ScreenTimePermissionType permissionType = ScreenTimePermissionType.appUsage,
  }) =>
      throw UnimplementedError('requestPermission() has not been implemented.');

  Future<ScreenTimePermissionStatus> permissionStatus({
    ScreenTimePermissionType permissionType = ScreenTimePermissionType.appUsage,
  }) =>
      throw UnimplementedError('permissionStatus() has not been implemented.');

  /// Fetch app usage data from the device.
  ///
  /// Returns a map with the following keys:
  /// - `status`: Whether the data was successfully fetched.
  /// - `data`: Map of app bundle IDs to usage data.
  /// - `error`: Error message if the data fetch failed.
  Future<List<AppUsage>> appUsageData({
    DateTime? startTime,
    DateTime? endTime,
    UsageInterval usageInterval = UsageInterval.daily,
    List<String>? packagesName,
  }) {
    throw UnimplementedError('appUsageData() has not been implemented.');
  }

  Future<bool> blockApps({
    List<String> packagesName = const <String>[],
    required Duration duration,
    required String layoutName,
    String? notificationTitle,
    String? notificationText,
  }) =>
      throw UnimplementedError('blockApps() has not been implemented.');

  Future<bool> get isOnBlockingApps =>
      throw UnimplementedError('isOnBlockingApps() has not been implemented.');

  Future<bool> unblockApps({
    List<String> packagesName = const <String>[],
  }) =>
      throw UnimplementedError('unblockApps() has not been implemented.');

  /// Temporarily pause blocking apps for a specified duration
  /// After the pause duration expires, blocking will automatically resume
  Future<bool> pauseBlockApps({
    required Duration pauseDuration,
    String? notificationTitle,
    String? notificationText,
    bool showNotification = true,
  }) =>
      throw UnimplementedError('pauseBlockApps() has not been implemented.');

  /// Check if app blocking is currently paused
  Future<bool> get isOnPausedBlockingApps => throw UnimplementedError(
      'isOnPausedBlockingApps has not been implemented.');

  Future<bool?> scheduleBlock({
    required String scheduleId,
    required List<String> packagesName,
    required DateTime startTime,
    required Duration duration,
    bool recurring = false,
    List<int> daysOfWeek = const [],
  }) {
    throw UnimplementedError('scheduleBlock() has not been implemented.');
  }

  Future<bool?> cancelScheduledBlock(String scheduleId) {
    throw UnimplementedError(
        'cancelScheduledBlock() has not been implemented.');
  }

  Future<Map<String, dynamic>?> getActiveSchedules() {
    throw UnimplementedError('getActiveSchedules() has not been implemented.');
  }

  /// Start monitoring app usage with the specified schedule.
  ///
  /// Parameters:
  /// - `startHour`: The hour to start monitoring (0-23).
  /// - `startMinute`: The minute to start monitoring (0-59).
  /// - `endHour`: The hour to end monitoring (0-23).
  /// - `endMinute`: The minute to end monitoring (0-59).
  ///
  /// Returns a map with the following keys:
  /// - `status`: Whether monitoring was successfully started.
  /// - `monitoringActive`: Whether monitoring is currently active.
  /// - `schedule`: Map containing schedule details (startTime, endTime, frequency).
  /// - `timestamp`: When monitoring was started.
  /// - `error`: Error message if monitoring failed to start.
  Future<MonitoringAppUsage> monitoringAppUsage({
    int startHour = 0,
    int startMinute = 0,
    int endHour = 23,
    int endMinute = 59,
    UsageInterval usageInterval = UsageInterval.daily,
    int lookbackTimeMs = 10000,
    List<String>? packagesName,
  }) {
    throw UnimplementedError('monitoringAppUsage() has not been implemented.');
  }

  /// Configures the app monitoring service with the specified interval and lookback time
  ///
  /// Parameters:
  /// - `interval`: The interval to use for usage stats queries (DAILY, WEEKLY, MONTHLY, YEARLY, BEST)
  /// - `lookbackTimeMs`: How far back in time to look for app usage data (in milliseconds)
  ///
  /// Returns `true` if the service was configured successfully, `false` otherwise
  Future<bool> configureAppMonitoringService({
    UsageInterval interval = UsageInterval.daily,
    int lookbackTimeMs = 10000,
  }) {
    throw UnimplementedError(
        'configureAppMonitoringService() has not been implemented.');
  }

  /// Stream app usage data in real-time.
  ///
  /// This method returns a Stream that emits events whenever the foreground app changes.
  /// It uses the native AppMonitoringService to provide real-time updates.
  ///
  /// Parameters:
  /// - `usageInterval`: The interval to use for usage stats queries (DAILY, WEEKLY, MONTHLY, YEARLY, BEST)
  /// - `lookbackTimeMs`: How far back in time to look for app usage data (in milliseconds)
  ///
  /// Returns a Stream of [Map<String, dynamic>] containing the foreground app data.
  Stream<Map<String, dynamic>> streamAppUsage({
    UsageInterval usageInterval = UsageInterval.daily,
    int lookbackTimeMs = 10000,
  }) {
    throw UnimplementedError('streamAppUsage() has not been implemented.');
  }
}
