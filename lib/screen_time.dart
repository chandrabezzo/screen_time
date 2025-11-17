import 'screen_time_platform_interface.dart';
import 'src/model/screen_time_permission_status.dart';
import 'src/model/screen_time_permission_type.dart';
import 'src/model/app_usage.dart';
import 'src/model/installed_app.dart';
import 'src/model/monitoring_app_usage.dart';
import 'src/model/usage_interval.dart';
export 'src/model/screen_time_permission_status.dart';
export 'src/model/installed_app.dart';
export 'src/model/app_category.dart';
export 'src/model/app_usage.dart';
export 'src/model/monitoring_app_usage.dart';
export 'src/model/request_permission_model.dart';
export 'src/model/usage_interval.dart';
export 'src/model/screen_time_permission_type.dart';
export 'src/util/duration_ext.dart';

class ScreenTime {
  ScreenTime._();

  static final ScreenTime _instance = ScreenTime._();

  factory ScreenTime() {
    return _instance;
  }

  Future<List<InstalledApp>> installedApps({
    bool ignoreSystemApps = true,
  }) {
    return ScreenTimePlatform.instance.installedApps(
      ignoreSystemApps: ignoreSystemApps,
    );
  }

  Future<Map<String, dynamic>> showFamilyActivityPicker() {
    return ScreenTimePlatform.instance.showFamilyActivityPicker();
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

  /// Block apps for a specified duration
  ///
  /// Parameters:
  /// - `packagesName`: List of package names to block
  /// - `duration`: How long to block the apps
  /// - `layoutName`: Optional custom layout name to use for the block overlay
  ///   This allows for customizing the UI of the block screen
  /// - `notificationTitle`: Title for the notification (default: "App Blocker Active")
  /// - `notificationText`: Text template for the notification (default: "Blocking {count} apps for {minutes} more minutes")
  ///   You can use placeholders: {count} for number of apps, {duration} or {minutes} for time remaining
  Future<bool> blockApps({
    List<String> packagesName = const <String>[],
    required Duration duration,
    required String layoutName,
    String? notificationTitle,
    String? notificationText,
  }) async {
    return await ScreenTimePlatform.instance.blockApps(
      packagesName: packagesName,
      duration: duration,
      layoutName: layoutName,
      notificationTitle: notificationTitle,
      notificationText: notificationText,
    );
  }

  Future<bool> unblockApps({
    List<String> packagesName = const <String>[],
  }) async {
    return await ScreenTimePlatform.instance.unblockApps(
      packagesName: packagesName,
    );
  }

  /// Temporarily pause blocking apps for a specified duration
  /// After the pause duration expires, blocking will automatically resume
  ///
  /// Parameters:
  /// - `pauseDuration`: How long to pause the blocking for
  /// - `notificationTitle`: Title for the notification when blocking resumes
  /// - `notificationText`: Text for the notification when blocking resumes
  /// - `showNotification`: Whether to show a notification when blocking resumes
  Future<bool> pauseBlockApps({
    required Duration pauseDuration,
    String? notificationTitle,
    String? notificationText,
    bool showNotification = true,
  }) async {
    return await ScreenTimePlatform.instance.pauseBlockApps(
      pauseDuration: pauseDuration,
      notificationTitle: notificationTitle,
      notificationText: notificationText,
      showNotification: showNotification,
    );
  }

  /// Check if app blocking is currently paused
  ///
  /// Returns a map with the following keys:
  /// - `isPaused`: Boolean indicating if blocking is currently paused
  /// - `remainingPauseTime`: Duration in milliseconds until blocking resumes (if paused)
  /// - `pausedPackages`: List of package names that will be blocked when pause ends
  /// - `remainingBlockTime`: Duration in milliseconds of blocking that will resume after pause
  Future<bool> get isOnPausedBlockingApps async {
    return await ScreenTimePlatform.instance.isOnPausedBlockingApps;
  }

  Future<bool?> scheduleBlock({
    required String scheduleId,
    required List<String> packagesName,
    required DateTime startTime,
    required Duration duration,
    bool recurring = false,
    List<int> daysOfWeek = const [],
  }) {
    return ScreenTimePlatform.instance.scheduleBlock(
      scheduleId: scheduleId,
      packagesName: packagesName,
      startTime: startTime,
      duration: duration,
      recurring: recurring,
      daysOfWeek: daysOfWeek,
    );
  }

  /// Cancel a scheduled block
  Future<bool?> cancelScheduledBlock(String scheduleId) {
    return ScreenTimePlatform.instance.cancelScheduledBlock(scheduleId);
  }

  /// Get all active block schedules
  Future<Map<String, dynamic>?> getActiveSchedules() {
    return ScreenTimePlatform.instance.getActiveSchedules();
  }

  /// Check if apps are currently being blocked
  Future<bool> get isOnBlockingApps =>
      ScreenTimePlatform.instance.isOnBlockingApps;

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
}
