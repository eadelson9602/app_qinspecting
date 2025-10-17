package com.example.app_qinspecting

import android.app.*
import android.content.Context
import android.content.Intent
import android.os.Build
import android.os.IBinder
import androidx.core.app.NotificationCompat

class UploadForegroundService : Service() {
    
    companion object {
        const val CHANNEL_ID = "upload_service_channel"
        const val NOTIFICATION_ID = 1
        const val ACTION_START_UPLOAD = "start_upload"
        const val ACTION_STOP_UPLOAD = "stop_upload"
    }

    override fun onCreate() {
        super.onCreate()
        createNotificationChannel()
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        when (intent?.action) {
            ACTION_START_UPLOAD -> {
                startForegroundService()
            }
            ACTION_STOP_UPLOAD -> {
                stopForegroundService()
            }
        }
        return START_STICKY
    }

    override fun onBind(intent: Intent?): IBinder? {
        return null
    }

    private fun createNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                CHANNEL_ID,
                "Upload Service Channel",
                NotificationManager.IMPORTANCE_LOW
            ).apply {
                description = "Channel for upload service notifications"
                setShowBadge(false)
            }
            
            val notificationManager = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
            notificationManager.createNotificationChannel(channel)
        }
    }

    private fun startForegroundService() {
        val notification = NotificationCompat.Builder(this, CHANNEL_ID)
            .setContentTitle("Subiendo Inspección")
            .setContentText("Procesando datos en segundo plano...")
            .setSmallIcon(android.R.drawable.ic_dialog_info)
            .setForegroundServiceBehavior(NotificationCompat.FOREGROUND_SERVICE_IMMEDIATE)
            .setPriority(NotificationCompat.PRIORITY_LOW)
            .setCategory(NotificationCompat.CATEGORY_SERVICE)
            .build()

        startForeground(NOTIFICATION_ID, notification)
    }

    private fun stopForegroundService() {
        stopForeground(true)
        stopSelf()
    }
}
