package main.kotlin.com.example.hiking4nerds

import android.content.Intent
import android.os.Bundle

import io.flutter.plugin.common.MethodChannel


class MainActivity: FlutterActivity() {
  private val CHANNEL = "app.hikingfornerds.shared.data"
  override fun onCreate(savedInstanceState: Bundle?) {
    super.onCreate(savedInstanceState)
    GeneratedPluginRegistrant.registerWith(this)
    println("heyho")

    val data: android.net.Uri? = intent?.data

    MethodChannel(flutterView, CHANNEL).setMethodCallHandler{ call, result ->
      if (call.method.contentEquals("getSharedData")){
        result.success(data)
      }
    }
  }
}
