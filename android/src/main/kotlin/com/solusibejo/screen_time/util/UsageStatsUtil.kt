package com.solusibejo.screen_time.util

import android.app.usage.UsageStatsManager
import android.content.Context
import com.solusibejo.screen_time.const.UsageInterval

object UsageStatsUtil {
    /**
     * Checks if usage statistics are available for the app.
     * This verifies if the app has been granted the PACKAGE_USAGE_STATS permission.
     *
     * @param context The application context
     * @param interval The interval type for the query (DAILY, WEEKLY, MONTHLY, YEARLY, BEST)
     * @return Boolean indicating if usage stats are available
     */
    fun checkIfStatsAreAvailable(
        context: Context,
        interval: UsageInterval = UsageInterval.DAILY
    ): Boolean {
        val usageStatsManager = context.getSystemService(Context.USAGE_STATS_SERVICE) as UsageStatsManager
        val now = System.currentTimeMillis()
        val stats = usageStatsManager.queryUsageStats(interval.type, 0, now)
        return stats.size > 0
    }
}