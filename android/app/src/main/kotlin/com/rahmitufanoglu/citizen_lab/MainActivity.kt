package com.rahmitufanoglu.citizen_lab

import android.content.Intent
import android.os.Bundle
import androidx.core.content.FileProvider
import io.flutter.app.FlutterActivity
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugins.GeneratedPluginRegistrant
import java.io.File

class MainActivity : FlutterActivity() {

    private val channel = "rahmitufanoglu.citizenlab.share"
    private val shareChannel = "channel:$channel/share"

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        GeneratedPluginRegistrant.registerWith(this)

        MethodChannel(this.flutterView, shareChannel).setMethodCallHandler { methodCall, _ ->
            if (methodCall.method == "shareImage") {
                shareImage(methodCall.arguments as String)
            }
            if (methodCall.method == "shareTable") {
                shareTable(methodCall.arguments as String)
            }
        }
    }

    private fun shareImage(path: String) {
        val imageFile = File(this.applicationContext.cacheDir, "$path.jpg")
        val uriToImage = FileProvider.getUriForFile(this, channel, imageFile)

        val shareIntent: Intent = Intent().apply {
            action = Intent.ACTION_SEND
            putExtra(Intent.EXTRA_TEXT, path)
            putExtra(Intent.EXTRA_STREAM, uriToImage)
            type = "image/*"
        }

        this.startActivity(Intent.createChooser(shareIntent, "Share image to.."))
    }

    private fun shareTable(path: String) {
        val tableFile = File(this.applicationContext.cacheDir, path)
        val uriToTable = FileProvider.getUriForFile(this, channel, tableFile)

        val shareIntent: Intent = Intent().apply {
            action = Intent.ACTION_SEND
            putExtra(Intent.EXTRA_TEXT, "RAUL_TABLE")
            putExtra(Intent.EXTRA_STREAM, uriToTable)
            type = "table/*"
        }

        this.startActivity(Intent.createChooser(shareIntent, "Share table to.."))
    }
}
