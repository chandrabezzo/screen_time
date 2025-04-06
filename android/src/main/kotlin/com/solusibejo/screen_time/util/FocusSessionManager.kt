package com.solusibejo.screen_time.util

import android.content.Context
import android.content.Intent
import android.os.Handler
import android.os.Looper
import com.solusibejo.screen_time.service.AppMonitoringService
import com.solusibejo.screen_time.service.OverlayService
import com.solusibejo.screen_time.service.VpnService

object FocusSessionManager {
    private var sessionHandler: Handler? = null
    private  var sessionRunnable: Runnable? = null

    fun startSession(context: Context, apps: List<String>, durationInMillisecond: Long){
        // Start Accessibility Service (used to monitor app usage)
        if(!AppMonitoringService.isRunning){
            val accessibilityIntent = Intent(context, AppMonitoringService::class.java)
            context.startService(accessibilityIntent)
        }

        // Start VPN Service (used to block network)
//        if(!VpnService.isRunning(context)){
//            val vpnIntent = Intent(context, VpnService::class.java)
//            vpnIntent.putStringArrayListExtra("apps", ArrayList(apps))
//            context.startService(vpnIntent)
//        }

        // Start overlay service (used to block UI)
//        if(!OverlayService.isRunning(context)){
//            val overlayIntent = Intent(context, OverlayService::class.java)
//            context.startService(overlayIntent)
//        }

        sessionHandler = Handler(Looper.getMainLooper())
        sessionRunnable = Runnable { stopSession(context) }
        sessionHandler?.postDelayed(sessionRunnable!!, durationInMillisecond)
    }

    fun stopSession(context: Context){
        if(AppMonitoringService.isRunning){
            context.stopService(Intent(context, AppMonitoringService::class.java))
        }

//        if(VpnService.isRunning(context)){
//            context.stopService(Intent(context, VpnService::class.java))
//        }
//
//        if(OverlayService.isRunning(context)){
//            context.stopService(Intent(context, OverlayService::class.java))
//        }

        if(sessionRunnable != null){
            sessionHandler?.removeCallbacks(sessionRunnable!!)
        }
        sessionHandler = null
        sessionRunnable = null
    }
}