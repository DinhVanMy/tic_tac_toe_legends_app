package com.example.tictactoe_gameapp

import android.graphics.Bitmap
import android.media.MediaMetadataRetriever
import androidx.annotation.NonNull
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.io.ByteArrayOutputStream
import java.io.File
import java.util.HashMap
import kotlin.math.min

// Enum định nghĩa các định dạng ảnh thumbnail
enum class ImageFormat(val index: Int) {
    JPEG(0),
    PNG(1),
    WEBP(2)
}

class ThumbnailPlugin : FlutterPlugin, MethodChannel.MethodCallHandler {
    private lateinit var channel: MethodChannel

    override fun onAttachedToEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(binding.binaryMessenger, "com.example.tictactoe_gameapp/video_thumbnail")
        channel.setMethodCallHandler(this)
    }

    override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: MethodChannel.Result) {
        when (call.method) {
            "file" -> {
                val args = call.arguments as HashMap<*, *>
                val videoPath = args["video"] as String
                val thumbnailPath = args["path"] as? String
                val format = args["format"] as Int
                val maxHeight = args["maxh"] as Int
                val maxWidth = args["maxw"] as Int
                val timeMs = args["timeMs"] as Int
                val quality = args["quality"] as Int
                val headers = args["headers"] as? HashMap<String, String>

                try {
                    val filePath = generateThumbnailFile(
                        videoPath, thumbnailPath, format, maxHeight, maxWidth, timeMs, quality, headers
                    )
                    result.success(filePath)
                } catch (e: Exception) {
                    result.error("ThumbnailError", e.message, null)
                }
            }
            "data" -> {
                val args = call.arguments as HashMap<*, *>
                val videoPath = args["video"] as String
                val format = args["format"] as Int
                val maxHeight = args["maxh"] as Int
                val maxWidth = args["maxw"] as Int
                val timeMs = args["timeMs"] as Int
                val quality = args["quality"] as Int
                val headers = args["headers"] as? HashMap<String, String>

                try {
                    val data = generateThumbnailData(
                        videoPath, format, maxHeight, maxWidth, timeMs, quality, headers
                    )
                    result.success(data)
                } catch (e: Exception) {
                    result.error("ThumbnailError", e.message, null)
                }
            }
            else -> result.notImplemented()
        }
    }

    private fun generateThumbnailFile(
        videoPath: String, thumbnailPath: String?, format: Int, maxHeight: Int, maxWidth: Int,
        timeMs: Int, quality: Int, headers: HashMap<String, String>?
    ): String {
        val retriever = MediaMetadataRetriever()
        try {
            if (videoPath.startsWith("http")) {
                retriever.setDataSource(videoPath, headers ?: emptyMap())
            } else {
                retriever.setDataSource(videoPath)
            }

            val bitmap = retriever.getFrameAtTime(
                (timeMs * 1000).toLong(), MediaMetadataRetriever.OPTION_CLOSEST
            ) ?: throw Exception("Failed to extract frame")

            val scaledBitmap = scaleBitmap(bitmap, maxHeight, maxWidth)
            val outputPath = thumbnailPath ?: (File(videoPath).parent + "/thumb_${System.currentTimeMillis()}.jpg")
            val file = File(outputPath)

            val outputStream = file.outputStream()
            when (format) {
                ImageFormat.JPEG.index -> scaledBitmap.compress(Bitmap.CompressFormat.JPEG, quality, outputStream)
                ImageFormat.PNG.index -> scaledBitmap.compress(Bitmap.CompressFormat.PNG, 100, outputStream)
                ImageFormat.WEBP.index -> scaledBitmap.compress(Bitmap.CompressFormat.WEBP, quality, outputStream)
            }
            outputStream.close()
            return file.absolutePath
        } finally {
            retriever.release()
        }
    }

    private fun generateThumbnailData(
        videoPath: String, format: Int, maxHeight: Int, maxWidth: Int,
        timeMs: Int, quality: Int, headers: HashMap<String, String>?
    ): ByteArray {
        val retriever = MediaMetadataRetriever()
        try {
            if (videoPath.startsWith("http")) {
                retriever.setDataSource(videoPath, headers ?: emptyMap())
            } else {
                retriever.setDataSource(videoPath)
            }

            val bitmap = retriever.getFrameAtTime(
                (timeMs * 1000).toLong(), MediaMetadataRetriever.OPTION_CLOSEST
            ) ?: throw Exception("Failed to extract frame")

            val scaledBitmap = scaleBitmap(bitmap, maxHeight, maxWidth)
            val outputStream = ByteArrayOutputStream()
            when (format) {
                ImageFormat.JPEG.index -> scaledBitmap.compress(Bitmap.CompressFormat.JPEG, quality, outputStream)
                ImageFormat.PNG.index -> scaledBitmap.compress(Bitmap.CompressFormat.PNG, 100, outputStream)
                ImageFormat.WEBP.index -> scaledBitmap.compress(Bitmap.CompressFormat.WEBP, quality, outputStream)
            }
            return outputStream.toByteArray()
        } finally {
            retriever.release()
        }
    }

    private fun scaleBitmap(bitmap: Bitmap, maxHeight: Int, maxWidth: Int): Bitmap {
        val width = bitmap.width
        val height = bitmap.height
        if (maxHeight == 0 && maxWidth == 0) return bitmap

        val scale = if (maxHeight > 0 && maxWidth > 0) {
            minOf(maxWidth.toFloat() / width, maxHeight.toFloat() / height)
        } else if (maxHeight > 0) {
            maxHeight.toFloat() / height
        } else {
            maxWidth.toFloat() / width
        }

        val newWidth = (width * scale).toInt()
        val newHeight = (height * scale).toInt()
        return Bitmap.createScaledBitmap(bitmap, newWidth, newHeight, true)
    }

    override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }
}