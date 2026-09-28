package io.github.rainerwingel.aapodcastguru

import android.annotation.SuppressLint
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
        // Battery optimisation ("Nicht eingeschränkt"), see docs/playback.md.
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "aapodcastguru/battery")
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "isExempt" -> result.success(isExempt())
                    "requestExemption" -> result.success(requestExemption())
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

    /** Shows the system dialog "allow running in the background?". */
    @SuppressLint("BatteryLife") // Sideloaded podcast player: background playback is the core function.
    private fun requestExemption(): Boolean {
        if (isExempt()) return true
        return start(
            Intent(
                Settings.ACTION_REQUEST_IGNORE_BATTERY_OPTIMIZATIONS,
                Uri.parse("package:$packageName"),
            ),
        )
    }

    private fun start(intent: Intent): Boolean =
        try {
            startActivity(intent)
            true
        } catch (e: ActivityNotFoundException) {
            false
        }
}
