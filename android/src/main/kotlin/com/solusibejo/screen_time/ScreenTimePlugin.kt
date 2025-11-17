package com.solusibejo.screen_time

import android.content.Context
import android.content.SharedPreferences
import androidx.work.Configuration
import androidx.work.WorkManager
import com.solusibejo.screen_time.const.Argument
import com.solusibejo.screen_time.const.Field
import com.solusibejo.screen_time.const.MethodName
import com.solusibejo.screen_time.const.ScreenTimePermissionType
import com.solusibejo.screen_time.const.UsageInterval
import com.solusibejo.screen_time.service.AppMonitoringService
import com.solusibejo.screen_time.util.EnumExtension.toCamelCase
import com.solusibejo.screen_time.util.EnumExtension.toEnumFormat
import io.flutter.Log
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext
import java.time.Duration
import java.util.Locale

/** ScreenTimePlugin */
class ScreenTimePlugin: FlutterPlugin, MethodCallHandler, EventChannel.StreamHandler {
  /// The MethodChannel that will the communication between Flutter and native Android
  ///
  /// This local reference serves to register the plugin with the Flutter Engine and unregister it
  /// when the Flutter Engine is detached from the Activity
  private lateinit var channel : MethodChannel
  private lateinit var eventChannel: EventChannel
  private lateinit var context: Context
  private lateinit var sharedPreferences: SharedPreferences
  private var eventSink: EventChannel.EventSink? = null

  companion object {
    const val PREF_NAME = "screen_time"
    const val PACKAGE_NAME = "com.solusibejo.screen_time"
  }

  override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    channel = MethodChannel(flutterPluginBinding.binaryMessenger, "screen_time")
    channel.setMethodCallHandler(this)
    
    context = flutterPluginBinding.applicationContext

    // Initialize WorkManager
    try {
      val config = Configuration.Builder()
        .setMinimumLoggingLevel(android.util.Log.INFO)
        .build()
      WorkManager.initialize(context, config)
    } catch (e: IllegalStateException) {
      // WorkManager might already be initialized by the app
      Log.i("ScreenTimePlugin", "WorkManager already initialized")
    }

    // Set up event channel for streaming app usage data
    eventChannel = EventChannel(flutterPluginBinding.binaryMessenger, "screen_time/app_usage_stream")
    eventChannel.setStreamHandler(this)
    
