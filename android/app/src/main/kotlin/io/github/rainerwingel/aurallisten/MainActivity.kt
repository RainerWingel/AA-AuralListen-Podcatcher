package io.github.rainerwingel.aurallisten

import android.app.PendingIntent
import android.app.PictureInPictureParams
import android.app.RemoteAction
import android.content.ActivityNotFoundException
import android.content.ComponentName
import android.content.Intent
import android.content.pm.PackageManager
import android.content.res.Configuration
import android.graphics.drawable.Icon
import android.net.Uri
import android.os.Build
import android.os.PowerManager
import android.provider.Settings
import android.util.Rational
import android.view.KeyEvent
import com.ryanheise.audioservice.AudioServiceActivity
import com.ryanheise.audioservice.MediaButtonReceiver
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

// audio_service shares its FlutterEngine with this activity (background playback).
class MainActivity : AudioServiceActivity() {
    // Picture-in-picture of video episodes (docs/playback.md "Video"): Dart
    // says when a playing video is on screen; leaving the app then shows it
    // in a small window.
    private var pipChannel: MethodChannel? = null
    private var pipWanted = false
    private var pipPlaying = false
    private var pipAspect = Rational(16, 9)
    private var pipLabels = mapOf<String, String>()

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        pipChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "aurallisten/pip")
            .also { channel ->
                channel.setMethodCallHandler { call, result ->
                    when (call.method) {
                        "update" -> {
                            pipWanted = call.argument<Boolean>("wanted") ?: false
                            pipPlaying = call.argument<Boolean>("playing") ?: false
                            pipAspect = pipRatio(
                                call.argument<Int>("width") ?: 16,
                                call.argument<Int>("height") ?: 9,
                            )
                            pipLabels = call.argument<Map<String, String>>("labels") ?: mapOf()
                            applyPipParams()
                            result.success(null)
                        }
                        "isSupported" -> result.success(pipSupported())
                        else -> result.notImplemented()
                    }
                }
            }
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
        // Android Auto connected? The Auto-Sleep-Timer never starts in the
        // car, see docs/playback.md.
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "aurallisten/car")
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "isConnected" -> result.success(isCarConnected())
                    else -> result.notImplemented()
                }
            }
    }

    // The provider androidx.car.app's CarConnection reads (Android Auto app
    // and Android Automotive publish it): 0 = not connected, 1 = built-in
    // car system, 2 = phone projected to the car. No provider = no car.
    private fun isCarConnected(): Boolean =
        try {
            contentResolver.query(
                Uri.parse("content://androidx.car.app.connection"),
                arrayOf("CarConnectionState"),
                null,
                null,
                null,
            )?.use { cursor ->
                val column = cursor.getColumnIndex("CarConnectionState")
                column >= 0 && cursor.moveToNext() && cursor.getInt(column) != 0
            } ?: false
        } catch (e: Exception) {
            false
        }

    override fun cleanUpFlutterEngine(flutterEngine: FlutterEngine) {
        pipChannel?.setMethodCallHandler(null)
        pipChannel = null
        super.cleanUpFlutterEngine(flutterEngine)
    }

    // Android 12+ enters by itself (setAutoEnterEnabled); older versions
    // when the user leaves with Home or the app switcher.
    override fun onUserLeaveHint() {
        super.onUserLeaveHint()
        if (pipWanted && pipSupported() && Build.VERSION.SDK_INT < Build.VERSION_CODES.S) {
            try {
                enterPictureInPictureMode(pipParams())
            } catch (e: IllegalStateException) {
                // PiP turned off for this app in the system settings.
            }
        }
    }

    override fun onPictureInPictureModeChanged(
        isInPictureInPictureMode: Boolean,
        newConfig: Configuration,
    ) {
        super.onPictureInPictureModeChanged(isInPictureInPictureMode, newConfig)
        pipChannel?.invokeMethod("mode", isInPictureInPictureMode)
    }

    private fun pipSupported(): Boolean =
        Build.VERSION.SDK_INT >= Build.VERSION_CODES.O &&
            packageManager.hasSystemFeature(PackageManager.FEATURE_PICTURE_IN_PICTURE)

    private fun applyPipParams() {
        if (!pipSupported()) return
        try {
            setPictureInPictureParams(pipParams())
        } catch (e: IllegalStateException) {
            // PiP turned off for this app in the system settings.
        }
    }

    private fun pipParams(): PictureInPictureParams {
        val builder = PictureInPictureParams.Builder()
            .setAspectRatio(pipAspect)
            .setActions(
                listOf(
                    mediaAction(KeyEvent.KEYCODE_MEDIA_REWIND, "rewind", com.ryanheise.audioservice.R.drawable.audio_service_fast_rewind),
                    if (pipPlaying) {
                        mediaAction(KeyEvent.KEYCODE_MEDIA_PAUSE, "pause", com.ryanheise.audioservice.R.drawable.audio_service_pause)
                    } else {
                        mediaAction(KeyEvent.KEYCODE_MEDIA_PLAY, "play", com.ryanheise.audioservice.R.drawable.audio_service_play_arrow)
                    },
                    mediaAction(KeyEvent.KEYCODE_MEDIA_FAST_FORWARD, "forward", com.ryanheise.audioservice.R.drawable.audio_service_fast_forward),
                ),
            )
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            builder.setAutoEnterEnabled(pipWanted)
        }
        return builder.build()
    }

    // The buttons in the small window send media keys to audio_service –
    // the same way as Bluetooth buttons (−15 s, play/pause, +30 s).
    private fun mediaAction(keyCode: Int, label: String, icon: Int): RemoteAction {
        val intent = Intent(Intent.ACTION_MEDIA_BUTTON)
            .setComponent(ComponentName(this, MediaButtonReceiver::class.java))
            .putExtra(Intent.EXTRA_KEY_EVENT, KeyEvent(KeyEvent.ACTION_DOWN, keyCode))
        val pending = PendingIntent.getBroadcast(
            this,
            keyCode,
            intent,
            PendingIntent.FLAG_IMMUTABLE or PendingIntent.FLAG_UPDATE_CURRENT,
        )
        val title = pipLabels[label] ?: label
        return RemoteAction(Icon.createWithResource(this, icon), title, title, pending)
    }

    // Android allows ratios from 1:2.39 to 2.39:1 only.
    private fun pipRatio(width: Int, height: Int): Rational {
        if (width <= 0 || height <= 0) return Rational(16, 9)
        val ratio = width.toDouble() / height
        return when {
            ratio > 2.39 -> Rational(239, 100)
            ratio < 1 / 2.39 -> Rational(100, 239)
            else -> Rational(width, height)
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
