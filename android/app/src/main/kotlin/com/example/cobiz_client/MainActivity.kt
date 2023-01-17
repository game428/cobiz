package io.cobiz.client

import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {
    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        // 该行必要
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "back/desktop").setMethodCallHandler { call, res ->
            if (call.method == "backToDesktop") {
                // 获取传入的参数
                // val msg = call.argument<String>("msg")
                res.success(true)
                moveTaskToBack(false)
            } else {
                // 如果有未识别的方法名，通知执行失败
                res.error("error_code", "error_message", "未识别,执行失败")
            }
        }
    }
}
