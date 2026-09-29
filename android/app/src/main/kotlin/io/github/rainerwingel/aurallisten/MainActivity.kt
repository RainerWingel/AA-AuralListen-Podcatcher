package io.github.rainerwingel.aurallisten

import android.content.ActivityNotFoundException
import android.content.Intent
import android.net.Uri
import android.os.Build
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
        // App info page: installed version (from pubspec.yaml via the build)
        // and opening links in the browser, see docs/ui-ux.md.
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "aurallisten/app")
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "version" -> {
                        val info = packageManager.getPackageInfo(packageName, 0)
                        result.success(
                            mapOf(
                                "name" to info.versionName,
                                "build" to if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {
                                    info.longVersionCode
                                } else {
                                    @Suppress("DEPRECATION")
                                    info.versionCode.toLong()
                                },
                            ),
                        )
                    }
                    "openUrl" -> result.success(
                        start(Intent(Intent.ACTION_VIEW, Uri.parse(call.arguments as String))),
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
