package com.solusibejo.screen_time

import android.app.AppOpsManager
import android.app.usage.UsageStats
import android.app.usage.UsageStatsManager
import android.content.Context
import android.content.Intent
import android.content.pm.ApplicationInfo
import android.content.pm.PackageManager
import android.net.Uri
import android.os.Build
import android.provider.Settings
import androidx.work.OneTimeWorkRequestBuilder
import androidx.work.WorkManager
import androidx.work.workDataOf
import com.solusibejo.screen_time.const.Argument
import com.solusibejo.screen_time.const.Field
import com.solusibejo.screen_time.const.ScreenTimePermissionStatus
import com.solusibejo.screen_time.const.ScreenTimePermissionType
import com.solusibejo.screen_time.const.UsageInterval
import com.solusibejo.screen_time.service.AppMonitoringService
import com.solusibejo.screen_time.util.IconUtil
import com.solusibejo.screen_time.util.IntExtension.timeInString
import com.solusibejo.screen_time.util.UsageStatsUtil
import com.solusibejo.screen_time.worker.UsageStatsWorker
import io.flutter.Log

object ScreenTimeMethod {
    /**
     * Retrieves a list of all installed applications on the device with their details.
     *
     * @param context The application context
     * @return Map containing status, data (list of app details), and error message if applicable
     *         - status: Boolean indicating success or failure
     *         - data: ArrayList of app details including name, category, version, and icon
     *         - error: Error message if the operation failed
     */
    fun installedApps(context: Context, ignoreSystemApps: Boolean = true): Map<String, Any> {
        try {
            val packageManager = context.packageManager
            val apps = ArrayList<ApplicationInfo>()

            val installedApplications = packageManager.getInstalledApplications(PackageManager.GET_META_DATA)
            if(ignoreSystemApps){
                val filtered = installedApplications.filter { app -> (app.flags and ApplicationInfo.FLAG_SYSTEM) == 0 }
                apps.addAll(filtered)
            }
            else {
                apps.addAll(installedApplications)
            }

            val appMap = ArrayList<MutableMap<String, Any?>>()

            val categoryMap = mapOf(
                ApplicationInfo.CATEGORY_GAME to "Game",
                ApplicationInfo.CATEGORY_AUDIO to "Audio",
                ApplicationInfo.CATEGORY_VIDEO to "Video",
                ApplicationInfo.CATEGORY_IMAGE to "Image",
                ApplicationInfo.CATEGORY_SOCIAL to "Social",
                ApplicationInfo.CATEGORY_NEWS to "News",
                ApplicationInfo.CATEGORY_MAPS to "Maps",
                ApplicationInfo.CATEGORY_PRODUCTIVITY to "Productivity",
                ApplicationInfo.CATEGORY_UNDEFINED to "Undefined"
            )

            for (app in apps){
                val appCategory = categoryMap[app.category] ?: "Undefined"
                val packageInfo = packageManager.getPackageInfo(app.packageName, 0)
                val appIcon = IconUtil.asBase64(
                    packageManager,
                    app.packageName
                )

                val data = mutableMapOf(
                    Field.appName to app.loadLabel(packageManager),
                    Field.packageName to app.packageName,
                    Field.enabled to app.enabled,
                    Field.category to appCategory,
                    Field.versionName to packageInfo.versionName,
                    Field.versionCode to packageInfo.versionCode,
                )

                if(appIcon != null){
                    data[Field.appIcon] = appIcon
                }

                appMap.add(data)
            }

            return mutableMapOf(
                Field.status to true,
                Field.data to appMap,
            )
        } catch (exception: Exception){
            exception.localizedMessage?.let { Log.e("installedApps", it) }

            return mutableMapOf(
                Field.status to false,
                Field.data to ArrayList<MutableMap<String, Any?>>(),
            )
        }
    }

