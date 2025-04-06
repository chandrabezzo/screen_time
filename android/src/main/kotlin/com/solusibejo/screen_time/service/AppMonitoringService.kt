package com.solusibejo.screen_time.service

import android.accessibilityservice.AccessibilityService
import android.accessibilityservice.AccessibilityServiceInfo
import android.app.ActivityManager
import android.content.Context
import android.content.pm.PackageManager
import android.graphics.Bitmap
import android.graphics.Canvas
import android.graphics.drawable.BitmapDrawable
import android.graphics.drawable.Drawable
import android.os.Handler
import android.os.Looper
import android.util.Base64
import android.view.accessibility.AccessibilityEvent
import com.solusibejo.screen_time.const.UsageInterval
import io.flutter.Log
import java.io.ByteArrayOutputStream

/**
 * AccessibilityService for monitoring current foreground app
 * This service provides real-time information about which app is currently in use
 */
class AppMonitoringService : AccessibilityService() {
    private val TAG = "AppMonitoringService"
    private val handler = Handler(Looper.getMainLooper())
    private var lastDetectedPackage: String? = null
    private var currentInterval = UsageInterval.DAILY
    private var lookbackTimeMs = 5 * 1000L // Default: 5 seconds lookback
    
    private val checkRunnable = object : Runnable {
        override fun run() {
            checkCurrentApp()
            handler.postDelayed(this, 1000) // Check every second
        }
    }
    
    // Callback interface for app monitoring
    interface AppMonitorCallback {
        fun onAppChanged(appData: Map<String, Any>)
    }
    
    // Listener interface for streaming app changes
    interface AppChangeListener {
        fun onAppChanged(appData: Map<String, Any?>)
    }

    companion object {
        private var instance: AppMonitoringService? = null
        private var callback: AppMonitorCallback? = null
        private var appChangeListener: AppChangeListener? = null
        var listenerCount = 0

        fun getInstance(context: Context? = null): AppMonitoringService? {
            return instance
        }
        
        fun setCallback(callback: AppMonitorCallback) {
            this.callback = callback
        }
        
        fun setAppChangeListener(listener: AppChangeListener?) {
            if (listener != null) {
                listenerCount++
            } else {
                listenerCount = maxOf(0, listenerCount - 1)
            }
            this.appChangeListener = listener
        }
        
        /**
         * Configure the app monitoring service with specified parameters
         * @param interval The interval to use for usage stats queries
         * @param lookbackTimeMs Time in milliseconds to look back for app usage data
         */
        fun configure(interval: UsageInterval, lookbackTimeMs: Long) {
            getInstance()?.apply {
                this.currentInterval = interval
                this.lookbackTimeMs = lookbackTimeMs
            }
        }
        
        /**
         * Set the interval for usage stats queries
         * @param interval The interval to use (DAILY, WEEKLY, MONTHLY, YEARLY, BEST)
         */
        fun setInterval(interval: UsageInterval) {
            getInstance()?.currentInterval = interval
        }
        
        /**
         * Set how far back in time to look for app usage data
         * @param timeMs Time in milliseconds
         */
        fun setLookbackTime(timeMs: Long) {
            getInstance()?.lookbackTimeMs = timeMs
        }

        val isRunning: Boolean
            get() = instance?.isMonitoring ?: false
    }

    private var isMonitoring = false
    
    override fun onServiceConnected() {
        super.onServiceConnected()
        instance = this
        isMonitoring = true

        val info = AccessibilityServiceInfo()
        info.eventTypes = AccessibilityEvent.TYPE_WINDOW_STATE_CHANGED
        info.feedbackType = AccessibilityServiceInfo.FEEDBACK_GENERIC
        info.flags = AccessibilityServiceInfo.FLAG_REPORT_VIEW_IDS
        serviceInfo = info

        Log.d(TAG, "Accessibility service connected")
        if (listenerCount > 0) {
            startMonitoring()
        }
    }

    override fun onAccessibilityEvent(event: AccessibilityEvent) {
        if (event.eventType == AccessibilityEvent.TYPE_WINDOW_STATE_CHANGED) {
            checkCurrentApp()
        }
    }

    override fun onInterrupt() {
        Log.d(TAG, "Service interrupted")
    }

    override fun onDestroy() {
        super.onDestroy()
        handler.removeCallbacks(checkRunnable)
        instance = null
        isMonitoring = false
        Log.d(TAG, "Service destroyed")
    }

    fun startMonitoring() {
        if (!isMonitoring) {
            handler.post(checkRunnable)
            isMonitoring = true
            Log.d(TAG, "Monitoring started")
        }
    }

    fun stopMonitoring() {
        if (isMonitoring) {
            handler.removeCallbacks(checkRunnable)
            isMonitoring = false
            Log.d(TAG, "Monitoring stopped")
        }
    }


    private fun checkCurrentApp() {
        val appData = getCurrentForegroundAppData()
        
        if (appData == null) {
            Log.d(TAG, "Could not determine foreground app")
            return
        }
        
        val packageName = appData["packageName"] as? String ?: return
        
        // Only notify if the package has changed
        if (packageName != lastDetectedPackage) {
            Log.d(TAG, "App changed: $packageName")
            lastDetectedPackage = packageName
            
            // Notify through callback with detailed app data
            callback?.onAppChanged(appData)
            
            // Notify through stream listener for real-time updates
            appChangeListener?.onAppChanged(appData)
        }
    }
    
