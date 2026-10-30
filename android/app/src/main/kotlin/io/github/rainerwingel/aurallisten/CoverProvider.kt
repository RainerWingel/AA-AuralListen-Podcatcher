package io.github.rainerwingel.aurallisten

import android.content.ContentProvider
import android.content.ContentValues
import android.database.Cursor
import android.net.Uri
import android.os.ParcelFileDescriptor
import java.io.File
import java.io.FileNotFoundException

/**
 * Hands cached covers to Android Auto, which loads pictures only from
 * content:// addresses (docs/playback.md → Android Auto).
 *
 * Read-only and only files directly in the cover cache
 * (`CoverCacheManager`, folder "coverCache" in the app's cache): nothing is
 * downloaded or copied here, so there is no second cache to clean up.
 * Address: content://io.github.rainerwingel.aurallisten.covers/<file name>.
 */
class CoverProvider : ContentProvider() {
    override fun onCreate(): Boolean = true

    override fun openFile(uri: Uri, mode: String): ParcelFileDescriptor {
        if (mode != "r") throw FileNotFoundException("read-only")
        val name = uri.lastPathSegment
        // A bare file name only: no folders, no way out of the cache.
        if (uri.pathSegments.size != 1 || name == null || !NAME.matches(name)) {
            throw FileNotFoundException(uri.toString())
        }
        val file = File(File(context!!.cacheDir, CACHE_FOLDER), name)
        if (!file.isFile) throw FileNotFoundException(uri.toString())
        return ParcelFileDescriptor.open(file, ParcelFileDescriptor.MODE_READ_ONLY)
    }

    override fun getType(uri: Uri): String = "image/*"

    override fun query(
        uri: Uri,
        projection: Array<out String>?,
        selection: String?,
        selectionArgs: Array<out String>?,
        sortOrder: String?,
    ): Cursor? = null

    override fun insert(uri: Uri, values: ContentValues?): Uri? = null

    override fun update(
        uri: Uri,
        values: ContentValues?,
        selection: String?,
        selectionArgs: Array<out String>?,
    ): Int = 0

    override fun delete(uri: Uri, selection: String?, selectionArgs: Array<out String>?): Int = 0

    private companion object {
        /** Folder of `CoverCacheManager.key` in the cache directory. */
        const val CACHE_FOLDER = "coverCache"
        val NAME = Regex("[A-Za-z0-9_-][A-Za-z0-9._-]*")
    }
}