    sharedPreferences = context.getSharedPreferences("screen_time", Context.MODE_PRIVATE)
  }

  override fun onMethodCall(call: MethodCall, result: Result) {
    when(call.method){
      MethodName.installedApps -> {
        val args = call.arguments as Map<String, Any?>
        val ignoreSystemApps = args[Argument.ignoreSystemApps] as Boolean? ?: true

        CoroutineScope(Dispatchers.IO).launch {
          val installedApps = ScreenTimeMethod.installedApps(context, ignoreSystemApps)
          withContext(Dispatchers.Main){
            result.success(installedApps)
          }
        }
      }
      MethodName.requestPermission -> {
        val args = call.arguments as Map<String, Any?>
        val usageInterval = args[Argument.interval] as String
        val permissionType = args[Argument.permissionType] as String

        val response = ScreenTimeMethod.requestPermission(context,
          UsageInterval.valueOf(usageInterval.uppercase(Locale.getDefault())),
          ScreenTimePermissionType.valueOf(permissionType.toEnumFormat()),
        )
        if(response){
          result.success(true)
        }
        else {
          result.success(false)
        }
      }
      MethodName.permissionStatus -> {
        val args = call.arguments as Map<String, Any?>
        val permissionType = args[Argument.permissionType] as String

        val response = ScreenTimeMethod.permissionStatus(context,
          ScreenTimePermissionType.valueOf(permissionType.toEnumFormat())
        )

        result.success(response.name.toCamelCase())
      }
      MethodName.appUsageData -> {
        val args = call.arguments as Map<String, Any?>
        val startTimeInMillisecond = args[Argument.startTimeInMillisecond] as Number?
        val endTimeInMillisecond = args[Argument.endTimeInMillisecond] as Number?
        val usageInterval = args[Argument.interval] as String?
            ?: UsageInterval.DAILY.name.lowercase()
        val packagesName = args[Argument.packagesName] as List<*>?

        val data = ScreenTimeMethod.appUsageData(
          context,
          startTimeInMillisecond?.toLong(),
          endTimeInMillisecond?.toLong(),
          UsageInterval.valueOf(usageInterval.uppercase(Locale.getDefault())),
          packagesName?.filterIsInstance<String>(),
        )
        val status = data[Field.status]
        if(status == true){
          result.success(data)
        }
        else {
          val error = data[Field.error]
          result.error("500", "Failed to fetch app usage data", error)
        }
      }
      MethodName.blockApps -> {
        val args = call.arguments as Map<String, Any?>
        val packagesName = args[Argument.packagesName] as List<*>?
        val durationInMillisecond = args[Argument.duration] as Int
        val duration = Duration.ofMillis(durationInMillisecond.toLong())
        val layoutName = args[Argument.layoutName] as String?
        val notificationTitle = args[Argument.notificationTitle] as String?
        val notificationText = args[Argument.notificationText] as String?

        val response = ScreenTimeMethod.blockApps(
          context,
          packagesName?.filterIsInstance<String>() ?: mutableListOf(),
          duration,
          sharedPreferences,
          layoutName,
          notificationTitle,
          notificationText
        )

        result.success(response)
      }
      MethodName.scheduleBlock -> {
        val args = call.arguments as Map<String, Any?>
        val scheduleId = args[Argument.scheduleId] as String
        val packagesName = args[Argument.packagesName] as List<*>?
        val startTime = args[Argument.startTime] as Int
        val durationInMillisecond = args[Argument.duration] as Int
        val recurring = args[Argument.recurring]as Boolean
        val daysOfWeek = args[Argument.daysOfWeek] as List<*>?

        val duration = Duration.ofMillis(durationInMillisecond.toLong())

        ScreenTimeMethod.scheduleBlock(
          context,
          scheduleId,
          packagesName?.filterIsInstance<String>() ?: mutableListOf(),
          startTime.toLong(),
          duration,
          recurring,
          daysOfWeek?.filterIsInstance<Int>() ?: mutableListOf(),
        ) { callback ->
          result.success(callback)
        }
      }
      MethodName.cancelScheduledBlock -> {
        val args = call.arguments as Map<String, Any?>
        val scheduleId = args[Argument.scheduleId] as String

        ScreenTimeMethod.cancelScheduledBlock(
          context,
          scheduleId,
        ) { callback ->
          result.success(callback)
        }
      }
      MethodName.getActiveSchedules -> {
        ScreenTimeMethod.getActiveSchedules(
          context,
        ) { callback ->
          result.success(callback)
        }
      }
      MethodName.isOnBlockingApps -> {
        val response = ScreenTimeMethod.isOnBlockingApps(context)
        result.success(response)
      }
      MethodName.unblockApps -> {
        val args = call.arguments as Map<String, Any?>
        val packagesName = args[Argument.packagesName] as List<*>?

        val response = ScreenTimeMethod.unblockApps(
          context,
          packagesName?.filterIsInstance<String>() ?: mutableListOf(),
          sharedPreferences
        )
        result.success(response)
      }
      MethodName.monitoringAppUsage -> {
        val args = call.arguments as Map<String, Any?>
        val startHour = args[Argument.startHour] as Int
        val startMinute = args[Argument.startMinute] as Int
        val endHour = args[Argument.endHour] as Int
        val endMinute = args[Argument.endMinute] as Int
        val usageInterval = args[Argument.interval] as String
        val lookbackTimeMs = args[Argument.lookbackTimeMs] as Int
        val packagesName = args[Argument.packagesName] as List<*>?

        val data = ScreenTimeMethod.monitoringAppUsage(
          context,
          startHour,
          startMinute,
          endHour,
          endMinute,
          UsageInterval.valueOf(usageInterval.uppercase(Locale.getDefault())),
          lookbackTimeMs.toLong(),
          packagesName?.filterIsInstance<String>(),
        )

        val status = data[Field.status]
        if(status == true){
          result.success(data)
        }
        else {
          val error = data[Field.error]
          result.error("500", "Failed to start monitoring app usage", error)
        }
      }
      MethodName.configureAppMonitoringService -> {
        val args = call.arguments as Map<String, Any?>
        val interval = args[Argument.interval] as String
        val lookbackTimeMs = args[Argument.lookbackTimeMs] as Int
        
        val data = ScreenTimeMethod.configureAppMonitoringService(
          UsageInterval.valueOf(interval.uppercase(Locale.getDefault())),
          lookbackTimeMs.toLong(),
        )
        result.success(data)
      }
      MethodName.pauseBlockApps -> {
        val args = call.arguments as Map<String, Any?>
        val pauseDurationInMillisecond = args[Argument.pauseDuration] as Int
        val pauseDuration = Duration.ofMillis(pauseDurationInMillisecond.toLong())
        val notificationTitle = args[Argument.notificationTitle] as String?
        val notificationText = args[Argument.notificationText] as String?
        val showNotification = args[Argument.showNotification] as Boolean? ?: true

        val response = ScreenTimeMethod.pauseBlockApps(
          context,
          pauseDuration,
          sharedPreferences,
          notificationTitle,
          notificationText,
          showNotification
        )

        result.success(response)
      }
      MethodName.isBlockingPaused -> {
        val response = ScreenTimeMethod.isBlockingPaused(
          context,
          sharedPreferences
        )
        result.success(response)
      }
      else -> result.notImplemented()
    }
  }

  override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
    channel.setMethodCallHandler(null)
    eventChannel.setStreamHandler(null)
  }
  
  // StreamHandler implementation for EventChannel
  override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
    eventSink = events
    
    try {
      // Extract parameters from arguments
      val args = arguments as? Map<*, *>
      val intervalName = args?.get(Argument.interval) as? String ?: UsageInterval.DAILY.name
      val lookbackTimeMs = args?.get(Argument.lookbackTimeMs) as? Int ?: 10000
      
      // Configure the service with the specified parameters
      AppMonitoringService.configure(
          UsageInterval.valueOf(intervalName.uppercase(Locale.getDefault())),
          lookbackTimeMs.toLong()
      )
      
      // Set up the app change listener
      AppMonitoringService.setAppChangeListener(object : AppMonitoringService.AppChangeListener {
        override fun onAppChanged(appData: Map<String, Any?>) {
          eventSink?.success(appData)
        }
      })
      
      // Start the service if it's not already running
      val appMonitoringService = AppMonitoringService.getInstance(context)
      if (appMonitoringService != null && !appMonitoringService.isRunning) {
        appMonitoringService.startMonitoring()
      }
    } catch (e: Exception) {
      eventSink?.error("500", "Failed to start app usage streaming", e.message)
      eventSink = null
    }
  }
  
  override fun onCancel(arguments: Any?) {
    try {
      // Clean up resources when the stream is cancelled
      eventSink = null
      AppMonitoringService.setAppChangeListener(null)
      
      // Stop the service if no other listeners are active
      if (AppMonitoringService.listenerCount == 0) {
        val appMonitoringService = AppMonitoringService.getInstance(context)
        appMonitoringService?.stopMonitoring()
      }
    } catch (e: Exception) {
      // Log the error but don't throw as we're cleaning up
      android.util.Log.e("ScreenTimePlugin", "Error cleaning up stream: ${e.message}")
    }
  }
}
