package com.tadanobutubutu.flowscout

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {
    private val CHANNEL = "com.tadanobutubutu.flowscout/native"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        androidx.core.view.WindowCompat.setDecorFitsSystemWindows(window, false)
        window.statusBarColor = android.graphics.Color.TRANSPARENT
        window.navigationBarColor = android.graphics.Color.TRANSPARENT

        
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "getNativeDeviceInfo" -> {
                    val deviceName = android.os.Build.MODEL
                    val osVersion = android.os.Build.VERSION.RELEASE
                    result.success(mapOf("deviceName" to deviceName, "osVersion" to osVersion))
                }
                "performHeavyNativeTask" -> {
                    // 重いネイティブ処理、暗号化処理、OS固有のバックグラウンドタスクなどをここに記述
                    val data = call.argument<String>("data")
                    val processed = performHeavyNativeJob(data)
                    result.success(processed)
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
    }

    private fun performHeavyNativeJob(data: String?): String {
        // 重いネイティブ・ロジックのプレースホルダー
        return "Processed native data: ${data?.reversed()}"
    }
}
