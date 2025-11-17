import 'package:flutter_test/flutter_test.dart';
import 'package:screen_time/screen_time.dart';
import 'package:screen_time/screen_time_platform_interface.dart';
import 'package:screen_time/screen_time_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockScreenTimePlatform
    with MockPlatformInterfaceMixin
    implements ScreenTimePlatform {
  @override
  Future<List<InstalledApp>> installedApps({
    bool ignoreSystemApps = true,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<List<AppUsage>> appUsageData({
    DateTime? startTime,
    DateTime? endTime,
    UsageInterval usageInterval = UsageInterval.daily,
    List<String>? packagesName,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<bool> configureAppMonitoringService(
      {UsageInterval interval = UsageInterval.daily,
      int lookbackTimeMs = 10000}) {
    throw UnimplementedError();
  }

  @override
  Future<MonitoringAppUsage> monitoringAppUsage({
    int startHour = 0,
    int startMinute = 0,
    int endHour = 23,
    int endMinute = 59,
    UsageInterval usageInterval = UsageInterval.daily,
    int lookbackTimeMs = 10000,
    List<String>? packagesName,
  }) {
    throw UnimplementedError();
  }

  @override
  Stream<Map<String, dynamic>> streamAppUsage(
      {UsageInterval usageInterval = UsageInterval.daily,
      int lookbackTimeMs = 10000}) {
    throw UnimplementedError();
  }

  @override
  Future<ScreenTimePermissionStatus> permissionStatus(
      {ScreenTimePermissionType permissionType =
          ScreenTimePermissionType.appUsage}) {
    throw UnimplementedError();
  }

  @override
  Future<bool> requestPermission(
      {UsageInterval interval = UsageInterval.daily,
      ScreenTimePermissionType permissionType =
          ScreenTimePermissionType.appUsage}) {
    throw UnimplementedError();
  }

  @override
  Future<bool> blockApps({
    List<String> packagesName = const <String>[],
    required Duration duration,
    required String layoutName,
    String? notificationTitle,
    String? notificationText,
  }) async {
    return true;
  }

  @override
  Future<bool> unblockApps({List<String> packagesName = const <String>[]}) {
    throw UnimplementedError();
  }

  @override
  Future<bool> get isOnBlockingApps => throw UnimplementedError();

  @override
  Future<bool?> cancelScheduledBlock(String scheduleId) {
    throw UnimplementedError();
  }

  @override
  Future<Map<String, dynamic>?> getActiveSchedules() {
    throw UnimplementedError();
  }

  @override
  Future<bool?> scheduleBlock(
      {required String scheduleId,
      required List<String> packagesName,
      required DateTime startTime,
      required Duration duration,
      bool recurring = false,
      List<int> daysOfWeek = const []}) {
    throw UnimplementedError();
  }

  @override
  Future<bool> pauseBlockApps({
    required Duration pauseDuration,
    String? notificationTitle,
    String? notificationText,
    bool showNotification = true,
  }) async {
    return true;
  }

  @override
  Future<bool> get isOnPausedBlockingApps async {
    return false;
  }

  @override
  Future<Map<String, dynamic>> showFamilyActivityPicker() {
    throw UnimplementedError();
  }
}

void main() {
  final ScreenTimePlatform initialPlatform = ScreenTimePlatform.instance;

  test('$MethodChannelScreenTime is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelScreenTime>());
  });

  test('getPlatformVersion', () async {
    // ScreenTime screenTimePlugin = ScreenTime();
    MockScreenTimePlatform fakePlatform = MockScreenTimePlatform();
    ScreenTimePlatform.instance = fakePlatform;

    // expect(await screenTimePlugin.getPlatformVersion(), '42');
  });
}
