package com.solusibejo.screen_time.service

import android.content.Intent
import android.net.VpnService
import android.os.ParcelFileDescriptor
import io.flutter.Log
import java.io.FileInputStream
import java.io.FileOutputStream
import java.io.IOException
import kotlin.concurrent.thread

class ScreenTimeVpnService : VpnService() {
    companion object {
        var isRunning = false
    }

    private var vpnInterface: ParcelFileDescriptor? = null
    private var blockedApps: List<String> = listOf()

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        isRunning = true

        blockedApps = intent?.getStringArrayListExtra("blockedApps") ?: listOf()

        val builder = Builder()
        builder.setSession("FocusGuardVPN")
            .addAddress("10.0.0.2", 32)
            .addDnsServer("8.8.8.8")
            .addRoute("0.0.0.0", 0)

        // Set per-app VPN exclusion based on the blockedApps list
        for (packageName in blockedApps) {
            try {
                builder.addDisallowedApplication(packageName)
            } catch (e: Exception) {
                Log.e("SimpleVpnService", "Failed to disallow app: $packageName", e)
            }
        }

        vpnInterface = builder.establish()

        // Optional traffic monitoring (not used here, but shows traffic handling setup)
        thread {
            try {
                val inputStream = FileInputStream(vpnInterface?.fileDescriptor)
                val outputStream = FileOutputStream(vpnInterface?.fileDescriptor)
                val buffer = ByteArray(32767)
                while (isRunning && vpnInterface != null) {
                    val length = inputStream.read(buffer)
                    if (length > 0) {
                        // Discard or route packets as needed
                        Log.d("SimpleVpnService", "Captured VPN packet of size: $length")
                    }
                }
            } catch (e: Exception) {
                Log.e("SimpleVpnService", "VPN error: ${e.message}", e)
            }
        }

        return START_STICKY
    }

    override fun onDestroy() {
        super.onDestroy()
        isRunning = false
        try {
            vpnInterface?.close()
        } catch (e: IOException) {
            Log.e("SimpleVpnService", "Failed to close VPN interface: ${e.message}")
        }
    }
}