    private fun getCurrentForegroundAppData(): Map<String, Any>? {
        try {
            val usageStatsManager = getSystemService(Context.USAGE_STATS_SERVICE) as android.app.usage.UsageStatsManager
            val packageManager = applicationContext.packageManager
            val time = System.currentTimeMillis()
            
            // Get usage stats using the configured interval and lookback time
            val stats = usageStatsManager.queryUsageStats(
                currentInterval.type,
                time - lookbackTimeMs,
                time
            )
            
            // Find the most recent app
            if (stats != null) {
                var latestUsageStats: android.app.usage.UsageStats? = null
                var latestUsedTime = 0L
                
                for (usageStats in stats) {
                    if (usageStats.lastTimeUsed > latestUsedTime) {
                        latestUsedTime = usageStats.lastTimeUsed
                        latestUsageStats = usageStats
                    }
                }
                
                if (latestUsageStats != null) {
                    try {
                        val packageName = latestUsageStats.packageName
                        val appInfo = packageManager.getApplicationInfo(packageName, 0)
                        val appIcon = appIconAsBase64(packageManager, packageName)
                        
                        val data = mutableMapOf<String, Any>(
                            // The app name
                            "appName" to packageManager.getApplicationLabel(appInfo).toString(),
                            // The package name of the app
                            "packageName" to packageName,
                            // The last recorded timestamp when the app was used
                            "lastTimeUsed" to latestUsageStats.lastTimeUsed,
                            // The first recorded timestamp when the app was used
                            "firstTime" to latestUsageStats.firstTimeStamp,
                            // The last recorded timestamp when the app was used
                            "lastTime" to latestUsageStats.lastTimeStamp,
                            // How long ago (in milliseconds) the app was last used
                            "timeAgo" to (time - latestUsageStats.lastTimeUsed)
                        )
                        
                        if(android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.Q){
                            // The total time (in milliseconds) the app was visible on screen
                            data["usageTime"] = latestUsageStats.totalTimeVisible
                        } else {
                            // The total time (in milliseconds) the app was in the foreground
                            data["usageTime"] = latestUsageStats.totalTimeInForeground
                        }
                        
                        if(appIcon != null){
                            data["appIcon"] = appIcon
                        }
                        
                        return data
                    } catch (e: PackageManager.NameNotFoundException) {
                        // App might be a system app or uninstalled
                        return mapOf(
                            "packageName" to latestUsageStats.packageName,
                            "lastTimeUsed" to latestUsageStats.lastTimeUsed
                        )
                    }
                }
            }
            
            // Fallback to ActivityManager if UsageStatsManager doesn't work
            val activityManager = getSystemService(Context.ACTIVITY_SERVICE) as ActivityManager
            val processName = activityManager.runningAppProcesses
                .filter { it.importance == ActivityManager.RunningAppProcessInfo.IMPORTANCE_FOREGROUND }
                .firstOrNull()?.processName
                
            if (processName != null) {
                try {
                    val appInfo = packageManager.getApplicationInfo(processName, 0)
                    return mapOf(
                        "appName" to packageManager.getApplicationLabel(appInfo).toString(),
                        "packageName" to processName,
                        "lastTimeUsed" to time
                    )
                } catch (e: PackageManager.NameNotFoundException) {
                    return mapOf(
                        "packageName" to processName,
                        "lastTimeUsed" to time
                    )
                }
            }
            
            return null
        } catch (e: Exception) {
            Log.e(TAG, "Error getting foreground app: ${e.message}")
            return null
        }
    }

    fun getAppName(packageName: String): String {
        val packageManager = applicationContext.packageManager
        return try {
            val applicationInfo = packageManager.getApplicationInfo(packageName, 0)
            packageManager.getApplicationLabel(applicationInfo).toString()
        } catch (e: PackageManager.NameNotFoundException) {
            packageName
        }
    }
    
    private fun appIconAsBase64(
        packageManager: PackageManager,
        packageName: String,
    ): String? {
        return try {
            val drawable: Drawable = packageManager.getApplicationIcon(packageName)
            val bitmap = drawableToBitmap(drawable)
            val outputStream = ByteArrayOutputStream()
            bitmap.compress(Bitmap.CompressFormat.PNG, 100, outputStream)
            val byteArray = outputStream.toByteArray()
            Base64.encodeToString(byteArray, Base64.DEFAULT)  // Convert to Base64
        } catch (e: Exception) {
            e.printStackTrace()
            null
        }
    }

    private fun drawableToBitmap(drawable: Drawable): Bitmap {
        if (drawable is BitmapDrawable) {
            return drawable.bitmap
        }
        val bitmap = Bitmap.createBitmap(
            drawable.intrinsicWidth, drawable.intrinsicHeight,
            Bitmap.Config.ARGB_8888
        )
        val canvas = Canvas(bitmap)
        drawable.setBounds(0, 0, canvas.width, canvas.height)
        drawable.draw(canvas)
        return bitmap
    }
}
