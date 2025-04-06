import 'package:screen_time/src/model/screen_time_permission_status.dart';

import 'screen_time_platform_interface.dart';
import 'src/model/app_usage.dart';
import 'src/model/installed_app.dart';
import 'src/model/monitoring_app_usage.dart';
import 'src/model/screen_time_permission_type.dart';
import 'src/model/usage_interval.dart';

export 'src/const/method_name.dart';
export 'src/const/argument.dart';
export 'src/model/screen_time_permission_status.dart';
export 'src/model/installed_app.dart';
export 'src/model/app_category.dart';
export 'src/model/app_usage.dart';
export 'src/model/monitoring_app_usage.dart';
export 'src/model/request_permission_model.dart';
export 'src/model/usage_interval.dart';
export 'src/model/screen_time_permission_type.dart';
export 'src/util/json_converter_util.dart';

class ScreenTime {
  Future<List<InstalledApp>> installedApps({
    bool ignoreSystemApps = true,
  }) {
    return ScreenTimePlatform.instance.installedApps(
      ignoreSystemApps: ignoreSystemApps,
    );
  }

  /// Request Screen Time permission from the user.
  ///
  /// Parameters:
  /// - `interval`: The interval to use for usage stats queries (DAILY, WEEKLY, MONTHLY, YEARLY, BEST)
  ///
  /// Returns a [bool] with the following keys:
  /// - `true`: Request Permission launched
  /// - `false`: Request Permission failed to launch
  Future<bool> requestPermission({
    UsageInterval interval = UsageInterval.daily,
    ScreenTimePermissionType permissionType = ScreenTimePermissionType.appUsage,
  }) async {
    return await ScreenTimePlatform.instance
        .requestPermission(interval: interval, permissionType: permissionType);
  }

  Future<ScreenTimePermissionStatus> permissionStatus({
    ScreenTimePermissionType permissionType = ScreenTimePermissionType.appUsage,
  }) async {
    return await ScreenTimePlatform.instance
        .permissionStatus(permissionType: permissionType);
  }

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
    return ScreenTimePlatform.instance.appUsageData(
      startTime: startTime,
      endTime: endTime,
      usageInterval: usageInterval,
      packagesName: packagesName,
    );
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
    required int startHour,
    required int startMinute,
    required int endHour,
    required int endMinute,
    UsageInterval usageInterval = UsageInterval.daily,
    int lookbackTimeMs = 10000, // Default: 10 seconds
    List<String>? packagesName,
  }) {
    return ScreenTimePlatform.instance.monitoringAppUsage(
      startHour: startHour,
      startMinute: startMinute,
      endHour: endHour,
      endMinute: endMinute,
      usageInterval: usageInterval,
      lookbackTimeMs: lookbackTimeMs,
      packagesName: packagesName,
    );
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
    int lookbackTimeMs = 10000, // Default: 10 seconds
  }) {
    return ScreenTimePlatform.instance.streamAppUsage(
      usageInterval: usageInterval,
      lookbackTimeMs: lookbackTimeMs,
    );
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
    int lookbackTimeMs = 10000, // Default: 10 seconds
  }) {
    return ScreenTimePlatform.instance.configureAppMonitoringService(
      interval: interval,
      lookbackTimeMs: lookbackTimeMs,
    );
  }

  Future<bool> startFocusSession({
    List<String> packagesName = const [],
    required int durationInMillisecond,
  }) {
    return ScreenTimePlatform.instance.startFocusSession(
      packagesName: packagesName,
      durationInMillisecond: durationInMillisecond,
    );
  }

  Future<bool> stopFocusSession() {
    return ScreenTimePlatform.instance.stopFocusSession();
  }
}
