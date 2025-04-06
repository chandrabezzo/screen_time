package com.solusibejo.screen_time.util

import android.content.pm.PackageManager
import android.graphics.Bitmap
import android.graphics.Canvas
import android.graphics.drawable.BitmapDrawable
import android.graphics.drawable.Drawable
import android.util.Base64
import java.io.ByteArrayOutputStream

object IconUtil {
    /**
     * Converts an application's icon to a Base64 encoded string.
     *
     * @param packageManager The package manager to retrieve app icons
     * @param packageName The package name of the app
     * @return Base64 encoded string representation of the app icon, or null if conversion fails
     */
    fun asBase64(
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


    /**
     * Converts a Drawable to a Bitmap.
     *
     * @param drawable The drawable to convert
     * @return Bitmap representation of the drawable
     */
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