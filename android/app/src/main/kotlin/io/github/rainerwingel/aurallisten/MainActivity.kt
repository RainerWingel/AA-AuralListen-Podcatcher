package io.github.rainerwingel.aurallisten

import android.content.ActivityNotFoundException
import android.content.Intent
import android.net.Uri
import android.os.PowerManager
import android.provider.Settings
import com.ryanheise.audioservice.AudioServiceActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

// audio_service shares its FlutterEngine with this activity (background playback).
class MainActivity : AudioServiceActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        // Battery optimisation status + app settings (the user sets
        // "Nicht eingeschränkt" there himself), see docs/playback.md.
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "aurallisten/battery")
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "isExempt" -> result.success(isExempt())
                    "openAppSettings" -> result.success(
                        start(
                            Intent(
                                Settings.ACTION_APPLICATION_DETAILS_SETTINGS,
                                Uri.parse("package:$packageName"),
                            ),
                        ),
                    )
                    else -> result.notImplemented()
                }
            }
    }

    private fun isExempt(): Boolean =
        (getSystemService(POWER_SERVICE) as PowerManager).isIgnoringBatteryOptimizations(packageName)

    private fun start(intent: Intent): Boolean =
        try {
            startActivity(intent)
            true
        } catch (e: ActivityNotFoundException) {
            false
        }
}
