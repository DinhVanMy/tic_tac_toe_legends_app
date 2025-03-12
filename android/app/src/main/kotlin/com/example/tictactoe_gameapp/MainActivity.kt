package com.example.tictactoe_gameapp

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugins.GeneratedPluginRegistrant

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        GeneratedPluginRegistrant.registerWith(flutterEngine)
        val pluginRegistry = flutterEngine.plugins
        if (!pluginRegistry.has(ThumbnailPlugin::class.java)) {
            pluginRegistry.add(ThumbnailPlugin())
        }
    }
}