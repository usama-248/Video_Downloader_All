package com.example.facebook_video_downloader

import android.os.Bundle
import android.webkit.WebResourceRequest
import android.webkit.WebView
import android.webkit.WebViewClient
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {

    private val CHANNEL = "video_detector"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            .setMethodCallHandler { call, result ->
                // communication if needed
            }
    }

    inner class CustomWebViewClient: WebViewClient() {
        override fun shouldInterceptRequest(
            view: WebView?,
            request: WebResourceRequest?
        ): android.webkit.WebResourceResponse? {

            val url = request?.url.toString()

            if (url.contains(".mp4") || url.contains(".m3u8")) {
                println("VIDEO DETECTED: $url")

                MethodChannel(flutterEngine!!.dartExecutor.binaryMessenger, CHANNEL)
                    .invokeMethod("onVideoDetected", url)
            }

            return super.shouldInterceptRequest(view, request)
        }
    }
}