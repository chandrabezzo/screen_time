package com.solusibejo.screen_time.worker

import android.app.usage.UsageStatsManager
import android.content.Context
import androidx.work.Worker
import androidx.work.WorkerParameters
import io.flutter.Log
import java.util.Calendar

class UsageStatsWorker(context: Context, workerParams: WorkerParameters) :
    Worker(context, workerParams) {

    override fun doWork(): Result {
        val screenTimeData = fetchAppUsageData()
        Log.d("UsageStatsWorker", "Background screen time data: $screenTimeData")
        return Result.success()
    }

    private fun fetchAppUsageData(): Map<String, Long> {
        val usageStatsManager =
            applicationContext.getSystemService(Context.USAGE_STATS_SERVICE) as UsageStatsManager
        val calendar = Calendar.getInstance()
        val endTime = calendar.timeInMillis
        calendar.set(Calendar.HOUR_OF_DAY, 0)
        calendar.set(Calendar.MINUTE, 0)
        val startTime = calendar.timeInMillis

        val stats =
            usageStatsManager.queryUsageStats(UsageStatsManager.INTERVAL_DAILY, startTime, endTime)
        val usageMap = mutableMapOf<String, Long>()

        for (usageStat in stats) {
            usageMap[usageStat.packageName] = usageStat.totalTimeInForeground
        }

        return usageMap
    }
}