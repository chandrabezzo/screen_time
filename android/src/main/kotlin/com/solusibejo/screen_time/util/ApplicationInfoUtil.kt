package com.solusibejo.screen_time.util

import android.content.pm.ApplicationInfo

object ApplicationInfoUtil {
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

    fun category(applicationCategory: Int): String {
        return categoryMap[applicationCategory] ?: "Undefined"
    }
}