    /**
     * Requests permission to access usage statistics by directing the user to system settings.
     * Opens the usage access settings screen if permission is not already granted.
     *
     * @param context The application context
     * @param interval The interval type for the query (DAILY, WEEKLY, MONTHLY, YEARLY, BEST)
     * @return Map containing status and error message if applicable
     *         - status: Boolean indicating success or failure of the request
     *         - error: Error message if the request failed
     */
    fun requestPermission(
        context: Context,
        interval: UsageInterval = UsageInterval.DAILY,
        type: ScreenTimePermissionType = ScreenTimePermissionType.APP_USAGE,
    ): Boolean {
        return when(type){
            ScreenTimePermissionType.APP_USAGE -> {
                if(!UsageStatsUtil.checkIfStatsAreAvailable(context, interval)){
                    try {
                        val intent = Intent(Settings.ACTION_USAGE_ACCESS_SETTINGS)
                        intent.flags = Intent.FLAG_ACTIVITY_NEW_TASK
                        context.startActivity(intent)

                        true
                    } catch (exception: Exception){
                        exception.localizedMessage?.let { Log.e("requestPermission appUsage", it) }
                        false
                    }
                }
                else {
                    false
                }
            }
            ScreenTimePermissionType.ACCESSIBILITY_SETTINGS -> {
                try {
                    val intent = Intent(Settings.ACTION_ACCESSIBILITY_SETTINGS)
                    intent.flags = Intent.FLAG_ACTIVITY_NEW_TASK
                    context.startActivity(intent)
                    true
                } catch (exception: Exception) {
                    exception.localizedMessage?.let { Log.e("requestPermission accessibilitySettings", it) }
                    false
                }
            }
            ScreenTimePermissionType.MANAGE_OVERLAY_PERMISSION -> {
                try {
                    if (!Settings.canDrawOverlays(context)) {
                        val intent = Intent(
                            Settings.ACTION_MANAGE_OVERLAY_PERMISSION,
                            Uri.parse("package:" + context.packageName)
                        )
                        intent.flags = Intent.FLAG_ACTIVITY_NEW_TASK
                        context.startActivity(intent)
                    }

                    true
                } catch (exception: Exception){
                    exception.localizedMessage?.let { Log.e("requestPermission manageOverlayPermission", it) }
                    false
                }
            }
        }
    }

