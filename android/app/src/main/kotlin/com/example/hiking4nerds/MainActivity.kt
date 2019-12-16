package de.berlin.htw.hiking4nerds

import io.flutter.app.FlutterActivity
import io.flutter.plugins.GeneratedPluginRegistrant

import android.os.Bundle

import io.flutter.plugin.common.MethodChannel


class MainActivity: FlutterActivity() {
  private val CHANNEL = "app.channel.hikingfornerds.data"

  override fun onCreate(savedInstanceState: Bundle?) {
    super.onCreate(savedInstanceState)
    GeneratedPluginRegistrant.registerWith(this)

    val data: android.net.Uri? = intent?.data

    MethodChannel(flutterView, CHANNEL).setMethodCallHandler{ call, result ->
      if (call.method!!.contentEquals("getSharedData")){
        result.success(data?.toString() ?: "")
      }
    }
  }
}
