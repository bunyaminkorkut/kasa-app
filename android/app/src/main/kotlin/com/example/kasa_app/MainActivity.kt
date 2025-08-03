package com.bunyamin.kasa

import android.content.Intent
import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel

class MainActivity: FlutterActivity() {
    private val CHANNEL = "com.bunyamin.kasa/universal_link"
    private var eventSink: EventChannel.EventSink? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        EventChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setStreamHandler(
            object : EventChannel.StreamHandler {
                override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                    eventSink = events
                    // İlk açılışta varsa intent data'sını gönder
                    intent?.data?.let { uri ->
                        eventSink?.success(uri.toString())
                    }
                }

                override fun onCancel(arguments: Any?) {
                    eventSink = null
                }
            }
        )
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        setIntent(intent) // Yeni intent'i set et
        
        val data = intent.data
        data?.let { uri ->
            eventSink?.success(uri.toString()) // Flutter tarafına linki gönder
        }
    }
}