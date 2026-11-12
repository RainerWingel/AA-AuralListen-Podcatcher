package com.ryanheise.just_audio;

import android.view.Surface;
import androidx.annotation.NonNull;
import androidx.media3.common.C;
import androidx.media3.common.Format;
import androidx.media3.common.MimeTypes;
import androidx.media3.common.Player;
import androidx.media3.common.TrackSelectionParameters;
import androidx.media3.common.Tracks;
import androidx.media3.exoplayer.ExoPlayer;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.view.TextureRegistry;
import java.util.HashMap;
import java.util.LinkedHashMap;
import java.util.Map;

/**
 * AuralListen patch (PATCH.md): shows the picture of a video episode on a
 * Flutter texture – with the same ExoPlayer that plays the sound, so
 * background playback, notification and Android Auto stay unchanged.
 *
 * Channel "com.ryanheise.just_audio.video":
 * - attach() → texture id; the players render into a SurfaceProducer.
 * - detach() → the video track is disabled (sound only, no decoding in the
 *   background), the producer is released.
 * - Dart receives "videoFormat" {width, height, pixelRatio} or null whenever
 *   the tracks of the current item change, and "firstFrame" once a picture
 *   is on the texture after attach().
 *
 * There is at most one texture; it applies to every player (the app has
 * exactly one).
 */
final class VideoOutput implements MethodChannel.MethodCallHandler, TextureRegistry.SurfaceProducer.Callback {
    private static VideoOutput instance;

    private final TextureRegistry textureRegistry;
    private final MethodChannel channel;
    private final Map<ExoPlayer, Player.Listener> players = new LinkedHashMap<>();
    private TextureRegistry.SurfaceProducer producer;
    private Map<String, Object> lastFormat;

    private VideoOutput(TextureRegistry textureRegistry, BinaryMessenger messenger) {
        this.textureRegistry = textureRegistry;
        channel = new MethodChannel(messenger, "com.ryanheise.just_audio.video");
        channel.setMethodCallHandler(this);
    }

    static void install(TextureRegistry textureRegistry, BinaryMessenger messenger) {
        uninstall();
        instance = new VideoOutput(textureRegistry, messenger);
    }

    static void uninstall() {
        if (instance == null) return;
        instance.detach();
        for (Map.Entry<ExoPlayer, Player.Listener> entry : instance.players.entrySet()) {
            entry.getKey().removeListener(entry.getValue());
        }
        instance.players.clear();
        instance.channel.setMethodCallHandler(null);
        instance = null;
    }

    /** Called by AudioPlayer right after it built its ExoPlayer. */
    static void onPlayerCreated(ExoPlayer player) {
        final VideoOutput output = instance;
        if (output == null) return;
        Player.Listener listener = new Player.Listener() {
            @Override
            public void onTracksChanged(@NonNull Tracks tracks) {
                output.reportFormat(videoFormatOf(tracks));
            }

            @Override
            public void onRenderedFirstFrame() {
                output.channel.invokeMethod("firstFrame", null);
            }
        };
        player.addListener(listener);
        output.players.put(player, listener);
        output.apply(player, output.producer == null ? null : output.producer.getSurface());
    }

    /** Called by AudioPlayer right before it releases its ExoPlayer. */
    static void onPlayerReleased(ExoPlayer player) {
        if (instance == null) return;
        Player.Listener listener = instance.players.remove(player);
        if (listener != null) player.removeListener(listener);
        if (instance.players.isEmpty()) instance.reportFormat(null);
    }

    @Override
    public void onMethodCall(@NonNull MethodCall call, @NonNull Result result) {
        switch (call.method) {
        case "attach":
            result.success(attach());
            break;
        case "detach":
            detach();
            result.success(null);
            break;
        case "videoFormat":
            result.success(lastFormat);
            break;
        default:
            result.notImplemented();
            break;
        }
    }

    private long attach() {
        if (producer == null) {
            producer = textureRegistry.createSurfaceProducer();
            producer.setCallback(this);
            applyAll(producer.getSurface());
        }
        return producer.id();
    }

    private void detach() {
        if (producer == null) return;
        // Players first: they must stop writing before the surface goes away.
        applyAll(null);
        producer.setCallback(null);
        producer.release();
        producer = null;
    }

    private void applyAll(Surface surface) {
        for (ExoPlayer player : players.keySet()) {
            apply(player, surface);
        }
    }

    /**
     * With a surface the video track plays; without one it is disabled –
     * otherwise ExoPlayer keeps decoding into a placeholder surface. Turning
     * it back on makes ExoPlayer seek to the current position (from the
     * previous key frame), so the picture starts right away.
     */
    private void apply(ExoPlayer player, Surface surface) {
        if (surface == null) player.clearVideoSurface();
        boolean disabled = surface == null;
        TrackSelectionParameters params = player.getTrackSelectionParameters();
        if (params.disabledTrackTypes.contains(C.TRACK_TYPE_VIDEO) != disabled) {
            player.setTrackSelectionParameters(
                params.buildUpon().setTrackTypeDisabled(C.TRACK_TYPE_VIDEO, disabled).build());
        }
        if (surface != null) player.setVideoSurface(surface);
    }

    // The engine may drop the surface while the app is in the background
    // (Impeller's ImageReader backend) and offer a new one later.
    @Override
    public void onSurfaceAvailable() {
        if (producer != null) applyAll(producer.getSurface());
    }

    @Override
    public void onSurfaceCleanup() {
        applyAll(null);
    }

    private void reportFormat(Map<String, Object> format) {
        if (format == null ? lastFormat == null : format.equals(lastFormat)) return;
        lastFormat = format;
        channel.invokeMethod("videoFormat", format);
    }

    /** Size of the first playable video track, or null for sound only. */
    private static Map<String, Object> videoFormatOf(Tracks tracks) {
        for (Tracks.Group group : tracks.getGroups()) {
            if (group.getType() != C.TRACK_TYPE_VIDEO) continue;
            for (int i = 0; i < group.length; i++) {
                if (!group.isTrackSupported(i)) continue;
                Format format = group.getTrackFormat(i);
                // Cover art inside some files shows up as a JPEG/PNG track.
                if (!MimeTypes.isVideo(format.sampleMimeType)) continue;
                if (format.width <= 0 || format.height <= 0) continue;
                Map<String, Object> result = new HashMap<>();
                result.put("width", format.width);
                result.put("height", format.height);
                result.put("pixelRatio", (double) format.pixelWidthHeightRatio);
                return result;
            }
        }
        return null;
    }
}