    fun permissionStatus(
        context: Context,
        type: ScreenTimePermissionType = ScreenTimePermissionType.APP_USAGE
    ): ScreenTimePermissionStatus {
        when(type){
            ScreenTimePermissionType.APP_USAGE -> {
                val appOps = context.getSystemService(Context.APP_OPS_SERVICE) as AppOpsManager
                val mode = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                    appOps.unsafeCheckOpNoThrow(
                        AppOpsManager.OPSTR_GET_USAGE_STATS,
                        android.os.Process.myUid(),
                        context.packageName
                    )
                } else {
                    appOps.checkOpNoThrow(
                        AppOpsManager.OPSTR_GET_USAGE_STATS,
                        android.os.Process.myUid(),
                        context.packageName
                    )
                }

                return when(mode){
                    AppOpsManager.MODE_ALLOWED -> {
                        ScreenTimePermissionStatus.APPROVED
                    }

                    AppOpsManager.MODE_IGNORED -> {
                        ScreenTimePermissionStatus.DENIED
                    }

                    else -> {
                        ScreenTimePermissionStatus.NOT_DETERMINED
                    }
                }
            }
            ScreenTimePermissionType.ACCESSIBILITY_SETTINGS -> {
                val result = AppMonitoringService.isRunning
                return if(result){
                    ScreenTimePermissionStatus.APPROVED
                } else {
                    ScreenTimePermissionStatus.DENIED
                }
            }
            ScreenTimePermissionType.MANAGE_OVERLAY_PERMISSION -> {
                val result = Settings.canDrawOverlays(context)
                return if(result){
                    ScreenTimePermissionStatus.APPROVED
                } else {
                    ScreenTimePermissionStatus.DENIED
                }
            }
        }
    }

    /**
     * Retrieves app usage data for the specified time period.
     * Provides detailed information about how long each app was used.
     *
     * @param context The application context
     * @param startTime The start time for the query in milliseconds, defaults to 1 day ago if null
     * @param endTime The end time for the query in milliseconds, defaults to current time if null
     * @param interval The interval type for the query (DAILY, WEEKLY, MONTHLY, YEARLY, BEST)
     * @return Map containing status, data (list of app usage details), and error message if applicable
     *         - status: Boolean indicating success or failure
     *         - data: ArrayList of app usage details including usage time, first and last usage
     *         - error: Error message if the operation failed
     */
    fun appUsageData(
        context: Context,
        startTime: Long?,
        endTime: Long?,
        interval: UsageInterval = UsageInterval.DAILY,
        packagesName: List<String>?
    ): Map<String, Any> {
        try {
            val usageStatsManager = context.getSystemService(Context.USAGE_STATS_SERVICE) as UsageStatsManager
            val packageManager = context.packageManager

            val calendar = java.util.Calendar.getInstance()
            val endTimeDefault = calendar.timeInMillis
            val end = endTime ?: endTimeDefault

            calendar.add(java.util.Calendar.DAY_OF_YEAR, -1)
            val startTimeDefault = calendar.timeInMillis
            val start = startTime ?: startTimeDefault

            val stats = ArrayList<UsageStats>()
            val queryResult = usageStatsManager.queryUsageStats(
                interval.type, start, end
            )
            if(packagesName != null){
                val result = queryResult.filter { it.packageName in packagesName }
                stats.addAll(result)
            }
            else{
                stats.addAll(queryResult)
            }

            val usageMap = ArrayList<Map<String, Any>>()

            for (usageStat in stats) {
                val packageName = usageStat.packageName
                val appInfo = packageManager.getApplicationInfo(packageName, 0)
                val appIcon = IconUtil.asBase64(packageManager, usageStat.packageName)

                val data = mutableMapOf(
                    // The package name of the app.
                    Field.appName to packageManager.getApplicationLabel(appInfo),
                    // The package name of the app.
                    Field.packageName to usageStat.packageName,
                    // The last recorded timestamp when the app was used.
                    Field.lastTimeUsed to usageStat.lastTimeUsed,
                    // The first recorded timestamp when the app was used.
                    Field.firstTime to usageStat.firstTimeStamp,
                    // The last recorded timestamp when the app was used.
                    Field.lastTime to usageStat.lastTimeStamp,
                )

                if(Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q){
                    // The total time (in milliseconds) the app was visible on screen.
                    // When the app is partially visible (e.g., in split-screen mode or PiP mode).
                    // totalTimeInForeground + partially visible
                    data[Field.usageTime] = usageStat.totalTimeVisible
                }
                else {
                    // The total time (in milliseconds) the app was in the foreground.
                    data[Field.usageTime] = usageStat.totalTimeInForeground
                }

                if(appIcon != null){
                    data[Field.appIcon] = appIcon
                }

                usageMap.add(data)
            }

            return mutableMapOf(
                Field.status to true,
                Field.data to usageMap,
            )
        } catch (exception: Exception){
            return mutableMapOf(
                Field.status to false,
                Field.error to exception.localizedMessage,
            )
        }
    }

    /**
     * Starts monitoring app usage within the specified time range and retrieves current foreground app.
     * Uses WorkManager to schedule the monitoring task and provides real-time information about
     * the currently active application.
     *
     * @param context The application context
     * @param startHour The hour to start monitoring (0-23)
     * @param startMinute The minute to start monitoring (0-59)
     * @param endHour The hour to end monitoring (0-23)
     * @param endMinute The minute to end monitoring (0-59)
     * @param interval The interval type for usage stats queries (DAILY, WEEKLY, MONTHLY, YEARLY, BEST)
     * @param lookbackTimeMs How far back in time to look for app usage data (in milliseconds)
     * @return Map containing status, monitoring data, and error message if applicable
     *         - status: Boolean indicating success or failure
     *         - data: Map containing schedule details and current foreground app information
     *         - error: Error message if the operation failed
     */
    fun monitoringAppUsage(
        context: Context,
        startHour: Int = 0,
        startMinute: Int = 0,
        endHour: Int = 23,
        endMinute: Int = 59,
        interval: UsageInterval = UsageInterval.DAILY,
        lookbackTimeMs: Long = 10 * 1000, // Default: 10 seconds lookback
        packagesName: List<String>?,
    ): Map<String, Any> {
        try {
            // Use WorkManager for collecting usage statistics within the specified time range
            val workRequest = OneTimeWorkRequestBuilder<UsageStatsWorker>()
                .setInputData(
                    workDataOf(
                        Argument.startHour to startHour,
                        Argument.startMinute to startMinute,
                        Argument.endHour to endHour,
                        Argument.endMinute to endMinute
                    )
                )
                .build()

            WorkManager.getInstance(context).enqueue(workRequest)
            
            // Get current foreground app using UsageStatsManager with detailed information
            val currentApp = currentForegroundApp(context, interval, lookbackTimeMs, packagesName)
            
            val resultData = mutableMapOf<String, Any>(
                Field.startTime to "${timeInString(startHour)}:${timeInString(startMinute)}",
                Field.endTime to "${timeInString(endHour)}:${timeInString(endMinute)}",
                Field.frequency to interval.name.lowercase()
            )
            
            // Add foreground app data if available
            if (currentApp != null) {
                resultData[Field.currentForegroundApp] = currentApp
            }

            return mutableMapOf(
                Field.status to true,
                Field.data to resultData
            )
        } catch (exception: Exception){
            return mutableMapOf(
                Field.status to false,
                Field.error to exception.localizedMessage,
            )
        }
    }
    
    /**
     * Configures the app monitoring service with specified parameters.
     * Sets the interval and lookback time for usage stats queries.
     *
     * @param interval The interval to use for usage stats queries (DAILY, WEEKLY, MONTHLY, YEARLY, BEST)
     * @param lookbackTimeMs How far back in time to look for app usage data (in milliseconds)
     * @return Boolean indicating if the service was configured successfully
     */
    fun configureAppMonitoringService(
        interval: UsageInterval = UsageInterval.DAILY,
        lookbackTimeMs: Long = 10 * 1000 // Default: 10 seconds lookback
    ): Boolean {
        try {
            // Configure the service
            AppMonitoringService.setInterval(interval)
            AppMonitoringService.setLookbackTime(lookbackTimeMs)
            return true
        } catch (e: Exception) {
            return false
        }
    }
    
    /**
     * Gets the current foreground app using UsageStatsManager with detailed information.
     * Requires PACKAGE_USAGE_STATS permission.
     *
     * @param context The application context
     * @param interval The interval to use for usage stats queries (DAILY, WEEKLY, MONTHLY, YEARLY, BEST)
     * @param lookbackTimeMs How far back in time to look for app usage data (in milliseconds)
     * @return Map containing detailed information about the current foreground app, or null if not available
     */
    private fun currentForegroundApp(
        context: Context,
        interval: UsageInterval = UsageInterval.DAILY,
        lookbackTimeMs: Long = 10 * 1000, // Default: 10 seconds lookback
        packagesName: List<String>?,
    ): Map<String, Any>? {
        try {
            // Check if we have the permission
            if (!UsageStatsUtil.checkIfStatsAreAvailable(context)) {
                return null
            }
            
            val time = System.currentTimeMillis()
            val startTime = time - lookbackTimeMs
            
            // Reuse appUsageData to get usage stats for the specified lookback time and interval
            val result = appUsageData(
                context,
                startTime,
                time,
                interval,
                packagesName,
            )
            
            // Check if we got valid data
            if (result[Field.status] == true) {
                @Suppress("UNCHECKED_CAST")
                val usageData = result[Field.data] as? ArrayList<Map<String, Any>> ?: return null
                
                if (usageData.isEmpty()) {
                    return null
                }
                
                // Find the most recently used app from the list
                var mostRecentApp: Map<String, Any>? = null
                var mostRecentTime = 0L
                
                for (app in usageData) {
                    val lastTimeUsed = app[Field.lastTimeUsed] as? Long ?: 0L
                    if (lastTimeUsed > mostRecentTime) {
                        mostRecentTime = lastTimeUsed
                        mostRecentApp = app
                    }
                }
                
                if (mostRecentApp != null) {
                    // Add time ago information
                    val mutableApp = mostRecentApp.toMutableMap()
                    val lastTimeUsed = mostRecentApp[Field.lastTimeUsed] as? Long ?: 0L
                    mutableApp[Field.timeAgo] = time - lastTimeUsed
                    return mutableApp
                }
            }
            
            return null
        } catch (e: Exception) {
            return null
        }
    }

    fun startFocusSession(apps: List<String>, durationInMillisecond: Long): Boolean {
        return true
    }

    fun stopFocusSession(): Boolean {
        return true
    }
}