package com.qinspecting.mobile

import android.content.Context
import android.content.Intent
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result

class UploadServicePlugin : FlutterPlugin, MethodCallHandler {
    private lateinit var channel: MethodChannel
    private lateinit var context: Context

    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "upload_service")
        channel.setMethodCallHandler(this)
        context = flutterPluginBinding.applicationContext
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        when (call.method) {
            "startForegroundService" -> {
                startForegroundService()
                result.success("Foreground service started")
            }
            "stopForegroundService" -> {
                stopForegroundService()
                result.success("Foreground service stopped")
            }
            else -> {
                result.notImplemented()
            }
        }
    }

    private fun startForegroundService() {
        val intent = Intent(context, UploadForegroundService::class.java).apply {
            action = UploadForegroundService.ACTION_START_UPLOAD
        }
        context.startForegroundService(intent)
    }

    private fun stopForegroundService() {
        val intent = Intent(context, UploadForegroundService::class.java).apply {
            action = UploadForegroundService.ACTION_STOP_UPLOAD
        }
        context.startService(intent)
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }
}

