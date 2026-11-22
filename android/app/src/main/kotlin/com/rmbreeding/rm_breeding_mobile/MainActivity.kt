package com.rmbreeding.rm_breeding_mobile

import android.app.NotificationChannel
import android.app.NotificationManager
import android.os.Build
import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity

class MainActivity : FlutterActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                "rm_breeding_alerts",
                "Alertes RM Breeding",
                NotificationManager.IMPORTANCE_HIGH,
            )
            channel.description = "Alertes importantes et critiques de l'exploitation"
            getSystemService(NotificationManager::class.java)
                .createNotificationChannel(channel)
        }
    }
}
